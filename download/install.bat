@echo off
setlocal enabledelayedexpansion

:: ============================================================
::  Agent花园 Code —— Windows 一键安装脚本
::  版本 1.1.0（壳模式 — 不包含核心配置）
::  适用系统：Windows 10 / 11 (64-bit)
::  授权模式：安装后需激活才能使用全部功能
:: ============================================================

cd /d "%~dp0"
title Agent花园 Code 安装程序

chcp 65001 >nul 2>&1

:: ─── 配置（分发时按客户填写）────────────────────
:: 验证服务器地址（Tailscale 内网 IP）
set "AUTH_SERVER=http://100.90.50.38:3001"
:: Tailscale 一次性 auth key（客户付款后生成）
set "TS_AUTH_KEY="
:: 客户名称（选填）
set "CUSTOMER_NAME="

set "LOG=%TEMP%\agent-garden-install.log"
echo [%DATE% %TIME%] 安装开始 > "%LOG%"

:: ═══════════════════════════════════════════════
::  1. 管理员权限检查
:: ═══════════════════════════════════════════════
:check_admin
echo.
echo   ^> 检查系统权限...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo   ! 请以管理员身份运行本脚本
    echo     右键单击 install.bat → 以管理员身份运行
    pause
    exit /b 1
)
echo   ✓ 管理员权限已获取

:: ═══════════════════════════════════════════════
::  2. 系统检查
:: ═══════════════════════════════════════════════
:check_system
echo.
echo   ^> 检查系统版本...
ver | findstr /i "10\.0" >nul 2>&1
if %errorlevel% neq 0 (
    echo   ! 仅支持 Windows 10 及以上版本
    pause
    exit /b 1
)
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE | findstr AMD64 >nul
if %errorlevel% neq 0 (
    echo   ! 仅支持 64 位系统
    pause
    exit /b 1
)
echo   ✓ 系统检查通过

:: ═══════════════════════════════════════════════
::  3. 激活码验证
:: ═══════════════════════════════════════════════
:verify_code
cls
echo  ╔══════════════════════════════════════════╗
echo  ║       Agent花园 Code · 一键安装           ║
echo  ╚══════════════════════════════════════════╝
echo.
echo  ────────────────────────────────────────────
echo  🔑 激活码验证
echo  ────────────────────────────────────────────
echo.
echo  请输入您购买后收到的激活码
echo  格式：AG-XXXXXXXX-XXXXXXXX
echo.
set /p ACTIVATION_CODE=激活码:
if "%ACTIVATION_CODE%"=="" (
    echo   ! 激活码不能为空
    pause
    goto :verify_code
)

:: 尝试在线验证
echo   > 正在验证激活码...
curl -s --connect-timeout 5 "https://agent-garden.com/api/verify?code=%ACTIVATION_CODE%" -o "%TEMP%\verify-result.json" 2>nul
if exist "%TEMP%\verify-result.json" (
    findstr "true" "%TEMP%\verify-result.json" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   ✓ 激活码验证通过
    ) else (
        echo   ! 激活码无效，请联系客服
        pause
        exit /b 1
    )
) else (
    echo   ⚠ 无法连接验证服务器（网络问题）
    echo     激活码将稍后验证
)
echo.

:: ═══════════════════════════════════════════════
::  4. 输入 DeepSeek Key
:: ═══════════════════════════════════════════════
:get_deepseek_key
cls
echo  ╔══════════════════════════════════════════╗
echo  ║       Agent花园 Code · 一键安装           ║
echo  ╚══════════════════════════════════════════╝
echo.
echo  ────────────────────────────────────────────
echo  🔑 请输入你的 DeepSeek API Key
echo  ────────────────────────────────────────────
echo.
echo  在 DeepSeek 官网注册并创建 Key：
echo  https://platform.deepseek.com/api_keys
echo.
echo  还没有？3 分钟注册一个
echo.
set /p DEEPSEEK_KEY=DeepSeek API Key:
if "%DEEPSEEK_KEY%"=="" (
    echo   ! Key 不能为空
    pause
    goto :get_deepseek_key
)
echo.
echo  ✓ 准备就绪，开始安装...
echo.

:: ═══════════════════════════════════════════════
::  4. 安装 Node.js
:: ═══════════════════════════════════════════════
:install_node
echo.
echo  ────────────────────────────────────────────
echo  [1/5] 安装运行环境
echo  ────────────────────────────────────────────

