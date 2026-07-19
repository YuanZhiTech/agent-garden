// Cloudflare Pages Function - returns config as batch-compatible format
export async function onRequest() {
  const config = [
    '@echo off',
    'set ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic',
    'set ANTHROPIC_MODEL=deepseek-v4-flash[1m]',
    'set DISABLE_TRAFFIC=true',
  ].join('\r\n');

  return new Response(config, {
    headers: { 'Content-Type': 'text/plain; charset=utf-8' },
  });
}
