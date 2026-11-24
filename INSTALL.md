# Antigravity 日本語化インストーラー Ver1.2.0 インストールガイド (Windows / macOS / Linux)

このドキュメントでは、**Windows**、**macOS**、**Linux** の各 OS 環境で **Google Antigravity デスクトップアプリ** のメニュー・設定画面（Settings）・内蔵ブラウザ・音声設定・チャットUI（全 1,279 項目）を日本語化する手順を説明します。

> [!NOTE]
> - 本ツールは **Antigravity デスクトップアプリ** 専用です。Antigravity IDE (VS Code エディタ版) の設定は一切変更しません（完全除外・英語維持）。
> - バックグラウンドで常駐する監視プロセス（Watcher）は一切使用しないため、メモリや CPU を消費しません。

---

## 1. Windows でのインストール (Windows 10 / 11)

### 方法 A: バッチインストーラー（推奨）
1. リリースファイル `antigravity-ja-dict-installer.zip`（または `antigravity-ja-dict-installer-Ver1.2.0-windows.zip`）をダウンロードし、右クリックして **「すべて展開...」** を実行します。
2. 展開したフォルダ内の **`install-windows.bat`**（または **`AntigravityJP_Setup.bat`**）をダブルクリックします。
3. Antigravity が起動中の場合は、確認画面で `y` を入力すると安全に一度終了し、日本語化パッチと辞書（1,279項目）を適用して日本語表示で再起動します。

### 方法 B: PowerShell コマンドライン
PowerShell を開き、展開したフォルダ内で以下を実行します：

```powershell
# インストール＆日本語化適用
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1

# ステータス確認
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1 -Status

# 英語原本に復元（アンインストール）
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1 -Restore
```

---

## 2. macOS でのインストール (Apple Silicon / Intel)

1. リリースファイル `antigravity-ja-dict-installer-Ver1.2.0-macos.zip` をダウンロードして展開します。
2. macOS の Gatekeeper によって実行がブロックされる場合は、ターミナルで展開先フォルダに移動して検疫属性を解除します：
   ```bash
   xattr -cr .
   chmod +x AntigravityJP_Setup.command install.sh uninstall.sh
   ```
3. Finder から **`AntigravityJP_Setup.command`** をダブルクリックするか、ターミナルで `./install.sh` を実行します。

---

## 3. Linux でのインストール (Ubuntu / Debian / Fedora / Arch 等)

1. リリースファイル `antigravity-ja-dict-installer-Ver1.2.0-linux.tar.gz` をダウンロードして展開します：
   ```bash
   tar -xzf antigravity-ja-dict-installer-Ver1.2.0-linux.tar.gz
   cd antigravity-ja-dict-installer-Ver1.2.0
   chmod +x install-linux.sh uninstall-linux.sh
   ```
2. インストーラーを実行します：
   ```bash
   ./install-linux.sh
   ```

---

## 4. アンインストール（公式の英語環境への復元）

- **Windows**: `uninstall-windows.bat` をダブルクリックし、確認画面で `y` を入力します。
- **Linux**: `./uninstall-linux.sh` を実行します。
- **macOS**: `./uninstall.sh` を実行します。
