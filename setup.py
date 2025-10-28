from setuptools import setup, find_packages
from pathlib import Path

# Read README for long description
readme_file = Path(__file__).parent / "README.md"
if readme_file.exists():
    with open(readme_file, "r", encoding="utf-8") as fh:
        long_description = fh.read()
else:
    long_description = "Professional file encryption system using Fernet (AES-128)"

# Read requirements
requirements_file = Path(__file__).parent / "config" / "requirements.txt"
if requirements_file.exists():
    with open(requirements_file, "r", encoding="utf-8") as fh:
        requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]
else:
    requirements = ["cryptography>=42.0.0"]

setup(
    name="cryptvault",
    version="1.0.0",
    author="pawored",
    author_email="zogoxi-gobo52@protonmail.com",
    description="Professional file encryption system using Fernet (AES-128)",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/pawored/cryptvault",
    project_urls={
        "Bug Reports": "https://github.com/pawored/cryptvault/issues",
        "Source": "https://github.com/pawored/cryptvault",
        "Documentation": "https://github.com/pawored/cryptvault/blob/main/docs/",
    },
    packages=["cryptvault"],
    py_modules=[],
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Intended Audience :: End Users/Desktop",
        "Topic :: Security :: Cryptography",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
    keywords="encryption, cryptography, security, aes, fernet, file-encryption",
    python_requires=">=3.8",
    install_requires=requirements,
    entry_points={
        "console_scripts": [
            "cryptvault=cryptvault.file_encryption_sandbox:main",
        ],
    },
    include_package_data=True,
    zip_safe=False,
)