# Changelog

## [Ver1.2.0] - 2026-11-24

### Changed & Improved
- **バックグラウンド常駐監視プロセス（Watcher）の完全廃止**
  - `watcher.ps1` / `watcher.sh` および OS スタートアップ（Run レジストリ / autostart）への常駐登録を廃止し、旧バージョンの常駐プロセスや登録が存在する場合は自動でクリーンアップする仕組みを追加。
- **Antigravity デスクトップアプリ専用化（Antigravity IDE の完全除外）**
  - 対象を Google Antigravity デスクトップアプリ (`Antigravity.exe` / `app.asar`) のみに厳格化し、Antigravity IDE (VS Code エディタ版) の設定変更を一切行わない安全設計に統一。
- **起動中アプリの自動終了確認・ワンショットパッチ適用・再起動フローの改善**
  - Antigravity 起動中にインストーラーを実行した場合も、安全に終了・パッチ適用・日本語での再起動までを対話的に完了できるよう改善。
- **最新 UI 対応の日本語辞書（1,279 項目）および Mod v1.4.4 を収録**
  - メニュー、Settings、Interface Layout、内蔵ブラウザ、音声設定、チャット画面の日本語化辞書（Live reload 対応）を更新。
- **不要ファイルの整理とパッケージ構造のスリム化**

## [Ver1.1.0] - 2026-11-22

### Added
- Windows / macOS / Linux マルチプラットフォーム対応パッケージと 1,279 項目の日本語辞書を公開。
