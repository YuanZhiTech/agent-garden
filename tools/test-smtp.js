const nodemailer = require('nodemailer');

const EMAIL = 'zbbsjl72@163.com';
const PASS = 'PXgmAhriszkJ8YTk';

async function test() {
  const transporter = nodemailer.createTransport({
    host: 'smtp.163.com',
    port: 465,
    secure: true,
    auth: { user: EMAIL, pass: PASS },
  });

  try {
    await transporter.verify();
    console.log('✅ SMTP 连接成功！授权码有效');
  } catch (e) {
    console.log('❌ SMTP 连接失败:', e.message);
  }
}

test();
