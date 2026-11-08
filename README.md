# Antigravity 日本語化インストーラー（Windows / Linux 対応）

Google の AI 開発アプリ「Antigravity」（デスクトップ版）を日本語化するための軽量インストーラーパッケージです。
常駐プロセスは一切なく、PC のメモリや CPU を消費しません。

---

## 📁 フォルダ構成
```text
antigravity-ja-dict-installer/
├── マニュアル.html              ★ ブラウザで読める図解マニュアル
├── はじめにお読みください.txt    ★ メモ帳で読めるかんたん説明書
├── install-windows.bat          ★ Windows用 インストーラー（ダブルクリックで実行）
├── install-windows.ps1          ★ Windows PowerShell用処理本体
├── uninstall-windows.bat        ★ Windows用 完全アンインストーラー
├── uninstall-windows.ps1        ★ Windows 完全アンインストール本体
├── install-linux.sh             ★ Linux用 インストーラー
├── uninstall-linux.sh           ★ Linux用 完全アンインストーラー
├── i18n_dict.json               ★ 日本語辞書（全71項目）
├── i18n_module.js / patcher.js / main_hook.js ★ Modプログラム
└── README.md
```

---

## 🚀 インストール手順

### 🪟 Windows の場合
1. `antigravity-ja-dict-installer.zip` を右クリックして **「すべて展開...」** を行います。
2. 展開したフォルダ内の **`install-windows.bat`** をダブルクリックして実行します。
3. 画面に `Setup completed successfully!` と表示されたらセットアップ完了です！

### 🐧 Linux の場合
ターミナルを開き、解凍フォルダで以下を実行します：
```bash
chmod +x install-linux.sh
./install-linux.sh
```

---

## 🗑️ 完全アンインストール（初期状態への復元）
- **Windows**: フォルダ内の **`uninstall-windows.bat`** をダブルクリックし、`y` を押します。
- **Linux**: ターミナルで `./uninstall-linux.sh` を実行し、`y` を押します。

アプリ本体および設定ファイルが、公式の初期状態（英語）に完全に戻ります。

---

## ⚠️ 免責事項・ライセンスについて (Disclaimer)

- **非公式ツール**: 本ツールは有志が作成した非公式（Unofficial）のローカライズツールであり、Google LLC との関係、提携、保証等はありません。
- **無保証・自己責任**: 本ツールの使用によって生じたいかなる損害（データ破損、アプリの不具合等）についても、作成者は一切の責任を負いかねます。自己責任にてご利用ください。
- **再配布の規約**: 本ツールには Antigravity 本体の実行ファイルや著作物は同梱されておらず、ローカル差分適用スクリプトおよび辞書データのみで構成されています。
- **謝辞**: 本ツールのパッチ機構および辞書ベースは、先行してコミュニティで Antigravity 日本語化 Mod を公開・共有してくださった有志の方々の知見を参考に作成されています。
