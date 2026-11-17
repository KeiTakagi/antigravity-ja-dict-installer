<#
.SYNOPSIS
    Antigravity & Antigravity IDE 日本語化インストーラー Ver1.1.0 (Windows PowerShell)
.DESCRIPTION
    Google の AI 開発アプリ「Antigravity」（デスクトップ版）および
    「Antigravity IDE」（エディタ版）の双方を完全日本語化し、
    アップデート時も自動で日本語状態を維持する統合インストーラーです。
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
$watcherScript = Join-Path $dataDir "watcher.ps1"
$patcherScript = Join-Path $dataDir "patcher.js"

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
    Write-Host "  Antigravity 日本語化ステータス確認" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    
    # 1. デスクトップ版
    if (Test-Path $desktopAsar) {
        $marker = [System.Text.Encoding]::UTF8.GetBytes("Antigravity UI Japanese Localization Mod")
        $bytes = [System.IO.File]::ReadAllBytes($desktopAsar)
        $text = [System.Text.Encoding]::GetEncoding(28591).GetString($bytes)
        $isPatched = $text.Contains([System.Text.Encoding]::GetEncoding(28591).GetString($marker))
        $watcherProc = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like "*antigravity-ja\watcher.ps1*" }
        
        Write-Host "【Antigravity デスクトップ版】" -ForegroundColor Yellow
        Write-Host "  ・app.asar パッチ状態 : $(if ($isPatched) { '適用済み (日本語)' } else { '未適用 (英語)' })" -ForegroundColor $(if ($isPatched) { 'Green' } else { 'Red' })
        Write-Host "  ・自動更新見張り役     : $(if ($watcherProc) { '常駐実行中 (OK)' } else { '停止中' })" -ForegroundColor $(if ($watcherProc) { 'Green' } else { 'Yellow' })
    }
    
    # 2. IDE 版
    $idePy = Join-Path $scriptDir "scripts\translate_antigravity.py"
    if (Test-Path $idePy) {
        Write-Host "`n【Antigravity IDE エディタ版】" -ForegroundColor Yellow
        $pyCandidates = @(
            "$env:LOCALAPPDATA\Programs\Python\Python314\python.exe",
            "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe",
            "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe"
        )
        $py = $pyCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
        if (-not $py) { $py = (Get-Command python -ErrorAction SilentlyContinue).Source }
        if ($py) {
            & $py $idePy --status
        }
    }
    exit 0
}

# -------------------------------------------------------------
# 通常インストール＆日本語化モード
# -------------------------------------------------------------
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Antigravity 日本語化インストーラー Ver1.1.0" -ForegroundColor Cyan
Write-Host "  (デスクトップ版 & IDE エディタ版 統合セットアップ)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# -------------------------------------------------------------
# 1. Antigravity デスクトップ版 (Electron app.asar) の日本語化
# -------------------------------------------------------------
if (Test-Path $desktopExeDir) {
    Write-Host "[1/2] Antigravity デスクトップ版の日本語化を構成中..." -ForegroundColor Cyan
    if (-not (Test-Path $dataDir)) {
        New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    }

    # Mod ファイルの配置
    $modFiles = @("i18n_module.js", "main_hook.js", "patcher.js", "watcher.ps1", "i18n_dict.json")
    foreach ($f in $modFiles) {
        $src = Join-Path $scriptDir $f
        if (-not (Test-Path $src)) {
            $src = Join-Path $scriptDir "desktop_mod\$f"
        }
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination (Join-Path $dataDir $f) -Force
        }
    }

    # カスタム辞書をユーザー設定フォルダへ配置・マージ
    $dictSrc = Join-Path $dataDir "i18n_dict.json"
    $userDictDir = Join-Path $env:USERPROFILE ".gemini\antigravity"
    $userDict = Join-Path $userDictDir "i18n_dict.json"
    if (Test-Path $dictSrc) {
        if (-not (Test-Path $userDictDir)) {
            New-Item -ItemType Directory -Path $userDictDir -Force | Out-Null
        }
        Copy-Item -Path $dictSrc -Destination $userDict -Force
        Write-Host "  -> 日本語辞書（1,200項目以上）を配置しました: $userDict" -ForegroundColor Green
    }

    # アプリ実行確認と初期パッチ適用
    $appProcesses = Get-Process Antigravity -ErrorAction SilentlyContinue
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
                    Write-Host "  -> パッチは次回起動時または更新時に適用されます。" -ForegroundColor Yellow
                }
            } finally {
                Remove-Item Env:\ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host "  [情報] Antigravity が現在起動中です (app.asar がロックされています)。" -ForegroundColor Yellow
            Write-Host "         バックグラウンドの見張り役が終了・再起動時に自動でパッチを当てます。" -ForegroundColor Yellow
        }
    }

    # アップデート自動監視見張り役（Watcher）の常駐登録＆起動
    if (Test-Path $watcherScript) {
        $runCmd = "powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$watcherScript`""
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AntigravityJaWatcher" -Value $runCmd

        $runningWatcher = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like "*antigravity-ja\watcher.ps1*" }
        if (-not $runningWatcher) {
            $watcherArgs = @("-WindowStyle", "Hidden", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $watcherScript)
            Start-Process powershell.exe -ArgumentList $watcherArgs
            Write-Host "  -> 自動更新追従見張り役（Watcher）をバックグラウンド起動しました。" -ForegroundColor Green
        } else {
            Write-Host "  -> 自動更新追従見張り役（Watcher）は既に常駐実行中です。" -ForegroundColor Green
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
    Write-Host "[1/2] Antigravity デスクトップ版のインストールフォルダは見つかりませんでした（スキップ）" -ForegroundColor Gray
}

# -------------------------------------------------------------
# 2. Antigravity IDE (VS Code エディタ版) の日本語化
# -------------------------------------------------------------
Write-Host ""
Write-Host "[2/2] Antigravity IDE エディタ版の言語設定ファイルを確認中..." -ForegroundColor Cyan

$translateScript = Join-Path $scriptDir "scripts\translate_antigravity.py"
if (-not (Test-Path $translateScript)) {
    $translateScript = Join-Path (Split-Path $scriptDir -Parent) "scripts\translate_antigravity.py"
}

if (Test-Path $translateScript) {
    function Find-PythonExe {
        $candidates = @(
            "$env:LOCALAPPDATA\Programs\Python\Python314\python.exe",
            "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe",
            "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
            "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe"
        )
        foreach ($c in $candidates) {
            if (Test-Path $c) { return $c }
        }
        $cmd = Get-Command python -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
        return $null
    }

    $PythonExe = Find-PythonExe
    if ($PythonExe) {
        $pyArgs = @($translateScript, "--apply")
        if ($AppDir -ne "") {
            $pyArgs += "--app-dir"
            $pyArgs += $AppDir
        }
        & $PythonExe @pyArgs
    } else {
        Write-Host "  [情報] Python が見つからないため、IDE 版言語設定ファイルの翻訳はスキップしました。" -ForegroundColor Gray
    }
} else {
    Write-Host "  [情報] IDE 版翻訳スクリプトが見つからないためスキップしました。" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "  セットアップが完了しました！" -ForegroundColor Green
if ($appProcesses) {
    Write-Host "  ※ Antigravity を一度閉じて再起動すると、" -ForegroundColor Yellow
    Write-Host "     自動的に日本語表示で起動します。" -ForegroundColor Yellow
} else {
    Write-Host "  Antigravity を起動すると、日本語表示でご利用いただけます。" -ForegroundColor Green
}
Write-Host "========================================================" -ForegroundColor Green
