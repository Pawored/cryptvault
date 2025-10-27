"""
CryptVault Test Suite - Encryption Tests

Comprehensive tests for encryption/decryption functionality.
"""

import pytest
import os
import tempfile
from pathlib import Path
from cryptography.fernet import Fernet
from cryptvault import CryptVault


class TestBasicEncryption:
    """Test basic encryption/decryption operations."""

    @pytest.fixture
    def vault(self, tmp_path):
        """Create a CryptVault instance with temporary sandbox."""
        sandbox = tmp_path / "sandbox"
        return CryptVault(sandbox_dir=str(sandbox))

    @pytest.fixture
    def test_file(self, tmp_path):
        """Create a temporary test file."""
        test_file = tmp_path / "test.txt"
        test_file.write_text("Test content for encryption")
        return test_file

    def test_encrypt_with_password(self, vault, test_file):
        """Test encryption with password."""
        encrypted_path, key_id = vault.encrypt_file(
            str(test_file),
            password="TestPassword123"
        )

        assert Path(encrypted_path).exists()
        assert Path(encrypted_path).stat().st_size > 0
        assert key_id.startswith("key_")

    def test_decrypt_with_password(self, vault, test_file):
        """Test decryption with password."""
        # Encrypt
        encrypted_path, _ = vault.encrypt_file(
            str(test_file),
            password="TestPassword123"
        )

        # Decrypt
        decrypted_path = vault.decrypt_file(
            encrypted_path,
            password="TestPassword123"
        )

        assert Path(decrypted_path).exists()
        assert Path(decrypted_path).read_text() == "Test content for encryption"

    def test_encrypt_with_random_key(self, vault, test_file):
        """Test encryption with randomly generated key."""
        encrypted_path, key_id = vault.encrypt_file(str(test_file))

        assert Path(encrypted_path).exists()
        keys = vault.list_keys()
        assert key_id in keys
        assert keys[key_id]['type'] == 'key'

    def test_decrypt_with_direct_key(self, vault, test_file):
        """Test decryption with direct key."""
        # Encrypt with random key
        encrypted_path, key_id = vault.encrypt_file(str(test_file))

        # Get the key
        keys = vault.list_keys()
        direct_key = keys[key_id]['key']

        # Decrypt with direct key
        decrypted_path = vault.decrypt_file(
            encrypted_path,
            key=direct_key
        )

        assert Path(decrypted_path).read_text() == "Test content for encryption"

    def test_encrypt_binary_file(self, vault, tmp_path):
        """Test encryption of binary files."""
        binary_file = tmp_path / "test.bin"
        binary_data = os.urandom(1024)
        binary_file.write_bytes(binary_data)

        encrypted_path, _ = vault.encrypt_file(
            str(binary_file),
            password="BinaryTest123"
        )

        decrypted_path = vault.decrypt_file(
            encrypted_path,
            password="BinaryTest123"
        )

        assert Path(decrypted_path).read_bytes() == binary_data

    def test_custom_output_path(self, vault, test_file, tmp_path):
        """Test encryption with custom output path."""
        custom_output = tmp_path / "custom" / "encrypted.dat"
        custom_output.parent.mkdir()

        encrypted_path, _ = vault.encrypt_file(
            str(test_file),
            output_path=str(custom_output),
            password="CustomPath123"
        )

        assert encrypted_path == str(custom_output)
        assert Path(custom_output).exists()


class TestErrorHandling:
    """Test error handling and edge cases."""

    @pytest.fixture
    def vault(self, tmp_path):
        """Create a CryptVault instance with temporary sandbox."""
        sandbox = tmp_path / "sandbox"
        return CryptVault(sandbox_dir=str(sandbox))

    def test_encrypt_nonexistent_file(self, vault):
        """Test encrypting a file that doesn't exist."""
        with pytest.raises(FileNotFoundError):
            vault.encrypt_file("nonexistent.txt", password="test")

    def test_decrypt_nonexistent_file(self, vault):
        """Test decrypting a file that doesn't exist."""
        with pytest.raises(FileNotFoundError):
            vault.decrypt_file("nonexistent.encrypted", password="test")

    def test_decrypt_wrong_password(self, vault, tmp_path):
        """Test decryption with wrong password."""
        test_file = tmp_path / "test.txt"
        test_file.write_text("Secret content")

        encrypted_path, _ = vault.encrypt_file(
            str(test_file),
            password="CorrectPassword"
        )

        with pytest.raises(ValueError, match="Decryption failed"):
            vault.decrypt_file(encrypted_path, password="WrongPassword")

    def test_decrypt_without_credentials(self, vault, tmp_path):
        """Test decryption without providing password or key."""
        test_file = tmp_path / "test.txt"
        test_file.write_text("Content")

        encrypted_path, _ = vault.encrypt_file(str(test_file), password="pass")

        with pytest.raises(ValueError, match="Must provide"):
            vault.decrypt_file(encrypted_path)

    def test_encrypt_with_nonexistent_saved_key(self, vault, tmp_path):
        """Test encryption with a saved key that doesn't exist."""
        test_file = tmp_path / "test.txt"
        test_file.write_text("Content")

        with pytest.raises(ValueError, match="not found"):
            vault.encrypt_file(
                str(test_file),
                key_name="nonexistent-key",
                password="pass"
            )


class TestLargeFiles:
    """Test encryption of large files."""

    @pytest.fixture
    def vault(self, tmp_path):
        """Create a CryptVault instance with temporary sandbox."""
        sandbox = tmp_path / "sandbox"
        return CryptVault(sandbox_dir=str(sandbox))

    def test_encrypt_large_file(self, vault, tmp_path):
        """Test encryption of a large file (10MB)."""
        large_file = tmp_path / "large.bin"
        # Create 10MB file
        large_data = os.urandom(10 * 1024 * 1024)
        large_file.write_bytes(large_data)

        encrypted_path, _ = vault.encrypt_file(
            str(large_file),
            password="LargeFile123"
        )

        assert Path(encrypted_path).exists()
        # Encrypted size should be larger due to metadata
        assert Path(encrypted_path).stat().st_size > len(large_data)

    def test_decrypt_large_file(self, vault, tmp_path):
        """Test decryption of a large file."""
        large_file = tmp_path / "large.bin"
        large_data = os.urandom(5 * 1024 * 1024)  # 5MB
        large_file.write_bytes(large_data)

        encrypted_path, _ = vault.encrypt_file(
            str(large_file),
            password="LargeFile123"
        )

        decrypted_path = vault.decrypt_file(
            encrypted_path,
            password="LargeFile123"
        )

        assert Path(decrypted_path).read_bytes() == large_data


class TestFileNaming:
    """Test file naming conventions."""

    @pytest.fixture
    def vault(self, tmp_path):
        """Create a CryptVault instance with temporary sandbox."""
        sandbox = tmp_path / "sandbox"
        return CryptVault(sandbox_dir=str(sandbox))

    def test_encrypted_file_naming(self, vault, tmp_path):
        """Test that encrypted files have .encrypted extension."""
        test_file = tmp_path / "document.pdf"
        test_file.write_text("PDF content")

        encrypted_path, _ = vault.encrypt_file(str(test_file), password="test")

        assert encrypted_path.endswith("document.pdf.encrypted")

    def test_decrypted_file_naming(self, vault, tmp_path):
        """Test that decrypted files have .decrypted extension."""
        test_file = tmp_path / "file.txt"
        test_file.write_text("Content")

        encrypted_path, _ = vault.encrypt_file(str(test_file), password="test")
        decrypted_path = vault.decrypt_file(encrypted_path, password="test")

        assert decrypted_path.endswith(".decrypted")
