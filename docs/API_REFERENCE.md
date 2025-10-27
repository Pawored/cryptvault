# 📚 API Reference

Complete reference for using CryptVault as a Python library.

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Classes](#classes)
- [Methods](#methods)
- [Exceptions](#exceptions)
- [Examples](#examples)
- [Best Practices](#best-practices)

---

## Overview

CryptVault can be used as a Python library in your own applications. The API provides simple, high-level functions for file encryption and key management.

### Main Components

- **FileEncryption** - Encrypt and decrypt files
- **KeyManagement** - Generate, save, and load encryption keys

---

## Installation

### As a Library

```bash
# Install in your project
pip install cryptvault

# Or add to requirements.txt
echo "cryptvault" >> requirements.txt
pip install -r requirements.txt
```

### From Source

```bash
# Clone and install
git clone https://github.com/pawored/cryptvault.git
cd cryptvault
pip install -e .
```

---

## Quick Start

### Basic Encryption

```python
from cryptvault import FileEncryption

# Initialize
encryptor = FileEncryption()

# Encrypt a file
encryptor.encrypt_file(
    input_file="document.pdf",
    password="MySecurePassword123!"
)
# Creates: document.pdf.encrypted

# Decrypt a file
encryptor.decrypt_file(
    input_file="document.pdf.encrypted",
    password="MySecurePassword123!"
)
# Creates: document.pdf.decrypted
```

### With Key Management

```python
from cryptvault import FileEncryption, KeyManagement

# Generate and save a key
key_manager = KeyManagement()
key = key_manager.generate_key_from_password("MyPassword123!")
key_manager.save_key(key, "my-backup-key")

# Use saved key
encryptor = FileEncryption()
encryptor.encrypt_file(
    input_file="document.pdf",
    key_name="my-backup-key"
)
```

---

## Classes

### FileEncryption

Main class for file encryption and decryption operations.

**Methods:**
- `encrypt_file()` - Encrypt a file
- `decrypt_file()` - Decrypt a file
- `generate_random_key()` - Generate random encryption key

### KeyManagement

Class for managing encryption keys.

**Methods:**
- `generate_key_from_password()` - Derive key from password
- `save_key()` - Save key to file
- `load_key()` - Load key from file
- `list_keys()` - List all saved keys
- `delete_key()` - Delete a saved key

---

## Methods

See full method documentation in the complete API reference.

---

## Examples

### Complete Encryption Workflow

```python
from cryptvault import FileEncryption, KeyManagement

# Setup
key_manager = KeyManagement()
encryptor = FileEncryption(output_dir="encrypted_files")

# Generate and save key
password = "SuperSecurePassword123!"
key = key_manager.generate_key_from_password(password)
key_manager.save_key(key, "project-backup")

# Encrypt files
files_to_encrypt = [
    "important_document.pdf",
    "financial_data.xlsx",
    "personal_photos.zip"
]

for file in files_to_encrypt:
    try:
        output = encryptor.encrypt_file(
            input_file=file,
            key_name="project-backup"
        )
        print(f"✅ Encrypted: {file} -> {output}")
    except Exception as e:
        print(f"❌ Failed: {file} - {e}")
```

---

## Best Practices

1. **Use environment variables for passwords**
2. **Implement proper error handling**
3. **Reuse keys for batch operations**
4. **Validate inputs before encryption**
5. **Clean up temporary files**

---

## Additional Resources

- [Usage Guide](USAGE.md) - Command-line usage
- [Examples](EXAMPLES.md) - More practical examples
- [Security](SECURITY.md) - Security specifications

---

<div align="center">

**Happy coding! 🔐**

[← Back to Documentation](README.md)

</div>
