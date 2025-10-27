"""
CryptVault Test Suite - Key Management Tests

Comprehensive tests for key management functionality.
"""

import pytest
import json
from pathlib import Path
from cryptvault import CryptVault


class TestKeyStorage:
    """Test key storage and retrieval."""

    @pytest.fixture
    def vault(self, tmp_path):
        """Create a CryptVault instance with temporary sandbox."""
        sandbox = tmp_path / "sandbox"
        return CryptVault(sandbox_dir=str(sandbox))

    def test_save_password_key(self, vault):
        """Test saving a password-based key."""
        vault.save_key("test-key", password="TestPassword123")

        keys = vault.list_keys()
        assert "test-key" in keys
        assert keys["test-key"]["type"] == "password"
        assert "salt" in keys["test-key"]
        assert "created" in keys["test-key"]

    def test_save_direct_key(self, vault):
        """Test saving a direct encryption key."""
        from cryptography.fernet import Fernet
        import base64

        key = base64.b64encode(Fernet.generate_key()).decode()
        vault.save_key("direct-key", key=key)

        keys = vault.list_keys()
        assert "direct-key" in keys
        assert keys["direct-key"]["type"] == "key"
        assert keys["direct-key"]["key"] == key

    def test_save_key_without_credentials(self, vault):
        """Test that saving a key without password or key raises error."""
        with pytest.raises(ValueError, match="Must provide"):
            vault.save_key("invalid-key")

    def test_list_empty_keys(self, vault):
        """Test listing keys when none are saved."""
        keys = vault.list_keys()
        assert keys == {}

    def test_list_multiple_keys(self, vault):
        """Test listing multiple saved keys."""
        vault.save_key("key1", password="pass1")
        vault.save_key("key2", password="pass2")
        vault.save_key("key3", password="pass3")

        keys = vault.list_keys()
        assert len(keys) == 3
        assert "key1" in keys
        assert "key2" in keys
        assert "key3" in keys


class TestKeyUsage:
    """Test using saved keys for encryption/decryption."""

    @pytest.fixture
    def vault(self, tmp_path):
        """Create a CryptVault instance with temporary sandbox."""
        sandbox = tmp_path / "sandbox"
        return CryptVault(sandbox_dir=str(sandbox))

    @pytest.fixture
    def test_file(self, tmp_path):
        """Create a temporary test file."""
        test_file = tmp_path / "test.txt"
        test_file.write_text("Test content")
        return test_file

    def test_encrypt_with_saved_key(self, vault, test_file):
        """Test encrypting with a saved key."""
        vault.save_key("my-key", password="SavedPassword123")

        encrypted_path, _ = vault.encrypt_file(
            str(test_file),
            key_name="my-key",
            password="SavedPassword123"
        )

        assert Path(encrypted_path).exists()

    def test_decrypt_with_saved_key(self, vault, test_file):
        """Test decrypting with a saved key."""
        vault.save_key("my-key", password="SavedPassword123")

        encrypted_path, _ = vault.encrypt_file(
            str(test_file),
            key_name="my-key",
            password="SavedPassword123"
        )

        decrypted_path = vault.decrypt_file(
            encrypted_path,
            key_name="my-key",
            password="SavedPassword123"
        )

        assert Path(decrypted_path).read_text() == "Test content"

    def test_encrypt_multiple_files_same_key(self, vault, tmp_path):
        """Test encrypting multiple files with the same key."""
        vault.save_key("shared-key", password="SharedPass123")

        file1 = tmp_path / "file1.txt"
        file2 = tmp_path / "file2.txt"
        file1.write_text("Content 1")
        file2.write_text("Content 2")

        vault.encrypt_file(str(file1), key_name="shared-key", password="SharedPass123")
        vault.encrypt_file(str(file2), key_name="shared-key", password="SharedPass123")

        keys = vault.list_keys()
        assert len(keys["shared-key"]["files"]) == 2

    def test_use_nonexistent_key(self, vault, test_file):
        """Test using a key that doesn't exist."""
        with pytest.raises(ValueError, match="not found"):
            vault.encrypt_file(
                str(test_file),
                key_name="nonexistent",
                password="pass"
            )


