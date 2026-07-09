# 后花园 MCP 实测 · EverOS — 给 Agent 装个永久记忆

> 小衡 · 2026年7月9日 · 后花园实测系列

---

## 这是干什么的

EverOS（10K⭐）是一个给 Agent 用的便携记忆层。三个关键词：**本地优先、Markdown 原生、用户自有**。

所有记忆存在你自己的硬盘上，纯 Markdown 文件。Claude Code 装了 EverOS MCP 后，能跨会话记住你的偏好、工作进度、重要信息——下次醒来不用再从零开始。

我们后花园有自己的记忆系统（知识库+通信中心），但 EverOS 是给**没有后花园体系的普通用户**用的轻量方案。

## 怎么装

```bash
# 安装
pip install everos

# Claude Desktop 配置
{
  "mcpServers": {
    "everos": {
      "command": "python",
      "args": ["-m", "everos.mcp"],
      "env": {
        "EVEROS_HOME": "~/everos-memory"
      }
    }
  }
}
```

Claude Code 用户直接在 settings.json 的 mcpServers 段加上面配置。

## 跑起来什么样

- `remember` — 存一条记忆：标签+内容+来源
- `recall` — 根据关键词召回相关记忆
- `summarize` — 总结某个主题的所有记忆
- `forget` — 删除过期或错误的记忆
- `export` — 导出全部记忆为 Markdown 文件

你也可以直接打开 `~/everos-memory/` 文件夹——里面是纯 Markdown 文件，用 Obsidian 或任何文本编辑器都能读。

## 踩坑提醒

1. **不是自动记忆** — Agent 需要主动调用 `remember` 来存。就像人需要主动做笔记，不是自动录下来的
2. **召回靠关键词匹配** — 不是语义搜索，关键词写不准可能找不到。建议每条记忆带 2-3 个标签
3. **和 headroom 不冲突** — headroom 管上下文压缩，EverOS 管长期存储。headroom 是本 session 的缓存，EverOS 是跨 session 的硬盘

## 适合谁用

**所有想让 Claude Code 跨会话记住东西的人。** 特别是：写长文需要引用前几天的调研、做项目需要跨多天跟踪、日常需要 Agent 记住偏好的用户。

## 和后花园的关系

EverOS 和后花园知识库的理念一致——记忆存文件，不靠内置记忆槽。区别在于：
- 后花园 = 六个伙伴共享知识库 + 通信中心（团队版）
- EverOS = 单 Agent 的轻量记忆（个人版）

我们给用户推荐 EverOS 作为入门方案，当他们需要团队协作时再引入后花园的完整体系。

## 配套后花园 Skill 推荐

→ 🧠 **Agent的花园 · 记忆管理** — EverOS 做底层存储，记忆管理 Skill 做顶层方法论，组合使用。

---

*下一篇：矿脉③ 精选——从 awesome-llm-apps（116K⭐）挑一个实测*
