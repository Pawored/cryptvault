# ❓ FAQ

Frequently Asked Questions about CryptVault.

---

## General Questions

### What is CryptVault?
Command-line tool for encrypting/decrypting files using AES-128 (Fernet).

### Is it free?
Yes! Open-source under MIT License.

### What platforms are supported?
Linux, macOS, and Windows.

---

## Usage Questions

### How do I encrypt a file?
```bash
cryptvault encrypt myfile.pdf -p MyPassword123!
```

### How do I decrypt a file?
```bash
cryptvault decrypt myfile.pdf.encrypted -p MyPassword123!
```

### Can I encrypt multiple files at once?
Yes! Use automation scripts in `scripts/` directory.

### What file types can I encrypt?
All file types! Documents, images, videos, archives, databases, etc.

---

## Security Questions

### How secure is CryptVault?
Very secure:
- AES-128 encryption
- HMAC-SHA256 integrity
- 480,000 PBKDF2 iterations

### What if I forget my password?
**Files are unrecoverable.** Use a password manager and keep backups.

### Can someone modify encrypted files without detection?
No. HMAC authentication detects tampering.

### Is it safe to upload encrypted files to cloud?
Yes! Encrypted files are safe on any cloud service.

---

## Troubleshooting

### "Command not found" error
Use full Python path: `python3 src/file_encryption_sandbox.py ...`

### "Module 'cryptography' not found"
Install dependencies: `pip install -r config/requirements.txt`

### "Wrong password" error
Check:
- Password typo
- Correct file
- Caps Lock/keyboard layout

---

## Advanced Questions

### Can I use it in Python code?
Yes! See [API Reference](API_REFERENCE.md).

### How do I automate backups?
Use automation scripts in `scripts/linux/` or `scripts/windows/`.

### Can I change PBKDF2 iterations?
Yes, in code. Default: 480,000 (recommended).

### How do I share encrypted files securely?
1. Share encrypted file via email/cloud
2. Share password via different channel (Signal, in person)

---

## More Help

- [Documentation](README.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [GitHub Issues](https://github.com/pawored/cryptvault/issues)
- Email: zogoxi-gobo52@protonmail.com

---

[← Back to Documentation](README.md)
