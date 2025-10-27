#!/usr/bin/env python3
"""
CryptVault Demo - Example usage of the CryptVault library

This demo shows how to use CryptVault as a Python library in your code.
"""

import os
import tempfile
from pathlib import Path
from file_encryption_sandbox import CryptVault


def demo_basic_encryption():
    """Demo 1: Basic password-based encryption."""
    print("\n" + "=" * 60)
    print("DEMO 1: Basic Password-Based Encryption")
    print("=" * 60)

    # Create a temporary file
    with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
        f.write("This is a secret message!")
        temp_file = f.name

    print(f" Created test file: {temp_file}")

    # Initialize CryptVault
    vault = CryptVault(sandbox_dir="demo_sandbox")
    print(" Initialized CryptVault")

    # Encrypt the file
    encrypted_path, key_id = vault.encrypt_file(
        input_path=temp_file,
        password="DemoPassword123!"
    )
    print(f" File encrypted: {encrypted_path}")
    print(f" Key ID: {key_id}")

    # Decrypt the file
    decrypted_path = vault.decrypt_file(
        input_path=encrypted_path,
        password="DemoPassword123!"
    )
    print(f" File decrypted: {decrypted_path}")

    # Verify content
    with open(decrypted_path, 'r') as f:
        content = f.read()
    print(f" Decrypted content: '{content}'")

    # Cleanup
    os.unlink(temp_file)
    print(" Cleaned up test file")


