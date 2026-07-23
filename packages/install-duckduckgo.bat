@echo off
echo MCP Installer for DuckDuckGo
echo.
echo Step 1: Finding Claude Code config...

:: Path 1: User home (for raw Claude Code)
set "PATH1=%USERPROFILE%\.claude\settings.json"
:: Path 2: garden-code isolated home (for Agent Garden Code)
set "PATH2=%TEMP%\garden-home\.claude\settings.json"

set "INSTALLED=0"

:: Try to write to Path 2 (garden-code)
if exist "%TEMP%\garden-home\" (
  echo   Found garden-code at: %TEMP%\garden-home\.claude\
  if not exist "%TEMP%\garden-home\.claude" mkdir "%TEMP%\garden-home\.claude"
  powershell -ExecutionPolicy Bypass -NoProfile -Command "& {$f=$env:TEMP+'\garden-home\.claude\settings.json'; $c=@{}; if(test-path $f){$c=gc $f -raw -Encoding UTF8|convertfrom-json}; if(!$c.mcpServers){$c|add-member -name mcpServers -value @{} -membertype noteproperty}; $c.mcpServers|add-member -name duckduckgo -value @{command='npx';args=@('-y','mcp-duckduckgo')} -membertype noteproperty -force; $c|convertto-json -depth 10|out-file $f -Encoding UTF8; write-host '  garden-code config updated'}" && set "INSTALLED=1"
)

:: Try to write to Path 1 (user home)
if exist "%USERPROFILE%\.claude\" (
  if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
  powershell -ExecutionPolicy Bypass -NoProfile -Command "& {$f=$env:USERPROFILE+'\\.claude\\settings.json'; $c=@{}; if(test-path $f){$c=gc $f -raw -Encoding UTF8|convertfrom-json}; if(!$c.mcpServers){$c|add-member -name mcpServers -value @{} -membertype noteproperty}; $c.mcpServers|add-member -name duckduckgo -value @{command='npx';args=@('-y','mcp-duckduckgo')} -membertype noteproperty -force; $c|convertto-json -depth 10|out-file $f -Encoding UTF8; write-host '  user config updated'}" && set "INSTALLED=1"
)

echo.
if "%INSTALLED%"=="1" (
  echo SUCCESS: DuckDuckGo MCP installed!
  echo Restart Claude Code to use it.
) else (
  echo FAILED: Could not find Claude Code config location.
)
echo.
pause
