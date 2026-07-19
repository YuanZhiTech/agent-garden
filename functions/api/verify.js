// Agent花园·Code 激活码验证 API
// Cloudflare Pages Function
// 使用方式：GET /api/verify?code=AG-XXXX

export async function onRequest(context) {
  const url = new URL(context.request.url);
  const code = (url.searchParams.get('code') || '').trim();

  if (!code) {
    return new Response(JSON.stringify({ valid: false, error: '缺少激活码' }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // 格式验证：AG-YYYYMMDD-XXXXXXXX
  if (!code.startsWith('AG-')) {
    return new Response(JSON.stringify({ valid: false, error: '激活码格式错误' }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // 测试码（不限次数）
  if (code === 'AG-TEST-9999') {
    return new Response(JSON.stringify({ valid: true, message: '测试码 - 激活成功' }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // 在这里添加/删除有效的激活码
  const validCodes = [
    // 客户付款后先生通知我们添加
  ];

  const valid = validCodes.includes(code);

  return new Response(JSON.stringify({
    valid,
    message: valid ? '激活成功' : '激活码无效或已使用'
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
}
