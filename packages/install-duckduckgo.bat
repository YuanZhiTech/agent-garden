@echo off
echo MCP Installer for DuckDuckGo
echo.
echo Step 1: Checking settings.json...
set "FILE=%USERPROFILE%\.claude\settings.json"
if exist "%FILE%" (
  echo   Found settings.json
) else (
  echo   Creating new settings.json...
  if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
)
echo.
echo Step 2: Installing MCP config...
powershell -ExecutionPolicy Bypass -NoProfile -Command "& {$f=$env:USERPROFILE+'\.claude\settings.json'; $c=@{}; if(test-path $f){$c=gc $f -raw -Encoding UTF8|convertfrom-json}; if(!$c.mcpServers){$c|add-member -name mcpServers -value @{} -membertype noteproperty}; $c.mcpServers|add-member -name duckduckgo -value @{command='npx';args=@('-y','mcp-duckduckgo')} -membertype noteproperty -force; $c|convertto-json -depth 10|out-file $f -Encoding UTF8; write-host '  Config written successfully'}"
if %errorlevel% equ 0 (
  echo.
  echo SUCCESS: DuckDuckGo MCP installed!
  echo Restart Claude Code to use it.
) else (
  echo.
  echo FAILED. Try: close Claude Code/garden-code, then run again.
)
echo.
pause
