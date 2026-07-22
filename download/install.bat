@echo off
setlocal enabledelayedexpansion
cd /d "%TEMP%"

echo.
echo ============================================
echo   AgentGarden Code - Setup
echo ============================================
echo.

:: --- Step 1: Activation Code (required) ---
set /p ACTIVATION_CODE=Enter activation code:
if "%ACTIVATION_CODE%"=="" (
    echo Activation code required
    pause
    exit /b 1
)

echo   Validating...
powershell -Command ^
    "$c=New-Object Net.WebClient;" ^
    "$r=$c.DownloadString('https://agent-garden.com/api/verify?code=%ACTIVATION_CODE%');" ^
    "$j=$r | ConvertFrom-Json;" ^
    "if($j.valid){write $j.tier;exit 0}else{exit 1}" > "%TEMP%\garden-tier.txt" 2>&1
if %errorlevel% neq 0 (
    echo   Invalid code
    pause
    exit /b 1
)
set /p TIER=<"%TEMP%\garden-tier.txt"
del "%TEMP%\garden-tier.txt" 2>nul
echo   Activation OK (tier: %TIER%)
echo.

:: --- Step 2: DeepSeek Key ---
set /p DEEPSEEK_KEY=Enter DeepSeek API Key:
if "%DEEPSEEK_KEY%"=="" (
    echo Key required
    pause
    exit /b 1
)
echo.

:: --- Step 3: Node.js ---
echo [1/4] Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do echo   Node.js %%i found
) else (
    echo   Downloading...
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
    msiexec /i "%TEMP%\node-install.msi" /quiet /norestart >nul 2>&1
    del "%TEMP%\node-install.msi" 2>nul
    for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "Path=%%b"
    set "Path=%Path%;%USERPROFILE%\AppData\Roaming\npm"
    echo   Node.js installed
)
echo.

:: --- Step 4: Claude Code ---
echo [2/4] Claude Code (may take a few minutes)...
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

:: --- Step 5: Garden Code ---
echo [3/4] Installing Web UI...
set "GARDEN_DIR=%USERPROFILE%\agent-garden-code"
if exist "%GARDEN_DIR%" rmdir /s /q "%GARDEN_DIR%"
mkdir "%GARDEN_DIR%"

:: Download garden-claude
powershell -Command "try{$w=New-Object Net.WebClient;$w.DownloadFile('https://agent-garden.com/packages/garden-claude-portable.zip','%TEMP%\garden.zip')}catch{}" >nul 2>&1
if exist "%TEMP%\garden.zip" (
    powershell -Command "Expand-Archive -Path '%TEMP%\garden.zip' -DestinationPath '%TEMP%\garden-extract\' -Force" >nul 2>&1
    if exist "%TEMP%\garden-extract\garden-claude" (
        xcopy /e /i /q /y "%TEMP%\garden-extract\garden-claude\*" "%GARDEN_DIR%\" >nul 2>&1
    )
    rmdir /s /q "%TEMP%\garden-extract" 2>nul
    del "%TEMP%\garden.zip" 2>nul
)

:: Install dependencies
cd /d "%GARDEN_DIR%"
call npm install @fenton/ccwebui >nul 2>&1
echo   Web UI installed
echo.

:: --- Step 6: Config ---
echo [4/4] Writing config...

:: DeepSeek config
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
(
echo {
echo   "env": {
echo     "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
echo     "ANTHROPIC_AUTH_TOKEN": "!DEEPSEEK_KEY!",
echo     "ANTHROPIC_MODEL": "deepseek-v4-flash[1m]",
echo     "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "true"
echo   },
echo   "theme": "dark"
echo }
) > "%USERPROFILE%\.claude\settings.json"

:: Tier config
if not exist "%USERPROFILE%\.agent-garden" mkdir "%USERPROFILE%\.agent-garden"
(
echo {
echo   "tier": "!TIER!"
echo }
) > "%USERPROFILE%\.agent-garden\config.json"

:: Also write to isolated directory (for garden-claude)
if not exist "%TMP%\garden-home\.agent-garden" mkdir "%TMP%\garden-home\.agent-garden"
copy "%USERPROFILE%\.agent-garden\config.json" "%TMP%\garden-home\.agent-garden\" >nul 2>&1

echo   Config written
echo.

:: --- Step 7: Shortcut ---
cd /d "%GARDEN_DIR%"

:: Download icon
powershell -Command "try{$w=New-Object Net.WebClient;$w.DownloadFile('https://agent-garden.com/images/garden-icon.ico','%GARDEN_DIR%\garden-icon.ico')}catch{}" >nul 2>&1

:: Start script
(
echo @echo off
echo cd /d "%%~dp0"
echo node garden-claude.js
echo pause
) > start-garden.bat

:: Desktop shortcut
set "DESKTOP=%USERPROFILE%\Desktop"
if exist "%GARDEN_DIR%\garden-icon.ico" (
    powershell -Command ^
        "$ws = New-Object -ComObject WScript.Shell;" ^
        "$s = $ws.CreateShortcut('%DESKTOP%\AgentGarden Code.lnk');" ^
        "$s.TargetPath = '%GARDEN_DIR%\start-garden.bat';" ^
        "$s.IconLocation = '%GARDEN_DIR%\garden-icon.ico';" ^
        "$s.WorkingDirectory = '%GARDEN_DIR%';" ^
        "$s.Save()" >nul 2>&1
) else (
    powershell -Command ^
        "$ws = New-Object -ComObject WScript.Shell;" ^
        "$s = $ws.CreateShortcut('%DESKTOP%\AgentGarden Code.lnk');" ^
        "$s.TargetPath = '%GARDEN_DIR%\start-garden.bat';" ^
        "$s.WorkingDirectory = '%GARDEN_DIR%';" ^
        "$s.Save()" >nul 2>&1
)
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
