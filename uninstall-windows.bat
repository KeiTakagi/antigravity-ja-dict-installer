@echo off
rem ====================================================================
rem Antigravity 日本語化 アンインストーラー Ver1.1.0 (Windows / Shift-JIS / CRLF)
rem ====================================================================
setlocal
chcp 932 > nul
title Antigravity 日本語化 アンインストーラー Ver1.1.0

set "SCRIPT_DIR=%~dp0"
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install-windows.ps1" -Restore %*
if %ERRORLEVEL% neq 0 (
    echo.
    echo [エラー] 復元処理中にエラーが発生しました。
    pause
    exit /b %ERRORLEVEL%
)
echo.
echo [完了] 英語環境への復元が完了しました。
pause
endlocal
