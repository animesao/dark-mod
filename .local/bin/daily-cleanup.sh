#!/bin/bash
# Daily system cleanup script
# Removes: package cache, npm cache, thumbnails, trash, old logs

LOG="/home/animesao/.local/share/log/cleanup.log"
mkdir -p "$(dirname "$LOG")"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting cleanup..." >> "$LOG"

# 1. Package cache (non-interactive)
yes | yay -Scc 2>/dev/null >> "$LOG" 2>&1

# 2. npm cache
npm cache clean --force 2>/dev/null >> "$LOG" 2>&1

# 3. Thumbnails
rm -rf ~/.cache/thumbnails/* 2>/dev/null

# 4. Trash
rm -rf ~/.local/share/Trash/* 2>/dev/null

# 5. Old logs (keep 3 days)
sudo journalctl --vacuum-time=3d 2>/dev/null >> "$LOG" 2>&1

# 6. Font cache
rm -rf ~/.cache/fontconfig/* 2>/dev/null

# 7. GStreamer cache
rm -rf ~/.cache/gstreamer-1.0/* 2>/dev/null

# 8. Mesa shader cache
rm -rf ~/.cache/mesa_shader_cache/* 2>/dev/null

echo "$(date '+%Y-%m-%d %H:%M:%S') - Cleanup done!" >> "$LOG"
