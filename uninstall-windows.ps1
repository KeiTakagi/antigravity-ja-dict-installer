# uninstall-windows.ps1
$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Yellow
Write-Host "  Antigravity Japanese Localization Uninstaller" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "This will restore Antigravity to the official English version" -ForegroundColor Gray
Write-Host "and remove all Japanese translation mod files and dictionaries." -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "Are you sure you want to completely uninstall? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Uninstallation canceled." -ForegroundColor Yellow
    exit 0
}

$dataDir = Join-Path $env:LOCALAPPDATA "antigravity-ja"
$exe = Join-Path $env:LOCALAPPDATA "Programs\antigravity\Antigravity.exe"
$startupLnk = Join-Path ([Environment]::GetFolderPath("Startup")) "Antigravity日本語化.lnk"
$desktopLnk = Join-Path ([Environment]::GetFolderPath("Desktop")) "Antigravity.lnk"

# 1. Stop any residual processes
Write-Host "[1/5] Stopping any running watcher or checker processes..." -ForegroundColor Cyan
try {
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
        Where-Object { $_.CommandLine -like "*antigravity-ja\*" } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
} catch {}

# 2. Cleanup shortcuts & registry
Write-Host "[2/5] Cleaning up shortcuts and registry keys..." -ForegroundColor Cyan
if (Test-Path $startupLnk) { Remove-Item $startupLnk -Force -ErrorAction SilentlyContinue }
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AntigravityJaWatcher" -ErrorAction SilentlyContinue

if (Test-Path $desktopLnk) {
    if (Test-Path $exe) {
        $wsh = New-Object -ComObject WScript.Shell
        $sc = $wsh.CreateShortcut($desktopLnk)
        $sc.TargetPath = $exe
        $sc.Arguments = ""
        $sc.WorkingDirectory = Split-Path $exe
        $sc.IconLocation = "$exe,0"
        $sc.Save()
    } else {
        Remove-Item $desktopLnk -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "  -> Desktop shortcut restored to original." -ForegroundColor Green

# 3. Check running Antigravity
$runningApp = Get-Process Antigravity -ErrorAction SilentlyContinue
if ($runningApp) {
    Write-Host "  ! Closing running Antigravity to restore files..." -ForegroundColor Yellow
    $runningApp | ForEach-Object { [void]$_.CloseMainWindow() }
    Start-Sleep 2
    Get-Process Antigravity -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
}

# 4. Restore app.asar
Write-Host "[3/5] Restoring official app.asar..." -ForegroundColor Cyan
$patcher = Join-Path $dataDir "patcher.js"
if (-not (Test-Path $patcher)) {
    $patcher = Join-Path $PSScriptRoot "patcher.js"
}

if ((Test-Path $patcher) -and (Test-Path $exe)) {
    $env:ELECTRON_RUN_AS_NODE = "1"
    try {
        $code = (Start-Process $exe -ArgumentList "`"$patcher`" --restore" -Wait -PassThru -WindowStyle Hidden).ExitCode
        if ($code -eq 0) {
            Write-Host "  -> Successfully restored official English version." -ForegroundColor Green
        }
    } finally {
        Remove-Item Env:\ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue
    }
}

# 5. Remove directories
Write-Host "[4/5] Removing mod files, dictionaries, and cache..." -ForegroundColor Cyan
Set-Location $env:TEMP
if (Test-Path $dataDir) { Remove-Item $dataDir -Recurse -Force -ErrorAction SilentlyContinue }

$dictFile = Join-Path $env:USERPROFILE ".gemini\antigravity\i18n_dict.json"
if (Test-Path $dictFile) { Remove-Item $dictFile -Force -ErrorAction SilentlyContinue }

$skillDir = Join-Path $env:USERPROFILE ".gemini\config\skills\antigravity-ja"
if (Test-Path $skillDir) { Remove-Item $skillDir -Recurse -Force -ErrorAction SilentlyContinue }
Write-Host "  -> Mod files and dictionary cleaned up." -ForegroundColor Green

Write-Host "[5/5] Cleanup complete." -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "  Uninstallation completed successfully!" -ForegroundColor Green
Write-Host "  Antigravity is restored to official factory state." -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
