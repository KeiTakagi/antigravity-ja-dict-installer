<#
.SYNOPSIS
    Antigravity デスクトップアプリ日本語化インストーラー Ver1.2.1 (Windows PowerShell)
.DESCRIPTION
    Google の AI アプリ「Antigravity」（デスクトップ版 v2.35.0 対応）を完全日本語化します。
    ※ Antigravity IDE (VS Code エディタ版) は設定変更せず対象外（除外・英語維持）とします。
    ※ 常駐監視プロセス（Watcher）は使用しません。
#>
param(
    [switch]$Silent,
    [switch]$Cli,
    [string]$AppDir = "",
    [switch]$Status,
    [switch]$Restore
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

$dataDir = Join-Path $env:LOCALAPPDATA "antigravity-ja"
$desktopExeDir = Join-Path $env:LOCALAPPDATA "Programs\antigravity"
$desktopExe = Join-Path $desktopExeDir "Antigravity.exe"
$desktopAsar = Join-Path $desktopExeDir "resources\app.asar"
$patcherScript = Join-Path $dataDir "patcher.js"

# -------------------------------------------------------------
# 監視プロセス (Watcher) の停止・登録削除ヘルパー
# -------------------------------------------------------------
function Clear-Watcher {
    # 稼働中の監視プロセスを停止
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
        Where-Object { $_.CommandLine -like "*antigravity-ja\watcher.ps1*" } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
    # Run レジストリから削除
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AntigravityJaWatcher" -Force -ErrorAction SilentlyContinue
    # 不要な watcher スクリプトを削除
    @("watcher.ps1", "watcher.sh", "watcher.log", "watcher.log.old") | ForEach-Object {
        $p = Join-Path $dataDir $_
        if (Test-Path $p) { Remove-Item $p -Force -ErrorAction SilentlyContinue }
    }
}

# -------------------------------------------------------------
# 復元 (アンインストール) モード
# -------------------------------------------------------------
if ($Restore) {
    $uninstallScript = Join-Path $scriptDir "uninstall-windows.ps1"
    if (Test-Path $uninstallScript) {
        & $uninstallScript
        exit $LASTEXITCODE
    }
}

# -------------------------------------------------------------
# ステータス確認モード
# -------------------------------------------------------------
if ($Status) {
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "  Antigravity デスクトップアプリ日本語化 ステータス確認" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    
    if (Test-Path $desktopAsar) {
        $marker = [System.Text.Encoding]::UTF8.GetBytes("Antigravity UI Japanese Localization Mod")
        $bytes = [System.IO.File]::ReadAllBytes($desktopAsar)
        $text = [System.Text.Encoding]::GetEncoding(28591).GetString($bytes)
        $isPatched = $text.Contains([System.Text.Encoding]::GetEncoding(28591).GetString($marker))
        
        Write-Host "【Antigravity デスクトップ版】" -ForegroundColor Yellow
        Write-Host "  ・app.asar パッチ状態 : $(if ($isPatched) { '適用済み (日本語)' } else { '未適用 (英語)' })" -ForegroundColor $(if ($isPatched) { 'Green' } else { 'Red' })
        Write-Host "  ・監視プロセス (Watcher): 常駐なし（削除済み・不要）" -ForegroundColor Green
    } else {
        Write-Host "  ・Antigravity インストールが見つかりません" -ForegroundColor Red
    }
    
    Write-Host "【Antigravity IDE エディタ版】" -ForegroundColor Yellow
    Write-Host "  ・IDE 設定           : 変更なし（完全除外・英語維持）" -ForegroundColor Gray
    Write-Host "========================================================" -ForegroundColor Cyan
    exit 0
}

# -------------------------------------------------------------
# 通常インストール＆日本語化モード
# -------------------------------------------------------------
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Antigravity 日本語化インストーラー Ver1.2.1" -ForegroundColor Cyan
Write-Host "  (Antigravity デスクトップ版 v2.35.0 対応セットアップ)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# 監視プロセスは不要のため完全に停止・削除
Clear-Watcher

if (Test-Path $desktopExeDir) {
    Write-Host "Antigravity デスクトップ版の日本語化を構成中..." -ForegroundColor Cyan
    if (-not (Test-Path $dataDir)) {
        New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    }

    # Mod ファイルの配置 (watcher は除外)
    $modFiles = @("i18n_module.js", "main_hook.js", "patcher.js", "i18n_dict.json")
    foreach ($f in $modFiles) {
        $src = Join-Path $scriptDir $f
        if (-not (Test-Path $src)) {
            $src = Join-Path $scriptDir "desktop_mod\$f"
        }
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination (Join-Path $dataDir $f) -Force
        }
    }

    # カスタム辞書をユーザー設定フォルダへ配置
    $dictSrc = Join-Path $dataDir "i18n_dict.json"
    $userDictDir = Join-Path $env:USERPROFILE ".gemini\antigravity"
    $userDict = Join-Path $userDictDir "i18n_dict.json"
    if (Test-Path $dictSrc) {
        if (-not (Test-Path $userDictDir)) {
            New-Item -ItemType Directory -Path $userDictDir -Force | Out-Null
        }
        Copy-Item -Path $dictSrc -Destination $userDict -Force
        Write-Host "  -> 日本語辞書（1,279項目）を配置しました: $userDict" -ForegroundColor Green
    }

    # アプリ実行確認とパッチ適用
    $appProcesses = Get-Process Antigravity -ErrorAction SilentlyContinue
    if ($appProcesses -and -not $Silent) {
        Write-Host "  [案内] Antigravity デスクトップアプリが現在起動中です。" -ForegroundColor Yellow
        $ans = Read-Host "  パッチを適用するために Antigravity を終了してよろしいですか？ (y/N)"
        if ($ans -eq "y" -or $ans -eq "Y") {
            Write-Host "  -> Antigravity を終了中..." -ForegroundColor Cyan
            $appProcesses | ForEach-Object { [void]$_.CloseMainWindow() }
            $deadline = (Get-Date).AddSeconds(5)
            while ((Get-Process Antigravity -ErrorAction SilentlyContinue) -and (Get-Date) -lt $deadline) {
                Start-Sleep -Milliseconds 500
            }
            Get-Process Antigravity -ErrorAction SilentlyContinue | Stop-Process -Force
            Start-Sleep 1
            $appProcesses = Get-Process Antigravity -ErrorAction SilentlyContinue
        }
    }

    $patchSuccess = $false
    if (Test-Path $desktopAsar) {
        if (-not $appProcesses) {
            Write-Host "  -> Antigravity 本体へ日本語化パッチを適用中..." -ForegroundColor Cyan
            $env:ELECTRON_RUN_AS_NODE = "1"
            try {
                $code = (Start-Process -FilePath $desktopExe -ArgumentList "`"$patcherScript`"" -WorkingDirectory $dataDir -Wait -PassThru -WindowStyle Hidden).ExitCode
                if ($code -eq 0) {
                    Write-Host "  -> 日本語化パッチの適用に成功しました！" -ForegroundColor Green
                    $patchSuccess = $true
                } else {
                    Write-Host "  -> パッチ適用で終了コード $code が返されました。" -ForegroundColor Yellow
                }
            } finally {
                Remove-Item Env:\ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host "  [情報] Antigravity が起動中のため、app.asar は変更されていません。" -ForegroundColor Yellow
            Write-Host "         Antigravity を終了した状態でこのインストーラーを実行すると即座にパッチが適用されます。" -ForegroundColor Yellow
        }
    }

    # デスクトップ ショートカットの作成
    $desktopDir = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopDir "Antigravity.lnk"
    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $desktopExe
        $shortcut.WorkingDirectory = $desktopExeDir
        $shortcut.IconLocation = "$desktopExe,0"
        $shortcut.Description = "Google Antigravity"
        $shortcut.Save()
        Write-Host "  -> デスクトップ ショートカットを作成・確認しました。" -ForegroundColor Green
    } catch {}
} else {
    Write-Host "Antigravity デスクトップ版のインストールフォルダは見つかりませんでした（スキップ）" -ForegroundColor Gray
}

Write-Host ""
Write-Host "※ Antigravity IDE (エディタ版) は対象外のため設定変更は一切行いません（英語維持）。" -ForegroundColor Gray
Write-Host "※ 常駐監視プロセス（Watcher）は不要のため作成・常駐しません。" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "  セットアップが完了しました！" -ForegroundColor Green
if ($patchSuccess) {
    Write-Host "  Antigravity デスクトップアプリの日本語化が完了しました。" -ForegroundColor Green
    if (-not $Silent) {
        $launch = Read-Host "  Antigravity を日本語で起動しますか？ (Y/n)"
        if ($launch -ne "n" -and $launch -ne "N") {
            Start-Process -FilePath $desktopExe
        }
    }
} elseif ($appProcesses) {
    Write-Host "  ※ Antigravity が起動中のため、一度アプリを終了して再度実行してください。" -ForegroundColor Yellow
} else {
    Write-Host "  Antigravity を起動すると、日本語表示でご利用いただけます。" -ForegroundColor Green
}
Write-Host "========================================================" -ForegroundColor Green
