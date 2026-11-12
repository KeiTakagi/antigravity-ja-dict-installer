#!/usr/bin/env bash
# ============================================================================
# Antigravity 日本語化インストーラー Ver1.1.0 (macOS ダブルクリック起動用)
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"${SCRIPT_DIR}/install.sh" "$@"
EXIT_CODE=$?
if [ ${EXIT_CODE} -ne 0 ]; then
    echo ""
    read -r -p "エラーが発生しました。Enter キーを押してウィンドウを閉じます..." _
fi
exit ${EXIT_CODE}
