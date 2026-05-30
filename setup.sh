#!/bin/bash

set -e

echo "=============================="
echo " VPS BOOTSTRAP - DEBIAN 12 FIXED"
echo "=============================="

# update system
echo "[1/7] Updating system..."
apt update -y && apt upgrade -y

# base tools
echo "[2/7] Installing base tools..."
apt install -y \
  git curl wget vim htop unzip sudo \
  build-essential ca-certificates gnupg lsb-release zsh

# set zsh default (safe version)
echo "[3/7] Setting zsh..."
if grep -q "/zsh" /etc/shells; then
  chsh -s $(which zsh) || true
fi

# install oh-my-zsh (SAFE MODE - no prompt)
echo "[4/7] Installing oh-my-zsh..."
export RUNZSH=no
export KEEP_ZSHRC=yes

rm -rf ~/.oh-my-zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install plugins directory
echo "[5/7] Installing plugins..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

mkdir -p ${ZSH_CUSTOM}/plugins

# autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
fi

# syntax highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
fi

# fix .zshrc safely
echo "[6/7] Configuring zshrc..."

if [ ! -f ~/.zshrc ]; then
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
fi

sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc || true

# final check
echo "[7/7] Verifying installation..."

zsh --version || true
git --version || true

echo "=============================="
echo " VPS SETUP DONE OK"
echo " RECONNECT SSH OR RUN: zsh"
echo "=============================="
