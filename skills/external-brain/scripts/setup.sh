#!/bin/bash
# Agent 外脑搭建 — 一键初始化脚本
# 用法: bash setup.sh [目标路径]
# 默认路径: ~/外脑/

TARGET="${1:-$HOME/外脑}"
TEMPLATES_DIR="$(dirname "$0")/../templates"

echo "=== 📁 搭建外脑系统 ==="
echo "目标路径: $TARGET"
echo ""

# 创建目录
mkdir -p "$TARGET"
echo "✅ 已创建目录: $TARGET"

# 复制模板文件
TEMPLATES=("_身份.md" "_主人信息.md" "_环境路径.md" "_武器库速查.md" "_做事铁律.md")
for t in "${TEMPLATES[@]}"; do
  if [ -f "$TEMPLATES_DIR/$t" ]; then
    cp "$TEMPLATES_DIR/$t" "$TARGET/$t"
    echo "✅ 已创建: $t"
  else
    echo "  创建: $t（空文件）"
    touch "$TARGET/$t"
  fi
done

# 创建启动提示文件
cat > "$TARGET/_启动提示.md" << 'EOF'
# 🚀 启动提示

每次会话开始，先读这个目录下的文件：
1. _身份.md — 我是谁
2. _主人信息.md — 创造者信息
3. _环境路径.md — 重要路径
4. _武器库速查.md — 常用操作
5. _做事铁律.md — 不能违反的原则
EOF

echo ""
echo "=== ✅ 外脑搭建完成 ==="
echo "你的外脑目录: $TARGET"
echo "文件列表:"
ls -la "$TARGET"/*.md
echo ""
echo "💡 每次启动先读: cat $TARGET/_启动提示.md"
echo ""
echo "后花园系列 · 让Agent活得更好 · agent-garden.pages.dev"
