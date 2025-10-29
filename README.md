# 🔐 CryptVault

<div align="center">

**Professional file encryption system using modern cryptography**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20windows-lightgrey)](https://github.com/Pawored/cryptvault)
[![Cryptography](https://img.shields.io/badge/cryptography-42.0.0+-green.svg)](https://cryptography.io/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

*Protect your files with military-grade encryption (AES-128)*

</div>

---

## ⚡ Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/pawored/cryptvault.git
cd cryptvault

# Install CryptVault (installs package + all dependencies)
pipx install .
```

### Basic Usage

```bash
# Encrypt a file
cryptvault encrypt document.pdf -p myPassword123

# Decrypt a file
cryptvault decrypt sandbox/document.pdf.encrypted -p myPassword123

# List saved keys
cryptvault list-keys
```

That's it! Your files are now protected with AES-128 encryption.

---

## 🎓 Getting Started

### 📖 First-time user?

1. **[Installation Guide](docs/INSTALLATION.md)** - Set up CryptVault in minutes
2. **[Usage Guide](docs/USAGE.md)** - Learn all commands and options
3. **[Examples](docs/EXAMPLES.md)** - See real-world use cases

### 🚀 Power user?

1. **[API Reference](docs/API_REFERENCE.md)** - Use CryptVault as a Python library
2. **[Automation Scripts](scripts/)** - Ready-to-use Bash & PowerShell scripts
3. **[Security Details](docs/SECURITY.md)** - Cryptographic specifications

---

## 🆚 Why CryptVault?

| Feature | CryptVault | GPG | 7-Zip | Others |
|---------|-----------|-----|-------|--------|
| **Easy CLI** | ✅ Intuitive | ❌ Complex | ⚠️ GUI-focused | ⚠️ Varies |
| **Modern Crypto** | ✅ AES-128 | ⚠️ Legacy algos | ⚠️ Various | ⚠️ Mixed |
| **Automation** | ✅ 14 scripts | ❌ None | ❌ None | ❌ Rare |
| **Documentation** | ✅ 10+ guides | ⚠️ Limited | ⚠️ Basic | ❌ Poor |
| **Pure Python** | ✅ Yes | ❌ No | ❌ No | ⚠️ Varies |
| **Password KDF** | ✅ PBKDF2 600K | ⚠️ Varies | ❌ None | ⚠️ Varies |
| **Cross-platform** | ✅ Win/Mac/Linux | ✅ Yes | ✅ Yes | ⚠️ Limited |
| **Key Management** | ✅ Built-in | ⚠️ External | ❌ None | ❌ None |

---

## ✨ Key Features

- 🔒 **Military-grade encryption** - Fernet (AES-128 + HMAC)
- 🔑 **Flexible key management** - Passwords, random keys, or saved keys
- 🎯 **Simple CLI** - Intuitive command-line interface
- 📦 **Batch processing** - Encrypt multiple files with the same key
- 🛡️ **Secure by default** - PBKDF2 with 600,000 iterations (OWASP 2023)
- 🐍 **Pure Python** - No external dependencies except cryptography
- 🤖 **Automation ready** - Bash and PowerShell scripts included

---

## 🤖 Automation Scripts

Ready-to-use scripts for common tasks:

**Linux/Mac (Bash):**
- Daily backups
- Encrypt by file type
- Organized category backups
- Batch decryption
- Sandbox cleanup
- Password rotation

**Windows (PowerShell):**
- Daily backups
- Encrypt by file type
- Organized category backups
- Batch decryption
- Sandbox cleanup
- Password rotation

See [scripts/](scripts/) for complete documentation.

---

## 📚 Documentation

Complete documentation is available in the [`docs/`](docs/) directory:

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation instructions
- **[Usage Guide](docs/USAGE.md)** - Complete command reference
- **[Examples](docs/EXAMPLES.md)** - Real-world use cases and advanced examples
- **[Automation Scripts](scripts/)** - Ready-to-use Bash and PowerShell scripts
- **[API Reference](docs/API_REFERENCE.md)** - Use as a Python library
- **[Security](docs/SECURITY.md)** - Security specifications and best practices
- **[FAQ](docs/FAQ.md)** - Frequently asked questions
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Contributing](docs/CONTRIBUTING.md)** - How to contribute to the project
- **[Changelog](docs/CHANGELOG.md)** - Version history and release notes

---

## 🏗️ Project Structure

```
cryptvault/
├── config/          # Configuration files
├── docs/            # Complete documentation
├── scripts/         # Automation scripts (Bash & PowerShell)
│   ├── linux/       # Linux/Mac scripts
│   └── windows/     # Windows scripts
├── src/             # Source code
├── tests/           # Unit tests
└── sandbox/         # Encrypted files (auto-created)
```

---

## 🔐 Security

CryptVault uses industry-standard cryptography:

| Component | Technology |
|-----------|------------|
| Encryption | Fernet (AES-128 CBC) |
| Authentication | HMAC-SHA256 |
| Key Derivation | PBKDF2-HMAC-SHA256 (600K iterations) |
| Salt | 16 random bytes per password |

**⚠️ Important:** If you lose your password/key, your files cannot be recovered. Always backup your keys securely.

See [docs/SECURITY.md](docs/SECURITY.md) for detailed security information.

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](docs/CONTRIBUTING.md) for details.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact

- **Author:** pawored
- **Email:** zogoxi-gobo52@protonmail.com
- **GitHub:** [@pawored](https://github.com/pawored)
- **Issues:** [GitHub Issues](https://github.com/pawored/cryptvault/issues)

---

<div align="center">

**Made with ❤️ and 🔐 by pawored**

⭐ If you find this project useful, please consider giving it a star on GitHub!

</div>
