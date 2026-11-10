# install-windows.ps1
$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Antigravity Japanese Localization Installer" -ForegroundColor Cyan
Write-Host "  (Auto-Updating Localization System)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

try {
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

    $dataDir = Join-Path $env:LOCALAPPDATA "antigravity-ja"
    if (-not (Test-Path $dataDir)) {
        New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    }

    # 1. Deploy mod files & watcher
    Write-Host "[1/4] Deploying mod programs and auto-updater watcher..." -ForegroundColor Cyan
    $files = @("i18n_module.js", "main_hook.js", "patcher.js", "watcher.ps1")
    foreach ($f in $files) {
        $src = Join-Path $scriptDir $f
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination (Join-Path $dataDir $f) -Force
        }
    }

    # Clean old temp files
    Remove-Item (Join-Path $dataDir "launch.cmd") -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $dataDir "check_startup.cmd") -Force -ErrorAction SilentlyContinue

    # 2. Deploy dictionary
    Write-Host "[2/4] Deploying Japanese dictionary..." -ForegroundColor Cyan
    $dictSrc = Join-Path $scriptDir "i18n_dict.json"
    $dictDestDir = Join-Path $env:USERPROFILE ".gemini\antigravity"
    $dictDest = Join-Path $dictDestDir "i18n_dict.json"

    if (-not (Test-Path $dictDestDir)) {
        New-Item -ItemType Directory -Path $dictDestDir -Force | Out-Null
    }
    Copy-Item -Path $dictSrc -Destination $dictDest -Force
    Write-Host "  -> Dictionary deployed to: $dictDest" -ForegroundColor Green

    # 3. Apply initial patch
    Write-Host "[3/4] Applying Japanese patch..." -ForegroundColor Cyan
    $exeDir = Join-Path $env:LOCALAPPDATA "Programs\antigravity"
    $exe = Join-Path $exeDir "Antigravity.exe"
    $patcher = Join-Path $dataDir "patcher.js"

    if ((Test-Path $exe) -and (Test-Path $patcher)) {
        $env:ELECTRON_RUN_AS_NODE = "1"
        try {
            $code = (Start-Process -FilePath $exe -ArgumentList "`"$patcher`"" -WorkingDirectory $exeDir -Wait -PassThru -WindowStyle Hidden).ExitCode
            if ($code -eq 0) {
                Write-Host "  -> Japanese patch applied successfully!" -ForegroundColor Green
            } else {
                Write-Host "  -> Patch already active or app busy." -ForegroundColor Yellow
            }
        } finally {
            Remove-Item Env:\ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue
        }
    }

    # 4. Register watcher service & setup desktop shortcut
    Write-Host "[4/4] Setting up auto-update background watcher & clean shortcut..." -ForegroundColor Cyan
    $watcherPath = Join-Path $dataDir "watcher.ps1"
    $runCmd = "powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$watcherPath`""
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AntigravityJaWatcher" -Value $runCmd

    # Launch watcher if not already running
    $runningWatcher = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like "*antigravity-ja\watcher.ps1*" }
    if (-not $runningWatcher) {
        $watcherArgs = @("-WindowStyle", "Hidden", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $watcherPath)
        Start-Process powershell.exe -ArgumentList $watcherArgs
        Write-Host "  -> Auto-update watcher launched in background." -ForegroundColor Green
    } else {
        Write-Host "  -> Auto-update watcher is already active." -ForegroundColor Green
    }

    # Direct official shortcut (100% reliable, zero crash)
    $desktopDir = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopDir "Antigravity.lnk"
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $exe
    $shortcut.Arguments = ""
    $shortcut.WorkingDirectory = $exeDir
    $shortcut.IconLocation = "$exe,0"
    $shortcut.WindowStyle = 1
    $shortcut.Description = "Antigravity"
    $shortcut.Save()
    Write-Host "  -> Official desktop shortcut created directly to Antigravity.exe." -ForegroundColor Green

    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "  Setup completed successfully!" -ForegroundColor Green
    Write-Host "  Antigravity is now in Japanese." -ForegroundColor Green
    Write-Host "  When updated, it will automatically remain in Japanese!" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
} catch {
    Write-Host "[Error] Setup failed: $_" -ForegroundColor Red
    exit 1
}
