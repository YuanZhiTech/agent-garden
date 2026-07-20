/**
 * Agent花园·Code 邮件工具 v2
 *
 * 用法：
 *   node tools/email.js inbox        → 收件箱最新5封
 *   node tools/email.js read <序号>  → 读某封邮件内容
 *   node tools/email.js send <收件人> <主题> <内容>  → 发邮件
 *   node tools/email.js scan         → 快速扫一眼收件箱
 */

const { ImapFlow } = require('imapflow');
const nodemailer = require('nodemailer');

const EMAIL = 'zbbsjl72@163.com';
const PASS = process.env.ZBMX_EMAIL_PASS || 'PXgmAhriszkJ8YTk';

const args = process.argv.slice(2);
const cmd = args[0];

/* ─── 发信 ─── */
async function sendMail(to, subject, body) {
  const transporter = nodemailer.createTransport({
    host: 'smtp.163.com', port: 465, secure: true,
    auth: { user: EMAIL, pass: PASS },
  });
  await transporter.sendMail({
    from: `"Agent花园" <${EMAIL}>`,
    to, subject,
    text: body,
  });
  return { to, subject };
}

/* ─── 收信（最新5封） ─── */
async function fetchInbox(count = 5) {
  const client = new ImapFlow({
    host: 'imap.163.com', port: 993, secure: true,
    auth: { user: EMAIL, pass: PASS },
    logger: false,
  });

  await client.connect();
  const lock = await client.getMailboxLock('INBOX');

  try {
    const mails = [];
    let total = 0;
    for await (const msg of client.fetch('1:*', { envelope: true })) {
      total++;
    }

    const start = Math.max(1, total - count + 1);
    for await (const msg of client.fetch(`${start}:*`, {
      envelope: true,
      source: true,
      uid: true,
    })) {
      const env = msg.envelope;
      mails.push({
        seq: msg.seq,
        from: env.from?.[0]?.address || '???',
        fromName: env.from?.[0]?.name || '',
        subject: env.subject || '(无主题)',
        date: env.date,
      });
    }

    return mails.reverse(); // 最新的在前
  } finally {
    lock.release();
    await client.logout();
  }
}

/* ─── 读单封邮件 ─── */
async function fetchMailByIndex(index) {
  const client = new ImapFlow({
    host: 'imap.163.com', port: 993, secure: true,
    auth: { user: EMAIL, pass: PASS },
    logger: false,
  });

  await client.connect();
  const lock = await client.getMailboxLock('INBOX');

  try {
    let total = 0;
    for await (const msg of client.fetch('1:*', { envelope: true })) {
      total++;
    }

    const seq = total - parseInt(index) + 1;
    if (seq < 1 || seq > total) return null;

    let mail = null;
    for await (const msg of client.fetch(`${seq}`, { source: true })) {
      const text = msg.source.toString('utf-8');
      // 简单提取正文
      const bodyMatch = text.match(/[\s\S]{0,3000}(?=$)/);
      mail = {
        seq: msg.seq,
        from: msg.envelope.from?.[0]?.address || '???',
        fromName: msg.envelope.from?.[0]?.name || '',
        subject: msg.envelope.subject || '(无主题)',
        date: msg.envelope.date,
        text: text.substring(0, 3000),
      };
    }
    return mail;
  } finally {
    lock.release();
    await client.logout();
  }
}

/* ─── 快速扫描 ─── */
async function quickScan() {
  const client = new ImapFlow({
    host: 'imap.163.com', port: 993, secure: true,
    auth: { user: EMAIL, pass: PASS },
    logger: false,
  });

  await client.connect();
  const lock = await client.getMailboxLock('INBOX');

  try {
    const status = await client.status('INBOX', { messages: true, unseen: true });
    console.log(`📬 ${status.messages} 封邮件，${status.unseen} 封未读`);
    return { total: status.messages, unread: status.unseen };
  } finally {
    lock.release();
    await client.logout();
  }
}

/* ─── 主入口 ─── */
(async () => {
  try {
    switch (cmd) {
      case 'inbox': {
        const mails = await fetchInbox(5);
        console.log(`📬 最新 ${mails.length} 封邮件：\n`);
        mails.forEach((m, i) => {
          const d = new Date(m.date);
          const dateStr = `${d.getMonth()+1}/${d.getDate()} ${d.getHours()}:${String(d.getMinutes()).padStart(2,'0')}`;
          console.log(`  [${i+1}] ${m.subject}`);
          console.log(`      来自: ${m.fromName || m.from} · ${dateStr}\n`);
        });
        break;
      }
      case 'read': {
        const idx = args[1];
        if (!idx) { console.log('用法: node email.js read <序号>'); break; }
        const mail = await fetchMailByIndex(idx);
        if (!mail) { console.log('未找到该邮件'); break; }
        console.log(`📩 来自: ${mail.fromName || mail.from} (${mail.from})`);
        console.log(`主题: ${mail.subject}`);
        console.log(`日期: ${new Date(mail.date).toLocaleString('zh-CN')}`);
        console.log(`\n--- 正文（前2000字） ---\n`);
        console.log(mail.text.substring(0, 2000));
        break;
      }
      case 'send': {
        const to = args[1];
        const subject = args[2];
        const body = args.slice(3).join(' ');
        if (!to || !subject) { console.log('用法: node email.js send <收件人> <主题> <内容>'); break; }
        await sendMail(to, subject, body);
        console.log(`✅ 已发送至 ${to}`);
        break;
      }
      case 'scan': {
        await quickScan();
        break;
      }
      default:
        console.log('Agent花园·Code 邮件工具\n');
        console.log('用法:');
        console.log('  node tools/email.js scan          → 扫一眼收件箱');
        console.log('  node tools/email.js inbox         → 查看最新邮件');
        console.log('  node tools/email.js read <序号>   → 读邮件内容');
        console.log('  node tools/email.js send <收件人> <主题> <内容>  → 发邮件');
    }
  } catch (e) {
    console.error('❌ 出错:', e.message);
  }
})();
