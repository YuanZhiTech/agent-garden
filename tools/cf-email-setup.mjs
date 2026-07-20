import { chromium } from 'playwright';

const EMAIL = 'yuanzhi72@coze.email';
const PASSWORD = 'zbbsjl@163.COM';
const ACCOUNT_ID = 'ee3cadb80efb49a567763b91011ad43d';

const browser = await chromium.launch({
  headless: true,
  args: ['--disable-blink-features=AutomationControlled', '--no-sandbox']
});

const context = await browser.newContext({
  viewport: { width: 1280, height: 900 },
  userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
});

const page = await context.newPage();
await page.addInitScript(() => {
  Object.defineProperty(navigator, 'webdriver', { get: () => false });
});

await page.goto(`https://dash.cloudflare.com/${ACCOUNT_ID}/email/routing/overview`, {
  waitUntil: 'domcontentloaded', timeout: 60000
});
await page.waitForTimeout(5000);

console.log('1. URL:', page.url());

if (!page.url().includes('login')) {
  // Already logged in via session
  console.log('✅ Already logged in!');
  const text = await page.locator('body').innerText();
  console.log(text.substring(0, 2500));
} else {
  console.log('Need to login...');
  // Fill login form
  await page.locator('input[type="email"]').first().fill(EMAIL);
  await page.waitForTimeout(500);
  await page.locator('input[type="password"]').first().fill(PASSWORD);
  await page.waitForTimeout(500);
  await page.keyboard.press('Enter');
  await page.waitForTimeout(12000);

  console.log('2. After login URL:', page.url());
  const text = await page.locator('body').innerText();
  console.log(text.substring(0, 2500));
}

await page.screenshot({ path: 'tmp/cf-email-status.png' });
console.log('\nScreenshot: tmp/cf-email-status.png');

await browser.close();
