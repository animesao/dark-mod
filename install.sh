#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "╔══════════════════════════════════════╗"
echo "║    Установка dotfiles (Niri + Noctalia)    ║"
echo "╚══════════════════════════════════════╝"

# ─── Проверка пакетного менеджера ───
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
    echo "❌ Неизвестный пакетный менеджер. Установи пакеты вручную."
    exit 1
fi

echo "📦 Пакетный менеджер: $PKG"

# ─── Установка зависимостей ───
echo ""
echo "📦 Установка пакетов..."

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
        grim \
        slurp \
        wl-clipboard \
        fish \
        polkit \
        NetworkManager \
        sddm
fi

# ─── Установка конфигов ───
echo ""
echo "📁 Установка конфигов..."

# Niri
mkdir -p ~/.config/niri/cfg
cp -f "$DOTFILES_DIR/.config/niri/config.kdl" ~/.config/niri/config.kdl
cp -f "$DOTFILES_DIR/.config/niri/cfg/"*.kdl ~/.config/niri/cfg/
echo "  ✅ Niri"

# Alacritty
mkdir -p ~/.config/alacritty
cp -f "$DOTFILES_DIR/.config/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml
echo "  ✅ Alacritty"

# Noctalia
mkdir -p ~/.config/noctalia
cp -f "$DOTFILES_DIR/.config/noctalia/config.toml" ~/.config/noctalia/config.toml
echo "  ✅ Noctalia"

# Курсор
mkdir -p ~/.local/share/icons
cp -rf "$DOTFILES_DIR/cursors" ~/.local/share/icons/future-dark-cursors
echo "  ✅ Курсор (future-dark-cursors)"

# ─── Fish shell ───
echo ""
echo "🐚 Настройка Fish shell..."
if ! grep -q "fish" /etc/shells 2>/dev/null; then
    echo "$(which fish)" | sudo tee -a /etc/shells > /dev/null
fi
echo "  ✅ Fish добавлен в /etc/shells"
echo "  ⚠️  Чтобы сделать Fish основным: chsh -s $(which fish)"

# ─── Включение сервисов ───
echo ""
echo "🔧 Включение сервисов..."
if command -v systemctl &>/dev/null; then
    sudo systemctl enable --now NetworkManager 2>/dev/null || true
    sudo systemctl enable sddm 2>/dev/null || true
    echo "  ✅ NetworkManager, SDDM"
fi

echo ""
echo "╔══════════════════════════════════════╗"
echo "║           Готово! 🎉                    ║"
echo "╠══════════════════════════════════════╣"
echo "║ Перезайди в сессию для применения.    ║"
echo "║ Mod+Shift+Q → Выйти                   ║"
echo "╚══════════════════════════════════════╝"
