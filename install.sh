#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "  Установка dotfiles (Niri + Noctalia)"
echo "========================================"

# --- Проверка пакетного менеджера ---
if command -v pacman &>/dev/null; then
    PKG="pacman"
    INSTALL="sudo pacman -S --noconfirm"
elif command -v apt &>/dev/null; then
    PKG="apt"
    INSTALL="sudo apt install -y"
elif command -v dnf &>/dev/null; then
    PKG="dnf"
    INSTALL="sudo dnf install -y"
else
    echo "Unknown package manager. Install packages manually."
    exit 1
fi

echo "Package manager: $PKG"

# --- Установка зависимостей ---
echo ""
echo "Installing packages..."

if [ "$PKG" = "pacman" ]; then
    $INSTALL \
        niri \
        noctalia \
        cachyos-niri-noctalia \
        alacritty \
        grim \
        slurp \
        wl-clipboard \
        fish \
        polkit \
        networkmanager \
        sddm

elif [ "$PKG" = "apt" ]; then
    $INSTALL \
        niri \
        alacritty \
        grim \
        slurp \
        wl-clipboard \
        fish \
        polkit \
        network-manager \
        sddm

elif [ "$PKG" = "dnf" ]; then
    $INSTALL \
        niri \
        alacritty \
        grim \
        slurp \
        wl-clipboard \
        fish \
        polkit \
        NetworkManager \
        sddm
fi

# --- Установка конфигов ---
echo ""
echo "Installing configs..."

# Niri
mkdir -p ~/.config/niri/cfg
cp -f "$DOTFILES_DIR/.config/niri/config.kdl" ~/.config/niri/config.kdl
cp -f "$DOTFILES_DIR/.config/niri/cfg/"*.kdl ~/.config/niri/cfg/
echo "  [OK] Niri"

# Alacritty
mkdir -p ~/.config/alacritty
cp -f "$DOTFILES_DIR/.config/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml
echo "  [OK] Alacritty"

# Noctalia
mkdir -p ~/.config/noctalia
cp -f "$DOTFILES_DIR/.config/noctalia/config.toml" ~/.config/noctalia/config.toml
echo "  [OK] Noctalia"

# SDDM Theme (Silent)
sudo cp -rf "$DOTFILES_DIR/sddm/themes/silent" /usr/share/sddm/themes/
sudo cp -f "$DOTFILES_DIR/sddm/sddm.conf" /etc/sddm.conf
echo "  [OK] SDDM (Silent theme)"

# Cursor
mkdir -p ~/.local/share/icons
cp -rf "$DOTFILES_DIR/cursors" ~/.local/share/icons/future-dark-cursors
echo "  [OK] Cursor (future-dark-cursors)"

# --- Fish shell ---
echo ""
echo "Setting up Fish shell..."
if ! grep -q "fish" /etc/shells 2>/dev/null; then
    echo "$(which fish)" | sudo tee -a /etc/shells > /dev/null
fi
echo "  [OK] Fish added to /etc/shells"
echo "  Run: chsh -s $(which fish) to make Fish default"

# --- Enable services ---
echo ""
echo "Enabling services..."
if command -v systemctl &>/dev/null; then
    sudo systemctl enable --now NetworkManager 2>/dev/null || true
    sudo systemctl enable sddm 2>/dev/null || true
    echo "  [OK] NetworkManager, SDDM"
fi

echo ""
echo "========================================"
echo "           Done!"
echo "========================================"
echo ""
echo "Installed:"
echo "  - Niri (Wayland WM) + Noctalia (shell)"
echo "  - Alacritty (terminal)"
echo "  - SDDM (login screen - Silent theme)"
echo "  - Fish shell"
echo "  - Grim + Slurp (screenshots)"
echo "  - Cursor: future-dark-cursors"
echo ""
echo "Re-login to apply: Mod+Shift+Q -> Logout"
