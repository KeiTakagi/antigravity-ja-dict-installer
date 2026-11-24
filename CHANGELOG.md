# Changelog

本プロジェクトにおけるバージョンごとの主な変更点・修正内容の履歴です。

---

## [Ver1.2.2] - 2026-11-25

### Added & Fixed (`Antigravity v2.35.1` 対応・設定画面網羅・動的翻訳強化)
- **翻訳作業・動作確認済み `Antigravity` バージョン (`v2.35.1`) への更新**
  - Google Antigravity Desktop App **`v2.35.1`**（先行確認 `v2.35.0` を含め `v2.18.1` 〜 `v2.35.1` 対応）での動作検証を完了し、日本語辞書を **1,279 項目 → 1,580 項目（+301 項目）** へ拡充。
- **設定画面（Settings）未訳項目の大規模追加**
  - `Input Box`、`This computer`、`Chat`、`Conversation steps`、`Knowledge Work`、`Software Engineering`、`Notification settings`、`Font` / `Font size`、`Give Feedback`、`Show All`、`Orchestrator Settings`、`Dictation languages` など `v2.35.0`〜`v2.35.1` の設定 UI 項目を網羅。
- **`WebContentsView` 対応 Live reload 配信の修正（`Mod v1.4.7`）**
  - `main_hook.js` が親ウィンドウだけでなく `webContents.getAllWebContents()` へ `i18n:dict-updated` を送信するよう修正し、設定画面など子ビューでも辞書変更が即座に反映されるよう改善。
- **プラン・利用上限・残り時間などの動的英語メッセージ対応（`REGEX_RULES` 拡充）**
  - `Your plan: <プラン名>`、`You can upgrade to a/an <プラン名> plan to receive higher rate limits.`、`Five Hour Limit Remaining`、`You have used some of your 5-hour limit, it will fully refresh in ...`、`Available AI credits: ...` などの動的パターンを追加。

---

## [Ver1.2.1] - 2026-11-24

### Added & Improved (Documentation & Usability)
- **翻訳作業・動作確認済み `Antigravity` バージョン (`v2.35.0`) の明記**
  - 翻訳辞書の作成およびパッチ適用検証を実施した **Google Antigravity Desktop App `v2.35.0`**（対応確認範囲：`v2.18.1` 〜 `v2.35.0`）、パッチャーエンジン (`Mod v1.4.4`)、収録日本語辞書 (`1,279 項目`) を概要および環境要件テーブルに明記。
- **初心者向け「📦 インストール方法」と「🚀 翻訳の仕方」ガイドの刷新**
  - 目次・絵文字付きセクション分けを導入し、1ステップにつき1操作のステップバイステップ形式（手順1・手順2・手順3）に統一。
  - コピペでそのまま使えるコマンドブロック、インストーラー実行時の入出力イメージ、翻訳前（英語）と翻訳後（日本語）の比較表、カスタム辞書によるリアルタイム翻訳追加手順を追記。
  - 初心者がつまずきやすい箇所（ZIP 未展開での実行や Windows SmartScreen 保護画面など）を `> **💡 ポイント**` / `> **⚠️ 注意**` の引用ブロックで視覚的に強調。
- **参考資料・出典セクションの追加**
  - Google Antigravity 公式サイト、Electron ASAR 仕様、Electron IPC / Preload プロセスモデル等の参考資料リンクを追記。

---

## [Ver1.2.0] - 2026-11-24

### Changed & Fixed
- **バックグラウンド常駐監視プロセス（Watcher）の完全廃止（CPU / メモリ消費ゼロ）**
  - `watcher.ps1` / `watcher.sh` および OS スタートアップ（Windows `Run` レジストリ / Linux `autostart`）への常駐登録を完全廃止。
  - 旧バージョンの常駐プロセスや自動起動登録が残っている環境でも、インストーラー実行時に自動検出して停止・削除するクリーンアップ機能を搭載。
- **Antigravity デスクトップアプリ専用化（Antigravity IDE の完全除外）**
  - 翻訳・パッチ対象を Google Antigravity デスクトップアプリ (`Antigravity.exe` / `resources/app.asar`) のみに厳格化し、Antigravity IDE (VS Code エディタ版) の設定は一切変更しない設計に統一。
- **起動中アプリの安全終了確認・ワンショットパッチ適用・再起動フローの実装**
  - Antigravity 起動中にファイルロックでパッチが当たらない問題を解消し、終了確認からパッチ適用・再起動までを一貫して行えるよう改善。

---

## [Ver1.1.0] - 2026-11-22

### Added
- **Windows / macOS / Linux マルチプラットフォーム対応インストーラー** を公開。
- **最新 UI 対応の日本語辞書（1,279 項目）および Mod v1.4.4** を収録（Live reload 対応）。
- Windows 用バッチファイル (`install-windows.bat`, `AntigravityJP_Setup.bat`, `uninstall-windows.bat`) を Shift-JIS (`cp932`) + `CRLF` 形式に統一。
