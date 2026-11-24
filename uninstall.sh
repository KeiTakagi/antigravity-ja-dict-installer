#!/usr/bin/env bash
# ============================================================================
# Antigravity 日本語化 アンインストーラー Ver1.2.0 (macOS / Linux)
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$(uname -s)" = "Linux" ] && [ -f "${SCRIPT_DIR}/uninstall-linux.sh" ]; then
    chmod +x "${SCRIPT_DIR}/uninstall-linux.sh" 2>/dev/null || true
    exec "${SCRIPT_DIR}/uninstall-linux.sh" "$@"
fi
exec "${SCRIPT_DIR}/install.sh" --restore "$@"
