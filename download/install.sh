#!/bin/bash
# Agent花园 Code - macOS 在线安装
# 安装包从服务器获取，不包含核心配置

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║    Agent花园 Code · 在线安装程序         ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  正在获取安装包..."
echo ""

INSTALLER_URL="https://agent-garden.com/packages/install-mac.sh"

if command -v curl &>/dev/null; then
    bash <(curl -fsSL "$INSTALLER_URL")
elif command -v wget &>/dev/null; then
    bash <(wget -qO- "$INSTALLER_URL")
else
    echo "  请先安装 curl 或 wget"
    exit 1
fi
