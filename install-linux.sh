#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/antigravity-ja"

echo "========================================================"
echo "  Antigravity 日本語化インストーラー (Linux)"
echo "========================================================"
echo ""

# 1. Antigravity 実行ファイルの探索
EXE=""
if [ -f "/opt/Antigravity/antigravity" ]; then
    EXE="/opt/Antigravity/antigravity"
elif [ -f "${HOME}/.local/share/antigravity/antigravity" ]; then
    EXE="${HOME}/.local/share/antigravity/antigravity"
elif command -v antigravity >/dev/null 2>&1; then
    EXE="$(command -v antigravity)"
fi

mkdir -p "${DATA_DIR}"

# 2. Modプログラムファイルの配置
echo "[1/3] 日本語化Modファイルを配置中..."
for f in "i18n_module.js" "main_hook.js" "patcher.js"; do
    if [ -f "${SCRIPT_DIR}/${f}" ]; then
        cp -f "${SCRIPT_DIR}/${f}" "${DATA_DIR}/${f}"
    fi
done

# 3. 辞書ファイル (i18n_dict.json) の配置・マージ
echo "[2/3] 日本語辞書ファイルを配置・マージ中..."
SRC_DICT="${SCRIPT_DIR}/i18n_dict.json"
DEST_DICT_DIR="${HOME}/.gemini/antigravity"
DEST_DICT="${DEST_DICT_DIR}/i18n_dict.json"
mkdir -p "${DEST_DICT_DIR}"

if [ -f "${DEST_DICT}" ]; then
    MERGED=0
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import json
try:
    with open('${DEST_DICT}', 'r', encoding='utf-8') as f: d1 = json.load(f)
    with open('${SRC_DICT}', 'r', encoding='utf-8') as f: d2 = json.load(f)
    d1.update(d2)
    with open('${DEST_DICT}', 'w', encoding='utf-8') as f: json.dump(d1, f, ensure_ascii=False, indent=2)
    print('  -> 既存の辞書とマージ完了（登録数:', len(d1), '）')
except Exception:
    exit(1)
" && MERGED=1
    fi
    if [ $MERGED -eq 0 ]; then
        cp -f "${SRC_DICT}" "${DEST_DICT}"
        echo "  -> 辞書を配置しました"
    fi
else
    cp -f "${SRC_DICT}" "${DEST_DICT}"
    echo "  -> 辞書を新規配置しました"
fi

# 4. 初期パッチの適用
echo "[3/3] Antigravity 本体へ日本語パッチを適用中..."
PATCHER="${DATA_DIR}/patcher.js"
if [ -n "${EXE}" ] && [ -x "${EXE}" ] && [ -f "${PATCHER}" ]; then
    ELECTRON_RUN_AS_NODE=1 "${EXE}" "${PATCHER}" || echo "  -> パッチは次回起動時に適用されます"
    echo "  -> 日本語パッチの適用に成功しました！"
else
    echo "  -> 実行ファイルが見つからないため、辞書のみ配置しました。"
fi

echo ""
echo "========================================================"
echo "  セットアップが完了しました！"
echo "  Antigravity を起動して日本語化をご確認ください。"
echo "========================================================"
