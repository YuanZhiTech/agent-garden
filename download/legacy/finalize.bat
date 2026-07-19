@echo off
echo AgentGarden Code - Final Setup
echo ===============================
echo.
echo Claude Code and Web UI are already installed.
echo This script will configure your DeepSeek key.
echo.

:: Get config from server
echo Getting config...
curl -s -o "%TEMP%\cfg.json" "https://agent-garden.com/api/config"

:: Ask for DeepSeek key
set /p DSKEY=Enter your DeepSeek API Key:
if "%DSKEY%"=="" (
    echo Key required. & pause & exit /b 1
)

:: Write settings.json
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"

for /f "tokens=2 delims=:," %%a in ('findstr "anthropic_base_url" "%TEMP%\cfg.json"') do set "BURL=%%~a"
for /f "tokens=2 delims=:," %%a in ('findstr "anthropic_model" "%TEMP%\cfg.json"') do set "MOD=%%~a"
set BURL=%BURL: =%
set BURL=%BURL:"=%
set MOD=%MOD: =%
set MOD=%MOD:"=%
del "%TEMP%\cfg.json" 2>nul

(
echo {
echo   "env": {
echo     "ANTHROPIC_BASE_URL": "%BURL%",
echo     "ANTHROPIC_AUTH_TOKEN": "%DSKEY%",
echo     "ANTHROPIC_MODEL": "%MOD%",
echo     "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "true"
echo   },
echo   "theme": "dark"
echo }
) > "%USERPROFILE%\.claude\settings.json"

echo Config written successfully!
echo.
echo To start: Double-click desktop "AgentGarden Code" shortcut
echo.
pause
