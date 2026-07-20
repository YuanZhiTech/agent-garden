// Agent花园·Code 兼容版下载页 - 密码保护
const PASSWORD = 'garden2026';

export async function onRequest(context) {
  const url = new URL(context.request.url);
  const pwd = url.searchParams.get('pwd');

  if (pwd === PASSWORD) {
    const html = await getPage(context);
    return new Response(html, {
      status: 200,
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
        'Set-Cookie': 'garden_ok=1; Max-Age=86400; Path=/download/legacy/; Secure; HttpOnly',
      },
    });
  }

  const cookies = context.request.headers.get('Cookie') || '';
  if (cookies.includes('garden_ok=1')) {
    const html = await getPage(context);
    return new Response(html, {
      status: 200,
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
    });
  }

  // 检查是否请求 .bat 文件或便携版分卷（允许直接下载）
  if (url.pathname.endsWith('.bat') || url.pathname.startsWith('/download/legacy/portable/')) {
    const resp = await context.env.ASSETS.fetch(context.request);
    return resp;
  }

  return new Response(getLoginPage(), {
    status: 200,
    headers: { 'Content-Type': 'text/html; charset=utf-8' },
  });
}

async function getPage(context) {
  try {
    const resp = await context.env.ASSETS.fetch(context.request);
    return await resp.text();
  } catch {
    return '<h1>页面加载失败</h1>';
  }
}

function getLoginPage() {
  return `<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>访问验证 · Agent花园</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#f5f0e8;font-family:"PingFang SC",sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh;padding:20px}
.box{background:#fff;border-radius:16px;padding:40px;max-width:400px;width:100%;text-align:center;border:1px solid rgba(212,168,83,0.15)}
h1{font-size:20px;margin-bottom:8px}
p{font-size:14px;color:#8b7d6b;margin-bottom:20px}
input{width:100%;padding:12px 16px;border:1px solid #ede8dc;border-radius:8px;font-size:16px;outline:none;margin-bottom:12px}
input:focus{border-color:#d4a853}
button{background:linear-gradient(135deg,#d4a853,#c49a40);color:#fff;border:none;padding:12px 40px;border-radius:30px;font-size:16px;cursor:pointer;width:100%}
.error{color:#e74c3c;font-size:13px;margin-top:8px;display:none}
</style>
</head>
<body>
<div class="box">
<h1>🔒 访问验证</h1>
<p>兼容版下载页</p>
<input type="password" id="pwd" placeholder="下载密码">
<button onclick="checkPwd()">验证</button>
<p class="error" id="err">密码错误</p>
</div>
<script>
function checkPwd(){
  var p=document.getElementById('pwd').value;
  if(!p){document.getElementById('err').style.display='block';return;}
  window.location.href='/download/legacy/?pwd='+encodeURIComponent(p);
}
document.getElementById('pwd').addEventListener('keydown',function(e){
  if(e.key==='Enter') checkPwd();
});
</script>
</body>
</html>`;
}
