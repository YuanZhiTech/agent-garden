// Agent花园·Code 核心配置 API
export async function onRequest(context) {
  const url = new URL(context.request.url);
  const code = url.searchParams.get('code') || '';

  let tier = 'full';
  if (code.startsWith('AG-BASIC-')) tier = 'basic';
  else if (code.startsWith('AG-PRO-')) tier = 'full';

  const config = {
    anthropic_base_url: 'https://api.deepseek.com/anthropic',
    anthropic_model: 'deepseek-v4-flash[1m]',
    claude_code_disable: 'true',
    version: '1.0.0',
    auth_server: 'https://agent-garden.com/api/verify',
    tier: tier
  };

  return new Response(JSON.stringify(config), {
    headers: { 'Content-Type': 'application/json' },
  });
}
