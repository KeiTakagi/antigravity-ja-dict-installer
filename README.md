# Antigravity 日本語化インストーラー Ver1.1.0（Windows / macOS / Linux 対応）

Google の AI 開発アプリ **「Antigravity」（デスクトップ版）** および **「Antigravity IDE」（エディタ版）** の双方を **100% 完全日本語化** し、**アプリの自動アップデートがあっても自動で日本語状態を維持する** 統合インストーラーパッケージです。

裏で重い常駐をする仕組みではないため、パソコンのメモリや CPU は消費しません。

---

## 💡 特徴・ハイライト

- **Antigravity デスクトップ版 & Antigravity IDE エディタ版の双方に対応**
  - デスクトップ版のメニューバー、設定画面（Settings）、Interface Layout、内蔵ブラウザ、音声設定、チャットUIを 100% 日本語化。
  - IDE エディタ版のコア UI（全 16,558 メッセージ）、言語パック、組み込み拡張機能（全 101 個）を 100% 日本語化。
- **完全自動アップデート追従（自動監視見張り役 Watcher）**
  - Antigravity がアップデートされて英語に戻っても、バックグラウンドの軽量見張り役が自動検知して即座にパッチを再適用します。
- **日本語辞書を大幅増強（1,200項目以上網羅）**
  - 最新バージョンに対応した日本語辞書を内包。
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
├── watcher.ps1                  ★ Windows アップデート自動監視スクリプト
├── patcher.js                   ★ app.asar パッチ適用エンジン
├── i18n_module.js               ★ UI リアルタイム日本語化 Mod
├── main_hook.js                 ★ メインプロセス通信フック
├── i18n_dict.json               ★ 日本語辞書（1,200項目以上）
├── install-linux.sh             ★ Linux用 インストーラー
├── uninstall-linux.sh           ★ Linux用 完全アンインストーラー
├── watcher.sh                   ★ Linux アップデート自動監視スクリプト
├── install.sh                   ★ macOS / Linux 共通インストーラー
├── uninstall.sh                 ★ macOS / Linux 共通アンインストーラー
├── AntigravityJP_Setup.command  ★ macOS用 インストーラー（ダブルクリックで実行）
├── AntigravityJP_Installer.py   ★ GUI / CLI インストーラー本体
├── マニュアル.html              ★ ブラウザで読める図解マニュアル
├── はじめにお読みください.txt    ★ メモ帳で読めるかんたん説明書
├── scripts/
│   └── translate_antigravity.py ★ IDE版 言語設定ファイル翻訳エンジン
├── translations/
│   └── ja_dictionary.json       ★ IDE版 翻訳辞書
├── INSTALL.md                   ★ 詳細インストール手順書
├── CHANGELOG.md                 ★ 更新履歴
└── README.md
```

---

## 🚀 インストール手順

### 🪟 Windows (Windows 10 / 11)
1. [Releases](https://github.com/KeiTakagi/antigravity-ja-dict-installer/releases) から `antigravity-ja-dict-installer.zip`（または `antigravity-ja-dict-installer-Ver1.1.0-windows.zip`）をダウンロードして **「すべて展開...」** します。
2. 展開したフォルダ内の **`install-windows.bat`** をダブルクリックして実行します。
3. 画面に `セットアップが完了しました！` と表示されたら完了です！
   - ※ Antigravity が起動中だった場合は、Antigravity を一度閉じて再起動すると自動的に日本語化されます。

### 🍎 macOS (Apple Silicon / Intel)
1. `antigravity-ja-dict-installer-Ver1.1.0-macos.zip` をダウンロードして展開します。
2. **`AntigravityJP_Setup.command`** をダブルクリックするか、ターミナルで `./install.sh` を実行します。

### 🐧 Linux (Ubuntu / Debian / Fedora / Arch 等)
1. `antigravity-ja-dict-installer-Ver1.1.0-linux.tar.gz` をダウンロードして展開します。
2. ターミナルで `./install-linux.sh`（または `./install.sh`）を実行します。

---

## 🔄 アンインストール（英語環境への復元）

- **Windows**: `uninstall-windows.bat` をダブルクリックして実行します。
- **Linux**: `./uninstall-linux.sh` を実行します。
- **macOS**: `./uninstall.sh` を実行します。

---

## 📄 ライセンス

MIT License
