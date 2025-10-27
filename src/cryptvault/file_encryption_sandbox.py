#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CryptVault - Professional File Encryption System
Secure file encryption using Fernet (AES-128-CBC) with PBKDF2 key derivation.
"""

import os
import sys
import json
import base64
import argparse
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, Any

try:
    from cryptography.fernet import Fernet
    from cryptography.hazmat.primitives import hashes
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
except ImportError:
    print("ERROR: cryptography package not installed")
    print("Install with: pip install cryptography>=42.0.0")
    sys.exit(1)


class CryptVault:
    """Main encryption/decryption engine for CryptVault."""

    # PBKDF2 iterations (OWASP 2023 recommendation)
    PBKDF2_ITERATIONS = 600000
    SALT_LENGTH = 16

    def __init__(self, sandbox_dir: str = "sandbox"):
        """Initialize CryptVault with sandbox directory.

        Args:
            sandbox_dir: Directory for encrypted files and key storage
        """
        self.sandbox_dir = Path(sandbox_dir)
        self.sandbox_dir.mkdir(exist_ok=True)
        self.keys_file = self.sandbox_dir / ".keys.json"
        self._keys_cache = None

    def _load_keys(self) -> Dict[str, Any]:
        """Load saved keys from .keys.json file."""
        if self._keys_cache is not None:
            return self._keys_cache

        if not self.keys_file.exists():
            self._keys_cache = {}
            return self._keys_cache

        try:
            with open(self.keys_file, 'r') as f:
                self._keys_cache = json.load(f)
            return self._keys_cache
        except (json.JSONDecodeError, IOError) as e:
            print(f"WARNING: Error loading keys file: {e}")
            self._keys_cache = {}
            return self._keys_cache

    def _save_keys(self, keys: Dict[str, Any]) -> None:
        """Save keys to .keys.json file."""
        try:
            with open(self.keys_file, 'w') as f:
                json.dump(keys, f, indent=2)
            self._keys_cache = keys
        except IOError as e:
            print(f"ERROR: Failed to save keys: {e}")
            raise

    def _derive_key_from_password(self, password: str, salt: Optional[bytes] = None) -> tuple[bytes, bytes]:
        """Derive encryption key from password using PBKDF2.

        Args:
            password: User password
            salt: Salt bytes (generated if not provided)

        Returns:
            Tuple of (key_bytes, salt_bytes)
        """
        if salt is None:
            salt = os.urandom(self.SALT_LENGTH)

        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=self.PBKDF2_ITERATIONS,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        return key, salt

    def _generate_random_key(self) -> bytes:
        """Generate a random Fernet key."""
        return Fernet.generate_key()

    def encrypt_file(self, input_path: str, output_path: Optional[str] = None,
                     password: Optional[str] = None, key_name: Optional[str] = None) -> tuple[str, str]:
        """Encrypt a file.

        Args:
            input_path: Path to file to encrypt
            output_path: Output path (default: sandbox/filename.encrypted)
            password: Password for encryption
            key_name: Name of saved key to use

        Returns:
            Tuple of (output_path, key_id)
        """
        input_path = Path(input_path)
        if not input_path.exists():
            raise FileNotFoundError(f"Input file not found: {input_path}")

        # Determine output path
        if output_path is None:
            output_path = self.sandbox_dir / f"{input_path.name}.encrypted"
        else:
            output_path = Path(output_path)
            output_path.parent.mkdir(parents=True, exist_ok=True)

        # Get or generate encryption key
        if key_name:
            # Use saved key
            keys = self._load_keys()
            if key_name not in keys:
                raise ValueError(f"Saved key '{key_name}' not found. Use save-key command first.")

            key_data = keys[key_name]
            if key_data['type'] == 'password':
                if not password:
                    raise ValueError(f"Password required for key '{key_name}'")
                salt = base64.b64decode(key_data['salt'])
                key, _ = self._derive_key_from_password(password, salt)
            else:  # type == 'key'
                key = base64.b64decode(key_data['key'])

            # Update usage stats
            keys[key_name].setdefault('files', [])
            if str(output_path.name) not in keys[key_name]['files']:
                keys[key_name]['files'].append(str(output_path.name))
            self._save_keys(keys)

            key_id = key_name

        elif password:
            # Derive key from password
            key, salt = self._derive_key_from_password(password)

            # Save key with timestamp
            key_id = f"key_{datetime.now().isoformat()}"
            keys = self._load_keys()
            keys[key_id] = {
                'type': 'password',
                'salt': base64.b64encode(salt).decode(),
                'created': datetime.now().isoformat(),
                'files': [str(output_path.name)]
            }
            self._save_keys(keys)

        else:
            # Generate random key
            key = self._generate_random_key()

            # Save key with timestamp
            key_id = f"key_{datetime.now().isoformat()}"
            keys = self._load_keys()
            keys[key_id] = {
                'type': 'key',
                'key': base64.b64encode(key).decode(),
                'created': datetime.now().isoformat(),
                'files': [str(output_path.name)]
            }
            self._save_keys(keys)

        # Encrypt file
        fernet = Fernet(key)
        with open(input_path, 'rb') as f:
            plaintext = f.read()

        encrypted = fernet.encrypt(plaintext)

        with open(output_path, 'wb') as f:
            f.write(encrypted)

        return str(output_path), key_id

    def decrypt_file(self, input_path: str, output_path: Optional[str] = None,
                     password: Optional[str] = None, key: Optional[str] = None,
                     key_name: Optional[str] = None) -> str:
        """Decrypt a file.

        Args:
            input_path: Path to encrypted file
            output_path: Output path (default: sandbox/filename.decrypted)
            password: Password for decryption
            key: Direct key (base64)
            key_name: Name of saved key

        Returns:
            Output file path
        """
        input_path = Path(input_path)
        if not input_path.exists():
            raise FileNotFoundError(f"Encrypted file not found: {input_path}")

        # Determine output path
        if output_path is None:
            # Remove .encrypted extension if present
            base_name = input_path.stem
            if base_name.endswith('.encrypted'):
                base_name = base_name[:-10]  # Remove .encrypted
            output_path = self.sandbox_dir / f"{base_name}.decrypted"
        else:
            output_path = Path(output_path)
            output_path.parent.mkdir(parents=True, exist_ok=True)

        # Get decryption key
        if key_name:
            # Use saved key by name
            keys = self._load_keys()
            if key_name not in keys:
                raise ValueError(f"Saved key '{key_name}' not found")

            key_data = keys[key_name]
            if key_data['type'] == 'password':
                if not password:
                    raise ValueError(f"Password required for key '{key_name}'")
                salt = base64.b64decode(key_data['salt'])
                decryption_key, _ = self._derive_key_from_password(password, salt)
            else:  # type == 'key'
                decryption_key = base64.b64decode(key_data['key'])

        elif key:
            # Use direct key
            try:
                decryption_key = base64.b64decode(key)
            except Exception:
                decryption_key = key.encode()

        elif password:
            # Need to find the salt from saved keys
            # Try to find matching file in saved keys
            keys = self._load_keys()
            found_key = None

            for key_id, key_data in keys.items():
                if key_data['type'] == 'password':
                    if str(input_path.name) in key_data.get('files', []):
                        salt = base64.b64decode(key_data['salt'])
                        decryption_key, _ = self._derive_key_from_password(password, salt)
                        found_key = key_id
                        break

            if not found_key:
                raise ValueError("Cannot decrypt: file not found in saved keys. Use -n to specify key name or -k for direct key.")
        else:
            raise ValueError("Must provide password, key, or key-name for decryption")

        # Decrypt file
        try:
            fernet = Fernet(decryption_key)
            with open(input_path, 'rb') as f:
                encrypted = f.read()

            decrypted = fernet.decrypt(encrypted)

            with open(output_path, 'wb') as f:
                f.write(decrypted)

            return str(output_path)

        except Exception as e:
            raise ValueError(f"Decryption failed: {e}. Check your password/key.")

    def save_key(self, name: str, password: Optional[str] = None, key: Optional[str] = None) -> None:
        """Save a key with a descriptive name.

        Args:
            name: Descriptive name for the key
            password: Password to save
            key: Direct key to save (base64)
        """
        if not password and not key:
            raise ValueError("Must provide either password or key")

        keys = self._load_keys()

        if password:
            # Save password with salt
            _, salt = self._derive_key_from_password(password)
            keys[name] = {
                'type': 'password',
                'salt': base64.b64encode(salt).decode(),
                'created': datetime.now().isoformat(),
                'files': []
            }
        else:
            # Save direct key
            try:
                # Validate key format
                base64.b64decode(key)
                keys[name] = {
                    'type': 'key',
                    'key': key,
                    'created': datetime.now().isoformat(),
                    'files': []
                }
            except Exception:
                raise ValueError("Invalid key format. Key must be base64 encoded.")

        self._save_keys(keys)

    def list_keys(self) -> Dict[str, Any]:
        """List all saved keys.

        Returns:
            Dictionary of saved keys
        """
        return self._load_keys()


def cmd_encrypt(args, vault: CryptVault):
    """Handle encrypt command."""
    try:
        output_path, key_id = vault.encrypt_file(
            args.input,
            args.output,
            args.password,
            args.key_name
        )

        print(f"[OK] File encrypted: {output_path}")

        if not args.key_name:
            keys = vault._load_keys()
            key_data = keys[key_id]

            if key_data['type'] == 'key':
                # Show random key
                random_key = key_data['key']
                print(f"[!] Randomly generated key: {random_key}")
                print(f"[!] IMPORTANT: Save this key! You'll need it to decrypt.")

            print(f"[OK] Key saved as: {key_id}")
        else:
            print(f"[OK] Using saved key: {args.key_name}")

    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)


def cmd_decrypt(args, vault: CryptVault):
    """Handle decrypt command."""
    try:
        if args.key_name:
            print(f"[OK] Using saved key: {args.key_name}")

        output_path = vault.decrypt_file(
            args.input,
            args.output,
            args.password,
            args.key,
            args.key_name
        )

        print(f"[OK] File decrypted: {output_path}")

    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)


def cmd_save_key(args, vault: CryptVault):
    """Handle save-key command."""
    try:
        vault.save_key(args.name, args.password, args.key)
        print(f"[OK] Key '{args.name}' saved successfully")

    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)


def cmd_list_keys(args, vault: CryptVault):
    """Handle list-keys command."""
    keys = vault.list_keys()

    if not keys:
        print("No saved keys found.")
        return

    print("[*] Saved keys:")
    print("-" * 60)

    for name, data in keys.items():
        print(f"  * {name}")
        print(f"    Type: {data['type']}")
        print(f"    Created: {data.get('created', 'N/A')}")
        print(f"    Used for: {len(data.get('files', []))} files")
        print()

    print("-" * 60)
    print(f"Total: {len(keys)} saved keys")


def main():
    """Main entry point for CryptVault CLI."""
    parser = argparse.ArgumentParser(
        description="CryptVault - Professional File Encryption System",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Encrypt with password
  %(prog)s encrypt document.pdf -p MyPassword123

  # Encrypt with random key
  %(prog)s encrypt confidential.docx

  # Decrypt with password
  %(prog)s decrypt sandbox/document.pdf.encrypted -p MyPassword123

  # Save a key
  %(prog)s save-key work-projects -p MyWorkPass2024

  # List saved keys
  %(prog)s list-keys

For more help: See docs/USAGE.md
"""
    )

    # Global options
    parser.add_argument('--sandbox-dir', default='sandbox',
                        help='Sandbox directory for encrypted files (default: sandbox)')

    # Subcommands
    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Encrypt command
    encrypt_parser = subparsers.add_parser('encrypt', help='Encrypt a file')
    encrypt_parser.add_argument('input', help='Input file to encrypt')
    encrypt_parser.add_argument('-o', '--output', help='Output file path')
    encrypt_parser.add_argument('-p', '--password', help='Password for encryption')
    encrypt_parser.add_argument('-k', '--key-name', help='Name of saved key to use')

    # Decrypt command
    decrypt_parser = subparsers.add_parser('decrypt', help='Decrypt a file')
    decrypt_parser.add_argument('input', help='Encrypted file to decrypt')
    decrypt_parser.add_argument('-o', '--output', help='Output file path')
    decrypt_parser.add_argument('-p', '--password', help='Password for decryption')
    decrypt_parser.add_argument('-k', '--key', help='Direct encryption key (base64)')
    decrypt_parser.add_argument('-n', '--key-name', help='Name of saved key')

    # Save-key command
    save_key_parser = subparsers.add_parser('save-key', help='Save a key for reuse')
    save_key_parser.add_argument('name', help='Descriptive name for the key')
    save_key_parser.add_argument('-p', '--password', help='Password to save')
    save_key_parser.add_argument('-k', '--key', help='Direct key to save (base64)')

    # List-keys command
    list_keys_parser = subparsers.add_parser('list-keys', help='List all saved keys')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    # Initialize vault
    vault = CryptVault(args.sandbox_dir)

    # Route to command handler
    if args.command == 'encrypt':
        cmd_encrypt(args, vault)
    elif args.command == 'decrypt':
        cmd_decrypt(args, vault)
    elif args.command == 'save-key':
        cmd_save_key(args, vault)
    elif args.command == 'list-keys':
        cmd_list_keys(args, vault)


if __name__ == '__main__':
    main()
