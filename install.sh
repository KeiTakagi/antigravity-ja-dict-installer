#!/usr/bin/env bash
# ============================================================================
# Antigravity 日本語化インストーラー Ver1.1.0 (macOS / Linux)
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_PY="${SCRIPT_DIR}/AntigravityJP_Installer.py"

find_python() {
    for candidate in python3 python /opt/homebrew/bin/python3 /usr/local/bin/python3 /usr/bin/python3; do
        if command -v "${candidate}" >/dev/null 2>&1; then
            if "${candidate}" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)' >/dev/null 2>&1; then
                command -v "${candidate}"
                return 0
            fi
        fi
    done
    return 1
}

if ! PYTHON_BIN="$(find_python)"; then
    echo "[Error] Python 3.9 以上が見つかりません。Python 3 をインストールしてから再実行してください。" >&2
    exit 1
fi

export PYTHONUTF8=1
export PYTHONIOENCODING=utf-8

exec "${PYTHON_BIN}" "${INSTALLER_PY}" "$@"
