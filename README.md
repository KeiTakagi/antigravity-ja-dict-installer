# Antigravity 日本語化インストーラー Ver1.2.0（Windows / macOS / Linux 対応）

Google の AI 開発アプリ **「Antigravity」**（デスクトップ版）をメニュー・設定画面（Settings）・Interface Layout・内蔵ブラウザ・音声設定・チャット画面までまとめて **100% 日本語化（1,279項目）** するインストーラーパッケージです。

バックグラウンドで常駐する監視プロセス（Watcher）やデーモンを一切使用しないクリーン設計のため、パソコンのメモリや CPU を一切消費しません。
※ 本ツールは **Antigravity デスクトップアプリ専用** です。Antigravity IDE (VS Code エディタ版) の設定は一切変更しません（完全除外・英語維持）。

---

## 💡 Ver1.2.0 の特徴・ハイライト

- **Antigravity デスクトップアプリの完全日本語化（Mod v1.4.4 + 1,279項目辞書）**
  - メニューバー、設定画面（Settings）、Interface Layout、内蔵ブラウザ、音声設定、チャットUIを 100% 日本語化。Live reload にも対応。
- **常駐プロセス完全廃止（CPU / メモリ消費ゼロ）**
  - Ver1.2.0 ではバックグラウンド常駐監視スクリプト（Watcher）やスタートアップ自動起動登録を完全廃止し、必要な時だけ一瞬でパッチを適用して即終了するクリーンな方式に刷新しました。
- **起動中アプリの安全自動再起動＆パッチ適用に対応**
  - Antigravity が起動中でも、インストーラーが安全に終了確認からパッチ適用・再起動までをワンストップで実行します。
- **Antigravity IDE (VS Code エディタ版) の設定変更なし（完全除外）**
  - エディタ版の環境や設定には一切手を加えません。
- **完全アンインストール対応**
  - 不要になった場合はワンクリックで公式の初期状態（英語）に完全復元できます。

---

## 📁 フォルダ構成

```text
antigravity-ja-dict-installer/
├── install-windows.bat          ★ Windows用 インストーラー（ダブルクリックで実行 / Shift-JIS・CRLF）
├── AntigravityJP_Setup.bat      ★ Windows用 インストーラー（同上）
├── uninstall-windows.bat        ★ Windows用 アンインストーラー（英語環境へ復元）
├── install-windows.ps1          ★ Windows 自動化セットアップ本体
├── uninstall-windows.ps1        ★ Windows 完全アンインストール本体
├── patcher.js                   ★ app.asar パッチ適用エンジン (Mod v1.4.4)
├── i18n_module.js               ★ UI リアルタイム日本語化 Mod
├── main_hook.js                 ★ メインプロセス通信・辞書同期フック
├── i18n_dict.json               ★ 日本語辞書（1,279項目）
├── install-linux.sh             ★ Linux用 インストーラー
├── uninstall-linux.sh           ★ Linux用 完全アンインストーラー
├── install.sh                   ★ macOS / Linux 共通インストーラー
├── uninstall.sh                 ★ macOS / Linux 共通アンインストーラー
├── AntigravityJP_Setup.command  ★ macOS用 インストーラー（ダブルクリックで実行）
├── AntigravityJP_Installer.py   ★ GUI / CLI インストーラー本体
├── マニュアル.html              ★ ブラウザで読める図解マニュアル
├── はじめにお読みください.txt    ★ メモ帳で読めるかんたん説明書
├── INSTALL.md                   ★ 詳細インストール手順書
├── CHANGELOG.md                 ★ 更新履歴
└── README.md
```

---

## 🚀 インストール手順

### 🪟 Windows (Windows 10 / 11)
1. [Releases](https://github.com/KeiTakagi/antigravity-ja-dict-installer/releases) から `antigravity-ja-dict-installer.zip`（または `antigravity-ja-dict-installer-Ver1.2.0-windows.zip`）をダウンロードして **「すべて展開...」** します。
2. 展開したフォルダ内の **`install-windows.bat`** をダブルクリックして実行します。
3. 画面に `セットアップが完了しました！` と表示されたら完了です！

### 🍎 macOS (Apple Silicon / Intel)
1. `antigravity-ja-dict-installer-Ver1.2.0-macos.zip` をダウンロードして展開します。
2. **`AntigravityJP_Setup.command`** をダブルクリックするか、ターミナルで `./install.sh` を実行します。

### 🐧 Linux (Ubuntu / Debian / Fedora / Arch 等)
1. `antigravity-ja-dict-installer-Ver1.2.0-linux.tar.gz` をダウンロードして展開します。
2. ターミナルで `./install-linux.sh`（または `./install.sh`）を実行します。

---

## 🔄 アンインストール（英語環境への復元）

- **Windows**: `uninstall-windows.bat` をダブルクリックして実行します。
- **Linux**: `./uninstall-linux.sh` を実行します。
- **macOS**: `./uninstall.sh` を実行します。

---

## 📄 ライセンス

MIT License
