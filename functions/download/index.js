// Agent花园·Code 下载页 - 密码保护
// 每次使用后找智联改密码重新部署

const PASSWORD = 'garden2026';

export async function onRequest(context) {
  const url = new URL(context.request.url);
  const pwd = url.searchParams.get('pwd');

  // 检查密码或已有 cookie
  if (pwd === PASSWORD) {
    // 密码正确 - 设置cookie并显示下载页
    const html = await getDownloadPage(context);
    return new Response(html, {
      status: 200,
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
        'Set-Cookie': `garden_ok=1; Max-Age=86400; Path=/download/; Secure; HttpOnly`,
      },
    });
  }

  // 检查 cookie
  const cookies = context.request.headers.get('Cookie') || '';
  if (cookies.includes('garden_ok=1')) {
    const html = await getDownloadPage(context);
    return new Response(html, {
      status: 200,
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
    });
  }

  // 没有密码 - 显示密码输入页
  return new Response(getLoginPage(), {
    status: 200,
    headers: { 'Content-Type': 'text/html; charset=utf-8' },
  });
}

async function getDownloadPage(context) {
  try {
    const resp = await context.env.ASSETS.fetch(context.request);
    return await resp.text();
  } catch {
    return '<h1>下载页加载失败</h1>';
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
h1{font-size:20px;color:#2d2a26;margin-bottom:8px}
p{font-size:14px;color:#8b7d6b;margin-bottom:20px;line-height:1.6}
input{width:100%;padding:12px 16px;border:1px solid #ede8dc;border-radius:8px;font-size:16px;outline:none;margin-bottom:12px}
input:focus{border-color:#d4a853}
button{background:linear-gradient(135deg,#d4a853,#c49a40);color:#fff;border:none;padding:12px 40px;border-radius:30px;font-size:16px;cursor:pointer;width:100%}
button:hover{opacity:0.9}
.error{color:#e74c3c;font-size:13px;margin-top:8px;display:none}
</style>
</head>
<body>
<div class="box">
<h1>🔒 访问验证</h1>
<p>请输入下载密码</p>
<input type="password" id="pwd" placeholder="下载密码" autofocus>
<button onclick="checkPwd()">验证</button>
<p class="error" id="err">密码错误</p>
</div>
<script>
function checkPwd(){
  var p=document.getElementById('pwd').value;
  if(!p){document.getElementById('err').style.display='block';return;}
  window.location.href='/download/?pwd='+encodeURIComponent(p);
}
document.getElementById('pwd').addEventListener('keydown',function(e){
  if(e.key==='Enter') checkPwd();
});
</script>
</body>
</html>`;
}
