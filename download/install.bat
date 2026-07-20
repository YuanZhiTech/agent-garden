@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>nul
title Agent花园 Code 安装程序
cd /d "%TEMP%"

echo.
echo ╔══════════════════════════════════════════╗
echo ║    Agent花园 Code · 一键安装程序         ║
echo ╚══════════════════════════════════════════╝
echo.

:: ═══════════════════════════════════════════
:: 第一步：配置获取
:: ═══════════════════════════════════════════
echo [1/5] 获取配置...
set "BASE_URL=https://api.deepseek.com/anthropic"
set "MODEL=deepseek-v4-flash[1m]"

:: 尝试下载配置（可选，失败就用默认值）
powershell -Command "try{$w=New-Object Net.WebClient;$d=$w.DownloadString('https://agent-garden.com/api/config');$d|Out-File -Encoding utf8 '%TEMP%\garden-cfg.json'}catch{}" >nul 2>&1
if exist "%TEMP%\garden-cfg.json" (
    for /f "tokens=2 delims=:," %%a in ('findstr "anthropic_base_url" "%TEMP%\garden-cfg.json"') do set "BASE_URL=%%~a"
    for /f "tokens=2 delims=:," %%a in ('findstr "anthropic_model" "%TEMP%\garden-cfg.json"') do set "MODEL=%%~a"
    set "BASE_URL=!BASE_URL: =!" & set "BASE_URL=!BASE_URL:"=!"
    set "MODEL=!MODEL: =!" & set "MODEL=!MODEL:"=!"
    del "%TEMP%\garden-cfg.json" 2>nul
    echo  配置加载成功
) else (
    echo  使用默认配置
)
echo.

:: ═══════════════════════════════════════════
:: 第二步：激活码（可选）
:: ═══════════════════════════════════════════
echo ──────────────────────────────────────────────
echo  激活码验证（没有就直接回车跳过）
echo ──────────────────────────────────────────────
set /p ACTIVATION_CODE=请输入激活码（直接回车跳过）:
if "%ACTIVATION_CODE%"=="" (
    echo  跳过激活
    goto :skip_activation
)
powershell -Command "try{$w=New-Object Net.WebClient;$r=$w.DownloadString('https://agent-garden.com/api/verify?code=%ACTIVATION_CODE%');if($r.Contains('true')){exit 0}else{exit 1}}catch{exit 0}" >nul 2>&1
if %errorlevel% equ 0 (
    echo  激活成功
) else (
    echo  激活码无效，请联系客服
    pause
    exit /b 1
)
:skip_activation
echo.

:: ═══════════════════════════════════════════
:: 第三步：DeepSeek Key
:: ═══════════════════════════════════════════
echo ──────────────────────────────────────────────
echo  请输入 DeepSeek API Key
echo ──────────────────────────────────────────────
set /p DEEPSEEK_KEY=API Key:
if "%DEEPSEEK_KEY%"=="" (
    echo Key 不能为空
    pause
    exit /b 1
)
echo.

:: ═══════════════════════════════════════════
:: 第四步：安装 Node.js
:: ═══════════════════════════════════════════
echo ──────────────────────────────────────────────
echo  [2/5] 检查 Node.js 运行环境
echo ──────────────────────────────────────────────
where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do echo  ✓ Node.js %%i 已安装
) else (
    echo  正在下载 Node.js...
    powershell -Command "try{$w=New-Object Net.WebClient;$w.DownloadFile('https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0-x64.msi','%TEMP%\node-install.msi')}catch{}" >nul 2>&1
    if not exist "%TEMP%\node-install.msi" (
        powershell -Command "try{$w=New-Object Net.WebClient;$w.DownloadFile('https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi','%TEMP%\node-install.msi')}catch{}" >nul 2>&1
    )
    if not exist "%TEMP%\node-install.msi" (
        echo  下载失败，请手动安装 Node.js
        start https://nodejs.org/
        pause
        exit /b 1
    )
    echo  正在安装 Node.js（请稍候）...
    msiexec /i "%TEMP%\node-install.msi" /quiet /norestart >nul 2>&1
    del "%TEMP%\node-install.msi" 2>nul
    :: 刷新环境变量
    for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "Path=%%b"
    set "Path=%Path%;%USERPROFILE%\AppData\Roaming\npm"
    echo  ✓ Node.js 安装完成
)
echo.

:: ═══════════════════════════════════════════
:: 第五步：安装 Claude Code
:: ═══════════════════════════════════════════
echo ──────────────────────────────────────────────
echo  [3/5] 安装 Claude Code（可能需要几分钟）
echo ──────────────────────────────────────────────
call npm config set registry https://registry.npmmirror.com >nul 2>&1
where claude >nul 2>&1
if %errorlevel% equ 0 (
    echo  ✓ Claude Code 已安装
) else (
    echo  正在安装 Claude Code...
    call npm install -g @anthropic-ai/claude-code
    if %errorlevel% neq 0 (
        echo  安装失败，请检查网络后重试
        pause
        exit /b 1
    )
    echo  ✓ Claude Code 安装完成
)
echo.

:: ═══════════════════════════════════════════
:: 第六步：安装 Web UI
:: ═══════════════════════════════════════════
echo ──────────────────────────────────────────────
echo  [4/5] 安装 Web 界面
echo ──────────────────────────────────────────────
set "GARDEN_DIR=%USERPROFILE%\agent-garden-code"
if not exist "%GARDEN_DIR%" mkdir "%GARDEN_DIR%"
cd /d "%GARDEN_DIR%"
call npm install @fenton/ccwebui >nul 2>&1
echo  ✓ Web 界面安装完成
echo.

:: ═══════════════════════════════════════════
:: 第七步：写入配置
:: ═══════════════════════════════════════════
echo ──────────────────────────────────────────────
echo  [5/5] 写入配置
echo ──────────────────────────────────────────────
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
echo  ✓ 配置已写入
echo.

:: ═══════════════════════════════════════════
:: 第八步：创建启动入口
:: ═══════════════════════════════════════════
echo ──────────────────────────────────────────────
echo   创建启动入口
echo ──────────────────────────────────────────────
cd /d "%GARDEN_DIR%"

:: 启动脚本（自带 DeepSeek 环境变量）
(
echo @echo off
echo chcp 65001 ^>nul
echo cd /d "%%~dp0"
echo set ANTHROPIC_BASE_URL=!BASE_URL!
echo set ANTHROPIC_AUTH_TOKEN=!DEEPSEEK_KEY!
echo set ANTHROPIC_MODEL=!MODEL!
echo npx @fenton/ccwebui -p 3000
echo pause
) > start-garden.bat

:: 桌面快捷方式
set "DESKTOP=%USERPROFILE%\Desktop"
powershell -Command ^
    "$ws = New-Object -ComObject WScript.Shell;" ^
    "$s = $ws.CreateShortcut('%DESKTOP%\Agent花园 Code.lnk');" ^
    "$s.TargetPath = '%GARDEN_DIR%\start-garden.bat';" ^
    "$s.WorkingDirectory = '%GARDEN_DIR%';" ^
    "$s.Save()" >nul 2>&1
echo  ✓ 桌面快捷方式已创建
echo.

:: ═══════════════════════════════════════════
:: 完成
:: ═══════════════════════════════════════════
cls
echo.
echo ╔══════════════════════════════════════════╗
echo ║    Agent花园 Code 安装完成！             ║
echo ╚══════════════════════════════════════════╝
echo.
echo  双击桌面「Agent花园 Code」启动
echo.
echo  📞 微信: yuhuashi7271
echo  📧 邮箱: contact@agent-garden.com
echo.
pause

endlocal
