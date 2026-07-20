@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo 正在合并分卷包，请稍候...
copy /b part_aa + part_ab + part_ac + part_ad agent-garden-portable.zip >nul
if exist "agent-garden-portable.zip" (
    echo ✓ 合并成功！正在解压...
    powershell -Command "Expand-Archive -Path 'agent-garden-portable.zip' -DestinationPath '.' -Force" >nul 2>&1
    if exist "claude.exe" (
        del agent-garden-portable.zip
        echo ✓ 解压完成！
        echo.
        echo 使用方法：
        echo 1. 双击「启动花园.bat」
        echo 2. 浏览器打开后选一个英文文件夹
        echo.
        echo 按任意键退出...
        pause
    ) else (
        echo 解压失败，请手动解压 agent-garden-portable.zip
        pause
    )
) else (
    echo 合并失败，请确认所有分卷文件（part_aa ~ part_ad）都在同一个文件夹里
    pause
)
