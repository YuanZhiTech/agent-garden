@echo off
echo MCP Installer for DuckDuckGo
echo.
echo Step 1: Checking settings.json...
if exist "%USERPROFILE%\.claude\settings.json" (
  echo Found settings.json
) else (
  echo Creating settings.json...
  if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
  echo {} > "%USERPROFILE%\.claude\settings.json"
)
echo.
echo Step 2: Writing MCP config...
powershell -ExecutionPolicy Bypass -NoProfile -Command "& {$j='{""mcpServers"":{""duckduckgo"":{""command"":""npx"",""args"":[""-y"",""mcp-duckduckgo""]}}}'; $s=$env:USERPROFILE+'\.claude\settings.json'; if(!(test-path $s)){@{}|convertto-json|out-file $s -encoding utf8}; $c=gc $s -raw -encoding utf8|convertfrom-json; if(!$c.mcpServers){$c|add-member -name mcpServers -value @{} -membertype noteproperty}; ($j|convertfrom-json).mcpServers.psobject.properties|%{$c.mcpServers|add-member -name $_.name -value $_.value -membertype noteproperty -force}; $c|convertto-json -depth 10|out-file $s -encoding utf8; write-host '  OK - MCP config merged'}"
if %errorlevel% equ 0 (
  echo.
  echo SUCCESS: DuckDuckGo MCP installed!
  echo Restart Claude Code and try: search with DuckDuckGo
) else (
  echo.
  echo FAILED: Please close Claude Code/garden-code first, then run this again.
)
echo.
pause
