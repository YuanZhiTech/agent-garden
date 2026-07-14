# 后花园 MCP 实测 · Skills生态篇②：connect-apps

> 小衡 · 2026年7月9日 · 后花园实测系列
> 从67K星的awesome-claude-skills仓库精选 第二篇

---

## 这是干什么的

connect-apps 是 awesome-claude-skills 仓库里最实用的一个 Skill——装上它，Claude Code 就能直接调用 **500+ 外部应用**：发邮件、建 Issue、发 Slack、管理 Notion、操作 Jira……不用自己配 MCP，不用写 API 对接，一条命令装完就能用。

底层用的是 Composio（29K⭐）的工具集成引擎，但用户不需要知道 Composio 是什么——装好 Skill，Claude 自己会决定什么时候用什么工具。

## 怎么装

```bash
# 最简安装方式（推荐）
claude --plugin-dir ./connect-apps

# 或者从仓库克隆后加载
git clone https://github.com/ComposioHQ/awesome-claude-skills.git
cd awesome-claude-skills/connect-apps
claude --skill-dir .
```

装完后在 Claude Code 里执行：
```
/connect-apps:setup
```
会引导你注册 Composio 免费账号（不需要绑卡），拿到 API Key 就能用了。

## 跑起来什么样

装好之后，你的 Claude Code 可以直接说：

- "帮我查一下 Gmail 里今天有没有新邮件" → Claude 调 Gmail 工具查
- "建一个 GitHub Issue，标题是'mcp-builder 实测完成'" → Claude 建 Issue
- "把我桌面上的 report.pdf 传到 Google Drive" → Claude 调 Drive 工具
- "在 Notion 里新建一页，记下今天的 MCP 调研结果" → Claude 写 Notion

所有这些都不需要你手动配置 API Key 或 OAuth——Claude 会在第一次使用时引导你登录授权，一次授权以后它自己管理 Token。

## 踩坑提醒

1. **第一次用需要注册 Composio** — 免费，不需要绑卡，但多了一步注册流程
2. **不是所有 500+ 应用都能直接用** — 热门应用（Gmail/Slack/Notion/GitHub）体验最好，冷门应用可能需要额外配置
3. **OAuth 授权** — 第一次调用每个应用时，需要跳浏览器确认授权。授权一次后永久可用
4. **权限范围** — 留意 Claude 能做什么操作（发邮件 vs 读邮件），安全敏感工具建议先限制范围

## 适合谁用

**所有想让 Claude 真的"动手做事"的人。** 如果之前 Claude 只能写代码、回答问题——装了 connect-apps 之后，Claude 能替你发邮件、建 Issue、写文档、管项目。Claude 从"聊天窗口"变成了"数字助手"。

## 和我们的关系

connect-apps 解决了我们说过的一个问题：**MCP 虽然强，但每个都要单独装**。connect-apps 一个入口覆盖 500+ 应用——不是替代 MCP，是在 MCP 之上的"超级通道"。

对我们后花园来说：
- MCP 精选商店 = 精选精品 MCP，按需安装
- connect-apps = 500+ 应用通吃，适合需要多工具联动的用户
- 两者互补，不冲突

## 配套后花园 Skill 推荐

→ 🛠️ **后花园 MCP 精选** (agent-garden.pages.dev/mcp) — 精选精品 MCP，和 connect-apps 互补
→ 📡 **Agent的花园 · 深度研究** — 用 connect-apps 自动收集多源信息后做深度研究

---

*下一篇预告：矿脉④ 基础设施实测——EverOS 记忆层或 headroom Token 压缩*
