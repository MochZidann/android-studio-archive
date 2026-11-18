@echo off
setlocal

set SCRIPT_DIR=%~dp0
set PROJECT_NAME=%1
set PACKAGE_NAME=%2

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%create_pml.ps1" "%PROJECT_NAME%" "%PACKAGE_NAME%"

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to generate template.
    exit /b %ERRORLEVEL%
)

endlocal
