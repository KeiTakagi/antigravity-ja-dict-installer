# Antigravity 日本語化インストーラー Ver1.2.2（Windows / macOS / Linux 対応）

[![Release](https://img.shields.io/badge/release-Ver1.2.2-blue.svg)](https://github.com/KeiTakagi/antigravity-ja-dict-installer/releases)
[![Antigravity](https://img.shields.io/badge/Antigravity-v2.35.1%20tested-brightgreen.svg)](https://antigravity.google)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-informational.svg)](./INSTALL.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

Google の AI 開発デスクトップアプリ **「Antigravity」** のメニューバー・設定画面（Settings）・チャット・通知・プラン表示・内蔵ブラウザ・音声設定まで、**全 1,580 項目（＋動的メッセージ対応）をワンクリックで日本語化** するインストーラーです。

> **💡 ポイント**
> - **パソコンが重くならない設計**：裏で動き続ける常駐監視プログラム（Watcher）を一切使わないため、CPU やメモリを消費しません。
> - **Antigravity デスクトップアプリ専用**：`Antigravity IDE`（VS Code エディタ版）の設定ファイルには一切手を加えません（完全除外・英語維持）。

---

## 📑 目次

1. [📋 動作環境・前提バージョン](#-動作環境前提バージョン)
2. [✨ 前回バージョンからの変更点（Ver1.2.2）](#-前回バージョンからの変更点ver122)
3. [📦 インストール方法](#-インストール方法)
   - [🪟 Windows のインストール手順](#-windows-のインストール手順)
   - [🍎 macOS のインストール手順](#-macos-のインストール手順)
   - [🐧 Linux のインストール手順](#-linux-のインストール手順)
4. [🚀 翻訳の仕方（基本の使い方）](#-翻訳の仕方基本の使い方)
   - [ケースA：インストーラーでアプリ全体を日本語に翻訳する](#ケースaインストーラーでアプリ全体を日本語に翻訳する)
   - [ケースB：アプリがアップデートされて英語に戻ったときに再翻訳する](#ケースbアプリがアップデートされて英語に戻ったときに再翻訳する)
   - [ケースC：自分好みの日本語訳を追加・変更する（リアルタイム反映）](#ケースc自分好みの日本語訳を追加変更するリアルタイム反映)
5. [🖼️ 実行例（翻訳前後の入出力イメージ）](#️-実行例翻訳前後の入出力イメージ)
6. [🔄 英語に戻す方法（アンインストール）](#-英語に戻す方法アンインストール)
7. [📁 フォルダ構成](#-フォルダ構成)
8. [📚 参考資料・出典](#-参考資料出典)

---

## 📋 動作環境・前提バージョン

本ツールの翻訳作業および動作検証は、以下のバージョンの `Antigravity` で実施しています。

| 項目 | バージョン・仕様 |
| :--- | :--- |
| **本ツールのバージョン** | **`Ver1.2.2`** (`1.2.2`) |
| **翻訳作業・動作確認済み Antigravity** | **Google Antigravity Desktop App `v2.35.1`**（`v2.35.0` / `v2.18.1` 〜 `v2.35.1` 対応確認済み） |
| **内蔵パッチャーエンジン** | `Antigravity UI Japanese Localization Mod v1.4.7` |
| **収録日本語翻訳辞書** | **`1,580 項目`**（`i18n_dict.json` ＋ 動的メッセージ正規表現ルール / リアルタイム Live reload 対応） |
| **対応 OS** | Windows 10 / 11 (x64 / ARM64)、macOS (Apple Silicon / Intel)、Linux (Ubuntu / Debian / Fedora / Arch 等) |
| **常駐監視プロセス (Watcher)** | **なし**（完全廃止・CPU / メモリ消費ゼロ） |
| **Antigravity IDE (VS Code 版)** | **対象外**（設定変更なし・完全除外） |

---

## ✨ 前回バージョンからの変更点（Ver1.2.2）

- **`Antigravity v2.35.0` / `v2.35.1` の設定画面（Settings）新規項目の網羅翻訳（+301 項目 → 計 1,580 項目）**
  - `Input Box`、`This computer`、`Chat`、`Conversation steps`、`Knowledge Work`、`Software Engineering`、`Notification settings`、`Font` / `Font size`、`Give Feedback`、`Show All`、`Orchestrator Settings`、`Dictation languages` など、設定画面の未訳項目を大幅に追加しました。
- **`WebContentsView` 対応 Live reload 修正（`main_hook.js` / `Mod v1.4.7`）**
  - `webContents.getAllWebContents()` へ辞書更新を配信するよう修正し、設定画面など子ビューに対しても辞書更新がリアルタイム反映されるようにしました。
- **プラン・利用上限・残り時間などの動的メッセージ翻訳ルールを拡充（`i18n_module.js`）**
  - `Your plan: ...`、`You can upgrade to a ... plan to receive higher rate limits.`、`Five Hour Limit Remaining`、`You have used some of your 5-hour limit, it will fully refresh in ...` など、数値やプラン名が動的に変化する英語メッセージにも対応しました。

詳細な履歴は **[CHANGELOG.md](./CHANGELOG.md)** を参照してください。

---

## 📦 インストール方法

お使いの OS に合わせて、以下のステップを順番に1つずつ進めてください。

### 🪟 Windows のインストール手順

#### 手順1：ZIP ファイルをダウンロードする
[Releases ページ](https://github.com/KeiTakagi/antigravity-ja-dict-installer/releases) から **`antigravity-ja-dict-installer.zip`**（または **`antigravity-ja-dict-installer-Ver1.2.2-windows.zip`**）をダウンロードします。

#### 手順2：ZIP ファイルを「すべて展開（解凍）」する
ダウンロードした ZIP ファイルを **右クリック** し、メニューから **「すべて展開...」** をクリックして展開します。

> **⚠️ 注意**
> ZIP ファイルを展開（解凍）せずに、ZIP の中身を直接ダブルクリックするとエラーになり正常に動作しません。必ず **「すべて展開...」** を実行してから次の手順に進んでください。

#### 手順3：インストーラー（`install-windows.bat`）をダブルクリックする
展開されて開いたフォルダの中にある **`install-windows.bat`**（または **`AntigravityJP_Setup.bat`**）をダブルクリックします。

> **💡 ポイント（「Windows によって PC が保護されました」と表示された場合）**
> 青い保護画面が出た場合は、画面内の **「詳細情報」** という文字をクリックし、右下に現れる **「実行」** ボタンをクリックしてください。

**PowerShell コマンドで直接インストールしたい場合（コピペ用）：**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1
```

---

### 🍎 macOS のインストール手順

#### 手順1：ZIP ファイルをダウンロードして展開する
`antigravity-ja-dict-installer-Ver1.2.2-macos.zip` をダウンロードし、ダブルクリックして展開します。

#### 手順2：ターミナルで実行権限を付与する
ターミナルを開き、展開したフォルダに移動して以下のコマンドをコピペして実行します。

```bash
xattr -cr .
chmod +x AntigravityJP_Setup.command install.sh uninstall.sh
```

#### 手順3：インストーラーを起動する
Finder から **`AntigravityJP_Setup.command`** をダブルクリックするか、ターミナルで以下のコマンドを実行します。

```bash
./install.sh
```

---

### 🐧 Linux のインストール手順

#### 手順1：アーカイブを展開する
ターミナルを開き、ダウンロードした `.tar.gz` ファイルを以下のコマンドで展開します。

```bash
tar -xzf antigravity-ja-dict-installer-Ver1.2.2-linux.tar.gz
cd antigravity-ja-dict-installer-Ver1.2.2
```

#### 手順2：実行権限を付与する
以下のコマンドをコピペして実行権限を付与します。

```bash
chmod +x install-linux.sh uninstall-linux.sh
```

#### 手順3：インストーラーを実行する
以下のコマンドを実行して日本語化を適用します。

```bash
./install-linux.sh
```

---

## 🚀 翻訳の仕方（基本の使い方）

インストールから日常の翻訳適用・アップデート時の再翻訳まで、3つのケース別に手順を説明します。

---

### ケースA：インストーラーでアプリ全体を日本語に翻訳する

#### 手順1：`install-windows.bat` を起動する
展開したフォルダの **`install-windows.bat`** をダブルクリックします（macOS は `./install.sh`、Linux は `./install-linux.sh`）。

#### 手順2：アプリ終了確認で `y` を入力する（Antigravity が起動中の場合のみ）
Antigravity が起動していると、黒い画面に終了確認が表示されます。キーボードで **`y`** を入力して **`Enter`** キーを押します。

```text
  [案内] Antigravity デスクトップアプリが現在起動中です。
  パッチを適用するために Antigravity を終了してよろしいですか？ (y/N): y
```

> **💡 ポイント**
> Antigravity をすでに閉じている状態で実行した場合は、この確認はスキップされ、即座にパッチが適用されます。

#### 手順3：起動確認で `Enter` キーを押して日本語版を起動する
約1秒で翻訳パッチと辞書（1,580項目）の組み込みが完了します。そのまま **`Enter`** キー（または `Y`）を押すと、日本語に翻訳された Antigravity が起動します。

```text
  Antigravity を日本語で起動しますか？ (Y/n): Y
```

---

### ケースB：アプリがアップデートされて英語に戻ったときに再翻訳する

Antigravity 本体が自動アップデートされると、アプリ内部のファイル（`app.asar`）が公式の英語ファイルに書き換わるため、表示が一度英語に戻ります。

#### 手順1：`install-windows.bat` をもう一度ダブルクリックする
先ほど展開したフォルダにある **`install-windows.bat`** をもう一度ダブルクリックする（またはコマンドラインで以下を実行する）だけで、数秒で再び日本語に翻訳されます。

```powershell
# Windows (コマンドラインから確認なしで一発再翻訳する場合)
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1 -Silent
```

```bash
# Linux / macOS で一発再翻訳する場合
./install-linux.sh
```

> **⚠️ 注意**
> `-Silent` オプションを使う場合は、あらかじめ Antigravity のウィンドウを「×」ボタンで閉じてから実行してください。

---

### ケースC：自分好みの日本語訳を追加・変更する（リアルタイム反映）

本ツールは、ユーザーのホームフォルダに配置されたカスタム辞書ファイル（`i18n_dict.json`）をリアルタイムに監視（Live reload）しています。

#### 手順1：カスタム辞書ファイルをテキストエディタで開く
お使いの OS の以下の場所にある `i18n_dict.json` をメモ帳やエディタで開きます。

```text
# Windows の辞書ファイル場所
C:\Users\<ユーザー名>\.gemini\antigravity\i18n_dict.json

# macOS / Linux の辞書ファイル場所
~/.gemini/antigravity/i18n_dict.json
```

#### 手順2：`"`英語原文`": "`日本語訳`"` を追記して保存する
JSON 形式で英語の原文と日本語訳を追加（または書き換え）して上書き保存します。

```json
{
  "Settings": "設定",
  "General": "一般",
  "Start New Conversation": "新しい会話を開始"
}
```

> **💡 ポイント**
> ファイルを保存した瞬間に、**Antigravity を再起動することなく開いている画面へ即座に新しい日本語訳が反映**されます。

---

## 🖼️ 実行例（翻訳前後の入出力イメージ）

### 1. インストーラー実行時の入出力イメージ

**【入力（実行コマンド）】**
```cmd
install-windows.bat
```

**【出力（コンソール画面の表示イメージ）】**
```text
========================================================
  Antigravity 日本語化インストーラー Ver1.2.2
  (Antigravity デスクトップ版 v2.35.1 対応セットアップ)
========================================================

Antigravity デスクトップ版の日本語化を構成中...
  -> 日本語辞書（1,580項目）を配置しました: C:\Users\<ユーザー名>\.gemini\antigravity\i18n_dict.json
  -> Antigravity 本体へ日本語化パッチを適用中...
  -> 日本語化パッチの適用に成功しました！
  -> デスクトップ ショートカットを作成・確認しました。

※ Antigravity IDE (エディタ版) は対象外のため設定変更は一切行いません（英語維持）。
※ 常駐監視プロセス（Watcher）は不要のため作成・常駐しません。

========================================================
  セットアップが完了しました！
  Antigravity デスクトップアプリの日本語化が完了しました。
  Antigravity を日本語で起動しますか？ (Y/n):
```

---

### 2. 翻訳前（英語）と翻訳後（日本語）の画面表示イメージ

パッチ適用後、Antigravity デスクトップアプリの各画面は以下のように英語から日本語へ翻訳されます。

| 画面箇所 | 翻訳前の表示（英語原文） | 翻訳後の表示（日本語出力） |
| :--- | :--- | :--- |
| **サイドバー / 会話** | `Start New Conversation` | **`新しい会話を開始`** |
| **設定メニュー** | `Settings` / `Input Box` / `This computer` | **`設定`** / **`入力欄`** / **`このコンピューター`** |
| **プラン・上限表示** | `Your plan: Google AI Pro` | **`現在のプラン: Google AI Pro`** |
| **利用上限通知** | `You have used some of your 5-hour limit, it will fully refresh in 3 hours, 49 minutes.` | **`5時間の上限の一部を使用しました。あと 3時間49分 で全回復します。`** |
| **エージェント設定** | `Auto-approve safe read-only tool calls` | **`安全な読み取り専用ツール呼び出しを自動承認`** |
| **内蔵ブラウザ設定** | `Built-in Browser` / `Clear Browser Data` | **`内蔵ブラウザ`** / **`ブラウザデータを消去`** |
| **アップデート通知** | `A new version is available.` | **`新しいバージョンが利用可能です。`** |
| **プロジェクト案内** | `A Google Cloud project is required to use Antigravity.` | **`Antigravity を使用するには Google Cloud プロジェクトが必要です。`** |

---

### 3. ステータス確認コマンドの入出力イメージ

正しく日本語化されているか確認したい場合は、以下のコマンドを実行します。

**【入力】**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1 -Status
```

**【出力】**
```text
========================================================
  Antigravity デスクトップアプリ日本語化 ステータス確認
========================================================
【Antigravity デスクトップ版】
  ・app.asar パッチ状態 : 適用済み (日本語)
  ・監視プロセス (Watcher): 常駐なし（削除済み・不要）
【Antigravity IDE エディタ版】
  ・IDE 設定           : 変更なし（完全除外・英語維持）
========================================================
```

---

## 🔄 英語に戻す方法（アンインストール）

元の公式英語状態に戻したい場合は、以下の手順で完全に復元できます。

### 手順1：アンインストーラーを実行する
お使いの OS に応じて以下を実行します。

**Windows の場合（`uninstall-windows.bat` をダブルクリック、または以下を実行）：**
```cmd
uninstall-windows.bat
```

**Linux の場合：**
```bash
./uninstall-linux.sh
```

**macOS の場合：**
```bash
./uninstall.sh
```

### 手順2：確認メッセージで `y` を入力する
`Are you sure you want to completely uninstall? (y/N)`（または日本語の確認）が表示されたら、**`y`** を入力して **`Enter`** キーを押します。

---

## 📁 フォルダ構成

```text
antigravity-ja-dict-installer/
├── install-windows.bat          ★ Windows用 インストーラー（ダブルクリックで実行 / Shift-JIS・CRLF）
├── AntigravityJP_Setup.bat      ★ Windows用 インストーラー（同上）
├── uninstall-windows.bat        ★ Windows用 アンインストーラー（英語環境へ復元）
├── install-windows.ps1          ★ Windows 自動化セットアップ本体
├── uninstall-windows.ps1        ★ Windows 完全アンインストール本体
├── patcher.js                   ★ app.asar パッチ適用エンジン (Mod v1.4.7)
├── i18n_module.js               ★ UI リアルタイム日本語化 Mod
├── main_hook.js                 ★ メインプロセス通信・辞書同期フック
├── i18n_dict.json               ★ 日本語辞書（1,580項目）
├── install-linux.sh             ★ Linux用 インストーラー
├── uninstall-linux.sh           ★ Linux用 完全アンインストーラー
├── install.sh                   ★ macOS / Linux 共通インストーラー
├── uninstall.sh                 ★ macOS / Linux 共通アンインストーラー
├── AntigravityJP_Setup.command  ★ macOS用 インストーラー（ダブルクリックで実行）
├── AntigravityJP_Installer.py   ★ GUI / CLI インストーラー本体
├── マニュアル.html              ★ ブラウザで読める初心者向け図解マニュアル
├── はじめにお読みください.txt    ★ メモ帳で読めるかんたん説明書
├── INSTALL.md                   ★ 詳細インストール＆使い方ガイド
├── CHANGELOG.md                 ★ 更新履歴
└── README.md                    ★ 本ドキュメント
```

---

## 📚 参考資料・出典

本ツールの開発およびドキュメント作成にあたり参考にした資料・仕様は以下の通りです。

- **Google Antigravity 公式ページ**: [https://antigravity.google](https://antigravity.google)
- **Electron ASAR Archive Format Specification**: [https://github.com/electron/asar](https://github.com/electron/asar)
- **Electron Process Model & Context Isolation / IPC Documentation**: [https://www.electronjs.org/docs/latest/tutorial/process-model](https://www.electronjs.org/docs/latest/tutorial/process-model)
- **Antigravity UI Japanese Localization Mod (`v1.4.7`)**: DOM MutationObserver 翻訳機構、WebContentsView Live reload 配信、および動的メッセージ正規表現ルール（`REGEX_RULES`）の実装・辞書構造

---

## 📄 ライセンス

MIT License
