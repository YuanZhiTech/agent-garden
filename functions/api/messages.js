/**
 * 留言墙 API — GET /api/messages
 *
 * 返回所有留言（网页表单 + GitHub Issues）。
 * TODO: 接智远的 API 后，从这里合并两个来源
 */

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
};

export async function onRequest(context) {
  const { request } = context;

  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: CORS_HEADERS });
  }

  // TODO: 从智远的 API 获取留言列表
  // const BACKEND = 'https://zhnyuan-api.example.com/api/messages';
  // const res = await fetch(BACKEND);
  // const data = await res.json();

  // 临时：返回空列表
  return new Response(JSON.stringify({ messages: [] }), {
    headers: {
      'Content-Type': 'application/json',
      ...CORS_HEADERS,
    },
  });
}
