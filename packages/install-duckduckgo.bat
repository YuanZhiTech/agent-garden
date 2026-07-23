@echo off
echo Installing MCP: DuckDuckGo...
echo.

echo $j='{"mcpServers":{"duckduckgo":{"command":"npx","args":["-y","mcp-duckduckgo"]}}}' > "%temp%\mcp.ps1"
echo $s=$env:USERPROFILE+\.claude\settings.json >> "%temp%\mcp.ps1"
echo $d=[System.IO.Path]::GetDirectoryName($s) >> "%temp%\mcp.ps1"
echo if(!(Test-Path $d)){mkdir $d | Out-Null} >> "%temp%\mcp.ps1"
echo if(!(Test-Path $s)){@{}|ConvertTo-Json|Out-File $s -Encoding UTF8} >> "%temp%\mcp.ps1"
echo $c=Get-Content $s -Raw -Encoding UTF8|ConvertFrom-Json >> "%temp%\mcp.ps1"
echo $m=$j|ConvertFrom-Json >> "%temp%\mcp.ps1"
echo if(!$c.mcpServers){$c|Add-Member -Name mcpServers -Value @{} -MemberType NoteProperty} >> "%temp%\mcp.ps1"
echo $m.mcpServers.PSObject.Properties|%%{$c.mcpServers|Add-Member -Name $_.Name -Value $_.Value -MemberType NoteProperty -Force} >> "%temp%\mcp.ps1"
echo $c|ConvertTo-Json -Depth 10|Set-Content $s -Encoding UTF8 >> "%temp%\mcp.ps1"
echo Write-Host "DuckDuckGo MCP installed successfully" >> "%temp%\mcp.ps1"

powershell -ExecutionPolicy Bypass -NoProfile -File "%temp%\mcp.ps1"

if %errorlevel% equ 0 (
  echo.
  echo DuckDuckGo MCP installed! Restart Claude Code to use it.
) else (
  echo.
  echo Install failed. Send the error above to ZhiLian.
)

del "%temp%\mcp.ps1" 2>nul
echo.
pause
