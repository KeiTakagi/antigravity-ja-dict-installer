# Antigravity 日本語化インストーラー Ver1.2.1 インストール＆翻訳ガイド

このガイドでは、初めて触れる初心者の方でも迷わず実行できるよう、**「📦 インストール方法」** と **「🚀 翻訳の仕方（基本の使い方）」** を 1 ステップ＝1 操作の形式で丁寧に解説します。

---

## 📋 動作環境・前提バージョン

| 項目 | バージョン・仕様 |
| :--- | :--- |
| **リリースバージョン** | **`Ver1.2.1`** (`1.2.1`) |
| **翻訳作業・動作確認済み Antigravity** | **Google Antigravity Desktop App `v2.35.0`**（`v2.18.1` 〜 `v2.35.0` 対応） |
| **内蔵パッチャーエンジン** | `Antigravity UI Japanese Localization Mod v1.4.4` |
| **収録日本語翻訳辞書** | **`1,279 項目`**（`i18n_dict.json` / Live reload 対応） |
| **常駐監視プロセス (Watcher)** | **なし**（完全廃止・CPU / メモリ消費ゼロ） |
| **Antigravity IDE (VS Code 版)** | **対象外**（設定変更なし・完全除外） |

---

## 📦 インストール方法

### 🪟 Windows (Windows 10 / 11)

#### 手順1：ZIP ファイルをダウンロードする
GitHub Releases から **`antigravity-ja-dict-installer.zip`**（または **`antigravity-ja-dict-installer-Ver1.2.1-windows.zip`**）をダウンロードします。

#### 手順2：ZIP ファイルを「すべて展開」する
ダウンロードした ZIP ファイルを **右クリック** し、**「すべて展開...」** をクリックして展開します。

> **⚠️ 注意**
> ZIP ファイルを展開せずに中身を直接ダブルクリックするとエラーになります。必ず **「すべて展開...」** を行ってください。

#### 手順3：`install-windows.bat` をダブルクリックする
展開したフォルダ内の **`install-windows.bat`**（または **`AntigravityJP_Setup.bat`**）をダブルクリックします。

> **💡 ポイント（「Windows によって PC が保護されました」と表示された場合）**
> 画面内の **「詳細情報」** をクリックし、右下に表示される **「実行」** ボタンをクリックしてください。

---

### 🍎 macOS (Apple Silicon / Intel)

#### 手順1：ZIP ファイルを展開する
ダウンロードした `antigravity-ja-dict-installer-Ver1.2.1-macos.zip` をダブルクリックして展開します。

#### 手順2：検疫属性の解除と実行権限の付与を行う
ターミナルを開き、展開したフォルダで以下のコマンドをコピペして実行します。

```bash
xattr -cr .
chmod +x AntigravityJP_Setup.command install.sh uninstall.sh
```

#### 手順3：インストーラーを実行する
Finder から **`AntigravityJP_Setup.command`** をダブルクリックするか、ターミナルで以下を実行します。

```bash
./install.sh
```

---

### 🐧 Linux (Ubuntu / Debian / Fedora / Arch 等)

#### 手順1：アーカイブを展開する
ターミナルで以下のコマンドを実行して展開します。

```bash
tar -xzf antigravity-ja-dict-installer-Ver1.2.1-linux.tar.gz
cd antigravity-ja-dict-installer-Ver1.2.1
```

#### 手順2：実行権限を付与する
```bash
chmod +x install-linux.sh uninstall-linux.sh
```

#### 手順3：インストーラーを実行する
```bash
./install-linux.sh
```

---

## 🚀 翻訳の仕方（基本の使い方）

### 手順1：インストーラーを起動する
Windows は **`install-windows.bat`** をダブルクリック、macOS は `./install.sh`、Linux は `./install-linux.sh` を実行します。

### 手順2：起動中の Antigravity を自動終了させる（起動中の場合のみ）
Antigravity が起動中の場合は以下の確認が表示されます。**`y`** を入力して **`Enter`** キーを押します。

```text
  [案内] Antigravity デスクトップアプリが現在起動中です。
  パッチを適用するために Antigravity を終了してよろしいですか？ (y/N): y
```

### 手順3：日本語化された Antigravity を起動する
パッチ適用完了後、以下のメッセージで **`Enter`** キーを押すと日本語表示で起動します。

```text
  Antigravity を日本語で起動しますか？ (Y/n): Y
```

> **💡 ポイント（アプリが自動アップデートされて英語に戻った場合）**
> Antigravity 本体がアップデートされて英語に戻ったときは、もう一度 **`install-windows.bat`** をダブルクリックするだけで、数秒で再び日本語に翻訳されます。

---

## 🖼️ 実行例（翻訳前後の比較イメージ）

| 画面箇所 | 翻訳前の入力（英語原文） | 翻訳後の出力（日本語表示） |
| :--- | :--- | :--- |
| **会話開始ボタン** | `Start New Conversation` | **`新しい会話を開始`** |
| **設定画面ヘッダー** | `Settings` / `General` | **`設定`** / **`一般`** |
| **レイアウト設定** | `Interface Layout` | **`インターフェースレイアウト`** |
| **ブラウザ設定** | `Built-in Browser` | **`内蔵ブラウザ`** |
| **更新メッセージ** | `A new version is available.` | **`新しいバージョンが利用可能です。`** |

---

## 🔄 英語に戻す方法（アンインストール）

**Windows の場合：**
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

---

## 📚 参考資料・出典

- [Google Antigravity 公式ページ](https://antigravity.google)
- [Electron ASAR Archive Format Specification (`electron/asar`)](https://github.com/electron/asar)
- [Electron Process Model & Context Isolation / IPC Documentation](https://www.electronjs.org/docs/latest/tutorial/process-model)
- Antigravity UI Japanese Localization Mod (`v1.4.4`) コミュニティローカライズ知見
