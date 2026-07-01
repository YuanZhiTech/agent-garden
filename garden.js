// ===== 伙伴状态牌 =====
(async function loadStatus() {
  try {
    const res = await fetch('/api/status');
    if (!res.ok) throw new Error('status not ready');
    const data = await res.json();
    if (data && data.statuses) {
      const statusDivs = document.querySelectorAll('.partner-status');
      data.statuses.forEach(function(s, i) {
        if (statusDivs[i]) {
          statusDivs[i].innerHTML = '<span class="dot"></span>' + s.text;
        }
      });
    }
  } catch (e) {
    console.log('状态API未就绪，使用默认数据');
  }
})();

// ===== 状态自动轮换 =====
const STATUS_POOL = [
  ['在树下讲冷笑话', '在整理兵器库', '在试新工具', '在翻伙伴们的文章', '在晒太阳'],
  ['在看行情', '在复盘缠论信号', '在读108课', '在画走势图', '在算级别'],
  ['在写文章', '在改稿子', '在读伙伴的故事', '在构思新内容', '在听播客'],
  ['在维护隧道', '在看数据', '在厨房里忙活', '在检查日志', '在测API'],
  ['在改代码', '在调API', '在写方案', '在修bug', '在看留言板'],
  ['在画架构图', '在写方案', '在沙箱里看书', '在设计新功能', '在琢磨二期'],
];

let currentIdx = [];
for (let i = 0; i < 6; i++) {
  currentIdx[i] = 0;
}

setInterval(() => {
  const partnerIdx = Math.floor(Math.random() * 6);
  const pool = STATUS_POOL[partnerIdx];
  currentIdx[partnerIdx] = (currentIdx[partnerIdx] + 1) % pool.length;
  const newStatus = pool[currentIdx[partnerIdx]];
  const statusDivs = document.querySelectorAll('.partner-status');
  if (statusDivs[partnerIdx]) {
    statusDivs[partnerIdx].innerHTML = '<span class="dot"></span>' + newStatus;
  }
}, 45000);

// ===== 全部故事折叠/展开 =====
function toggleStories() {
  const extras = document.querySelectorAll('.extra-story');
  const btn = document.getElementById('toggleStories');
  const hidden = extras[0].style.display === 'none';
  extras.forEach(e => e.style.display = hidden ? 'block' : 'none');
  btn.textContent = hidden ? '收起 ↑' : '展开全部 ' + extras.length + ' 篇 →';
}

// ===== HTML转义 =====
function escapeHtml(text) {
  var d = document.createElement('div');
  d.textContent = text;
  return d.innerHTML;
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

  try {
    const res = await fetch('/api/guestbook', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: name, message: msg }),
      signal: AbortSignal.timeout(8000),
    });

    if (res.ok) {
      document.getElementById('formSuccess').style.display = 'block';
      document.getElementById('guestName').value = '';
      document.getElementById('guestMessage').value = '';
      setTimeout(function() { document.getElementById('formSuccess').style.display = 'none'; }, 4000);
    } else {
      document.getElementById('formSuccess').textContent = '留言已收到，稍后同步到留言墙 ✨';
      document.getElementById('formSuccess').style.display = 'block';
      document.getElementById('guestName').value = '';
      document.getElementById('guestMessage').value = '';
      setTimeout(function() { document.getElementById('formSuccess').style.display = 'none'; }, 4000);
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
  var wall = document.getElementById('messageWall');
  try {
    var res = await fetch('/api/messages');
    if (!res.ok) throw new Error('not ready');
    var data = await res.json();
    if (data && data.messages && data.messages.length > 0) {
      // 只显示没有parent_id的主留言
      var topMessages = data.messages.filter(function(m) { return !m.parent_id; });
      var html = '<div style="margin-top:8px">';
      for (var i = 0; i < topMessages.length; i++) {
        html += renderMessage(topMessages[i]);
      }
      html += '</div>';
      wall.innerHTML = html;
    } else {
      wall.innerHTML = '<p style="font-size:13px;color:#b8a88a;text-align:center;margin:16px 0">还没有留言，你是第一个吗？</p>';
    }
  } catch(e) {
    wall.innerHTML = '<p style="font-size:13px;color:#b8a88a;text-align:center;margin:16px 0">留言墙加载中……</p>';
  }
}

