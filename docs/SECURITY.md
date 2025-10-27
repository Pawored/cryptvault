# 🔒 Security

Security specifications, best practices, and threat model for CryptVault.

---

## Table of Contents

- [Security Overview](#security-overview)
- [Cryptographic Specifications](#cryptographic-specifications)
- [Threat Model](#threat-model)
- [Best Practices](#best-practices)
- [Security Considerations](#security-considerations)
- [Vulnerability Reporting](#vulnerability-reporting)

---

## Security Overview

CryptVault uses industry-standard cryptographic primitives to provide confidential file encryption.

### Security Goals

✅ **Confidentiality** - Only authorized parties can read encrypted files  
✅ **Integrity** - Any tampering with encrypted files is detected  
✅ **Authentication** - Encrypted files can only be decrypted with correct key/password  

---

## Cryptographic Specifications

### Encryption Algorithm

**Fernet (Symmetric Encryption)**

```
Fernet = AES-128-CBC + HMAC-SHA256
```

**Components:**
- **AES-128-CBC** - Advanced Encryption Standard, 128-bit key, CBC mode
- **HMAC-SHA256** - Hash-based Message Authentication Code
- **IV Generation** - Random 16-byte initialization vector per encryption

---

### Key Derivation

**PBKDF2-HMAC-SHA256**

```python
key = PBKDF2-HMAC-SHA256(
    password=user_password,
    salt=random_16_bytes,
    iterations=600000,
    key_length=32
)
```

**Parameters:**
- **Iterations:** 600,000 (OWASP 2023 recommendation)
- **Salt:** 16 bytes, randomly generated
- **Output:** 32 bytes (256 bits)

---

## Threat Model

### Protected Threats

| Threat | Protection |
|--------|-----------|
| **File Theft** | ✅ AES-128 encryption |
| **Tampering** | ✅ HMAC authentication |
| **Brute Force** | ✅ 600K PBKDF2 iterations |
| **Rainbow Tables** | ✅ Random salt per key |

### Not Protected

| Threat | Mitigation |
|--------|-----------|
| **Weak Passwords** | Use strong passwords (12+ chars) |
| **Keyloggers** | Keep system malware-free |
| **Physical Access** | Secure your computer |

---

## Best Practices

### Password Guidelines

```
✅ Length: 12+ characters
✅ Complexity: Mix of upper, lower, numbers, symbols
✅ Uniqueness: Don't reuse passwords
❌ Avoid: Dictionary words, personal info
```

### Key Management

#### ✅ DO
- Use password managers
- Store keys securely
- Rotate passwords annually
- Backup keys separately

#### ❌ DON'T
- Hardcode passwords in code
- Email passwords unencrypted
- Reuse passwords
- Share passwords insecurely

---

## Security Considerations

### Metadata Leakage

Encrypted files may expose:
- File size (approximate)
- File name (unless renamed)
- Modification dates

**Mitigation:** Rename files, use full-disk encryption for complete protection.

---

## Vulnerability Reporting

**Email:** zogoxi-gobo52@protonmail.com

**Process:**
1. Do NOT open public issues
2. Email details privately
3. Allow 90 days for fix

---

## Disclaimer

CryptVault provides strong encryption but is not a substitute for physical, system, or operational security.

**Use at your own risk. No warranties provided.**

---

<div align="center">

**Security is a shared responsibility 🔐**

[← Back to Documentation](README.md)

</div>
