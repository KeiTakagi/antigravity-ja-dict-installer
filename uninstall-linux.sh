#!/usr/bin/env bash
set -e

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/antigravity-ja"

echo "========================================================"
echo "  Antigravity 日本語化 完全アンインストーラー (Linux)"
echo "========================================================"
echo ""
echo "この操作を行うと、日本語化Mod、監視役プロセス、カスタム辞書を削除し、"
echo "Antigravity を公式の初期状態（英語）に戻します。"
echo ""
read -r -p "本当に完全にアンインストールしますか？ (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[yY]$ ]]; then
    echo "アンインストールをキャンセルしました。"
    exit 0
fi

echo ""

# 1. 実行ファイルの探索
EXE=""
if [ -f "/opt/Antigravity/antigravity" ]; then
    EXE="/opt/Antigravity/antigravity"
elif [ -f "${HOME}/.local/share/antigravity/antigravity" ]; then
    EXE="${HOME}/.local/share/antigravity/antigravity"
elif command -v antigravity >/dev/null 2>&1; then
    EXE="$(command -v antigravity)"
fi

# 2. 監視プロセスの停止と自動起動の削除
echo "[1/4] 監視役プロセスを停止・解除中..."
pkill -f "watcher.sh" 2>/dev/null || true
rm -f "${HOME}/.config/autostart/antigravity-ja-watcher.desktop"

# 3. アプリ本体の復元
echo "[2/4] アプリ本体（app.asar）を元の公式状態へ復元中..."
pkill -f "Antigravity" 2>/dev/null || true
pkill -f "antigravity" 2>/dev/null || true
sleep 1

PATCHER="${DATA_DIR}/patcher.js"
if [ -n "${EXE}" ] && [ -x "${EXE}" ] && [ -f "${PATCHER}" ]; then
    ELECTRON_RUN_AS_NODE=1 "${EXE}" "${PATCHER}" --restore || true
    echo "  -> 公式状態への復元処理を実行しました。"
fi

# 4. データ・辞書・スキルの削除
echo "[3/4] 辞書ファイルおよび Mod 設定フォルダーを削除中..."
rm -rf "${DATA_DIR}"
rm -f "${HOME}/.gemini/antigravity/i18n_dict.json"
rm -rf "${HOME}/.gemini/config/skills/antigravity-ja"
echo "  -> 辞書およびキャッシュ設定を削除しました。"

echo "[4/4] クリーンアップ完了。"
echo ""
echo "========================================================"
echo "  完全アンインストールが正常に完了しました。"
echo "  Antigravity は公式の初期状態（英語）に戻りました。"
echo "========================================================"
