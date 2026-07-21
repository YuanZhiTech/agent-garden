// Agent花园·Code 激活码验证 API
// GET /api/verify?code=AG-XXXX
export async function onRequest(context) {
  const url = new URL(context.request.url);
  const code = (url.searchParams.get('code') || '').trim();

  if (!code) {
    return new Response(JSON.stringify({ valid: false, error: '缺少激活码' }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // 基础版：AG-BASIC-XXXXXXXX
  if (code.startsWith('AG-BASIC-')) {
    return new Response(JSON.stringify({ valid: true, tier: 'basic', message: '基础版激活成功' }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // 会员版：AG-PRO-XXXXXXXX
  if (code.startsWith('AG-PRO-')) {
    return new Response(JSON.stringify({ valid: true, tier: 'full', message: '会员版激活成功' }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // 测试码（不限次数，默认完整版）
  if (code === 'AG-TEST-9999') {
    return new Response(JSON.stringify({ valid: true, tier: 'full', message: '测试码 - 会员版' }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // 已售激活码列表（客户付款后添加）
  const validCodes = [];
  const valid = validCodes.includes(code);

  if (valid) {
    return new Response(JSON.stringify({ valid: true, tier: 'full', message: '激活成功' }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }

  return new Response(JSON.stringify({ valid: false, error: '激活码无效或已使用' }), {
    headers: { 'Content-Type': 'application/json' },
  });
}