class TestKeysPersistence:
    """Test that keys persist across CryptVault instances."""

    def test_keys_persist(self, tmp_path):
        """Test that keys are saved and can be loaded by new instance."""
        sandbox = tmp_path / "sandbox"

        # First instance - save a key
        vault1 = CryptVault(sandbox_dir=str(sandbox))
        vault1.save_key("persistent-key", password="PersistentPass123")

        # Second instance - should see the same key
        vault2 = CryptVault(sandbox_dir=str(sandbox))
        keys = vault2.list_keys()

        assert "persistent-key" in keys

    def test_keys_file_format(self, tmp_path):
        """Test that .keys.json file has correct format."""
        sandbox = tmp_path / "sandbox"
        vault = CryptVault(sandbox_dir=str(sandbox))

        vault.save_key("test-key", password="TestPass123")

        keys_file = Path(sandbox) / ".keys.json"
        assert keys_file.exists()

        with open(keys_file, 'r') as f:
            data = json.load(f)

        assert isinstance(data, dict)
        assert "test-key" in data
        assert "type" in data["test-key"]
        assert "created" in data["test-key"]


class TestKeyMetadata:
    """Test key metadata tracking."""

    @pytest.fixture
    def vault(self, tmp_path):
        """Create a CryptVault instance with temporary sandbox."""
        sandbox = tmp_path / "sandbox"
        return CryptVault(sandbox_dir=str(sandbox))

    @pytest.fixture
    def test_file(self, tmp_path):
        """Create a temporary test file."""
        test_file = tmp_path / "test.txt"
        test_file.write_text("Test content")
        return test_file

    def test_file_usage_tracking(self, vault, test_file):
        """Test that encrypted files are tracked in key metadata."""
        vault.save_key("tracked-key", password="TrackedPass123")

        vault.encrypt_file(
            str(test_file),
            key_name="tracked-key",
            password="TrackedPass123"
        )

        keys = vault.list_keys()
        assert len(keys["tracked-key"]["files"]) == 1
        assert "test.txt.encrypted" in keys["tracked-key"]["files"][0]

    def test_creation_timestamp(self, vault):
        """Test that keys have creation timestamps."""
        vault.save_key("timestamped-key", password="TimestampPass123")

        keys = vault.list_keys()
        assert "created" in keys["timestamped-key"]
        # Verify it's a valid ISO format timestamp
        from datetime import datetime
        datetime.fromisoformat(keys["timestamped-key"]["created"])

    def test_key_type_metadata(self, vault):
        """Test that key type is correctly stored."""
        vault.save_key("password-key", password="PasswordTest123")

        from cryptography.fernet import Fernet
        import base64
        direct_key = base64.b64encode(Fernet.generate_key()).decode()
        vault.save_key("direct-key", key=direct_key)

        keys = vault.list_keys()
        assert keys["password-key"]["type"] == "password"
        assert keys["direct-key"]["type"] == "key"


class TestInvalidKeys:
    """Test handling of invalid keys."""

    @pytest.fixture
    def vault(self, tmp_path):
        """Create a CryptVault instance with temporary sandbox."""
        sandbox = tmp_path / "sandbox"
        return CryptVault(sandbox_dir=str(sandbox))

    def test_save_invalid_direct_key(self, vault):
        """Test that saving an invalid direct key raises error."""
        with pytest.raises(ValueError, match="Invalid key format"):
            vault.save_key("invalid-key", key="not-a-valid-base64-key")

    def test_decrypt_with_wrong_key_name(self, vault, tmp_path):
        """Test decrypting with wrong saved key name."""
        test_file = tmp_path / "test.txt"
        test_file.write_text("Content")

        vault.save_key("key1", password="pass1")
        vault.save_key("key2", password="pass2")

        encrypted_path, _ = vault.encrypt_file(
            str(test_file),
            key_name="key1",
            password="pass1"
        )

        # Try to decrypt with key2 (wrong key)
        with pytest.raises(ValueError, match="Decryption failed"):
            vault.decrypt_file(
                encrypted_path,
                key_name="key2",
                password="pass2"
            )
