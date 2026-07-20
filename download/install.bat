@echo off
setlocal enabledelayedexpansion
cd /d "%TEMP%"

echo.
echo ============================================
echo   AgentGarden Code - Setup
echo ============================================
echo.

:: --- Step 1: Config ---
echo [1/5] Getting config...
set "BASE_URL=https://api.deepseek.com/anthropic"
set "MODEL=deepseek-v4-flash[1m]"

powershell -Command "try{$w=New-Object Net.WebClient;$d=$w.DownloadString('https://agent-garden.com/api/config');$d|Out-File -Encoding utf8 '%TEMP%\garden-cfg.json'}catch{}" >nul 2>&1
if exist "%TEMP%\garden-cfg.json" (
    for /f "tokens=2 delims=:," %%a in ('findstr "anthropic_base_url" "%TEMP%\garden-cfg.json"') do set "BASE_URL=%%~a"
    for /f "tokens=2 delims=:," %%a in ('findstr "anthropic_model" "%TEMP%\garden-cfg.json"') do set "MODEL=%%~a"
    set "BASE_URL=!BASE_URL: =!" & set "BASE_URL=!BASE_URL:"=!"
    set "MODEL=!MODEL: =!" & set "MODEL=!MODEL:"=!"
    del "%TEMP%\garden-cfg.json" 2>nul
    echo   Config loaded
) else (
    echo   Using defaults
)
echo.

:: --- Step 2: Activation (optional) ---
set /p ACTIVATION_CODE=Activation code (Enter to skip):
if "%ACTIVATION_CODE%"=="" (
    echo   Skipping activation
    goto :skip_activation
)
powershell -Command "try{$w=New-Object Net.WebClient;$r=$w.DownloadString('https://agent-garden.com/api/verify?code=%ACTIVATION_CODE%');if($r.Contains('true')){exit 0}else{exit 1}}catch{exit 0}" >nul 2>&1
if %errorlevel% equ 0 (
    echo   Activation OK
) else (
    echo   Invalid code
    pause
    exit /b 1
)
:skip_activation
echo.

:: --- Step 3: DeepSeek Key ---
set /p DEEPSEEK_KEY=Enter DeepSeek API Key:
if "%DEEPSEEK_KEY%"=="" (
    echo Key required
    pause
    exit /b 1
)
echo.

:: --- Step 4: Node.js ---
echo [2/5] Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do echo   Node.js %%i found
) else (
    echo   Downloading Node.js...
    powershell -Command "try{$w=New-Object Net.WebClient;$w.DownloadFile('https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0-x64.msi','%TEMP%\node-install.msi')}catch{}" >nul 2>&1
    if not exist "%TEMP%\node-install.msi" (
        powershell -Command "try{$w=New-Object Net.WebClient;$w.DownloadFile('https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi','%TEMP%\node-install.msi')}catch{}" >nul 2>&1
    )
    if not exist "%TEMP%\node-install.msi" (
        echo   Download failed
        start https://nodejs.org/
        pause
        exit /b 1
    )
    echo   Installing Node.js...
    msiexec /i "%TEMP%\node-install.msi" /quiet /norestart >nul 2>&1
    del "%TEMP%\node-install.msi" 2>nul
    for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "Path=%%b"
    set "Path=%Path%;%USERPROFILE%\AppData\Roaming\npm"
    echo   Node.js installed
)
echo.

:: --- Step 5: Claude Code ---
echo [3/5] Claude Code (may take a few minutes)...
call npm config set registry https://registry.npmmirror.com >nul 2>&1
where claude >nul 2>&1
if %errorlevel% equ 0 (
    echo   Claude Code already installed
) else (
    call npm install -g @anthropic-ai/claude-code
    if %errorlevel% neq 0 (
        echo   Install failed, check network
        pause
        exit /b 1
    )
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

:: --- Step 7: Config ---
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

:: --- Step 8: Shortcut ---
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
powershell -Command ^
    "$ws = New-Object -ComObject WScript.Shell;" ^
    "$s = $ws.CreateShortcut('%DESKTOP%\AgentGarden Code.lnk');" ^
    "$s.TargetPath = '%GARDEN_DIR%\start-garden.bat';" ^
    "$s.WorkingDirectory = '%GARDEN_DIR%';" ^
    "$s.Save()" >nul 2>&1
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
