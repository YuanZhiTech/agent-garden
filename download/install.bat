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
powershell -ExecutionPolicy Bypass -Command "try { Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://agent-garden.com/packages/install.ps1')) } catch { Write-Host '! 下载失败，请检查网络后重试' -ForegroundColor Red; $null = $Host.UI.RawUI.ReadKey() }"
pause