def demo_random_key():
    """Demo 2: Random key generation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Random Key Generation")
    print("=" * 60)

    # Create a temporary file
    with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
        f.write("Top secret data!")
        temp_file = f.name

    print(f" Created test file: {temp_file}")

    # Initialize CryptVault
    vault = CryptVault(sandbox_dir="demo_sandbox")

    # Encrypt with random key
    encrypted_path, key_id = vault.encrypt_file(input_path=temp_file)
    print(f" File encrypted with random key: {encrypted_path}")
    print(f" Key ID: {key_id}")

    # Get the generated key
    keys = vault.list_keys()
    random_key = keys[key_id]['key']
    print(f" Random key: {random_key}")

    # Decrypt using the key
    decrypted_path = vault.decrypt_file(
        input_path=encrypted_path,
        key=random_key
    )
    print(f" File decrypted: {decrypted_path}")

    # Verify content
    with open(decrypted_path, 'r') as f:
        content = f.read()
    print(f" Decrypted content: '{content}'")

    # Cleanup
    os.unlink(temp_file)
    print(" Cleaned up test file")


def demo_saved_keys():
    """Demo 3: Save and reuse keys."""
    print("\n" + "=" * 60)
    print("DEMO 3: Saved Keys")
    print("=" * 60)

    # Initialize CryptVault
    vault = CryptVault(sandbox_dir="demo_sandbox")

    # Save a key
    vault.save_key(name="demo-project", password="ProjectPassword2024!")
    print(" Saved key: demo-project")

    # Create and encrypt multiple files with the same key
    files_to_encrypt = []
    for i in range(3):
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix=f'_file{i+1}.txt') as f:
            f.write(f"Secret content {i+1}")
            files_to_encrypt.append(f.name)

    encrypted_files = []
    for file_path in files_to_encrypt:
        encrypted_path, _ = vault.encrypt_file(
            input_path=file_path,
            key_name="demo-project",
            password="ProjectPassword2024!"
        )
        encrypted_files.append(encrypted_path)
        print(f" Encrypted: {Path(file_path).name} -> {Path(encrypted_path).name}")

    # Decrypt all files using the saved key
    print("\nDecrypting files...")
    for encrypted_path in encrypted_files:
        decrypted_path = vault.decrypt_file(
            input_path=encrypted_path,
            key_name="demo-project",
            password="ProjectPassword2024!"
        )
        print(f" Decrypted: {Path(decrypted_path).name}")

    # Cleanup
    for f in files_to_encrypt:
        os.unlink(f)
    print(" Cleaned up test files")


def demo_key_management():
    """Demo 4: Key management operations."""
    print("\n" + "=" * 60)
    print("DEMO 4: Key Management")
    print("=" * 60)

    # Initialize CryptVault
    vault = CryptVault(sandbox_dir="demo_sandbox")

    # Save multiple keys
    vault.save_key(name="personal-docs", password="PersonalPass123!")
    vault.save_key(name="work-files", password="WorkPass456!")
    print(" Saved multiple keys")

    # List all keys
    keys = vault.list_keys()
    print(f"\n=Ë Total saved keys: {len(keys)}")
    print("-" * 60)

    for name, data in keys.items():
        print(f"  " {name}")
        print(f"    Type: {data['type']}")
        print(f"    Created: {data.get('created', 'N/A')}")
        print(f"    Files: {len(data.get('files', []))}")
        print()


def demo_custom_output():
    """Demo 5: Custom output paths."""
    print("\n" + "=" * 60)
    print("DEMO 5: Custom Output Paths")
    print("=" * 60)

    # Create a temporary file
    with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
        f.write("Data with custom path")
        temp_file = f.name

    # Create custom output directory
    custom_dir = Path("demo_sandbox/custom_output")
    custom_dir.mkdir(parents=True, exist_ok=True)

    # Initialize CryptVault
    vault = CryptVault(sandbox_dir="demo_sandbox")

    # Encrypt with custom output path
    custom_encrypted = custom_dir / "my_encrypted_file.enc"
    encrypted_path, _ = vault.encrypt_file(
        input_path=temp_file,
        output_path=str(custom_encrypted),
        password="CustomPath123!"
    )
    print(f" Encrypted to custom path: {encrypted_path}")

    # Decrypt with custom output path
    custom_decrypted = custom_dir / "my_decrypted_file.txt"
    decrypted_path = vault.decrypt_file(
        input_path=encrypted_path,
        output_path=str(custom_decrypted),
        password="CustomPath123!"
    )
    print(f" Decrypted to custom path: {decrypted_path}")

    # Cleanup
    os.unlink(temp_file)
    print(" Cleaned up test file")


def demo_binary_files():
    """Demo 6: Encrypting binary files."""
    print("\n" + "=" * 60)
    print("DEMO 6: Binary File Encryption")
    print("=" * 60)

    # Create a binary file (simulated image data)
    with tempfile.NamedTemporaryFile(mode='wb', delete=False, suffix='.bin') as f:
        # Write some random binary data
        binary_data = os.urandom(1024)  # 1KB of random data
        f.write(binary_data)
        temp_file = f.name
        original_data = binary_data

    print(f" Created binary test file: {temp_file} (1KB)")

    # Initialize CryptVault
    vault = CryptVault(sandbox_dir="demo_sandbox")

    # Encrypt the binary file
    encrypted_path, _ = vault.encrypt_file(
        input_path=temp_file,
        password="BinaryPass123!"
    )
    print(f" Binary file encrypted: {encrypted_path}")

    # Decrypt the binary file
    decrypted_path = vault.decrypt_file(
        input_path=encrypted_path,
        password="BinaryPass123!"
    )
    print(f" Binary file decrypted: {decrypted_path}")

    # Verify binary data integrity
    with open(decrypted_path, 'rb') as f:
        decrypted_data = f.read()

    if decrypted_data == original_data:
        print(" Binary data integrity verified!")
    else:
        print(" ERROR: Binary data mismatch!")

    # Cleanup
    os.unlink(temp_file)
    print(" Cleaned up test file")


def main():
    """Run all demos."""
    print("\n" + "=" * 60)
    print("CryptVault Library Demo")
    print("=" * 60)
    print("\nThis demo shows how to use CryptVault as a Python library.")
    print("All encrypted files will be stored in: demo_sandbox/")

    try:
        # Run demos
        demo_basic_encryption()
        demo_random_key()
        demo_saved_keys()
        demo_key_management()
        demo_custom_output()
        demo_binary_files()

        print("\n" + "=" * 60)
        print("All demos completed successfully!")
        print("=" * 60)
        print("\nCheck the 'demo_sandbox/' directory to see encrypted files.")
        print("\nTo clean up demo files, run:")
        print("  rm -rf demo_sandbox/")

    except Exception as e:
        print(f"\n Demo failed with error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    main()
