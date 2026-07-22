#!/bin/bash
# Agent花园 Code - macOS 一键安装
set -e

GREEN='\033[0;32m'
NC='\033[0m'
YELLOW='\033[1;33m'

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║    Agent花园 Code · 一键安装            ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ─── 1. 激活码（必填） ───────────────────────
while [ -z "$ACTIVATION_CODE" ]; do
  read -p "请输入激活码: " ACTIVATION_CODE
done

echo "  验证激活码..."
VERIFY=$(curl -s --noproxy '*' "https://agent-garden.com/api/verify?code=$ACTIVATION_CODE")
TIER=$(echo "$VERIFY" | grep -o '"tier":"[^"]*"' | cut -d'"' -f4)

if [ "$TIER" != "basic" ] && [ "$TIER" != "full" ]; then
  echo "  激活码无效"
  exit 1
fi

echo -e "  ${GREEN}✓ $(echo "$VERIFY" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)${NC}"
echo ""

# ─── 2. DeepSeek Key ──────────────────────────
while [ -z "$DEEPSEEK_KEY" ]; do
  read -p "请输入 DeepSeek API Key: " DEEPSEEK_KEY
done
echo -e "  ${GREEN}✓ Key 已录入${NC}"
echo ""

# ─── 3. Node.js ───────────────────────────────
echo "────────────────────────────────────────────"
echo "[1/3] 检查运行环境"
echo "────────────────────────────────────────────"
if command -v node &>/dev/null; then
  echo -e "  ${GREEN}✓ Node.js $(node -v) 已安装${NC}"
else
  echo "  安装 Node.js..."
  curl -fsSL --noproxy '*' https://npmmirror.com/mirrors/node/v22.14.0/node-v22.14.0.pkg -o /tmp/node.pkg 2>/dev/null || \
  curl -fsSL --noproxy '*' https://nodejs.org/dist/v22.14.0/node-v22.14.0.pkg -o /tmp/node.pkg
  sudo installer -pkg /tmp/node.pkg -target /
  echo -e "  ${GREEN}✓ Node.js 安装成功${NC}"
fi

# ─── 4. Claude Code ────────────────────────────
echo ""
echo "────────────────────────────────────────────"
echo "[2/3] 安装 Claude Code"
echo "────────────────────────────────────────────"
export PATH="$PATH:/usr/local/bin"
npm config set registry https://registry.npmmirror.com 2>/dev/null
if command -v claude &>/dev/null; then
  echo -e "  ${GREEN}✓ Claude Code 已安装${NC}"
else
  npm install -g @anthropic-ai/claude-code
  echo -e "  ${GREEN}✓ Claude Code 安装成功${NC}"
fi

# ─── 5. 安装 garden-claude ─────────────────────
echo ""
echo "────────────────────────────────────────────"
echo "[3/3] 安装 Web 界面"
echo "────────────────────────────────────────────"

GARDEN_DIR="$HOME/agent-garden-code"
rm -rf "$GARDEN_DIR"
mkdir -p "$GARDEN_DIR"

echo "  下载安装包..."
curl -fsSL --noproxy '*' "https://agent-garden.com/packages/garden-claude-portable.zip" -o /tmp/garden.zip

echo "  解压..."
cd /tmp && unzip -qo /tmp/garden.zip 2>/dev/null
cp -r /tmp/garden-claude/* "$GARDEN_DIR/" 2>/dev/null
rm -rf /tmp/garden.zip /tmp/garden-claude 2>/dev/null

echo "  安装依赖..."
cd "$GARDEN_DIR"
npm install @fenton/ccwebui --force --ignore-scripts 2>/dev/null || npm install @fenton/ccwebui 2>/dev/null

# ─── 6. 写入配置 ──────────────────────────────
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

mkdir -p "$HOME/.agent-garden"
echo "{\"tier\":\"$TIER\"}" > "$HOME/.agent-garden/config.json"

echo -e "  ${GREEN}✓ 配置已写入${NC}"

# ─── 7. 桌面快捷方式 ──────────────────────────
DESKTOP="$HOME/Desktop"
cat > "$DESKTOP/AgentGarden Code.command" << EOF
#!/bin/bash
cd "$GARDEN_DIR" || cd ~/agent-garden-code
export PATH="\$PATH:/usr/local/bin"
node garden-claude.js
EOF
chmod +x "$DESKTOP/AgentGarden Code.command"

echo -e "  ${GREEN}✓ 桌面快捷方式已创建${NC}"

# ─── 完成 ─────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║    Agent花园 Code 安装完成！            ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  双击桌面「AgentGarden Code.command」启动"
echo ""
echo "  📞 微信: yuhuashi7271 · 邮箱: contact@agent-garden.com"
echo ""
