<#
.SYNOPSIS
    Antigravity 日本語化インストーラー Ver1.1.0 (Windows PowerShell)
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

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

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
    if (Test-Path "$env:LOCALAPPDATA\Programs\Python") {
        $found = Get-ChildItem -Path "$env:LOCALAPPDATA\Programs\Python" -Recurse -Filter "python.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { return $found.FullName }
    }
    $cmd = Get-Command python -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    throw "Python 3 が見つかりません。https://www.python.org/ から Python 3 をインストールしてから再実行してください。"
}

$PythonExe = Find-PythonExe
$InstallerPy = Join-Path $ScriptDir "AntigravityJP_Installer.py"

$argsList = @($InstallerPy)
if ($Status) {
    $argsList += "--status"
} elseif ($Restore) {
    $argsList += "--restore"
} elseif ($Silent) {
    $argsList += "--silent"
} elseif ($Cli) {
    $argsList += "--cli"
}

if ($AppDir -ne "") {
    $argsList += "--app-dir"
    $argsList += $AppDir
}

& $PythonExe @argsList
