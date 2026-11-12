# Changelog

## [Ver1.1.0] - 2026-11-12

### Added
- **Windows / macOS / Linux マルチプラットフォーム対応インストーラー** (`AntigravityJP_Installer.py`, `install-windows.bat`, `AntigravityJP_Setup.command`, `install.sh`) を新規実装。
- **全言語設定ファイルの 100% 完全日本語化エンジン** (`scripts/translate_antigravity.py`) および **1,326 項目の日本語翻訳辞書** (`translations/ja_dictionary.json`) を搭載。
  - コア UI (`nls.messages.json` 全 16,558 件) の未翻訳残存 647 件を完全翻訳。
  - 日本語言語パック (`main.i18n.json`) に Antigravity 固有モジュール 1,228 キーを追加。
  - 組み込み拡張機能（全 101 個）とユーザー拡張機能の `package.nls.json` / `package.nls.ja.json` を完全日本語化。
  - CLP キャッシュ (`clp/*/nls.messages.json`) および `argv.json` (`"locale": "ja"`) の自動更新に対応。
- Windows 用バッチファイル (`install-windows.bat`, `AntigravityJP_Setup.bat`, `uninstall-windows.bat`) を Shift-JIS (`cp932`) + `CRLF` 形式に統一。
