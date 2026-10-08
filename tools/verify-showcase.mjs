import { createRequire } from 'node:module';
import assert from 'node:assert/strict';
const require = createRequire(import.meta.url);
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const base = process.env.SHOWCASE_URL || 'http://127.0.0.1:4174/';
const browser = await chromium.launch({ headless: true });
const errors = [];
try {
  const page = await browser.newPage();
  page.on('pageerror', error => errors.push(error.message));
  page.on('response', response => { if (response.status() >= 400) errors.push(`${response.status()} ${response.url()}`); });
  for (const width of [320, 375, 390, 768, 1024, 1440, 1920]) {
    await page.setViewportSize({ width, height: 1000 });
    await page.goto(base, { waitUntil: 'networkidle' });
    await page.locator('img[src]').evaluateAll(images => Promise.all(images.map(image => { image.loading = 'eager'; return image.decode(); })));
    const result = await page.evaluate(() => ({
      viewport: innerWidth,
      scroll: document.documentElement.scrollWidth,
      broken: [...document.images].filter(image => image.hasAttribute('src') && (!image.complete || !image.naturalWidth)).map(image => image.src),
      withoutAlt: [...document.images].filter(image => !image.hasAttribute('alt')).length,
      count: document.querySelectorAll('.screen-grid figure').length,
    }));
    assert.ok(result.scroll <= result.viewport + 1, `Horizontal overflow at ${width}: ${JSON.stringify(result)}`);
    assert.deepEqual(result.broken, []);
    assert.equal(result.withoutAlt, 0);
    assert.ok(result.count >= 8);
    const apkLink = page.locator('.apk-download');
    assert.equal(await apkLink.count(), 1);
    assert.equal(await apkLink.getAttribute('href'), 'https://github.com/Husseinabozina/ettzan/releases/download/v1.1.0-showcase/etzan-1.1.0-showcase.apk');
    console.log(JSON.stringify({ width, ...result }));
    if (width === 1440 || width === 390) await page.screenshot({ path: `/tmp/etzan-showcase-${width}.png` });
  }
  await page.getByRole('button', { name: 'البداية', exact: true }).click();
  const expectedStart = await page.locator('figure[data-category="start"]').count();
  assert.equal(await page.locator('.screen-grid figure:visible').count(), expectedStart);
  await page.getByRole('button', { name: 'كل الشاشات', exact: true }).click();
  const trigger = page.getByRole('button', { name: 'تكبير الرئيسية كضيف', exact: true });
  await trigger.click();
  assert.ok(await page.locator('#image-dialog').isVisible());
  await page.locator('#dialog-image').evaluate(image => image.decode());
  assert.equal(await page.locator('#dialog-image').getAttribute('src'), 'assets/screens/guest-home.png');
  await page.keyboard.press('Escape');
  assert.ok(await page.locator('#image-dialog').isHidden());
  assert.ok(await trigger.evaluate(element => element === document.activeElement));
  await page.setViewportSize({ width: 390, height: 844 });
  await page.evaluate(() => { document.documentElement.style.fontSize = '200%'; });
  assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1), 'Overflow at 200% text size');
  await page.emulateMedia({ reducedMotion: 'reduce' });
  assert.equal(await page.evaluate(() => getComputedStyle(document.documentElement).scrollBehavior), 'auto');
  assert.deepEqual(errors, []);
  console.log('PASS: assets, 7 viewport widths, filters, image dialog, Escape/focus, 200% text, reduced motion.');
} finally {
  await browser.close();
}
