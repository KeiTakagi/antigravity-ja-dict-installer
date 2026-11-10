# watcher.ps1
# Antigravity 日本語化アップデート監視役
# アプリが自動更新されたら即座に検知し、自動で日本語パッチを当て直します。

$ErrorActionPreference = "Stop"
$dataDir = Join-Path $env:LOCALAPPDATA "antigravity-ja"
$exe = Join-Path $env:LOCALAPPDATA "Programs\antigravity\Antigravity.exe"
$asar = Join-Path $env:LOCALAPPDATA "Programs\antigravity\resources\app.asar"
$patcher = Join-Path $dataDir "patcher.js"
$logFile = Join-Path $dataDir "watcher.log"

function Write-Log($msg) {
    if ((Test-Path $logFile) -and (Get-Item $logFile).Length -gt 512KB) {
        Move-Item $logFile "$logFile.old" -Force
    }
    Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg" -Encoding UTF8
}

Write-Log "watcher launched (pid $PID)"
try {
    $version = (Select-String -Path $patcher -Pattern 'const VERSION = "([^"]+)"').Matches[0].Groups[1].Value
    $marker = [System.Text.Encoding]::UTF8.GetBytes("Antigravity UI Japanese Localization Mod v$version")

    # 二重起動防止
    $created = $false
    $mutex = New-Object System.Threading.Mutex($true, "Local\AntigravityJaWatcher", [ref]$created)
} catch {
    Write-Log "startup error: $($_.Exception.Message)"
    exit 1
}
if (-not $created) { Write-Log "another watcher is running; exit"; exit 0 }

function Test-Patched {
    try {
        $bytes = [System.IO.File]::ReadAllBytes($asar)
        $text = [System.Text.Encoding]::GetEncoding(28591).GetString($bytes)
        return $text.Contains([System.Text.Encoding]::GetEncoding(28591).GetString($marker))
    } catch {
        return $true
    }
}

function Get-App {
    Get-Process Antigravity -ErrorAction SilentlyContinue
}

function Test-Writable {
    try { $f = [System.IO.File]::Open($asar, "Open", "ReadWrite", "None"); $f.Close(); return $true } catch { return $false }
}

function Test-Installing {
    [bool](Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*antigravity-updater*" })
}

function Invoke-Patch {
    $env:ELECTRON_RUN_AS_NODE = "1"
    try {
        $code = (Start-Process $exe -ArgumentList "`"$patcher`"" -Wait -PassThru -WindowStyle Hidden).ExitCode
    } finally {
        Remove-Item Env:\ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue
    }
    Write-Log "patch exit=$code"
    return ($code -eq 0)
}

Write-Log "watcher start (mod v$version)"
$okStamp = $null
$prevStamp = $null
$checkedStamp = $null
$checkedPatched = $false
$failStamp = $null
$failCount = 0
$gaveUp = $false
$noticeStamp = $null

function Write-Notice($s, $msg) {
    if ("$s|$msg" -ne $script:noticeStamp) { Write-Log $msg; $script:noticeStamp = "$s|$msg" }
}

function Add-Failure($s) {
    if ($s -ne $script:failStamp) { $script:failStamp = $s; $script:failCount = 0 }
    $script:failCount++
}

while ($true) {
    try {
        if (Test-Path $asar) {
            $item = Get-Item $asar
            $stamp = "$($item.Length)-$($item.LastWriteTimeUtc.Ticks)"
            if ($stamp -ne $okStamp -and (Test-Installing)) {
                Write-Notice $stamp "updater is running; waiting"
            } elseif ($stamp -ne $okStamp) {
                if ($stamp -ne $checkedStamp) {
                    $checkedPatched = Test-Patched; $checkedStamp = $stamp
                    if (-not $checkedPatched) { Write-Log "app.asar changed and is not patched (size $($item.Length))" }
                }
                if ($checkedPatched) {
                    $okStamp = $stamp
                } elseif ($stamp -eq $failStamp -and $failCount -ge 3) {
                    if (-not $gaveUp) { Write-Log "patch failed 3 times; giving up until app.asar changes"; $gaveUp = $true }
                } else {
                    $gaveUp = $false
                    $app = Get-App
                    if (-not $app) {
                        if ($stamp -eq $prevStamp -and (Test-Writable)) {
                            Write-Log "unpatched asar found (app closed) -> patch"
                            if (-not (Invoke-Patch)) { Add-Failure $stamp }
                        }
                    } else {
                        $justStarted = $app | Where-Object { $_.StartTime -gt (Get-Date).AddMinutes(-2) }
                        if ($justStarted) {
                            Write-Log "app started in English right after update -> restart with patch"
                            $app | ForEach-Object { [void]$_.CloseMainWindow() }
                            $deadline = (Get-Date).AddSeconds(15)
                            while ((Get-App) -and (Get-Date) -lt $deadline) { Start-Sleep 1 }
                            Get-App | Stop-Process -Force
                            $deadline = (Get-Date).AddSeconds(20)
                            while (-not (Test-Writable) -and (Get-Date) -lt $deadline) { Start-Sleep 1 }
                            if (-not (Invoke-Patch)) { Add-Failure $stamp }
                            Start-Process $exe
                        } else {
                            Write-Notice $stamp "app is running in English (started over 2 min ago); will patch after it closes"
                        }
                    }
                }
            }
            $prevStamp = $stamp
        }
    } catch {
        Write-Log "error: $($_.Exception.Message)"
    }
    Start-Sleep 10
}
