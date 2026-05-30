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

echo "[CONFIG] Enabling zsh plugins..."
echo "[ZSH CONFIG] Fix autosuggestions..."

ZSHRC=~/.zshrc
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# đảm bảo zshrc tồn tại
if [ ! -f "$ZSHRC" ]; then
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template $ZSHRC
fi

# set plugins (không đủ để autosuggestions chạy nhưng vẫn cần)
sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' $ZSHRC || true

# 🔥 QUAN TRỌNG: force source autosuggestions (fix chính)
if ! grep -q "zsh-autosuggestions.zsh" $ZSHRC; then
  echo "" >> $ZSHRC
  echo "# AUTO FIX AUTOSUGGESTIONS" >> $ZSHRC
  echo "source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> $ZSHRC
fi

# syntax highlighting phải đặt CUỐI file
if ! grep -q "zsh-syntax-highlighting.zsh" $ZSHRC; then
  echo "source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> $ZSHRC
fi

echo "[GIT] Cloning repository..."

REPO_DIR="$HOME/vps"
REPO_URL="https://github.com/sojgja/vps.git"

# luôn dọn sạch để tránh conflict
if [ -d "$REPO_DIR" ]; then
  echo "Repo exists → removing..."
  rm -rf "$REPO_DIR"
fi

# clone + check lỗi rõ ràng
if git clone "$REPO_URL" "$REPO_DIR"; then
  echo "Clone SUCCESS"
else
  echo "Clone FAILED"
  echo "Check network / github / disk space"
  exit 1
fi

echo "[PYTHON] Creating virtual environment..."
apt install -y python3-venv python3-pip

VENV_DIR="$HOME/.venv"

python3 -m venv "$VENV_DIR"

echo "[PYTHON] Upgrading pip..."
"$VENV_DIR/bin/pip" install --upgrade pip

echo "[PYTHON] Installing packages..."
"$VENV_DIR/bin/pip" install \
  requests \
  django \
  fastapi \
  pandas \
  SqlAlchemy