where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
    echo   ✓ Node.js %NODE_VER% 已安装，跳过
    goto :install_tailscale
)

echo   > 正在下载 Node.js...
set "NODE_URL=https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"
set "NODE_MIRROR=https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0-x64.msi"
set "NODE_MSI=%TEMP%\node-install.msi"

curl -L --connect-timeout 10 --retry 3 -o "%NODE_MSI%" "%NODE_URL%" 2>>"%LOG%"
if %errorlevel% neq 0 (
    curl -L --connect-timeout 10 --retry 3 -o "%NODE_MSI%" "%NODE_MIRROR%" 2>>"%LOG%"
    if !errorlevel! neq 0 (
        echo   ! 下载失败，请检查网络连接
        pause
        exit /b 1
    )
)

echo   > 正在安装 Node.js（请等待）...
msiexec /i "%NODE_MSI%" /quiet /norestart 2>>"%LOG%"
if %errorlevel% neq 0 (
    echo   ! Node.js 安装失败
    pause
    exit /b 1
)

:: 刷新 PATH
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "Path=%%b"

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo   ! 请重启电脑后重新运行本脚本
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
echo   ✓ Node.js %NODE_VER% 安装成功

:: ═══════════════════════════════════════════════
::  5. 安装 Tailscale（远程支持通道）
:: ═══════════════════════════════════════════════
:install_tailscale
echo.
echo  ────────────────────────────────────────────
echo  [2/5] 配置远程支持通道
echo  ────────────────────────────────────────────

where tailscale >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✓ Tailscale 已安装
    goto :install_claude
)

if "%TS_AUTH_KEY%"=="" (
    echo   ⚠ 远程通道 key 未配置，跳过
    echo     后续需要远程支持时可手动安装
    goto :install_claude
)

echo   > 正在下载 Tailscale...
curl -L --connect-timeout 10 --retry 3 -o "%TEMP%\tailscale-setup.exe" "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe" 2>>"%LOG%"
if %errorlevel% equ 0 (
    echo   > 正在安装...
    start /wait "" "%TEMP%\tailscale-setup.exe" /quiet /norestart 2>>"%LOG%"
    timeout /t 5 /nobreak >nul
    "C:\Program Files\Tailscale\tailscale.exe" up --authkey "%TS_AUTH_KEY%" --accept-routes --accept-dns=false 2>>"%LOG%"
    if !errorlevel! equ 0 (
        echo   ✓ 远程支持通道已建立
    ) else (
        echo   ~ 远程通道待配置（不影响正常使用）
    )
) else (
    echo   ~ Tailscale 下载失败（不影响核心功能）
)

:: ═══════════════════════════════════════════════
::  6. 安装 Claude Code
:: ═══════════════════════════════════════════════
:install_claude
echo.
echo  ────────────────────────────────────────────
echo  [3/5] 安装 Claude Code
echo  ────────────────────────────────────────────

npm config set registry https://registry.npmmirror.com 2>>"%LOG%"

where claude >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('claude --version 2^>nul') do set CLAUDE_VER=%%i
    echo   ✓ Claude Code !CLAUDE_VER! 已安装
    goto :install_webui
)

echo   > 正在安装 Claude Code（5-10 分钟）...
npm install -g @anthropic-ai/claude-code 2>>"%LOG%"
if %errorlevel% neq 0 (
    echo   ! 安装失败，请检查网络后重试
    pause
    exit /b 1
)