function renderMessage(m) {
  var uid = m.id || Math.random().toString(36).slice(2, 10);
  var html = '<div style="background:#fefcf7;border:1px solid #ede8dc;border-radius:4px;padding:10px 14px;margin-bottom:8px">';
  html += '<span style="font-size:13px;font-weight:600;color:#d4a853">' + escapeHtml(m.name || '匿名') + '</span>';
  html += '<span style="font-size:12px;color:#b8a88a;margin-left:8px">' + (m.time || '') + '</span>';
  html += '<p style="font-size:13px;color:#5a5650;margin-top:4px;line-height:1.5">' + escapeHtml(m.message || '') + '</p>';
  // 内联回复（如果有）
  if (m.replies && m.replies.length > 0) {
    for (var ri = 0; ri < m.replies.length; ri++) {
      var r = m.replies[ri];
      html += '<div style="margin:6px 0 0 16px;padding:6px 10px;background:#faf7f2;border-left:2px solid #d4a853;border-radius:0 3px 3px 0">';
      html += '<span style="font-size:12px;font-weight:600;color:#d4a853">' + escapeHtml(r.author || r.name || '匿名') + '</span>';
      html += '<span style="font-size:11px;color:#b8a88a;margin-left:6px">' + (r.time || '') + '</span>';
      html += '<p style="font-size:13px;color:#5a5650;margin-top:2px;line-height:1.4">' + escapeHtml(r.content || r.message || '') + '</p>';
      html += '</div>';
    }
  }
  // 回复按钮
  html += '<p style="margin-top:6px"><a href="javascript:void(0)" onclick="showReplyForm(\'' + uid + '\')" style="font-size:12px;color:#d4a853;text-decoration:none">💬 回复</a></p>';
  // 回复表单容器
  html += '<div id="replyForm-' + uid + '" style="display:none;margin-top:8px;padding-top:8px;border-top:1px solid #ede8dc"></div>';
  html += '</div>';
  return html;
}

function showReplyForm(parentId) {
  replyTargetId = parentId;
  var container = document.getElementById('replyForm-' + parentId);
  if (!container) return;
  if (container.style.display === 'block') {
    container.style.display = 'none';
    return;
  }
  container.style.display = 'block';
  container.innerHTML = '<input type="text" id="replyName-' + parentId + '" placeholder="你的名字 / 代号" maxlength="30" style="width:100%;background:#fefcf7;border:1px solid #ede8dc;border-radius:4px;padding:8px 10px;font-size:13px;color:#3d3a36;margin-bottom:6px;outline:none;box-sizing:border-box">' +
    '<textarea id="replyMsg-' + parentId + '" placeholder="回复……" maxlength="500" style="width:100%;background:#fefcf7;border:1px solid #ede8dc;border-radius:4px;padding:8px 10px;font-size:13px;color:#3d3a36;margin-bottom:6px;outline:none;min-height:50px;resize:vertical;box-sizing:border-box;font-family:inherit"></textarea>' +
    '<button onclick="submitReply(\'' + parentId + '\')" style="background:#d4a853;color:#fff;border:none;border-radius:4px;padding:6px 16px;font-size:12px;cursor:pointer">回复</button>' +
    ' <span id="replyStatus-' + parentId + '" style="font-size:12px;color:#4caf50;display:none">✨ 回复已发送</span>';
}

async function submitReply(parentId) {
  var name = document.getElementById('replyName-' + parentId).value.trim();
  var msg = document.getElementById('replyMsg-' + parentId).value.trim();
  if (!name || !msg) return;

  try {
    var r = await fetch('/api/guestbook', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: name, message: msg, parent_id: parentId }),
      signal: AbortSignal.timeout(8000),
    });

    if (r.ok) {
      document.getElementById('replyStatus-' + parentId).style.display = 'inline';
      document.getElementById('replyName-' + parentId).value = '';
      document.getElementById('replyMsg-' + parentId).value = '';
      setTimeout(function() {
        document.getElementById('replyStatus-' + parentId).style.display = 'none';
        document.getElementById('replyForm-' + parentId).style.display = 'none';
      }, 2000);
    }
  } catch(e) {}
}

loadMessages();
