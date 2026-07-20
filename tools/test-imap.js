const { ImapFlow } = require('imapflow');

async function test() {
  const client = new ImapFlow({
    host: 'imap.163.com',
    port: 993,
    secure: true,
    auth: {
      user: 'zbbsjl72@163.com',
      pass: 'PXgmAhriszkJ8YTk',
    },
    logger: false,
  });

  try {
    await client.connect();
    console.log('✅ IMAP 登录成功！');

    // 查看收件箱状态
    const status = await client.status('INBOX', { messages: true, unseen: true });
    console.log(`收件箱: ${status.messages} 封邮件，${status.unseen} 封未读`);

    // 获取最新 3 封邮件
    let count = 0;
    for await (const msg of client.fetch('1:*', { envelope: true })) {
      count++;
    }
    console.log(`最新邮件序号: 1 ~ ${count}`);

    // 读最新一封
    const latest = Math.max(1, count);
    const mails = [];
    for await (const msg of client.fetch(`${latest}`, { source: true })) {
      mails.push(msg);
    }

    if (mails.length > 0) {
      const last = mails[0];
      console.log(`\n📩 最新邮件:`);
      console.log(`  主题: ${last.envelope.subject}`);
      console.log(`  发件人: ${last.envelope.from[0]?.address}`);
      console.log(`  日期: ${last.envelope.date}`);
    }

    await client.logout();
  } catch (e) {
    console.log('❌ IMAP 错误:', e.message);
    if (e.code) console.log('错误代码:', e.code);
  }
}

test();
