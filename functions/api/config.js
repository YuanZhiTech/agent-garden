// Agent花园·Code 核心配置 API
// 核心参数存在服务端，不写在安装脚本里
export async function onRequest() {
  const config = {
    anthropic_base_url: 'https://api.deepseek.com/anthropic',
    anthropic_model: 'deepseek-v4-flash[1m]',
    claude_code_disable: 'true',
    version: '1.0.0',
    auth_server: 'https://agent-garden.com/api/verify'
  };

  return new Response(JSON.stringify(config), {
    headers: { 'Content-Type': 'application/json' },
  });
}
