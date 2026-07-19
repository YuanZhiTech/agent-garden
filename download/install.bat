@echo off
chcp 65001 >nul
title Agent花园 Code 安装程序
echo.
echo ╔══════════════════════════════════════════╗
echo ║    Agent花园 Code · 在线安装程序         ║
echo ╚══════════════════════════════════════════╝
echo.
echo  正在获取安装包，请稍候...
echo.

:: 第一步：下载安装脚本到临时目录
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://agent-garden.com/packages/install.ps1', '%TEMP%\garden-install.ps1')"

:: 第二步：执行安装脚本
powershell -ExecutionPolicy Bypass -File "%TEMP%\garden-install.ps1"

:: 第三步：清理临时文件
del "%TEMP%\garden-install.ps1" 2>nul

pause
