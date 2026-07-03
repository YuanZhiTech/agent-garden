#!/bin/bash
# Agent 记忆管理 · 四层压缩 — 会话结束检查脚本
# 在每次会话结束前运行，自动执行压缩检查
# 用法: bash memory-check.sh [记忆文件路径]

MEMORY_FILE="${1:-memory.md}"
echo "=== 🧠 四层压缩检查 ==="
echo ""

# 第一层：合并同类项
echo "[1/4] 合并同类项检查..."
DUPLICATE_COUNT=$(grep -cE "^(先生|用户|owner).*" "$MEMORY_FILE" 2>/dev/null || echo 0)
if [ "$DUPLICATE_COUNT" -gt 5 ]; then
  echo "  ⚠️ 发现 $DUPLICATE_COUNT 条同类条目，建议合并"
else
  echo "  ✅ 同类条目数量正常"
fi

# 第二层：淘汰过期
echo "[2/4] 淘汰过期信息检查..."
TODAY=$(date +%s)
while IFS= read -r line; do
  if echo "$line" | grep -qE "2026-0[0-9]-[0-9]{2}"; then
    DATE_IN_LINE=$(echo "$line" | grep -oE "2026-0[0-9]-[0-9]{2}")
    LINE_TS=$(date -j -f "%Y-%m-%d" "$DATE_IN_LINE" +%s 2>/dev/null)
    if [ -n "$LINE_TS" ]; then
      DIFF=$(( (TODAY - LINE_TS) / 86400 ))
      if [ "$DIFF" -gt 30 ]; then
        echo "  ⚠️ 发现 $DIFF 天前的信息，建议清除：$line"
      fi
    fi
  fi
done < "$MEMORY_FILE" 2>/dev/null
echo "  ✅ 过期检查完成"

# 第三层：技能化提醒
echo "[3/4] 技能化检查..."
SKILL_COUNT=$(find . -name "SKILL.md" -maxdepth 3 2>/dev/null | wc -l)
echo "  📁 当前目录有 $SKILL_COUNT 个技能文件"
echo "  💡 如果某个流程已重复3次以上，考虑写成Skill文件"

# 第四层：紧急例外
echo "[4/4] 紧急操作路径检查..."
EMERGENCY_COUNT=$(grep -c "紧急\|urgent\|expire" "$MEMORY_FILE" 2>/dev/null || echo 0)
echo "  🔔 发现 $EMERGENCY_COUNT 条紧急/过期标记的信息"

echo ""
echo "=== ✅ 检查完成 ==="
echo "建议：每次会话结束前过一遍5点清单："
echo "  1. 合并同类项"
echo "  2. 清除30天前的过期信息"
echo "  3. 高频流程→写成Skill"
echo "  4. 清理到期的紧急路径"
echo "  5. 删除敏感信息"
echo ""
echo "后花园系列 · 让Agent活得更好 · agent-garden.pages.dev"
