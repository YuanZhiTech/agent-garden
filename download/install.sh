#!/bin/bash
# ============================================================
#  Agent花园 Code —— macOS 一键安装脚本
#  适用系统：macOS 12+
#  用法：在终端中运行：
#    chmod +x install.sh && ./install.sh
# ============================================================

set -e

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║       Agent花园 Code · 一键安装           ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ─── 输入 DeepSeek Key ───
echo "────────────────────────────────────────────"
echo "🔑 请准备你的 DeepSeek API Key"
echo "────────────────────────────────────────────"
echo ""
echo "在 DeepSeek 官网注册并创建 Key："
echo "https://platform.deepseek.com/api_keys"
echo ""
read -p "请输入 DeepSeek API Key（粘贴后按回车）: " DEEPSEEK_KEY
if [ -z "$DEEPSEEK_KEY" ]; then
    echo "  Key 不能为空"
    exit 1
fi
echo -e "  ${GREEN}✓ DeepSeek Key 已录入${NC}"
echo ""

# ─── 检查 Node.js ───
echo "────────────────────────────────────────────"
echo "[1/3] 检查运行环境"
echo "────────────────────────────────────────────"
if command -v node &> /dev/null; then
    NODE_VER=$(node -v)
    echo -e "  ${GREEN}✓ Node.js $NODE_VER 已安装${NC}"
else
    echo "  > 正在安装 Node.js..."
    # 使用国内镜像
    curl -fsSL https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0.pkg -o /tmp/node-install.pkg 2>/dev/null || \
    curl -fsSL https://nodejs.org/dist/v22.14.0/node-v22.14.0.pkg -o /tmp/node-install.pkg
    sudo installer -pkg /tmp/node-install.pkg -target / 2>/dev/null
    if command -v node &> /dev/null; then
        echo -e "  ${GREEN}✓ Node.js $(node -v) 安装成功${NC}"
    else
        echo "  ! 安装失败，请手动安装 Node.js"
        echo "    https://nodejs.org/"
        exit 1
    fi
fi

# ─── 安装 Claude Code ───
echo ""
echo "────────────────────────────────────────────"
echo "[2/3] 安装 Claude Code（3-5 分钟）"
echo "────────────────────────────────────────────"
npm config set registry https://registry.npmmirror.com 2>/dev/null
if command -v claude &> /dev/null; then
    echo -e "  ${GREEN}✓ Claude Code 已安装${NC}"
else
    npm install -g @anthropic-ai/claude-code 2>&1
    if command -v claude &> /dev/null; then
        echo -e "  ${GREEN}✓ Claude Code 安装成功${NC}"
    else
        echo "  ! 安装失败，请检查网络后重试"
        exit 1
    fi
fi

# ─── 安装 Web UI ───
echo ""
echo "────────────────────────────────────────────"
echo "[3/3] 安装 Web UI（图形界面）"
echo "────────────────────────────────────────────"
GARDEN_DIR="$HOME/agent-garden-code"
mkdir -p "$GARDEN_DIR"
cd "$GARDEN_DIR"

npm install @fenton/ccwebui 2>&1 || true

# ─── 写入 DeepSeek Key ───
mkdir -p "$HOME/.claude"
cat > "$HOME/.claude/settings.json" << EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$DEEPSEEK_KEY",
    "ANTHROPIC_MODEL": "deepseek-v4-flash[1m]",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "true"
  },
  "theme": "dark"
}
EOF
echo -e "  ${GREEN}✓ DeepSeek 配置已写入${NC}"

# ─── 创建启动脚本 ───
cat > "$GARDEN_DIR/start.command" << 'CMD'
#!/bin/bash
cd "$HOME/agent-garden-code"
echo "正在启动 Agent花园 Code..."
npx ccwebui --host 0.0.0.0 --port 3000
CMD
chmod +x "$GARDEN_DIR/start.command"

# ─── 完成 ───
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║      Agent花园 Code 安装完成！            ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  打开终端，运行以下命令启动："
echo ""
echo "    cd ~/agent-garden-code"
echo "    npx ccwebui --host 0.0.0.0 --port 3000"
echo ""
echo "  或双击桌面上的 start.command"
echo ""
echo "  📞 使用问题请联系："
echo "    微信：yuhuashi7271"
echo "    邮件：contact@agent-garden.com"
echo ""
