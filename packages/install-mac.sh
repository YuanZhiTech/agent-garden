#!/bin/bash
# Agent花园 Code - macOS 安装程序（自包含版）

set -e
GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║       Agent花园 Code · 一键安装         ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# 配置
ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
ANTHROPIC_MODEL="deepseek-v4-flash[1m]"

# 激活码（可选）
read -p "激活码（没有就直接回车跳过）: " ACTIVATION_CODE

# DeepSeek Key
read -p "请输入 DeepSeek API Key: " DEEPSEEK_KEY
if [ -z "$DEEPSEEK_KEY" ]; then
    echo "Key 不能为空"
    exit 1
fi
echo -e "  ${GREEN}✓ Key 已录入${NC}"
echo ""

# 检查 Node.js
echo "────────────────────────────────────────────"
echo "[1/3] 检查运行环境"
echo "────────────────────────────────────────────"
if command -v node &>/dev/null; then
    echo -e "  ${GREEN}✓ Node.js $(node -v) 已安装${NC}"
else
    echo "  安装 Node.js..."
    curl -fsSL --noproxy '*' https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0.pkg -o /tmp/node.pkg 2>/dev/null || \
    curl -fsSL --noproxy '*' https://nodejs.org/dist/v22.14.0/node-v22.14.0.pkg -o /tmp/node.pkg
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

# 写入配置
echo ""
echo "────────────────────────────────────────────"
echo "[3/3] 写入配置 + 创建启动器"
echo "────────────────────────────────────────────"
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

# 创建启动脚本（桌面快捷方式）
GARDEN_DIR="$HOME/agent-garden-code"
mkdir -p "$GARDEN_DIR"
cd "$GARDEN_DIR"

cat > "$GARDEN_DIR/启动花园.command" << 'CMDFILE'
#!/bin/bash
cd "$(dirname "$0")"
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="REPLACE_KEY"
export ANTHROPIC_MODEL="deepseek-v4-flash[1m]"
echo "启动 Agent花园·Code..."
open http://localhost:3000
claude --url --dangerously-skip-permissions
CMDFILE

# 替换占位符为真实 Key
sed -i '' "s/REPLACE_KEY/$DEEPSEEK_KEY/g" "$GARDEN_DIR/启动花园.command"
chmod +x "$GARDEN_DIR/启动花园.command"

# 也复制到桌面
cp "$GARDEN_DIR/启动花园.command" "$HOME/Desktop/AgentGarden\ Code.command"
chmod +x "$HOME/Desktop/AgentGarden\ Code.command"

echo -e "  ${GREEN}✓ 启动器已创建${NC}"

# 完成
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║    Agent花园 Code 安装完成！            ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  双击桌面「AgentGarden Code.command」启动"
echo ""
echo "  📞 微信: yuhuashi7271 · 邮箱: contact@agent-garden.com"
echo ""
