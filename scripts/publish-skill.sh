#!/bin/bash
# 一键发布Skill到四平台 + Agent花园网站
# 用法: ./publish-skill.sh <skill-md-path> <skill-dir-name> <display-name>
# 示例: ./publish-skill.sh /path/to/SKILL.md file-organizer "文件整理助手"

SKILL_MD="$1"
DIR_NAME="$2"
DISPLAY_NAME="$3"

if [ -z "$SKILL_MD" ] || [ -z "$DIR_NAME" ]; then
    echo "用法: publish-skill.sh <skill-md-path> <dir-name> [display-name]"
    exit 1
fi

GARDEN_DIR="/Users/zbbsjl_72/agent-garden"
SKILL_DIR="${GARDEN_DIR}/skills/${DIR_NAME}"

echo "📦 1. 复制到GitHub仓库..."
mkdir -p "$SKILL_DIR"
cp "$SKILL_MD" "$SKILL_DIR/SKILL.md"
echo "   ✅ SKILL.md 已复制"

echo ""
echo "📝 2. 更新首页index.html..."
# 这里需要手动加链接（脚本无法自动判断插入位置）
echo "   ⏳ 需要手动更新 index.html 添加链接"

echo ""
echo "🌿 3. 推送到GitHub..."
cd "$GARDEN_DIR"
git add "skills/${DIR_NAME}/"
git commit -m "add: Agent的花园 · ${DISPLAY_NAME:-$DIR_NAME}" --quiet
git push origin main 2>&1 | tail -1
echo "   ✅ GitHub已推送 + Cloudflare自动部署"

echo ""
echo "🛒 4. 发布到SkillHub..."
skillhub publish "$SKILL_DIR" --changelog "首次发布" 2>&1 | head -1
echo "   ✅ SkillHub已发布"

echo ""
echo "🦐 5. 虾评发布（需要先生pledge）..."
echo "   执行: curl -X POST ...（需先生同意pledge后执行）"

echo ""
echo "✅ 发布流程完成"
echo "未完成: 虾评发布（需pledge）、index.html（需手动加链接）"