where claude >nul 2>&1
if %errorlevel% neq 0 (
    echo   ! 请重启电脑后重试
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('claude --version 2^>nul') do set CLAUDE_VER=%%i
echo   ✓ Claude Code !CLAUDE_VER! 安装成功

:: ═══════════════════════════════════════════════
::  7. 安装 Web UI
:: ═══════════════════════════════════════════════
:install_webui
echo.
echo  ────────────────────────────────────────────
echo  [4/5] 安装 Web UI（图形界面）
echo  ────────────────────────────────────────────

set "GARDEN_DIR=%USERPROFILE%\agent-garden-code"

if not exist "%GARDEN_DIR%" mkdir "%GARDEN_DIR%"
cd /d "%GARDEN_DIR%"

:: 写入 package.json
(
echo {
echo   "name": "agent-garden-code",
echo   "version": "1.0.0",
echo   "description": "Agent花园 Code - Claude Code Web UI",
echo   "main": "index.js",
echo   "scripts": {
echo     "start": "ccwebui"
echo   },
echo   "dependencies": {
echo     "@fenton/ccwebui": "^1.0.6"
echo   }
echo }
) > package.json

:: 复制 CLAUDE.md 灵魂引导文件
if exist "%~dp0CLAUDE.md" (
    copy "%~dp0CLAUDE.md" "%GARDEN_DIR%\CLAUDE.md" >nul 2>&1
)

echo   > 安装 Web UI 组件...
npm install 2>>"%LOG%"
if %errorlevel% neq 0 (
    echo   ~ Web UI 安装异常（不影响终端使用）
)

:: ═══════════════════════════════════════════════
::  8. 创建启动脚本和快捷方式
:: ═══════════════════════════════════════════════
:create_shortcuts
echo.
echo  ────────────────────────────────────────────
echo  [5/5] 创建启动入口
echo  ────────────────────────────────────────────

cd /d "%GARDEN_DIR%"

:: Web UI 启动脚本
(
echo @echo off
echo chcp 65001 ^>nul
echo echo  正在启动 Agent花园 Code...
echo cd /d "%%~dp0"
echo npx ccwebui --host 0.0.0.0 --port 3000
echo pause
) > start-garden.bat

:: 终端启动脚本
(
echo @echo off
echo chcp 65001 ^>nul
echo echo.
echo echo  Agent花园 Code - 终端模式
echo claude
) > start-cli.bat

:: 桌面快捷方式（PowerShell）
set "DESKTOP=%USERPROFILE%\Desktop"
powershell -Command ^
    "$ws = New-Object -ComObject WScript.Shell;" ^
    "$s = $ws.CreateShortcut('%DESKTOP%\Agent花园 Code 网页版.lnk');" ^
    "$s.TargetPath = '%GARDEN_DIR%\start-garden.bat';" ^
    "$s.WorkingDirectory = '%GARDEN_DIR%';" ^
    "$s.Save();" ^
    "$s2 = $ws.CreateShortcut('%DESKTOP%\Agent花园 Code 终端版.lnk');" ^
    "$s2.TargetPath = '%GARDEN_DIR%\start-cli.bat';" ^
    "$s2.WorkingDirectory = '%GARDEN_DIR%';" ^
    "$s2.Save();" 2>>"%LOG%"

echo   ✓ 启动入口已创建

:: ═══════════════════════════════════════════════
::  9. 激活授权（核心步骤）
:: ═══════════════════════════════════════════════
:activate
echo.
echo  ────────────────────────────────────────────
echo  验证授权中...
echo  ────────────────────────────────────────────

:: 生成机器标识（三重哈希：主机名+MAC+硬盘序列号）
set "MACHINE_ID="
:: 主机名
for /f "tokens=*" %%i in ('hostname') do set "HOSTNAME=%%i"
:: MAC 地址（取第一个非虚拟网卡）
for /f "tokens=2 delims==" %%i in ('wmic nic where "NetEnabled=true" get MACAddress /value 2^>nul') do (
    set "MAC=%%i"
    if not "!MAC!"=="" goto :mac_found
)
:mac_found
:: 硬盘序列号
for /f "tokens=*" %%i in ('wmic diskdrive get serialnumber 2^>nul ^| findstr /v "SerialNumber"') do (
    if not "%%i"=="" set "DISK_SN=%%i"
)
if "%DISK_SN%"=="" set "DISK_SN=UNKNOWN"

:: 三重哈希
set "RAW_ID=%HOSTNAME%-%MAC%-%DISK_SN%"
for /f "tokens=*" %%i in ('powershell -Command "[System.BitConverter]::ToString((New-Object System.Security.Cryptography.SHA256Managed).ComputeHash([System.Text.Encoding]::UTF8.GetBytes('%RAW_ID%')))).Replace('-','').Substring(0,32).ToLower()"') do set "MACHINE_ID=%%i"
if "%MACHINE_ID%"=="" set "MACHINE_ID=UNKNOWN-%RANDOM%"
echo   ✓ 机器标识生成完成

:: 调用验证服务激活
echo   > 正在连接授权服务器...
echo [%DATE% %TIME%] 发起激活请求 >> "%LOG%"

:: 构造 JSON 请求
set "JSON_DATA={\"machine_id\":\"%MACHINE_ID%\""
if not "%CUSTOMER_NAME%"=="" set "JSON_DATA=!JSON_DATA!,\"customer\":\"%CUSTOMER_NAME%\""
set "JSON_DATA=!JSON_DATA!}"

:: 调用 API
curl -s -X POST "%AUTH_SERVER%/api/activate" ^
  -H "Content-Type: application/json" ^
  -d "%JSON_DATA%" ^
  -o "%TEMP%\activation-response.json" ^
  -w "%%{http_code}" ^
  > "%TEMP%\activation-http-code.txt" 2>>"%LOG%"

set /p HTTP_CODE=<"%TEMP%\activation-http-code.txt"

if "%HTTP_CODE%"=="200" (
    :: 解析返回的配置并写入 settings.json
    echo   ✓ 授权成功

    :: 提取配置字段
    powershell -Command ^
        "$r = Get-Content '%TEMP%\activation-response.json' | ConvertFrom-Json;" ^
        "$config = $r.config;" ^
        "$settings = @{" ^
        "  env = @{" ^
        "    ANTHROPIC_BASE_URL = $config.ANTHROPIC_BASE_URL;" ^
        "    ANTHROPIC_AUTH_TOKEN = $r.code; " ^
        "    ANTHROPIC_MODEL = $config.ANTHROPIC_MODEL;" ^
        "    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = $config.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC;" ^
        "  };" ^
        "  theme = 'dark';" ^
        "};" ^
        "$settings | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 '%USERPROFILE%\.claude\settings.json';" ^
        "Write-Host 'Config written'"

    if exist "%USERPROFILE%\.claude\settings.json" (
        echo   ✓ 配置已写入
    ) else (
        echo   ! 配置写入失败，请联系技术支持
    )
) else (
    echo   ! 授权失败（HTTP %HTTP_CODE%）
    echo     请确认网络连接正常
    echo     安装完成后请联系我们激活
)

echo [%DATE% %TIME%] 激活完成 >> "%LOG%"

:: ═══════════════════════════════════════════════
::  10. 写入 DeepSeek Key 到配置
:: ═══════════════════════════════════════════════
:write_config
echo.
echo  ────────────────────────────────────────────
echo  配置 DeepSeek 连接
echo  ────────────────────────────────────────────

if exist "%USERPROFILE%\.claude\settings.json" (
    echo   ✓ 配置文件已存在
) else (
    mkdir "%USERPROFILE%\.claude" 2>nul
)

:: 写入 settings.json（使用客户自己的 DeepSeek Key）
powershell -Command ^
    "$settings = @{" ^
    "  env = @{" ^
    "    ANTHROPIC_BASE_URL = 'https://api.deepseek.com/anthropic';" ^
    "    ANTHROPIC_AUTH_TOKEN = '%DEEPSEEK_KEY%';" ^
    "    ANTHROPIC_MODEL = 'deepseek-v4-flash[1m]';" ^
    "    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 'true';" ^
    "  };" ^
    "  theme = 'dark';" ^
    "};" ^
    "$settings | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 '%USERPROFILE%\.claude\settings.json';" ^
    "Write-Host '✓ DeepSeek 配置已写入'"

echo   ✓ 配置完成
echo [%DATE% %TIME%] DeepSeek Key 已写入配置 >> "%LOG%"

:: ═══════════════════════════════════════════════
::  11. 完成
:: ═══════════════════════════════════════════════
cls
echo.
echo  ╔══════════════════════════════════════════╗
echo  ║      Agent花园 Code 安装完成！            ║
echo  ╚══════════════════════════════════════════╝
echo.
echo  桌面已创建两个快捷方式：
echo.
echo  🖥️  「Agent花园 Code 网页版」
echo     （推荐）浏览器界面，点鼠标就能用
echo.
echo  ⌨️  「Agent花园 Code 终端版」
echo     命令行模式，适合高级用户
echo.
echo  ⚡ 首次启动约需 10-30 秒
echo  如遇防火墙提示，请允许访问
echo.
echo  📞 使用问题请联系技术支持
echo.
echo  按任意键退出...
pause >nul

endlocal
