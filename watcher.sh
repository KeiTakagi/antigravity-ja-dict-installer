#!/usr/bin/env bash
# watcher.sh (Linux)
# Antigravity 日本語化アップデート監視役
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/antigravity-ja"
PATCHER="${DATA_DIR}/patcher.js"
LOG_FILE="${DATA_DIR}/watcher.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_FILE}"
}

EXE=""
if [ -f "/opt/Antigravity/antigravity" ]; then
    EXE="/opt/Antigravity/antigravity"
    ASAR="/opt/Antigravity/resources/app.asar"
elif [ -f "${HOME}/.local/share/antigravity/antigravity" ]; then
    EXE="${HOME}/.local/share/antigravity/antigravity"
    ASAR="${HOME}/.local/share/antigravity/resources/app.asar"
elif command -v antigravity >/dev/null 2>&1; then
    EXE="$(command -v antigravity)"
    ASAR=""
fi

log "watcher launched (pid $$)"
MARKER="Antigravity UI Japanese Localization Mod"
OK_STAMP=""

while true; do
    if [ -n "${ASAR}" ] && [ -f "${ASAR}" ] && [ -f "${PATCHER}" ] && [ -x "${EXE}" ]; then
        STAMP=$(stat -c "%s-%Y" "${ASAR}" 2>/dev/null || stat -f "%z-%m" "${ASAR}" 2>/dev/null)
        if [ "$STAMP" != "$OK_STAMP" ]; then
            if grep -qF "$MARKER" "${ASAR}" 2>/dev/null; then
                OK_STAMP="$STAMP"
            else
                log "app.asar updated and unpatched -> applying patch"
                ELECTRON_RUN_AS_NODE=1 "${EXE}" "${PATCHER}" >> "${LOG_FILE}" 2>&1 || true
                OK_STAMP="$STAMP"
            fi
        fi
    fi
    sleep 15
done
