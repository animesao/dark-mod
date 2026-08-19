# 🖥️ My Dotfiles

Niri + Noctalia + Alacritty — Wayland tiling setup.

## What's included

| Config | Path |
|---|---|
| Niri (WM) | `.config/niri/` |
| Alacritty (terminal) | `.config/alacritty/` |
| Noctalia (shell) | `.config/noctalia/` |
| Cursor | `cursors/future-dark-cursors/` |

## Quick install

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

## Keybindings

See `Хоткеи.txt` on desktop or check `.config/niri/cfg/keybinds.kdl`.

| Key | Action |
|---|---|
| Mod+Return | Terminal |
| Mod+Ctrl+Left | App Launcher |
| Mod+S | Control Center |
| Mod+Q | Close window |
| Print | Screenshot (fullscreen) |
| Ctrl+Print | Screenshot (area select) |
| Alt+Print | Screenshot (window) |

## Supported distros

- CachyOS / Arch Linux (pacman)
- Ubuntu / Debian (apt)
- Fedora (dnf)

## Manual steps

After install:
- `chsh -s $(which fish)` — set Fish as default shell
- Re-login for cursor and theme changes
# dark-mod
