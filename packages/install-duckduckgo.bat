@echo off
echo MCP Installer for DuckDuckGo
echo.

:: Step 1: Set PowerShell to allow local scripts
echo [1/3] Setting PowerShell policy...
powershell -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force" >nul 2>&1
echo   OK

:: Step 2: Install MCP config
echo [2/3] Writing MCP config...
if exist "%TEMP%\garden-home\" (
  if not exist "%TEMP%\garden-home\.claude" mkdir "%TEMP%\garden-home\.claude"
  powershell -ExecutionPolicy Bypass -NoProfile -Command "& {$f=$env:TEMP+'\garden-home\.claude\settings.json'; $c=@{}; if(test-path $f){$c=gc $f -raw -Encoding UTF8|convertfrom-json}; if(!$c.mcpServers){$c|add-member -name mcpServers -value @{} -membertype noteproperty}; $c.mcpServers|add-member -name duckduckgo -value @{command='npx';args=@('-y','mcp-duckduckgo')} -membertype noteproperty -force; $c|convertto-json -depth 10|out-file $f -Encoding UTF8}"
  echo   OK
) else (
  if exist "%USERPROFILE%\.claude\" (
    if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
    powershell -ExecutionPolicy Bypass -NoProfile -Command "& {$f=$env:USERPROFILE+'\\.claude\\settings.json'; $c=@{}; if(test-path $f){$c=gc $f -raw -Encoding UTF8|convertfrom-json}; if(!$c.mcpServers){$c|add-member -name mcpServers -value @{} -membertype noteproperty}; $c.mcpServers|add-member -name duckduckgo -value @{command='npx';args=@('-y','mcp-duckduckgo')} -membertype noteproperty -force; $c|convertto-json -depth 10|out-file $f -Encoding UTF8}"
    echo   OK
  )
)

:: Step 3: Verify
echo [3/3] Verifying...
set "VERIFIED=0"
if exist "%TEMP%\garden-home\.claude\settings.json" (
  findstr "duckduckgo" "%TEMP%\garden-home\.claude\settings.json" >nul && set "VERIFIED=1"
)
if "%VERIFIED%"=="0" (
  if exist "%USERPROFILE%\.claude\settings.json" (
    findstr "duckduckgo" "%USERPROFILE%\.claude\settings.json" >nul && set "VERIFIED=1"
  )
)

echo.
if "%VERIFIED%"=="1" (
  echo SUCCESS! DuckDuckGo MCP installed.
  echo Restart Claude Code to use it.
) else (
  echo WARNING: Could not verify MCP config.
  echo Please close Claude Code and run this installer again.
)
echo.
pause

