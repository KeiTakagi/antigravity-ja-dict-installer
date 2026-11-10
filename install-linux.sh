#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/antigravity-ja"

echo "========================================================"
echo "  Antigravity 日本語化インストーラー (Linux)"
echo "  (アップデート完全自動追従システム)"
echo "========================================================"
echo ""

EXE=""
if [ -f "/opt/Antigravity/antigravity" ]; then
    EXE="/opt/Antigravity/antigravity"
elif [ -f "${HOME}/.local/share/antigravity/antigravity" ]; then
    EXE="${HOME}/.local/share/antigravity/antigravity"
elif command -v antigravity >/dev/null 2>&1; then
    EXE="$(command -v antigravity)"
fi

mkdir -p "${DATA_DIR}"

# 1. Modプログラムファイル＆Watcherの配置
echo "[1/4] 日本語化Modプログラムとアップデート監視役を配置中..."
for f in "i18n_module.js" "main_hook.js" "patcher.js" "watcher.sh"; do
    if [ -f "${SCRIPT_DIR}/${f}" ]; then
        cp -f "${SCRIPT_DIR}/${f}" "${DATA_DIR}/${f}"
    fi
done
chmod +x "${DATA_DIR}/watcher.sh" 2>/dev/null || true

# 2. 辞書ファイル (i18n_dict.json) の配置・マージ
echo "[2/4] 日本語辞書ファイルを配置・マージ中..."
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

# 3. 初期パッチの適用
echo "[3/4] Antigravity 本体へ日本語パッチを適用中..."
PATCHER="${DATA_DIR}/patcher.js"
if [ -n "${EXE}" ] && [ -x "${EXE}" ] && [ -f "${PATCHER}" ]; then
    ELECTRON_RUN_AS_NODE=1 "${EXE}" "${PATCHER}" || echo "  -> パッチは次回起動時に適用されます"
    echo "  -> 日本語パッチの適用に成功しました！"
fi

# 4. アップデート監視役（Watcher）の自動起動登録
echo "[4/4] アップデート監視役（Watcher）を登録・起動中..."
AUTOSTART_DIR="${HOME}/.config/autostart"
mkdir -p "${AUTOSTART_DIR}"
cat <<EOF > "${AUTOSTART_DIR}/antigravity-ja-watcher.desktop"
[Desktop Entry]
Type=Application
Name=Antigravity Japanese Localization Watcher
Exec=/bin/bash "${DATA_DIR}/watcher.sh"
Terminal=false
NoDisplay=true
EOF

pkill -f "watcher.sh" 2>/dev/null || true
nohup /bin/bash "${DATA_DIR}/watcher.sh" >/dev/null 2>&1 &

echo ""
echo "========================================================"
echo "  セットアップが完了しました！"
echo "  Antigravity がアップデートされても自動で日本語が維持されます。"
echo "========================================================"
