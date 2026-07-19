@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>nul
title Agent花园 Code 安装程序
cd /d "%TEMP%"

echo.
echo ╔══════════════════════════════════════════╗
echo ║    Agent花园 Code · 一键安装程序         ║
echo ╚══════════════════════════════════════════╝
echo.
echo  正在获取安装包...
echo.

:: 用 bitsadmin 下载核心安装脚本（Windows自带，不被拦截）
bitsadmin /transfer garden_dl /download /priority high "https://agent-garden.com/packages/install-core.bat" "%TEMP%\garden-core.bat" >nul 2>&1

:: 如果 bitsadmin 失败，尝试 certutil（同样系统自带）
if not exist "%TEMP%\garden-core.bat" (
    echo  尝试备用下载方式...
    certutil -urlcache -split -f "https://agent-garden.com/packages/install-core.bat" "%TEMP%\garden-core.bat" >nul 2>&1
)

:: 如果还是失败，用 PowerShell
if not exist "%TEMP%\garden-core.bat" (
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://agent-garden.com/packages/install-core.bat', '%TEMP%\garden-core.bat')" >nul 2>&1
)

:: 检查是否下载成功
if not exist "%TEMP%\garden-core.bat" (
    echo  下载失败，请检查网络连接
    pause
    exit /b 1
)

:: 执行核心安装脚本
call "%TEMP%\garden-core.bat"

:: 清理
del "%TEMP%\garden-core.bat" 2>nul
endlocal
