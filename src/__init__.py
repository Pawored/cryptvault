"""
CryptVault - Professional File Encryption System

A secure file encryption library using Fernet (AES-128-CBC) with PBKDF2 key derivation.

Basic Usage:
    >>> from cryptvault import CryptVault
    >>>
    >>> # Initialize vault
    >>> vault = CryptVault()
    >>>
    >>> # Encrypt a file with password
    >>> encrypted_path, key_id = vault.encrypt_file("document.pdf", password="MyPassword123")
    >>>
    >>> # Decrypt the file
    >>> decrypted_path = vault.decrypt_file(encrypted_path, password="MyPassword123")

Advanced Usage:
    >>> # Save a key for reuse
    >>> vault.save_key("project-alpha", password="ProjectPass123")
    >>>
    >>> # Encrypt multiple files with the same key
    >>> vault.encrypt_file("file1.txt", key_name="project-alpha", password="ProjectPass123")
    >>> vault.encrypt_file("file2.txt", key_name="project-alpha", password="ProjectPass123")
    >>>
    >>> # List saved keys
    >>> keys = vault.list_keys()

For more information, see the documentation in docs/
"""

from .file_encryption_sandbox import CryptVault

__version__ = "1.0.0"
__author__ = "Pawored"
__email__ = "zogoxi-gobo52@protonmail.com"

__all__ = ['CryptVault']
