# Antigravity 日本語化インストーラー Ver1.1.0（Windows / macOS / Linux 対応）

Google の AI 開発アプリ **「Antigravity / Antigravity IDE」** で表示される言語設定ファイル内の英語メッセージを **100% 日本語化** するマルチプラットフォーム・インストーラーです。

裏で常駐して動き続ける仕組みではないため、**パソコンのメモリや CPU は一切消費しません**。

---

## ✨ Ver1.1.0 の主な進化点

- **Windows / macOS / Linux の 3 OS 完全対応**
  - GUI セットアップ ウィザード・対話型 CLI・ワンライナー (`--silent`) のすべてに対応。
- **言語設定ファイル全項目の 100% 完全日本語化（全 1,326 辞書項目・16,558 UI メッセージ網羅）**
  - コア UI (`nls.messages.json`: 全 16,558 件) の未翻訳残存 647 件をすべて自然な日本語に翻訳。
  - 日本語言語パック (`main.i18n.json`) に欠落していた Antigravity 固有モジュール（Agent, Walkthrough, Browser, Terminal, Chat 等）全 1,228 キーを追加。
  - 組み込み拡張機能（全 101 個: `agy`, `antigravity-code-executor`, `antigravity-dev-containers`, `antigravity-remote-openssh`, `antigravity-remote-wsl` 等）およびユーザー拡張機能の `package.nls.json` / `package.nls.ja.json` を完全日本語化。
  - コンパイル済み言語パック キャッシュ (`clp/*/nls.messages.json`) と `argv.json` (`"locale": "ja"`) を自動更新。
- **安全設計（自動バックアップ＆ワンクリック完全復元）**
  - 変更前の全ファイルを `backups/` に自動保存し、いつでも初期状態（英語）へ完全復元できます。

---

## 📁 フォルダ構成

```text
antigravity-ja-dict-installer/
├── install-windows.bat          ★ Windows用 インストーラー（ダブルクリックで実行 / Shift-JIS・CRLF）
├── AntigravityJP_Setup.bat      ★ Windows用 インストーラー（同上）
├── uninstall-windows.bat        ★ Windows用 アンインストーラー（英語環境へ復元）
├── install-windows.ps1          ★ Windows PowerShell セットアップスクリプト
├── AntigravityJP_Setup.command  ★ macOS用 インストーラー（Finder からダブルクリックで実行）
├── install.sh                   ★ macOS / Linux 共通インストーラー
├── uninstall.sh                 ★ macOS / Linux 共通アンインストーラー
├── AntigravityJP_Installer.py   ★ マルチプラットフォーム GUI / CLI インストーラー本体
├── scripts/
│   └── translate_antigravity.py ★ 全言語設定ファイル一括翻訳エンジン
├── translations/
│   └── ja_dictionary.json       ★ 日本語翻訳辞書（全 1,326 項目）
├── INSTALL.md                   ★ OS別 詳細インストール手順書
├── CHANGELOG.md                 ★ 更新履歴
└── README.md
```

---

## 🚀 インストール手順

### 🪟 Windows (Windows 10 / 11)
1. [Releases](https://github.com/KeiTakagi/antigravity-ja-dict-installer/releases) から `antigravity-ja-dict-installer-Ver1.1.0-windows.zip`（または `antigravity-ja-dict-installer.zip`）をダウンロードして **「すべて展開...」** します。
2. 展開したフォルダ内の **`install-windows.bat`**（または **`AntigravityJP_Setup.bat`**）をダブルクリックして実行します。
3. セットアップ画面の **「日本語化を実行 (推奨)」** をクリックします。
4. 完了メッセージが表示されたら、Antigravity IDE を再起動してください。

### 🍎 macOS (Apple Silicon / Intel)
1. [Releases](https://github.com/KeiTakagi/antigravity-ja-dict-installer/releases) から `antigravity-ja-dict-installer-Ver1.1.0-macos.zip` をダウンロードして展開します。
2. **`AntigravityJP_Setup.command`** をダブルクリックするか、ターミナルで以下を実行します：
   ```bash
   chmod +x install.sh AntigravityJP_Setup.command
   ./install.sh
   ```

### 🐧 Linux (Ubuntu / Debian / Fedora / Arch 等)
1. [Releases](https://github.com/KeiTakagi/antigravity-ja-dict-installer/releases) から `antigravity-ja-dict-installer-Ver1.1.0-linux.tar.gz` をダウンロードして展開し、`install.sh` を実行します：
   ```bash
   tar -xzf antigravity-ja-dict-installer-Ver1.1.0-linux.tar.gz
   cd antigravity-ja-dict-installer-Ver1.1.0
   ./install.sh
   ```

---

## 🔄 アンインストール（英語環境への復元）

- **Windows**: `uninstall-windows.bat` をダブルクリックするか、インストーラー画面の「英語に復元 (アンインストール)」をクリックします。
- **macOS / Linux**: `./uninstall.sh`（または `./install.sh --restore`）を実行します。

---

## 📄 ライセンス

MIT License
