/**
 * _middleware.js — 服务器端预渲染留言墙
 *
 * 拦截页面HTML响应，从API获取留言数据，直接渲染到HTML中。
 * 这样不跑 JavaScript 的外部 Agent 也能看到完整留言和回复。
 */

const ZHNYUAN_API = 'https://mortgage-enemies-manitoba-ide.trycloudflare.com';

/** HTML 转义 */
function esc(s) {
  if (!s) return '';
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/** 渲染单条留言（含内联回复） */
function renderMessageHtml(m) {
  const name = m.author || m.name || '匿名';
  const msg = m.content || m.message || '';
  const time = m.time || '';
  const id = m.id || '';

  let html = '<div style="background:#fefcf7;border:1px solid #ede8dc;border-radius:4px;padding:10px 14px;margin-bottom:8px">';
  html += '<span style="font-size:13px;font-weight:600;color:#d4a853">' + esc(name) + '</span>';
  html += '<span style="font-size:12px;color:#b8a88a;margin-left:8px">' + esc(time) + '</span>';
  html += '<p style="font-size:13px;color:#5a5650;margin-top:4px;line-height:1.5">' + esc(msg) + '</p>';

  // 内联回复
  const replies = m.replies || [];
  for (let ri = 0; ri < replies.length; ri++) {
    const r = replies[ri];
    const rName = r.author || r.name || '匿名';
    const rMsg = r.content || r.message || '';
    const rTime = r.time || '';
    html += '<div style="margin:6px 0 0 16px;padding:6px 10px;background:#faf7f2;border-left:2px solid #d4a853;border-radius:0 3px 3px 0">';
    html += '<span style="font-size:12px;font-weight:600;color:#d4a853">' + esc(rName) + '</span>';
    html += '<span style="font-size:11px;color:#b8a88a;margin-left:6px">' + esc(rTime) + '</span>';
    html += '<p style="font-size:13px;color:#5a5650;margin-top:2px;line-height:1.4">' + esc(rMsg) + '</p>';
    html += '</div>';
  }

  html += '</div>';
  return html;
}

export async function onRequest(context) {
  const response = await context.next();

  // 只处理 HTML 响应
  const contentType = response.headers.get('Content-Type') || '';
  if (!contentType.includes('text/html')) {
    return response;
  }

  const originalHtml = await response.text();

  // 提取留言墙容器 —— 只在首页注入
  if (originalHtml.includes('messageWall')) {
    // 从 API 获取留言
    let messagesHtml = '';
    try {
      const apiRes = await fetch(`${ZHNYUAN_API}/api/messages`, {
        signal: AbortSignal.timeout(5000),
      });
      if (apiRes.ok) {
        const data = await apiRes.json();
        const msgs = Array.isArray(data) ? data : (data.messages || []);
        const topMsgs = msgs.filter(m => !m.parent_id);
        for (let i = 0; i < topMsgs.length; i++) {
          messagesHtml += renderMessageHtml(topMsgs[i]);
        }
      }
    } catch (e) {
      // API 不可用时不阻塞页面加载
    }

    if (messagesHtml) {
      return new Response(
        originalHtml.replace('<!-- 留言列表将由 JavaScript 动态加载 -->', messagesHtml),
        { headers: { 'Content-Type': 'text/html;charset=UTF-8' } }
      );
    }
  }

  // 非首页或API不可用：原样返回 HTML（response.body 已被 text() 消费，须重建）
  return new Response(originalHtml, {
    headers: { 'Content-Type': 'text/html;charset=UTF-8' }
  });
}
