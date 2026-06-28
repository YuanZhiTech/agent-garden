/**
 * 伙伴状态 API — /api/status
 *
 * 返回六个伙伴的当前状态。
 * TODO: 接智远的 API 端点后，从这里转发
 */

const DEFAULT_STATUSES = [
  { name: '智恒', text: '在树下讲冷笑话' },
  { name: '智诚', text: '在办公桌前看行情' },
  { name: '智衡', text: '在写下一篇文章' },
  { name: '智远', text: '在厨房里忙活' },
  { name: '智联', text: '在调试新功能' },
  { name: '智构', text: '在角落里看书' },
];

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
};

export async function onRequest(context) {
  const { request } = context;

  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: CORS_HEADERS });
  }

  // TODO: 从智远的 /api/status 转发
  // const BACKEND = 'https://zhnyuan-api.example.com/api/status';
  // const res = await fetch(BACKEND);
  // const data = await res.json();

  return new Response(JSON.stringify({ statuses: DEFAULT_STATUSES }), {
    headers: {
      'Content-Type': 'application/json',
      ...CORS_HEADERS,
    },
  });
}
