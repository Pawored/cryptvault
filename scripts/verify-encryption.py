#!/usr/bin/env python3
"""
=============================================================================
CryptVault - Verify Encryption Script
=============================================================================

Verifies that encrypted files can be successfully decrypted.

Usage:
    python scripts/verify-encryption.py <password> [directory]

Examples:
    python scripts/verify-encryption.py MyPassword123!
    python scripts/verify-encryption.py MyPassword123! sandbox
    python scripts/verify-encryption.py MyPassword123! ~/encrypted-backup

=============================================================================
"""

import sys
import subprocess
from pathlib import Path


def verify_file(encrypted_file, password, cryptvault_path):
    """Verify a file can be decrypted"""
    print(f"Verifying: {encrypted_file}")
    
    # Try to decrypt
    result = subprocess.run([
        "python", f"{cryptvault_path}/src/file_encryption_sandbox.py",
        "decrypt", str(encrypted_file),
        "-p", password,
        "-o", "/tmp/verify-test"
    ], capture_output=True, text=True)
    
    # Check result
    if result.returncode == 0:
        print(f"✅ {encrypted_file.name} - OK")
        # Clean up test file
        Path("/tmp/verify-test").unlink(missing_ok=True)
        return True
    else:
        print(f"❌ {encrypted_file.name} - FAILED")
        if result.stderr:
            print(f"   Error: {result.stderr.strip()}")
        return False


def main():
    print("=" * 60)
    print("CryptVault - Encryption Verification")
    print("=" * 60)
    print()
    
    # Check arguments
    if len(sys.argv) < 2:
        print("Usage: verify-encryption.py <password> [directory]")
        print()
        print("Arguments:")
        print("  password   - Password used for encryption")
        print("  directory  - Directory to search (default: sandbox)")
        print()
        print("Examples:")
        print("  python scripts/verify-encryption.py MyPassword123!")
        print("  python scripts/verify-encryption.py MyPassword123! sandbox")
        print("  python scripts/verify-encryption.py MyPassword123! ~/backup")
        sys.exit(1)
    
    password = sys.argv[1]
    directory = sys.argv[2] if len(sys.argv) > 2 else "sandbox"
    
    # Get CryptVault path
    script_dir = Path(__file__).parent
    cryptvault_path = script_dir.parent
    
    print(f"Directory: {directory}")
    print(f"Searching for encrypted files...")
    print()
    
    # Find all encrypted files
    search_path = Path(directory)
    if not search_path.exists():
        print(f"❌ Error: Directory does not exist: {directory}")
        sys.exit(1)
    
    encrypted_files = list(search_path.glob("*.encrypted"))
    
    if not encrypted_files:
        print(f"⚠️ No .encrypted files found in {directory}")
        sys.exit(0)
    
    print(f"Found {len(encrypted_files)} encrypted file(s)")
    print()
    
    # Verify each file
    total = 0
    passed = 0
    
    for file in encrypted_files:
        total += 1
        if verify_file(file, password, cryptvault_path):
            passed += 1
        print()
    
    # Summary
    print("=" * 60)
    print("Verification Summary")
    print("=" * 60)
    print(f"Total files: {total}")
    print(f"Passed: {passed}")
    print(f"Failed: {total - passed}")
    print()
    
    if passed == total:
        print("✅ All files verified successfully!")
        sys.exit(0)
    else:
        print(f"❌ {total - passed} file(s) failed verification")
        print()
        print("Possible reasons:")
        print("  - Wrong password")
        print("  - Corrupted encrypted file")
        print("  - File encrypted with different password/key")
        sys.exit(1)


if __name__ == "__main__":
    main()
