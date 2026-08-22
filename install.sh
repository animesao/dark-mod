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
        sddm \
        tela-circle-icon-theme-grey

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

# X11/XWayland cursor (for games)
mkdir -p ~/.icons/default
cp -f "$DOTFILES_DIR/.icons/default/index.theme" ~/.icons/default/index.theme
echo "  [OK] X11 cursor fallback"

# SDDM cursor
sudo sed -i 's/GreeterEnvironment=.*/GreeterEnvironment=QML2_IMPORT_PATH=\/usr\/share\/sddm\/themes\/silent\/components\,QT_IM_MODULE=qtvirtualkeyboard,CURSOR_THEME=future-dark-cursors,CURSOR_SIZE=24/' /etc/sddm.conf 2>/dev/null || true
echo "  [OK] SDDM cursor theme"

# Icon theme
gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-grey-dark' 2>/dev/null || true
echo 'set -gx GTK_ICON_THEME Tela-circle-grey-dark' >> ~/.config/fish/config.fish
echo "  [OK] Icon theme (Tela-circle-grey-dark)"

# Fonts (JetBrains Mono)
mkdir -p ~/.local/share/fonts
cp -f "$DOTFILES_DIR/.local/share/fonts/"*.ttf ~/.local/share/fonts/
fc-cache -f 2>/dev/null || true
echo "  [OK] Fonts (JetBrains Mono)"

# Git config
cp -f "$DOTFILES_DIR/.gitconfig" ~/.gitconfig 2>/dev/null || true
echo "  [OK] Git config"

# --- Fish shell ---
echo ""
echo "Setting up Fish shell..."
if ! grep -q "fish" /etc/shells 2>/dev/null; then
    echo "$(which fish)" | sudo tee -a /etc/shells > /dev/null
fi
echo "  [OK] Fish added to /etc/shells"
echo "  Run: chsh -s $(which fish) to make Fish default"

# --- Cleanup script ---
echo ""
echo "Installing cleanup script..."
mkdir -p ~/.local/bin
cp -f "$DOTFILES_DIR/.local/bin/daily-cleanup.sh" ~/.local/bin/daily-cleanup.sh
chmod +x ~/.local/bin/daily-cleanup.sh
echo "  [OK] Cleanup script"

# Systemd timer for daily cleanup
mkdir -p ~/.config/systemd/user
cp -f "$DOTFILES_DIR/.config/systemd/user/daily-cleanup.timer" ~/.config/systemd/user/
cp -f "$DOTFILES_DIR/.config/systemd/user/daily-cleanup.service" ~/.config/systemd/user/
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable daily-cleanup.timer 2>/dev/null || true
systemctl --user start daily-cleanup.timer 2>/dev/null || true
echo "  [OK] Daily cleanup timer (4:00 AM)"

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
echo "  - Cursor: future-dark-cursors
  - Icons: Tela-circle-grey-dark
  - Fonts: JetBrains Mono
  - Git config (name, email)"
echo ""
echo "Re-login to apply: Mod+Shift+Q -> Logout"
