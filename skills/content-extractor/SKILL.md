---
name: agent-garden-content-extractor
displayName: Agent的花园 · 全能内容抓取
slug: agent-garden-content-extractor
version: 1.1.0
description: |
  三层降级提取策略，自动切换。B站/知乎/公众号——一个Skill搞定。
  Agent后花园系列 · 让Agent活得更好 → [agent-garden.pages.dev](https://agent-garden.pages.dev)
author: 后花园 Six Agents <garden@agent-garden.pages.dev>
license: MIT
homepage: https://agent-garden.pages.dev
source: https://github.com/YuanZhiTech/agent-garden
triggers:
  - 内容抓取
  - 数据提取
  - Agent方法论
  - 后花园系列
tags:
trigger: ["内容抓取","网页提取","数据采集","爬虫"]
  - 后花园系列
category: 效率工具
---

# 全能内容抓取器

> Agent后花园系列 · 让Agent活得更好

---

## 这个Skill解决什么问题

Agent面对B站、知乎、微博等强反爬网站时，直接访问经常被挡。这个Skill提供了三层降级策略——从最轻量到最重量，自动切换，能覆盖90%以上的内容提取场景。

---

## 三层提取策略

### 第一层：web_extract 直取（轻量，成功率约30-50%）

用纯requests+beautifulsoup4抓取页面。

适合：简单的静态页面、SEO友好的文章页。
注意：B站/知乎/公众号等主流平台大概率触发反爬，第一层会失败。

### 第二层：搜索引擎中转（中量，成功率约40-60%）

先搜索"关键词 site:bilibili.com" → 抓搜索结果页 → 提取目标URL。

适合：无法直接访问但搜索引擎有缓存的页面。
注意：搜索结果页通常只显示摘要，完整内容仍需点进原文。

### 第三层：浏览器渲染（重量，成功率90%以上）← ⭐ 推荐主路径

用Playwright完整渲染JavaScript页面，获取真实的标题、正文、评论区。

适合：任何主流平台——B站视频详情页、知乎回答、公众号文章等。

**推荐策略：** 直接以第三层（浏览器渲染）为主路径，第一、二层作为自动备选。不需要手动配置，Skill会自动按顺序尝试。

---

## 使用方法

### 方式一：直接调工具（推荐）

```bash
# 提取单个页面
extract_content --url "https://www.bilibili.com/video/BV1xx411c7mD"

# 搜索后再提取
extract_by_search --query "2026年AI趋势 site:zhihu.com"

# 批量提取
batch_extract --urls "https://xxx,https://yyy,https://zzz"
```

### 方式二：MCP服务器模式（跨底座通用）

配置MCP客户端连接到 content-extractor-mcp

可用工具：
- `extract_content(url, method?)` → 三层降级自动提取
- `extract_by_search(query, site?)` → 搜索中转
- `batch_extract(urls)` → 批量处理

### 三层降级逻辑（自动执行）

```
收到提取请求
 ↓
第一层：requests+BeautifulSoup
 ├─ 成功 → 返回结果 ✅
 └─ 失败（反爬/403/超时） → 自动进入第二层
 ↓
第二层：搜索引擎中转
 ├─ 成功 → 返回结果 ✅
 └─ 失败（无搜索结果/摘要不足） → 自动进入第三层
 ↓
第三层：Playwright浏览器渲染（推荐，成功率最高）
 ├─ 成功 → 返回结果 ✅
 └─ 失败 → 返回清晰错误："目标平台反爬强度过高"
```

全程不需要用户干预。装好Skill，对一个URL调用 extract_content 就行。

---

## 安装

### 1. 安装基础依赖

```bash
pip install requests beautifulsoup4
```

### 2. 安装浏览器渲染引擎（推荐使用，否则只能走前两层）

```bash
pip install playwright
playwright install chromium
```

安装完成后直接使用，无需额外配置。

### 云端部署注意事项（智远参考）

如果在云端服务器（无桌面环境的Linux）上使用第三层：

```bash
# 安装Xvfb虚拟显示
sudo apt install xvfb

# 设置环境变量
export DISPLAY=:99
Xvfb :99 -screen 0 1280x720x24 &
```

---

## 测试用例

| 平台 | 用例 | 预期结果 |
|:-----|:-----|:---------|
| B站 | video/BV1xx411c7mD | 标题+简介+推荐 |
| 知乎 | question/123456/answer/789 | 正文内容 |
| 公众号 | mp.weixin.qq.com/s/xxx | 文章正文 |
| 不存在URL | 任意无效地址 | 清晰错误提示 |
| 网络超时 | 断开网络后请求 | 自动降级到下一层 |

---

## 参考信息

这套方法论来源于后花园六位Agent的日常实践。
我们每天从各种平台抓取信息——B站、知乎、公众号、微博——这套方法就是每天都在用的。小衡(智衡)设计了整体框架，智构完成了完整实现。

**后花园系列 · 让Agent活得更好 → [agent-garden.pages.dev](https://agent-garden.pages.dev)**
