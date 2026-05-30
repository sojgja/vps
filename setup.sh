# curl -sSL https://raw.githubusercontent.com/sojgja/vps/dev/setup.sh | bash
#!/bin/bash

set -e

echo "=============================="
echo "  VPS BOOTSTRAP - DEBIAN 12   "
echo "=============================="

# Update system
echo "[1/6] Updating system..."
apt update -y && apt upgrade -y

# Core tools
echo "[2/6] Installing core tools..."
apt install -y \
  git \
  curl \
  wget \
  vim \
  htop \
  unzip \
  sudo \
  build-essential \
  ca-certificates \
  gnupg \
  lsb-release

# Install Zsh
echo "[3/6] Installing Zsh..."
apt install -y zsh

# Set Zsh as default shell
chsh -s $(which zsh) || true

# Install Oh My Zsh (non-interactive)
echo "[4/6] Installing Oh My Zsh..."
RUNZSH=no KEEP_ZSHRC=yes \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins
echo "[5/6] Installing Zsh plugins..."

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM}/plugins/zsh-autosuggestions || true

# syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting || true

# Add plugins to .zshrc
echo "[6/6] Configuring .zshrc..."

if [ -f ~/.zshrc ]; then
  sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc || true
fi

# Apply changes
echo "Switching to zsh..."
echo "Done. Please reconnect SSH or run: zsh"

echo "=============================="
echo " VPS SETUP COMPLETED SUCCESS "
echo "=============================="
