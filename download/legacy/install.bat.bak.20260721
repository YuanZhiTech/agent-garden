@echo off
setlocal enabledelayedexpansion
cd /d "%TEMP%"

echo.
echo ============================================
echo   AgentGarden Code - Setup
echo ============================================
echo.

:: --- Step 1: Config ---
echo [1/5] Configuring...
set "BASE_URL=https://api.deepseek.com/anthropic"
set "MODEL=deepseek-v4-flash[1m]"
echo   OK
echo.

:: --- Step 2: Activation code (optional) ---
set /p ACTIVATION_CODE=Activation code (optional, press Enter to skip):
if "%ACTIVATION_CODE%"=="" (
    echo   Skipping activation
    goto :skip_activation
)

curl -s -o "%TEMP%\garden-vr.json" "https://agent-garden.com/api/verify?code=%ACTIVATION_CODE%"
if exist "%TEMP%\garden-vr.json" (
    findstr "true" "%TEMP%\garden-vr.json" >nul && (
        echo   Activation OK
    ) || (
        echo   Invalid code & pause & exit /b 1
    )
    del "%TEMP%\garden-vr.json" 2>nul
) else (
    echo   Offline mode - skip verify
)
echo.
goto :after_activation

:skip_activation
echo.

:after_activation
:: --- Step 3: DeepSeek Key ---
set /p DEEPSEEK_KEY=Enter your DeepSeek API Key:
if "%DEEPSEEK_KEY%"=="" (
    echo Key required & pause & exit /b 1
)
echo.

:: --- Step 4: Install Node.js ---
echo [2/5] Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do echo   Node.js %%i found
) else (
    echo   Downloading Node.js...
    curl -L -o "%TEMP%\node.msi" "https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0-x64.msi"
    if not exist "%TEMP%\node.msi" (
        curl -L -o "%TEMP%\node.msi" "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"
    )
    if not exist "%TEMP%\node.msi" (
        echo   Download failed
        start https://nodejs.org/
        pause & exit /b 1
    )
    msiexec /i "%TEMP%\node.msi" /quiet /norestart >nul 2>&1
    del "%TEMP%\node.msi" 2>nul
    :: Refresh PATH so npm becomes available
    for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "Path=%%b"
    set "Path=%Path%;%USERPROFILE%\AppData\Roaming\npm"
    echo   Node.js installed
)
echo.

:: --- Step 5: Install Claude Code ---
echo [3/5] Claude Code...
npm config set registry https://registry.npmmirror.com >nul 2>&1
where claude >nul 2>&1
if %errorlevel% equ 0 (
    echo   Claude Code already installed
) else (
    call npm install -g @anthropic-ai/claude-code
    echo   Claude Code installed
)
echo.

:: --- Step 6: Web UI ---
echo [4/5] Web UI...
set "GARDEN_DIR=%USERPROFILE%\agent-garden-code"
if not exist "%GARDEN_DIR%" mkdir "%GARDEN_DIR%"
cd /d "%GARDEN_DIR%"
call npm install @fenton/ccwebui >nul 2>&1
echo   Web UI installed
echo.

:: --- Step 7: Write config ---
echo [5/5] Writing config...
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"

(
echo {
echo   "env": {
echo     "ANTHROPIC_BASE_URL": "!BASE_URL!",
echo     "ANTHROPIC_AUTH_TOKEN": "!DEEPSEEK_KEY!",
echo     "ANTHROPIC_MODEL": "!MODEL!",
echo     "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "true"
echo   },
echo   "theme": "dark"
echo }
) > "%USERPROFILE%\.claude\settings.json"
echo   Config written
echo.

:: --- Step 8: Shortcut (with DeepSeek env) ---
cd /d "%GARDEN_DIR%"
(
echo @echo off
echo cd /d "%%~dp0"
echo set ANTHROPIC_BASE_URL=!BASE_URL!
echo set ANTHROPIC_AUTH_TOKEN=!DEEPSEEK_KEY!
echo set ANTHROPIC_MODEL=!MODEL!
echo npx @fenton/ccwebui -p 3000
echo pause
) > start-garden.bat

set "DESKTOP=%USERPROFILE%\Desktop"
(
echo Set WshShell = WScript.CreateObject("WScript.Shell"^)
echo Set Shortcut = WshShell.CreateShortcut("%DESKTOP%\AgentGarden Code.lnk"^)
echo Shortcut.TargetPath = "%GARDEN_DIR%\start-garden.bat"
echo Shortcut.WorkingDirectory = "%GARDEN_DIR%"
echo Shortcut.Save
) > "%TEMP%\mklnk.vbs"
cscript "%TEMP%\mklnk.vbs" >nul 2>&1
del "%TEMP%\mklnk.vbs" 2>nul
echo   Shortcut created
echo.

:: --- Done ---
cls
echo.
echo ============================================
echo   AgentGarden Code - Installation Complete!
echo ============================================
echo.
echo   Double-click desktop "AgentGarden Code" to start
echo.
echo   WeChat: yuhuashi7271
echo   Email: contact@agent-garden.com
echo.
pause
endlocal
