@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>nul

:: ═══════════════════════════════════════════════
::  Agent花园 Code · 安装核心
::  由 install.bat 下载到临时目录执行
::  执行结束后自动删除
:: ═══════════════════════════════════════════════

cd /d "%TEMP%"
set "LOG=%TEMP%\garden-install.log"
echo [%DATE% %TIME%] 安装开始 > "%LOG%"

:: ─── 获取核心配置 ───
echo  ╔══════════════════════════════════════════╗
echo  ║    Agent花园 Code · 安装程序             ║
echo  ╚══════════════════════════════════════════╝
echo.
echo  [1/6] 获取配置... > CON
echo  [1/6] 获取配置...

:: 下载配置（三种方式兜底）
certutil -urlcache -split -f "https://agent-garden.com/api/config.bat" "%TEMP%\garden-config.bat" >nul 2>&1
if not exist "%TEMP%\garden-config.bat" (
    bitsadmin /transfer garden_cfg /download /priority high "https://agent-garden.com/api/config.bat" "%TEMP%\garden-config.bat" >nul 2>&1
)
if not exist "%TEMP%\garden-config.bat" (
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://agent-garden.com/api/config.bat', '%TEMP%\garden-config.bat')" >nul 2>&1
)

:: 加载配置
call "%TEMP%\garden-config.bat"
del "%TEMP%\garden-config.bat" 2>nul
echo  ✓ 配置加载完成
echo.

:: ─── 激活码 ───
echo  ────────────────────────────────────────────
echo  🔑 激活码验证
echo  ────────────────────────────────────────────
set /p ACTIVATION_CODE=请输入激活码（AG-XXXX-XXXX）:
if "%ACTIVATION_CODE%"=="" (
    echo  激活码不能为空
    pause
    exit /b 1
)

echo  正在验证...
certutil -urlcache -split -f "https://agent-garden.com/api/verify?code=%ACTIVATION_CODE%" "%TEMP%\garden-verify.json" >nul 2>&1
if exist "%TEMP%\garden-verify.json" (
    findstr "true" "%TEMP%\garden-verify.json" >nul && (
        echo  ✓ 激活码验证通过
    ) || (
        echo  激活码无效，请联系客服
        pause
        exit /b 1
    )
    del "%TEMP%\garden-verify.json" 2>nul
) else (
    echo  ~ 跳过验证（离线模式）
)
echo.

:: ─── DeepSeek Key ───
echo  ────────────────────────────────────────────
echo  🔑 请输入 DeepSeek API Key
echo  ────────────────────────────────────────────
echo.
set /p DEEPSEEK_KEY=DeepSeek API Key:
if "%DEEPSEEK_KEY%"=="" (
    echo  Key 不能为空
    pause
    exit /b 1
)
echo.

:: ─── 安装 Node.js ───
echo  ────────────────────────────────────────────
echo  [2/6] 检查 Node.js 运行环境
echo  ────────────────────────────────────────────

where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
    echo  ✓ Node.js !NODE_VER! 已安装，跳过
) else (
    echo  正在下载 Node.js...
    set "NODE_URL=https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0-x64.msi"
    set "NODE_MIRROR=https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"

    bitsadmin /transfer node_dl /download /priority high "!NODE_URL!" "%TEMP%\node-install.msi" >nul 2>&1
    if not exist "%TEMP%\node-install.msi" (
        bitsadmin /transfer node_dl2 /download /priority high "!NODE_MIRROR!" "%TEMP%\node-install.msi" >nul 2>&1
    )
    if not exist "%TEMP%\node-install.msi" (
        echo  下载失败，请检查网络
        pause
        exit /b 1
    )

    echo  正在安装 Node.js...
    msiexec /i "%TEMP%\node-install.msi" /quiet /norestart >nul 2>&1
    del "%TEMP%\node-install.msi" 2>nul
    echo  ✓ Node.js 安装成功
)
echo.

:: ─── 安装 Claude Code ───
echo  ────────────────────────────────────────────
echo  [3/6] 安装 Claude Code（3-5分钟）
echo  ────────────────────────────────────────────

npm config set registry https://registry.npmmirror.com >nul 2>&1

where claude >nul 2>&1
if %errorlevel% equ 0 (
    echo  ✓ Claude Code 已安装
) else (
    call npm install -g @anthropic-ai/claude-code
    echo  ✓ Claude Code 安装完成
)
echo.

:: ─── 安装 Web UI ───
echo  ────────────────────────────────────────────
echo  [4/6] 安装 Web UI
echo  ────────────────────────────────────────────

set "GARDEN_DIR=%USERPROFILE%\agent-garden-code"
if not exist "!GARDEN_DIR!" mkdir "!GARDEN_DIR!"
cd /d "!GARDEN_DIR!"

call npm install @fenton/ccwebui >nul 2>&1
echo  ✓ Web UI 安装完成
echo.

:: ─── 写入配置 ───
echo  ────────────────────────────────────────────
echo  [5/6] 写入配置
echo  ────────────────────────────────────────────

if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"

:: 用 PowerShell 写入 settings.json
powershell -Command ^
    "$settings = @{env=@{ANTHROPIC_BASE_URL='%ANTHROPIC_BASE_URL%';ANTHROPIC_AUTH_TOKEN='%DEEPSEEK_KEY%';ANTHROPIC_MODEL='%ANTHROPIC_MODEL%';CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC='%DISABLE_TRAFFIC%'};theme='dark'};" ^
    "$settings | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 '%USERPROFILE%\.claude\settings.json'" >nul 2>&1
echo  ✓ 配置已写入
echo.

:: ─── 创建快捷方式 ───
echo  ────────────────────────────────────────────
echo  [6/6] 创建启动入口
echo  ────────────────────────────────────────────

:: 启动脚本
cd /d "!GARDEN_DIR!"
(
echo @echo off
echo chcp 65001 ^>nul
echo cd /d "%%~dp0"
echo npx ccwebui --host 0.0.0.0 --port 3000
echo pause
) > start-garden.bat

:: 桌面快捷方式
set "DESKTOP=%USERPROFILE%\Desktop"
powershell -Command ^
    "$ws = New-Object -ComObject WScript.Shell;" ^
    "$s = $ws.CreateShortcut('%DESKTOP%\Agent花园 Code.lnk');" ^
    "$s.TargetPath = '!GARDEN_DIR!\start-garden.bat';" ^
    "$s.WorkingDirectory = '!GARDEN_DIR!';" ^
    "$s.Save()" >nul 2>&1
echo  ✓ 桌面快捷方式已创建
echo.

:: ─── 完成 ───
cls
echo.
echo  ╔══════════════════════════════════════════╗
echo  ║    Agent花园 Code 安装完成！             ║
echo  ╚══════════════════════════════════════════╝
echo.
echo  双击桌面「Agent花园 Code」启动
echo.
echo  📞 微信: yuhuashi7271 · 邮箱: contact@agent-garden.com
echo.
pause

endlocal
