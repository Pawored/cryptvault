# 🤝 Contributing to CryptVault

Thank you for your interest in contributing to CryptVault!

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)

---

## Code of Conduct

### Our Pledge

We pledge to make participation in CryptVault a harassment-free experience for everyone.

### Our Standards

**Positive behavior:**
- ✅ Using welcoming and inclusive language
- ✅ Being respectful of differing viewpoints
- ✅ Accepting constructive criticism gracefully
- ✅ Focusing on what's best for the community

**Unacceptable behavior:**
- ❌ Harassment or discriminatory language
- ❌ Personal attacks or insults
- ❌ Publishing others' private information
- ❌ Other unprofessional conduct

---

## How to Contribute

### Ways to Contribute

1. **Report bugs** - Found an issue? Let us know!
2. **Suggest features** - Have an idea? Share it!
3. **Improve documentation** - Fix typos, clarify instructions
4. **Write code** - Fix bugs, add features
5. **Create automation scripts** - Share useful scripts
6. **Write tests** - Improve code coverage
7. **Review pull requests** - Help review others' code

---

## Development Setup

### 1. Fork the Repository

Click "Fork" on GitHub: https://github.com/pawored/cryptvault

### 2. Clone Your Fork

```bash
git clone https://github.com/YOUR-USERNAME/cryptvault.git
cd cryptvault
```

### 3. Add Upstream Remote

```bash
git remote add upstream https://github.com/pawored/cryptvault.git
git remote -v
```

### 4. Create Virtual Environment

```bash
# Linux/Mac
python3 -m venv venv
source venv/bin/activate

# Windows
python -m venv venv
venv\Scripts\activate
```

### 5. Install Dependencies

```bash
# Install requirements
pip install -r config/requirements.txt

# Install development dependencies (if available)
pip install -r config/requirements-dev.txt
```

### 6. Create a Branch

```bash
git checkout -b feature/my-new-feature
# or
git checkout -b fix/bug-description
```

---

## Coding Standards

### Python Style Guide

Follow **PEP 8** style guide:

```python
# Good
def encrypt_file(input_file: str, password: str) -> str:
    """Encrypt a file with given password.
    
    Args:
        input_file: Path to input file
        password: Encryption password
        
    Returns:
        Path to encrypted file
    """
    # Implementation
    pass

# Bad
def EncryptFile(inputFile,pwd):
    # no docstring
    pass
```

### Code Quality

- ✅ Write clear, self-documenting code
- ✅ Add comments for complex logic
- ✅ Use type hints
- ✅ Write docstrings for functions/classes
- ✅ Keep functions small and focused
- ✅ Handle errors gracefully

### Testing

```bash
# Run tests (if available)
python -m pytest tests/

# Run specific test
python -m pytest tests/test_encryption.py

# Check code coverage
python -m pytest --cov=src tests/
```

---

## Pull Request Process

### Before Submitting

1. **Update from upstream**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Test your changes**
   ```bash
   # Manual testing
   python src/file_encryption_sandbox.py encrypt test.pdf -p Pass123!
   
   # Automated tests (if available)
   pytest tests/
   ```

3. **Update documentation**
   - Update relevant `.md` files
   - Add examples if needed
   - Update CHANGELOG.md

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add feature: brief description"
   
   # Use descriptive commit messages:
   # ✅ Good: "Add batch encryption support for multiple files"
   # ❌ Bad: "Update stuff"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/my-new-feature
   ```

### Submitting Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill in PR template:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
How you tested the changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Commented complex code
- [ ] Updated documentation
- [ ] No new warnings
- [ ] Added tests (if applicable)
```

5. Submit PR

### Review Process

1. Maintainer reviews PR
2. Address feedback if requested
3. Make changes in same branch
4. Push updates (PR updates automatically)
5. Once approved, PR is merged

---

## Reporting Bugs

### Before Reporting

1. Check [existing issues](https://github.com/pawored/cryptvault/issues)
2. Check [Troubleshooting guide](TROUBLESHOOTING.md)
3. Try latest version

### Bug Report Template

```markdown
**Describe the bug**
Clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Run command '...'
2. See error

**Expected behavior**
What should happen

**Environment**
- OS: [e.g., Ubuntu 22.04]
- Python version: [e.g., 3.10.5]
- CryptVault version: [e.g., 1.0.0]

**Error message**
```
Full error message here
```

**Additional context**
Any other relevant information
```

---

## Suggesting Features

### Feature Request Template

```markdown
**Is your feature related to a problem?**
Clear description of the problem

**Describe the solution**
How you'd like it to work

**Describe alternatives**
Other solutions you've considered

**Additional context**
Mockups, examples, use cases
```

### Good Feature Requests

- ✅ Clearly defined problem
- ✅ Proposed solution
- ✅ Use cases explained
- ✅ Benefits described

---

## Development Guidelines

### Project Structure

```
cryptvault/
├── src/                    # Source code
│   └── file_encryption_sandbox.py
├── tests/                  # Unit tests
├── scripts/                # Automation scripts
│   ├── linux/
│   └── windows/
├── docs/                   # Documentation
└── config/                 # Configuration files
```

### Adding New Features

1. Discuss in GitHub issue first
2. Create branch: `feature/feature-name`
3. Implement feature
4. Add tests
5. Update documentation
6. Submit PR

### Adding Scripts

When contributing automation scripts:

```bash
# 1. Add to appropriate directory
scripts/linux/my-script.sh
scripts/windows/my-script.ps1

# 2. Follow naming convention
verb-noun.sh  # e.g., backup-database.sh

# 3. Add documentation in script header
#!/bin/bash
# ==============================================================================
# CryptVault - Script Name
# ==============================================================================
#
# Description of what script does
#
# Usage:
#   ./script-name.sh <args>
#
# Examples:
#   ./script-name.sh example
# ==============================================================================

# 4. Update scripts README
# Add entry to scripts/linux/README.md or scripts/windows/README.md
```

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## Questions?

- **Email:** zogoxi-gobo52@protonmail.com
- **GitHub Issues:** [github.com/pawored/cryptvault/issues](https://github.com/pawored/cryptvault/issues)
- **Discussions:** [GitHub Discussions](https://github.com/pawored/cryptvault/discussions) (if enabled)

---

<div align="center">

**Thank you for contributing! 🎉**

[← Back to Documentation](README.md)

</div>
