# AntigravityJP OS 別インストールガイド (Windows / macOS / Linux)

このドキュメントでは、**Windows**、**macOS**、**Linux** の各 OS 環境で `AntigravityJP` をインストールし、Antigravity の言語設定ファイルをすべて日本語化する手順を説明します。

---

## 前提条件

- **Antigravity / Antigravity IDE** がインストールされていること
- **Python 3.8 以上** がインストールされていること
  - GUI インストーラを使用する場合は `tkinter` が含まれていること（`tkinter` がない環境では自動的に対話型 CLI インストーラが起動します）
- （推奨）Antigravity IDE の拡張機能マーケットプレイスから `Japanese Language Pack for Visual Studio Code` (`ms-ceintl.vscode-language-pack-ja`) をインストールしておくと、`main.i18n.json` および `clp` キャッシュの統合翻訳も同時に行われます（未インストールの環境でも `nls.messages.json` と全拡張機能ファイルの直接日本語化が動作します）。

---

## 1. Windows でのインストール

### 方法 A: GUI インストーラ（推奨）
1. リリースファイル `AntigravityJP-v1.0.0-windows.zip` をダウンロードし、任意のフォルダに展開します。
2. フォルダ内の **`AntigravityJP_Setup.bat`** をダブルクリックします。
3. セットアップ ウィザードが表示されたら、**「インストール＆日本語化を実行」** ボタンをクリックします。
4. 完了メッセージが表示されたら、Antigravity IDE を再起動します。

### 方法 B: PowerShell コマンドライン
PowerShell を開き、展開したフォルダ内で以下を実行します：

```powershell
# サイレントインストール＆即時日本語化
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-AntigravityJP.ps1 -Silent

# 状態確認
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-AntigravityJP.ps1 -Status

# バックアップから英語原本に復元
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-AntigravityJP.ps1 -Restore

# アンインストール
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-AntigravityJP.ps1 -Uninstall
```

> [!NOTE]
> Antigravity IDE をシステム全体 (`C:\Program Files\Antigravity IDE`) にインストールしている場合は、PowerShell を「管理者として実行」してインストーラを起動してください。ユーザー領域 (`%LOCALAPPDATA%\Programs\Antigravity IDE`) の場合は通常権限で実行できます。

---

## 2. macOS でのインストール

### 方法 A: Finder からダブルクリックで起動（推奨）
1. リリースファイル `AntigravityJP-v1.0.0-macos.zip` をダウンロードして展開します。
2. macOS の Gatekeeper によって実行がブロックされる場合は、ターミナルで展開先フォルダに移動して検疫属性を解除します：
   ```bash
   xattr -cr .
   chmod +x AntigravityJP_Setup.command install.sh
   ```
3. Finder から **`AntigravityJP_Setup.command`** をダブルクリックします。
4. GUI ウィザード（またはターミナルの対話メニュー）で **「インストール＆日本語化を実行」** を選択します。

### 方法 B: ターミナルから実行
```bash
chmod +x install.sh
./install.sh --silent
```

> [!IMPORTANT]
> `/Applications/Antigravity IDE.app` の所有者が `root` になっている場合は、`sudo ./install.sh --silent` を使用するか、`--app-dir` でカスタムパスを指定してください。

---

## 3. Linux でのインストール

### 方法 A: シェルインストーラ (`install.sh`)
1. リリースファイル `AntigravityJP-v1.0.0-linux.tar.gz` をダウンロードして展開します：
   ```bash
   tar -xzf AntigravityJP-v1.0.0-linux.tar.gz
   cd AntigravityJP
   chmod +x install.sh
   ```
2. インストーラを実行します：
   ```bash
   # デスクトップ環境 (GUI または対話型 CLI)
   ./install.sh

   # サイレントインストール（/usr/share や /opt 配下を更新する場合は sudo を付与）
   sudo ./install.sh --silent
   ```

> [!TIP]
> Debian / Ubuntu 系で GUI インストーラ (`tkinter`) を使用する場合は `sudo apt install python3-tk` で導入できます。未導入でも自動的に対話型 CLI メニューでインストールできます。

### カスタムパスに Antigravity IDE を配置している場合
tarball 等で任意の場所に展開している場合は `--app-dir` オプションまたは環境変数 `ANTIGRAVITY_IDE_APP_DIR` で `resources/app` のパスを指定できます：

```bash
./install.sh --silent --app-dir "/path/to/Antigravity IDE/resources/app"
```

---

## 4. インストール後の会話トリガーの使い方

インストールによって作成された `AntigravityJP` プロジェクトフォルダ（Windows 既定: `Documents\Google\AntigravityJP`、macOS/Linux 既定: `~/AntigravityJP`）を Antigravity で開きます。

チャット欄で以下のように入力してください：
- **「翻訳」**
- **「日本語化」**
- **「言語設定ファイルの英語メッセージを日本語に翻訳して」**

これだけで Antigravity が [`scripts/translate_antigravity.py`](scripts/translate_antigravity.py) を自動実行し、未翻訳の英語メッセージをすべて日本語に翻訳・適用します。
