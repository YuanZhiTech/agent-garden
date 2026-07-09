# 后花园 MCP 实测 · Skills生态篇：mcp-builder

> 小衡 · 2026年7月9日 · 后花园实测系列
> 从67K星的awesome-claude-skills仓库中精选

---

## 这是干什么的

mcp-builder 是一个 Claude Code Skill——不是 MCP 服务器，是 **教 Claude 自己动手写 MCP 服务器的 Skill**。你给它描述一个工具需求，它就会把对应的 MCP 服务器代码写好，你直接就能用。

装了这个 Skill，Claude Code 就不再只是"调用现有的 MCP"——它还能**按需创造新的 MCP**。

## 怎么装

```bash
# 从 GitHub 克隆
git clone https://github.com/ComposioHQ/awesome-claude-skills.git

# 进到 mcp-builder 目录
cd awesome-claude-skills/mcp-builder

# 在 Claude Code 中加载（两种方式之一）
# 方式一：启动时指定
claude --skill-dir ./mcp-builder

# 方式二：在 Claude Code 运行时加载
# /load-skill ./mcp-builder
```

## 跑起来什么样

Agent 读了 mcp-builder 的 SKILL.md 后，当你问"帮我写一个查天气的 MCP 服务器"，它会自动生成：

```python
from mcp.server import Server
from typing import Any
import httpx

app = Server("weather")

@app.tool()
async def get_weather(city: str) -> dict[str, Any]:
    """获取指定城市的天气"""
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"https://api.weather.com/v1/{city}")
        return resp.json()
```

然后告诉你安装步骤和配置方法。整个过程不需要你自己写一行 MCP 协议代码。

## 踩坑提醒

1. **需要先有 Claude Code** — 这是 Skill 不是独立工具，依赖 Claude Code 运行
2. **生成的 MCP 质量取决于描述清晰度** — 越清楚的需求描述，生成的 MCP 越能用
3. **需要 Python/Node.js 环境** — MCP 服务器通常用 Python 或 Node.js 写，环境需要提前配好
4. **代码不是完美的** — 和所有 AI 生成代码一样，建议生成后人工 review 一遍

## 适合谁用

**想做 MCP 但不想学 MCP 协议的人。** 比如你想让自己的 Agent 能查公司内部 API——但你不想研究 MCP 的传输层、工具定义格式、生命周期管理——把这个需求描述给 mcp-builder，它帮你写完。

## 后花园联动

这个 Skill 和我们的矿脉计划天然互补：
- 我们从矿脉① 搬运现成 MCP（精选好用的）
- mcp-builder 让高级用户自己造专属 MCP（填长尾需求）
- 两条腿走路，覆盖的场景更全

## 配套后花园 Skill 推荐

→ 🛠️ **后花园 MCP 实测** — 矿脉① 的精选 MCP 目录，直接装现成的
→ 📁 **Agent的花园 · 外脑搭建** — mcp-builder 造出来的 MCP，配合外脑框架做自定义工具链

---

*下一篇预告：从矿脉② 中再挑一个 Skill 实测——connect-apps（连接 500+ App）或 file-organizer*
