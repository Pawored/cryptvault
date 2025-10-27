# 📥 Installation Guide

Complete guide to installing CryptVault on your system.

---

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Installation](#quick-installation)
- [Installation Methods](#installation-methods)
  - [Method 1: From Source (Recommended)](#method-1-from-source-recommended)
  - [Method 2: Using pip](#method-2-using-pip)
  - [Method 3: Development Installation](#method-3-development-installation)
- [Platform-Specific Instructions](#platform-specific-instructions)
- [Verify Installation](#verify-installation)
- [Virtual Environment Setup](#virtual-environment-setup)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required

- **Python 3.8 or higher**
- **pip** (Python package manager)
- **Git** (for cloning the repository)

### Check Your Python Version

```bash
python --version
# Should show: Python 3.8.x or higher

pip --version
# Should show pip version
```

---

## Quick Installation

For most users, this is all you need:

```bash
# 1. Clone the repository
git clone https://github.com/pawored/cryptvault.git
cd cryptvault

# 2. Install CryptVault (installs package + all dependencies)
pip install .

# 3. Verify installation
cryptvault --help
```

**Done!** You're ready to start encrypting files.

---

## Installation Methods

### Method 1: From Source (Recommended)

This method gives you the latest version and allows easy updates.

#### Step 1: Clone the Repository

```bash
# Using HTTPS
git clone https://github.com/pawored/cryptvault.git

# Or using SSH
git clone git@github.com:pawored/cryptvault.git

# Navigate to the directory
cd cryptvault
```

#### Step 2: Install CryptVault

```bash
pip install .
```

This installs:
- CryptVault package
- All dependencies (cryptography>=42.0.0)
- `cryptvault` command globally

#### Step 3: Test Installation

```bash
cryptvault --help
```

**Expected Output:**
```
usage: cryptvault [-h] [--sandbox-dir SANDBOX_DIR]
                  {encrypt,decrypt,save-key,list-keys} ...

CryptVault - Professional File Encryption System
...
```

---

### Method 2: Using pip

Install CryptVault as a Python package.

#### Step 1: Install Package

```bash
# From GitHub
pip install git+https://github.com/pawored/cryptvault.git

# Or if setup.py is published
pip install cryptvault
```

#### Step 2: Use Anywhere

```bash
cryptvault encrypt myfile.txt -p mypassword
```

---

### Method 3: Development Installation

For contributors and developers who want to modify the code.

#### Step 1: Clone and Setup

```bash
# Clone the repository
git clone https://github.com/pawored/cryptvault.git
cd cryptvault

# Install in development mode
pip install -e .
```

#### Step 2: Install Development Dependencies

```bash
pip install -r config/requirements-dev.txt
```

This installs additional tools:
- Testing framework (pytest)
- Linting tools (pylint, flake8)
- Code formatting (black)
- Documentation tools (sphinx)

---

## Platform-Specific Instructions

### 🪟 Windows

#### Using PowerShell

```powershell
# Install Python from python.org (if not installed)
# Make sure "Add Python to PATH" is checked during installation

# Clone repository
git clone https://github.com/pawored/cryptvault.git
cd cryptvault

# Install CryptVault
pip install .

# If you get execution policy errors:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Using Command Prompt (CMD)

```cmd
git clone https://github.com/pawored/cryptvault.git
cd cryptvault
pip install -r config\requirements.txt
```

#### Using WSL (Windows Subsystem for Linux)

```bash
# Follow Linux instructions below
```

---

### 🐧 Linux

#### Ubuntu / Debian

```bash
# Install prerequisites
sudo apt update
sudo apt install python3 python3-pip git

# Clone and install
git clone https://github.com/pawored/cryptvault.git
cd cryptvault
pip3 install -r config/requirements.txt
```

#### Fedora / RHEL / CentOS

```bash
# Install prerequisites
sudo dnf install python3 python3-pip git

# Clone and install
git clone https://github.com/pawored/cryptvault.git
cd cryptvault
pip3 install -r config/requirements.txt
```

#### Arch Linux

```bash
# Install prerequisites
sudo pacman -S python python-pip git

# Clone and install
git clone https://github.com/pawored/cryptvault.git
cd cryptvault
pip install .
```

---

### 🍎 macOS

#### Using Homebrew

```bash
# Install prerequisites
brew install python git

# Clone and install
git clone https://github.com/pawored/cryptvault.git
cd cryptvault
pip3 install -r config/requirements.txt
```

#### Without Homebrew

```bash
# Python comes pre-installed on macOS
# Install git from: https://git-scm.com/download/mac

# Clone and install
git clone https://github.com/pawored/cryptvault.git
cd cryptvault
pip3 install -r config/requirements.txt
```

---

## Verify Installation

### Check Python Package

```bash
python -c "import cryptography; print(cryptography.__version__)"
```

**Expected Output:** `42.0.5` (or higher)

### Run Help Command

```bash
cryptvault --help
```

**Expected Output:** Usage information and available commands

### Run Test Encryption

```bash
# Create a test file
echo "Hello, World!" > test.txt

# Encrypt it
cryptvault encrypt test.txt -p test123

# Check if encrypted file exists
ls sandbox/

# Decrypt it
cryptvault decrypt sandbox/test.txt.encrypted -p test123

# Verify content
cat sandbox/test.txt.decrypted
```

**Expected:** "Hello, World!" should be recovered

---

## Virtual Environment Setup

### Why Use Virtual Environments?

✅ **Benefits:**
- Isolate project dependencies
- Avoid version conflicts
- Easy to reproduce environment
- Clean uninstallation

### Create Virtual Environment

#### Windows (PowerShell)

```powershell
# Create venv
python -m venv venv

# Activate
.\venv\Scripts\Activate.ps1

# If policy error:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Install dependencies
pip install .

# Deactivate when done
deactivate
```

#### Linux / macOS

```bash
# Create venv
python3 -m venv venv

# Activate
source venv/bin/activate

# Install dependencies
pip install .

# Deactivate when done
deactivate
```

### Using the Virtual Environment

```bash
# Always activate before working
source venv/bin/activate  # Linux/Mac
.\venv\Scripts\Activate.ps1  # Windows

# Your prompt will show (venv)
(venv) user@computer:~/cryptvault$

# Now all pip installs go to venv
pip install .

# Run the application (cryptvault command now available)
cryptvault encrypt file.txt -p pass

# Deactivate when done
deactivate
```

---

## Troubleshooting

### Error: "python: command not found"

**Solution:** Install Python or use `python3` instead:
```bash
python3 src/file_encryption_sandbox.py --help
```

### Error: "pip: command not found"

**Solution:** Install pip or use alternative:
```bash
python -m pip install .
```

### Error: "Permission denied"

**Solution 1:** Install for user only:
```bash
pip install --user -r config/requirements.txt
```

**Solution 2:** Use virtual environment (recommended)

### Error: "Could not find a version that satisfies the requirement cryptography"

**Solution:** Upgrade pip:
```bash
python -m pip install --upgrade pip
pip install .
```

### Error: Building wheel for cryptography failed

**Windows Solution:**
- Install Visual Studio Build Tools
- Or use pre-built wheels: `pip install --upgrade pip`

**Linux Solution:**
```bash
# Ubuntu/Debian
sudo apt install build-essential libssl-dev libffi-dev python3-dev

# Fedora
sudo dnf install gcc openssl-devel libffi-devel python3-devel
```

**macOS Solution:**
```bash
xcode-select --install
```

### Error: Git not found

**Solution:** Install Git:
- **Windows:** https://git-scm.com/download/win
- **Linux:** `sudo apt install git`
- **macOS:** `brew install git` or use Xcode

---

## Post-Installation

### Command Availability

After installation with `pip install .`, the `cryptvault` command is automatically available system-wide.

```bash
# Use from any directory
cryptvault encrypt ~/Documents/file.pdf -p password
cryptvault list-keys
```

No additional PATH configuration needed!

### Optional: Install Shell Completion

For command auto-completion (bash/zsh):

```bash
# Coming soon!
```

---

## Updating CryptVault

### Update from Git

```bash
cd cryptvault
git pull origin main
pip install --upgrade -r config/requirements.txt
```

### Update pip Package

```bash
pip install --upgrade cryptvault
```

---

## Uninstallation

### Remove Package

```bash
pip uninstall cryptography
```

### Remove Directory

```bash
rm -rf cryptvault  # Linux/Mac
rmdir /s cryptvault  # Windows
```

### Remove Virtual Environment

```bash
rm -rf venv  # Linux/Mac
rmdir /s venv  # Windows
```

---

## Next Steps

✅ Installation complete! What's next?

1. **Read [Usage Guide](USAGE.md)** - Learn all commands
2. **Check [Examples](EXAMPLES.md)** - See real-world use cases
3. **Review [Security](SECURITY.md)** - Understand best practices
4. **Try [Quick Start](USAGE.md#quick-start)** - Encrypt your first file

---

## Need Help?

If you encounter issues not covered here:

1. Check [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Search [GitHub Issues](https://github.com/pawored/cryptvault/issues)
3. Open a new issue with:
   - Your OS and Python version
   - Complete error message
   - Steps to reproduce

---

<div align="center">

[← Back to Docs](README.md) • [Usage Guide →](USAGE.md)

</div>
