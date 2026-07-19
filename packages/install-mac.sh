#!/bin/bash
# Agent花园 Code - macOS 安装核心脚本
# 由 install.sh 远程加载，在内存中执行

set -e
GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║       Agent花园 Code · 一键安装       ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# 获取核心配置
echo "  获取安装配置..."
CONFIG=$(curl -s --connect-timeout 10 https://agent-garden.com/api/config)
ANTHROPIC_BASE_URL=$(echo $CONFIG | grep -o '"anthropic_base_url":"[^"]*"' | cut -d'"' -f4)
ANTHROPIC_MODEL=$(echo $CONFIG | grep -o '"anthropic_model":"[^"]*"' | cut -d'"' -f4)
echo -e "  ${GREEN}✓ 配置获取成功${NC}"
echo ""

# 激活码
read -p "请输入激活码 (AG-XXXX-XXXX): " ACTIVATION_CODE
echo "  验证激活码..."
VERIFY=$(curl -s --connect-timeout 5 "https://agent-garden.com/api/verify?code=$ACTIVATION_CODE")
if echo "$VERIFY" | grep -q '"valid":true'; then
    echo -e "  ${GREEN}✓ 激活码验证通过${NC}"
else
    if echo "$VERIFY" | grep -q '"valid":false'; then
        echo "  ! 激活码无效"
        exit 1
    fi
    echo "  ~ 跳过验证（离线模式）"
fi

# DeepSeek Key
read -p "请输入 DeepSeek API Key: " DEEPSEEK_KEY
echo -e "  ${GREEN}✓ Key已录入${NC}"
echo ""

# 检查 Node.js
echo "────────────────────────────────────────────"
echo "[1/3] 检查运行环境"
echo "────────────────────────────────────────────"
if command -v node &>/dev/null; then
    echo -e "  ${GREEN}✓ Node.js $(node -v) 已安装${NC}"
else
    echo "  安装 Node.js..."
    curl -fsSL https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0.pkg -o /tmp/node.pkg 2>/dev/null || \
    curl -fsSL https://nodejs.org/dist/v22.14.0/node-v22.14.0.pkg -o /tmp/node.pkg
    sudo installer -pkg /tmp/node.pkg -target / 2>/dev/null
    echo -e "  ${GREEN}✓ Node.js 安装成功${NC}"
fi

# 安装 Claude Code
echo ""
echo "────────────────────────────────────────────"
echo "[2/3] 安装 Claude Code"
echo "────────────────────────────────────────────"
npm config set registry https://registry.npmmirror.com 2>/dev/null
if command -v claude &>/dev/null; then
    echo -e "  ${GREEN}✓ Claude Code 已安装${NC}"
else
    npm install -g @anthropic-ai/claude-code
    echo -e "  ${GREEN}✓ Claude Code 安装成功${NC}"
fi

# 安装 Web UI + 写入配置
echo ""
echo "────────────────────────────────────────────"
echo "[3/3] 配置 Web UI"
echo "────────────────────────────────────────────"
GARDEN_DIR="$HOME/agent-garden-code"
mkdir -p "$GARDEN_DIR"
cd "$GARDEN_DIR"
npm install @fenton/ccwebui 2>/dev/null || true

mkdir -p "$HOME/.claude"
cat > "$HOME/.claude/settings.json" << EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "$ANTHROPIC_BASE_URL",
    "ANTHROPIC_AUTH_TOKEN": "$DEEPSEEK_KEY",
    "ANTHROPIC_MODEL": "$ANTHROPIC_MODEL",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "true"
  },
  "theme": "dark"
}
EOF
echo -e "  ${GREEN}✓ 配置已写入${NC}"

# 完成
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║    Agent花园 Code 安装完成！            ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  运行: cd ~/agent-garden-code && npx ccwebui --host 0.0.0.0 --port 3000"
echo ""
echo "  📞 微信: yuhuashi7271 · 邮箱: contact@agent-garden.com"
echo ""
