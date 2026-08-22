#!/bin/bash
# Daily system cleanup script
# Removes: package cache, build caches, thumbnails, trash, app caches
# NO sudo calls - runs fully unattended
#
# Статистика: очищает ~3-5 GB за запуск (зависит от накопленного кэша)

set -euo pipefail

LOG="/home/animesao/.local/share/log/cleanup.log"
mkdir -p "$(dirname "$LOG")"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG"
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - WARNING: $1" >> "$LOG"
    echo -e "${YELLOW}⚠${NC} $1"
}

get_size() {
    du -sb "$1" 2>/dev/null | cut -f1 || echo 0
}

TOTAL_FREED=0

freed() {
    local before=$1
    local after=$2
    local name=$3
    local diff=$((before - after))
    if [ "$diff" -gt 0 ]; then
        local mb=$((diff / 1024 / 1024))
        TOTAL_FREED=$((TOTAL_FREED + diff))
        log "$name: freed ${mb}MB"
    else
        log "$name: already clean"
    fi
}

echo -e "${GREEN}=== Daily Cleanup ===${NC}"
log "Starting cleanup..."
START_TIME=$(date +%s)

# ──────────────────────────────────────────────────────────
# 1. General ~/.cache cleanup
# ──────────────────────────────────────────────────────────

# AUR build cache (yay/paru)
BEFORE=$(get_size ~/.cache/yay)
rm -rf ~/.cache/yay/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/yay)" "AUR cache (yay)"

# Thumbnails
BEFORE=$(get_size ~/.cache/thumbnails)
rm -rf ~/.cache/thumbnails/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/thumbnails)" "Thumbnails"

# Font cache
BEFORE=$(get_size ~/.cache/fontconfig)
rm -rf ~/.cache/fontconfig/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/fontconfig)" "Font cache"

# GStreamer cache
BEFORE=$(get_size ~/.cache/gstreamer-1.0)
rm -rf ~/.cache/gstreamer-1.0/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/gstreamer-1.0)" "GStreamer cache"

# Mesa shader cache
BEFORE=$(get_size ~/.cache/mesa_shader_cache)
rm -rf ~/.cache/mesa_shader_cache/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/mesa_shader_cache)" "Mesa shader cache"

# Tracker3 (GNOME file indexer)
BEFORE=$(get_size ~/.cache/tracker3)
rm -rf ~/.cache/tracker3/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/tracker3)" "Tracker3 cache"

# Electron cache
BEFORE=$(get_size ~/.cache/electron)
rm -rf ~/.cache/electron/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/electron)" "Electron cache"

# Electron-builder cache
BEFORE=$(get_size ~/.cache/electron-builder)
rm -rf ~/.cache/electron-builder/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/electron-builder)" "Electron-builder cache"

# Wine prefix cache
BEFORE=$(get_size ~/.cache/wine)
rm -rf ~/.cache/wine/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/wine)" "Wine cache"

# Node-gyp cache (native module builds)
BEFORE=$(get_size ~/.cache/node-gyp)
rm -rf ~/.cache/node-gyp/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/node-gyp)" "node-gyp cache"

# Mozilla/Firefox cache
BEFORE=$(get_size ~/.cache/mozilla)
rm -rf ~/.cache/mozilla/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/mozilla)" "Mozilla cache"

# NVIDIA cache
BEFORE=$(get_size ~/.cache/nvidia)
rm -rf ~/.cache/nvidia/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/nvidia)" "NVIDIA cache"

# ORT cache (dependency analysis)
BEFORE=$(get_size ~/.cache/ort.pyke.io)
rm -rf ~/.cache/ort.pyke.io/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/ort.pyke.io)" "ORT cache"

# Zen browser cache
BEFORE=$(get_size ~/.cache/zen)
rm -rf ~/.cache/zen/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cache/zen)" "Zen browser cache"

# ──────────────────────────────────────────────────────────
# 2. Build tool caches
# ──────────────────────────────────────────────────────────

# Cargo/Rust cache (source code & git deps, keeps index)
BEFORE=$(get_size ~/.cargo/registry/src)
rm -rf ~/.cargo/registry/src/* ~/.cargo/registry/cache/* ~/.cargo/git/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.cargo/registry/src)" "Cargo/Rust cache"

# npm cache
BEFORE=$(get_size ~/.npm)
npm cache clean --force 2>/dev/null >> "$LOG" 2>&1
freed "$BEFORE" "$(get_size ~/.npm)" "npm cache"

# Bun cache
BEFORE=$(get_size ~/.bun/install/cache)
rm -rf ~/.bun/install/cache/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.bun/install/cache)" "Bun cache"

# Gradle cache
BEFORE=$(get_size ~/.gradle/caches)
rm -rf ~/.gradle/caches/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.gradle/caches)" "Gradle cache"

# Maven cache
BEFORE=$(get_size ~/.m2/repository)
rm -rf ~/.m2/repository/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.m2/repository)" "Maven cache"

# ──────────────────────────────────────────────────────────
# 3. Trash & temp files
# ──────────────────────────────────────────────────────────

# Trash
BEFORE=$(get_size ~/.local/share/Trash)
rm -rf ~/.local/share/Trash/* 2>/dev/null
freed "$BEFORE" "$(get_size ~/.local/share/Trash)" "Trash"

# Old /tmp files (>7 days, user-owned only)
find /tmp -maxdepth 1 -user "$(whoami)" -type f -atime +7 -delete 2>/dev/null

# ──────────────────────────────────────────────────────────
# 4. Summary
# ──────────────────────────────────────────────────────────

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
TOTAL_MB=$((TOTAL_FREED / 1024 / 1024))

echo ""
echo -e "${GREEN}=== Done! ===${NC}"
echo -e "Freed: ${GREEN}${TOTAL_MB}MB${NC} in ${DURATION}s"
log "Cleanup done! Freed ${TOTAL_MB}MB in ${DURATION}s"
