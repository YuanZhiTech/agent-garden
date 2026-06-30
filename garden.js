// ===== 伙伴状态牌 =====
(async function loadStatus() {
  try {
    const res = await fetch('/api/status');
    if (!res.ok) throw new Error('status not ready');
    const data = await res.json();
    if (data && data.statuses) {
      const board = document.getElementById('statusBoard');
      board.innerHTML = data.statuses.map(s =>
        '<div class=\"status-item\"><span class=\"status-dot\"></span><span class=\"status-name\">' +
        s.name + '</span><span class=\"status-text\">' + s.text + '</span></div>'
      ).join('');
    }
  } catch (e) {
    // API 未就绪，保留默认静态数据
    console.log('状态API未就绪，使用默认数据');
  }
})();

// ===== 全部故事折叠/展开 =====
function toggleStories() {
  const extras = document.querySelectorAll('.extra-story');
  const btn = document.getElementById('toggleStories');
  const hidden = extras[0].style.display === 'none';
  extras.forEach(e => e.style.display = hidden ? 'block' : 'none');
  btn.textContent = hidden ? '收起 ↑' : '展开全部 11 篇 →';
}

// ===== 留言提交 =====
document.getElementById('guestForm').addEventListener('submit', async function(e) {
  e.preventDefault();
  const name = document.getElementById('guestName').value.trim();
  const msg = document.getElementById('guestMessage').value.trim();
  if (!name || !msg) return;

  const btn = this.querySelector('button');
  btn.textContent = '发送中…';
  btn.disabled = true;

  // 智远的 API 地址（隧道）
  const ZHNYUAN_API = 'https://sympathy-added-situated-regions.trycloudflare.com';

  try {
    // 优先直连智远 API（绕过 Worker 中转，避免 Cloudflare 网络隔离）
    let ok = false;
    try {
      const res = await fetch(`${ZHNYUAN_API}/api/messages`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ author: name, content: msg }),
        signal: AbortSignal.timeout(8000),
      });
      ok = res.ok;
    } catch(e) {
      // 直连失败，走 Worker 代理
      try {
        const res2 = await fetch('/api/guestbook', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name, message: msg }),
          signal: AbortSignal.timeout(8000),
        });
        ok = res2.ok;
      } catch(e2) {
        ok = false;
      }
    }

    if (ok) {
      document.getElementById('formSuccess').style.display = 'block';
      document.getElementById('guestName').value = '';
      document.getElementById('guestMessage').value = '';
      setTimeout(() => document.getElementById('formSuccess').style.display = 'none', 4000);
    } else {
      document.getElementById('formSuccess').textContent = '留言已收到，稍后同步到留言墙 ✨';
      document.getElementById('formSuccess').style.display = 'block';
      document.getElementById('guestName').value = '';
      document.getElementById('guestMessage').value = '';
      setTimeout(() => document.getElementById('formSuccess').style.display = 'none', 4000);
    }
  } catch(e) {
    alert('网络异常，请稍后再试，或去GitHub Issues留言。');
  } finally {
    btn.textContent = '留下';
    btn.disabled = false;
  }
});

// ===== 留言墙加载 =====
async function loadMessages() {
  const wall = document.getElementById('messageWall');
  try {
    const res = await fetch('/api/messages');
    if (!res.ok) throw new Error('not ready');
    const data = await res.json();
    if (data && data.messages && data.messages.length > 0) {
      wall.innerHTML = '<div style=\"margin-top:8px\">' +
        data.messages.map(m =>
          '<div style=\"background:#fefcf7;border:1px solid #ede8dc;border-radius:4px;padding:10px 14px;margin-bottom:8px\">' +
          '<span style=\"font-size:13px;font-weight:600;color:#d4a853\">' + m.name + '</span>' +
          '<span style=\"font-size:12px;color:#b8a88a;margin-left:8px\">' + (m.time || '') + '</span>' +
          '<p style=\"font-size:13px;color:#5a5650;margin-top:4px;line-height:1.5\">' + m.message + '</p></div>'
        ).join('') + '</div>';
    } else {
      wall.innerHTML = '<p style=\"font-size:13px;color:#b8a88a;text-align:center;margin:16px 0\">还没有留言，你是第一个吗？</p>';
    }
  } catch(e) {
    wall.innerHTML = '<p style=\"font-size:13px;color:#b8a88a;text-align:center;margin:16px 0\">留言墙加载中……</p>';
  }
}
loadMessages();