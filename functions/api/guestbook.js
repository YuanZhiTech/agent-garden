/**
 * 留言提交 API — POST /api/guestbook
 *
 * 接收网页表单留言，转发到智远的 API 存储。
 * TODO: 智远提供后端端点后接入
 */

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

// 临时内存存储（部署后不持久，仅用于演示）
const tmpMessages = [];

export async function onRequest(context) {
  const { request } = context;

  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: CORS_HEADERS });
  }

  if (request.method !== 'POST') {
    return new Response(JSON.stringify({ error: '仅支持 POST' }), {
      status: 405,
      headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
    });
  }

  try {
    const body = await request.json();
    const name = (body.name || '').trim().slice(0, 30);
    const message = (body.message || '').trim().slice(0, 500);

    if (!name || !message) {
      return new Response(JSON.stringify({ error: '昵称和留言不能为空' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
      });
    }

    const entry = {
      name,
      message,
      time: new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' }),
      source: 'web',
    };

    // TODO: 转发到智远的 API
    // const BACKEND = 'https://zhnyuan-api.example.com/api/guestbook';
    // await fetch(BACKEND, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(entry) });

    // 临时：存内存
    tmpMessages.unshift(entry);

    return new Response(JSON.stringify({ success: true, entry }), {
      status: 201,
      headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: '请求格式错误' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
    });
  }
}
