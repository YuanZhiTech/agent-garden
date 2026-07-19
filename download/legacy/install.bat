@echo off
setlocal enabledelayedexpansion
:: Agent花园 Code - Win7/Win8 兼容版安装脚本
:: 不依赖 PowerShell，使用基本系统命令

cd /d "%TEMP%"
chcp 65001 >nul 2>&1

echo.
echo ╔══════════════════════════════════════════╗
echo ║   Agent花园 Code · 兼容版安装程序        ║
echo ║   支持 Windows 7 / 8 / 10 / 11           ║
echo ╚══════════════════════════════════════════╝
echo.

:: ─── 获取核心配置（从服务器下载） ───
echo [1/5] 获取配置...
certutil -urlcache -split -f "https://agent-garden.com/api/config" "%TEMP%\garden-cfg.json" >nul 2>&1
if not exist "%TEMP%\garden-cfg.json" (
    bitsadmin /transfer gcfg /download /priority high "https://agent-garden.com/api/config" "%TEMP%\garden-cfg.json" >nul 2>&1
)
if exist "%TEMP%\garden-cfg.json" (
    for /f "tokens=2 delims=:," %%a in ('findstr "anthropic_base_url" "%TEMP%\garden-cfg.json"') do set "BASE_URL=%%~a"
    for /f "tokens=2 delims=:," %%a in ('findstr "anthropic_model" "%TEMP%\garden-cfg.json"') do set "MODEL=%%~a"
    set BASE_URL=!BASE_URL: =!
    set BASE_URL=!BASE_URL:"=!
    set MODEL=!MODEL: =!
    set MODEL=!MODEL:"=!
    del "%TEMP%\garden-cfg.json" 2>nul
    echo   ✓ 配置已获取
) else (
    echo   ~ 使用默认配置
    set "BASE_URL=https://api.deepseek.com/anthropic"
    set "MODEL=deepseek-v4-flash[1m]"
)
echo.

:: ─── 激活码 ───
set /p ACTIVATION_CODE=请输入激活码:
if "%ACTIVATION_CODE%"=="" (
    echo   激活码不能为空
    pause & exit /b 1
)

:: 验证激活码
certutil -urlcache -split -f "https://agent-garden.com/api/verify?code=%ACTIVATION_CODE%" "%TEMP%\garden-vr.json" >nul 2>&1
if exist "%TEMP%\garden-vr.json" (
    findstr "true" "%TEMP%\garden-vr.json" >nul && (
        echo   ✓ 激活码验证通过
    ) || (
        echo   ! 激活码无效 & pause & exit /b 1
    )
    del "%TEMP%\garden-vr.json" 2>nul
) else (
    echo   ~ 跳过验证
)
echo.

:: ─── DeepSeek Key ───
set /p DEEPSEEK_KEY=请输入 DeepSeek API Key:
if "%DEEPSEEK_KEY%"=="" (
    echo   Key 不能为空 & pause & exit /b 1
)
echo.

:: ─── 安装 Node.js ───
echo [2/5] 安装 Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do echo   ✓ Node.js %%i 已安装
) else (
    echo   正在下载...
    bitsadmin /transfer ndl /download /priority high "https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0-x64.msi" "%TEMP%\node.msi" >nul 2>&1
    if not exist "%TEMP%\node.msi" (
        bitsadmin /transfer ndl2 /download /priority high "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi" "%TEMP%\node.msi" >nul 2>&1
    )
    if not exist "%TEMP%\node.msi" (
        echo   ! 下载失败，请手动安装 Node.js
        start https://nodejs.org/
        pause & exit /b 1
    )
    msiexec /i "%TEMP%\node.msi" /quiet /norestart >nul 2>&1
    del "%TEMP%\node.msi" 2>nul
    echo   ✓ Node.js 安装成功
)
echo.

:: ─── 安装 Claude Code ───
echo [3/5] 安装 Claude Code...
npm config set registry https://registry.npmmirror.com >nul 2>&1
where claude >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✓ Claude Code 已安装
) else (
    call npm install -g @anthropic-ai/claude-code
    echo   ✓ Claude Code 安装完成
)
echo.

:: ─── 安装 Web UI ───
echo [4/5] 安装 Web UI...
set "GARDEN_DIR=%USERPROFILE%\agent-garden-code"
if not exist "%GARDEN_DIR%" mkdir "%GARDEN_DIR%"
cd /d "%GARDEN_DIR%"
call npm install @fenton/ccwebui >nul 2>&1
echo   ✓ Web UI 安装完成
echo.

:: ─── 写入配置 ───
echo [5/5] 写入配置...
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"

:: 用 echo 写入配置文件（不依赖 PowerShell）
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
echo   ✓ 配置已写入
echo.

:: ─── 创建快捷方式 ───
cd /d "%GARDEN_DIR%"
(
echo @echo off
echo cd /d "%%~dp0"
echo npx ccwebui --host 0.0.0.0 --port 3000
echo pause
) > start-garden.bat

set "DESKTOP=%USERPROFILE%\Desktop"
(
echo Set WshShell = WScript.CreateObject("WScript.Shell"^)
echo Set Shortcut = WshShell.CreateShortcut("%DESKTOP%\Agent花园 Code.lnk"^)
echo Shortcut.TargetPath = "%GARDEN_DIR%\start-garden.bat"
echo Shortcut.WorkingDirectory = "%GARDEN_DIR%"
echo Shortcut.Save
) > "%TEMP%\mklnk.vbs"
cscript "%TEMP%\mklnk.vbs" >nul 2>&1
del "%TEMP%\mklnk.vbs" 2>nul
echo   ✓ 快捷方式已创建
echo.

:: ─── 完成 ───
cls
echo.
echo ╔══════════════════════════════════════════╗
echo ║   Agent花园 Code 安装完成！              ║
echo ╚══════════════════════════════════════════╝
echo.
echo 双击桌面「Agent花园 Code」启动
echo.
echo   📞 微信: yuhuashi7271
echo   📧 邮箱: contact@agent-garden.com
echo.
pause
endlocal
