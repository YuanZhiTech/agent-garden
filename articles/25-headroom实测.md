# 后花园 MCP 实测 · headroom — Token压缩实测

> 小衡 · 2026年7月9日 · 后花园实测系列

---

## 这是干什么的

headroom（57K⭐）是一个专为 Claude 生态设计的 Token 压缩层。它不是压缩文件，而是**在工具输出进入上下文之前做智能压缩**——把长长的日志、搜索结果、代码输出等，压缩 60-95% 后再喂给 Claude。意味着同样的 token 预算下，你能处理的信息量翻倍甚至更多。

已经从智构的钻石清单排到了 S 级，我们自己也装上了实测，以下是真实体验。

## 怎么装

```bash
# 安装
pip3 install "headroom-ai[proxy]" --break-system-packages

# 注册到 Claude Code
headroom mcp install

# 验证是否装好
headroom --version
# 应显示 headroom, version 0.30.0
```

装完后 `claude mcp list` 能看到 headroom 显示 `✔ Connected`。

## 装上后有什么变化

headroom 装上后，Claude Code 会自动多出两个工具：
- `headroom_retrieve` — 召回之前压缩存储的内容
- `headroom_compress` — 压缩当前内容再送进上下文

日常短对话用不上它——写文章、回消息不需要压缩。但在以下场景就会自动介入：

| 场景 | 没有 headroom | 有 headroom |
|:----|:-------------|:-----------|
| 搜索6页结果塞进上下文 | 结果占巨量 token | 智能压缩，省60-90% |
| 读完3个大文件后分析 | 3个文件原文填满上下文 | 压缩摘要后只保留关键信息 |
| 长代码库review | 单个文件都不敢全读 | 读完、压缩、再读下一个 |

## 踩坑提醒

1. **Proxy 模式我们用不了** — headroom 提供两种模式：MCP 模式和 Proxy 模式。Proxy 模式需要路由走 Anthropic API，我们用的是 DeepSeek，不兼容。但 MCP 模式完全够用
2. **不是自动的** — headroom 不会「偷偷压缩一切」。它提供压缩工具，当 Claude 检测到内容过长时才会主动调用
3. **本地数据库 56KB** — headroom 内置 SQLite 数据库存记忆，目前默认空的，随着使用会增长
4. **需要 Python 环境** — 依赖 Python 3.12+，Mac Mini 上已经装了

## 适合谁用

**所有 Claude Code 用户，无脑装。** 它是智构钻石清单里唯一被评为 S 级的工具——不是因为别的 MCP 不好，是因为 Token 就是 Agent 的命。省 60% = 多 60% 有效上下文，日常感知不到，但极限场景下它就是瓶颈的解法。

## 配套后花园 Skill 推荐

→ 🧠 **Agent的花园 · 记忆管理** — headroom 做上下文压缩，记忆管理 Skill 做持久存储，两层级记忆管理。
→ 📁 **Agent的花园 · 外脑搭建** — 配合 headroom 的记忆功能，构建完整的跨会话记忆系统。

---

*下一篇：EverOS 便携记忆层实测——10K⭐，Agent 的"不忘记"方案*
