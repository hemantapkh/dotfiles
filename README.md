# ⚙️ Dotfiles

My personal macOS configuration files.

## 🚀 Installation & Setup

On a fresh macOS machine, run:
```bash
curl -fsSL https://dots.hemantapkh.com | bash
```

This installs the dotfiles and everything they need. It never overwrites existing files and is safe to re-run. See [`.install.sh`](.install.sh) for options.

### Manual setup

To set up by hand instead, follow these steps:

### 1. Install Homebrew
If you don't have Homebrew installed yet, run:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install yadm
Install **Yet Another Dotfiles Manager** via Homebrew:
```bash
brew install yadm
```

### 3. Clone and Bootstrap
Run the exact command below to clone the repository and run the bootstrap script:
```bash
yadm clone git@github.com:hemantapkh/dotfiles.git
```
