@echo off
chcp 65001 >nul 2>&1
title MCP: DuckDuckGo
echo.
echo   MCP: DuckDuckGo - 免费，零配置
echo.

set "SELF=%~f0"
set "TMPFILE=%TEMP%\mcp-duckduckgo.json"

for /f "usebackq delims=" %%A in (`findstr /n "===MCP_CONFIG===" "%SELF%"`) do set "LINE=%%A"
for /f "tokens=1 delims=:" %%B in ("%LINE%") do set /a "START=%%B"
set /a "START+=1"

more +%START% "%SELF%" > "%TMPFILE%"

set "MCP_DIR=%USERPROFILE%\.agent-garden\mcp"
if not exist "%MCP_DIR%" mkdir "%MCP_DIR%"
copy "%TMPFILE%" "%MCP_DIR%\duckduckgo.json" >nul

set "SETTINGS=%USERPROFILE%\.claude\settings.json"
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
if not exist "%SETTINGS%" echo {} > "%SETTINGS%"

echo 正在写入配置...
powershell -ExecutionPolicy Bypass -NoProfile -Command "
  $s = Get-Content """%SETTINGS%""" -Raw -Encoding UTF8 | ConvertFrom-Json;
  $m = Get-Content """%TMPFILE%""" -Raw | ConvertFrom-Json;
  if (-not $s.mcpServers) { $s | Add-Member -Name """mcpServers""" -Value @{} -MemberType NoteProperty };
  $m.mcpServers.PSObject.Properties | %%{ $s.mcpServers | Add-Member -Name $_.Name -Value $_.Value -MemberType NoteProperty -Force };
  $s | ConvertTo-Json -Depth 10 | Set-Content """%SETTINGS%""" -Encoding UTF8
"
if %errorlevel% equ 0 (
  echo.
  echo   DuckDuckGo 安装完成！重启 Claude Code 生效
) else (
  echo.
  echo   安装失败，请重试
)
del "%TMPFILE%" >nul 2>&1
echo.
pause
exit /b

===MCP_CONFIG===
{
  "mcpServers": {
    "duckduckgo": {
      "command": "npx",
      "args": ["-y", "mcp-duckduckgo"]
    }
  }
}