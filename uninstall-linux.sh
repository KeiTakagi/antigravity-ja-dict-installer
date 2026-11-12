#!/usr/bin/env bash
# ============================================================================
# Antigravity 日本語化 アンインストーラー Ver1.1.0 (macOS / Linux)
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/install.sh" --restore "$@"
