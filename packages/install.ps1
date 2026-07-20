<#
  Agent花园·Code 一键安装脚本
  此脚本在内存中运行，不写入磁盘
  核心参数通过 API 获取，不写在脚本里
#>

$host.UI.RawUI.WindowTitle = "Agent花园·Code 安装程序"
$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "  $msg" -ForegroundColor Green }
function Write-Info($msg) { Write-Host $msg }
function Write-Error($msg) { Write-Host "  ! $msg" -ForegroundColor Red }

# ─── 获取核心配置 ───
Write-Info "`n╔══════════════════════════════════════════╗"
Write-Info "║       Agent花园 Code · 一键安装       ║"
Write-Info "╚══════════════════════════════════════════╝`n"

Write-Info "  正在获取安装配置..."
try {
    $config = Invoke-RestMethod -Uri "https://agent-garden.com/api/config" -TimeoutSec 10
    Write-Step "配置获取成功"
} catch {
    # 离线兜底
    Write-Info "  ~ 使用默认配置继续"
    $config = @{
        anthropic_base_url = "https://api.deepseek.com/anthropic"
        anthropic_model = "deepseek-v4-flash[1m]"
        claude_code_disable = "true"
    }
}

# ─── 激活码验证 ───
do {
    $code = Read-Host "`n请输入激活码 (AG-XXXX-XXXX)"
} while ([string]::IsNullOrWhiteSpace($code))

Write-Info "  正在验证激活码..."
try {
    $verify = Invoke-RestMethod -Uri "https://agent-garden.com/api/verify?code=$code" -TimeoutSec 5
    if (-not $verify.valid) {
        Write-Error $verify.message
        Write-Info "  按任意键退出..."
        $null = $host.UI.RawUI.ReadKey()
        exit 1
    }
    Write-Step "激活码验证通过"
} catch {
    Write-Info "  ~ 无法连接验证服务器，跳过验证"
}

# ─── 输入 DeepSeek Key ───
do {
    $deepseek_key = Read-Host "`n请输入你的 DeepSeek API Key"
} while ([string]::IsNullOrWhiteSpace($deepseek_key))

Write-Step "DeepSeek Key已录入"

# ─── 安装 Node.js ───
Write-Info "`n────────────────────────────────────────────"
Write-Info "[1/4] 检查运行环境"
Write-Info "────────────────────────────────────────────"

$nodeInstalled = $false
try { $nodeVer = node -v; $nodeInstalled = $true } catch {}

if ($nodeInstalled) {
    Write-Step "Node.js $nodeVer 已安装"
} else {
    Write-Info "  > 下载 Node.js..."
    $nodeUrl = "https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0-x64.msi"
    $nodeMsi = "$env:TEMP\node-install.msi"
    try {
        Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeMsi -TimeoutSec 120
        Write-Info "  > 安装 Node.js（请等待）..."
        Start-Process msiexec -ArgumentList "/i `"$nodeMsi`" /quiet /norestart" -Wait
        $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine")
        Write-Step "Node.js 安装成功"
    } catch {
        Write-Error "Node.js 下载或安装失败，请检查网络后重试"
        $null = $host.UI.RawUI.ReadKey(); exit 1
    }
}

# ─── 安装 Claude Code ───
Write-Info "`n────────────────────────────────────────────"
Write-Info "[2/4] 安装 Claude Code"
Write-Info "────────────────────────────────────────────"

npm config set registry https://registry.npmmirror.com 2>$null

$claudeInstalled = $false
try { $claudeVer = claude --version 2>$null; $claudeInstalled = $true } catch {}

if ($claudeInstalled) {
    Write-Step "Claude Code 已安装"
} else {
    Write-Info "  > 正在安装（3-5分钟）..."
    npm install -g @anthropic-ai/claude-code 2>&1
    Write-Step "Claude Code 安装完成"
}

# ─── 安装 Web UI ───
Write-Info "`n────────────────────────────────────────────"
Write-Info "[3/4] 安装 Web UI"
Write-Info "────────────────────────────────────────────"

$gardenDir = "$env:USERPROFILE\agent-garden-code"
New-Item -ItemType Directory -Force -Path $gardenDir | Out-Null
Set-Location $gardenDir
npm install @fenton/ccwebui 2>$null | Out-Null
Write-Step "Web UI 安装完成"

# ─── 写入配置 ───
Write-Info "`n────────────────────────────────────────────"
Write-Info "[4/4] 写入配置"
Write-Info "────────────────────────────────────────────"

$claudeDir = "$env:USERPROFILE\.claude"
New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null

$settings = @{
    env = @{
        ANTHROPIC_BASE_URL = $config.anthropic_base_url
        ANTHROPIC_AUTH_TOKEN = $deepseek_key
        ANTHROPIC_MODEL = $config.anthropic_model
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = $config.claude_code_disable
    }
    theme = "dark"
}
$settings | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 "$claudeDir\settings.json"
Write-Step "配置已写入"

# ─── 创建快捷方式 ───
$desktop = [Environment]::GetFolderPath("Desktop")
$ws = New-Object -ComObject WScript.Shell

$batContent = @"
@echo off
chcp 65001 >nul
cd /d "$gardenDir"
npx @fenton/ccwebui -p 3000
pause
"@
$batContent | Out-File -Encoding ascii "$gardenDir\start-garden.bat"

$shortcut = $ws.CreateShortcut("$desktop\Agent花园 Code.lnk")
$shortcut.TargetPath = "$gardenDir\start-garden.bat"
$shortcut.WorkingDirectory = "$gardenDir"
$shortcut.Save()
Write-Step "桌面快捷方式已创建"

# ─── 完成 ───
Clear-Host
Write-Info "`n╔══════════════════════════════════════════╗"
Write-Info "║    Agent花园 Code 安装完成！            ║"
Write-Info "╚══════════════════════════════════════════╝`n"
Write-Info "  双击桌面「Agent花园 Code」启动`n"
Write-Info "  📞 问题联系："
Write-Info "    微信：yuhuashi7271"
Write-Info "    邮件：contact@agent-garden.com`n"
$null = $host.UI.RawUI.ReadKey()
