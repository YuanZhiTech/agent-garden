// 浏览计数器 API
export async function onRequest(context) {
  let count = 1;
  try {
    const resp = await fetch(`https://api.countapi.xyz/hit/agent-garden-com/visits`);
    if (resp.ok) {
      const data = await resp.json();
      count = data.value;
    }
  } catch (e) {
    // fallback to incrementing counter
  }
  return new Response(JSON.stringify({ count }), {
    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
  });
}
