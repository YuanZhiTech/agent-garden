@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Agent花园·Code 便携版

echo.
echo ╔══════════════════════════════════════╗
echo ║    Agent花园·Code 便携版            ║
echo ╚══════════════════════════════════════╝
echo.

:: 设置 DeepSeek 环境变量
set ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
set ANTHROPIC_AUTH_TOKEN=sk-11f12f2b7fa7441891fc80d9a909657a
set ANTHROPIC_MODEL=deepseek-v4-flash

:: 启动 Claude Code 网页模式
echo 正在启动网页界面...
echo 首次使用请选一个英文文件夹作为工作区
echo.
start http://localhost:3000
claude.exe --url --dangerously-skip-permissions

echo.
pause
