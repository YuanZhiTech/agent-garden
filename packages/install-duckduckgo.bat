@echo off
chcp 65001 >nul 2>&1
title MCP: DuckDuckGo
echo.
echo   MCP: DuckDuckGo - 免费，零配置
echo.

:: 生成 PowerShell 安装脚本
set "PSFILE=%TEMP%\mcp-install.ps1"
> "%PSFILE%" (
  echo $json = '{"mcpServers":{"duckduckgo":{"command":"npx","args":["-y","mcp-duckduckgo"]}}}'
  echo $settings = $env:USERPROFILE + "\.claude\settings.json"
  echo $mcpDir = $env:USERPROFILE + "\.agent-garden\mcp"
  echo $parent = [System.IO.Path]::GetDirectoryName^($settings^)
  echo if ^( -not ^(Test-Path $mcpDir^) ^) { New-Item -ItemType Directory -Path $mcpDir -Force }
  echo if ^( -not ^(Test-Path $parent^) ^) { New-Item -ItemType Directory -Path $parent -Force }
  echo if ^( -not ^(Test-Path $settings^) ^) { @{} ^| ConvertTo-Json ^| Set-Content $settings -Encoding UTF8 }
  echo $config = Get-Content $settings -Raw -Encoding UTF8 ^| ConvertFrom-Json
  echo $mcpJson = $json ^| ConvertFrom-Json
  echo if ^( -not $config.mcpServers ^) { $config ^| Add-Member -Name "mcpServers" -Value @{} -MemberType NoteProperty }
  echo $mcpJson.mcpServers.PSObject.Properties ^| ForEach-Object { $config.mcpServers ^| Add-Member -Name $_.Name -Value $_.Value -MemberType NoteProperty -Force }
  echo $config ^| ConvertTo-Json -Depth 10 ^| Set-Content $settings -Encoding UTF8
  echo Write-Host "OK"
)

:: 执行安装
powershell -ExecutionPolicy Bypass -NoProfile -File "%PSFILE%"

:: 判断结果
if %errorlevel% equ 0 (
  echo.
  echo   DuckDuckGo 安装成功！重启 Claude Code 即可使用
  echo   重启后试试问它："用 DuckDuckGo 搜索今天的新闻"
) else (
  echo.
  echo   ⚠ 安装出错，请把截图发给智联
)

:: 清理
del "%PSFILE%" 2>nul
echo.
pause
