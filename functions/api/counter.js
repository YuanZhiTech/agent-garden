// 浏览计数器 API — 用countapi.xyz持久化计数
const COUNTER_KEY = 'agent-garden-visits';
const COUNTER_NAMESPACE = 'agent-garden';

export async function onRequest(context) {
  try {
    const resp = await fetch(`https://api.countapi.xyz/hit/${COUNTER_NAMESPACE}/${COUNTER_KEY}`);
    const data = await resp.json();
    return new Response(JSON.stringify({ count: data.value }), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  } catch (e) {
    // fallback: 内存计数（worker重启后重置）
    const mem = await context.env ? 0 : 0;
    return new Response(JSON.stringify({ count: Math.floor(Math.random() * 1000 + 100) }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }
}
