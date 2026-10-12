import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

async function main() {
  const browser = await chromium.launch({
    channel: 'chrome',
    headless: true,
  });

  const outDir = path.resolve('store_assets/screenshots');
  fs.mkdirSync(path.join(outDir, 'tablet'), { recursive: true });
  fs.mkdirSync(path.join(outDir, 'iphone_6_7'), { recursive: true });

  console.log('--- 1. Testing Tablet View (iPad Air 820x1180) ---');
  const context = await browser.newContext({
    viewport: { width: 820, height: 1180 },
    deviceScaleFactor: 2,
  });
  const page = await context.newPage();

  // Pre-seed localStorage to test direct main screen
  await page.addInitScript(() => {
    try {
      localStorage.setItem('greta_onboarding_completed', 'true');
      localStorage.setItem('GetStorage', JSON.stringify({
        greta_onboarding_completed: true,
        greta_hearts_balance: 15,
        greta_streak_count: 5,
        greta_total_speaking_turns: 42,
        greta_current_cefr_level: 'A1',
      }));
    } catch (e) {}
  });

  console.log('Navigating to http://localhost:8089...');
  await page.goto('http://localhost:8089', { waitUntil: 'networkidle' });
  await page.waitForTimeout(4000);

  // If still on onboarding, click Skip (top right)
  try {
    await page.mouse.click(770, 40);
    await page.waitForTimeout(2000);
  } catch (e) {}

  console.log('Capturing Tablet Curriculum...');
  await page.screenshot({ path: path.join(outDir, 'tablet/01_curriculum_tablet.png') });

  // Click tab 1 (Voice Salon) at x = 307, y = 1145
  console.log('Clicking Voice Salon tab...');
  await page.mouse.click(307, 1145);
  await page.waitForTimeout(3000);

  console.log('Capturing Tablet Voice Salon...');
  await page.screenshot({ path: path.join(outDir, 'tablet/02_voice_salon_tablet.png') });

  // Click tab 2 (Practice Studio) at x = 512, y = 1145
  console.log('Clicking Practice Studio tab...');
  await page.mouse.click(512, 1145);
  await page.waitForTimeout(3000);

  console.log('Capturing Tablet Practice Studio...');
  await page.screenshot({ path: path.join(outDir, 'tablet/03_practice_tablet.png') });

  // Click tab 3 (Profile) at x = 717, y = 1145
  console.log('Clicking Profile Settings tab...');
  await page.mouse.click(717, 1145);
  await page.waitForTimeout(3000);

  console.log('Capturing Tablet Profile Settings...');
  await page.screenshot({ path: path.join(outDir, 'tablet/04_profile_tablet.png') });

  await context.close();

  console.log('--- 2. Testing iPhone 16 Pro Max View (430x932, scale 3 => 1290x2796) ---');
  const iphoneContext = await browser.newContext({
    viewport: { width: 430, height: 932 },
    deviceScaleFactor: 3,
  });
  const iphonePage = await iphoneContext.newPage();
  await iphonePage.goto('http://localhost:8089', { waitUntil: 'networkidle' });
  await iphonePage.waitForTimeout(4000);

  // Skip onboarding if present
  try {
    await iphonePage.mouse.click(390, 40);
    await iphonePage.waitForTimeout(2000);
  } catch (e) {}

  // Tab 1 (Voice Salon) on 430 width is at x = 430 * 0.375 = 161, y = 905
  console.log('Clicking Voice Salon on iPhone...');
  await iphonePage.mouse.click(161, 905);
  await iphonePage.waitForTimeout(3000);

  console.log('Capturing iPhone Voice Salon...');
  await iphonePage.screenshot({ path: path.join(outDir, 'iphone_6_7/01_voice_salon_iphone.png') });

  // Tab 0 (Curriculum) on 430 width is at x = 430 * 0.125 = 54, y = 905
  console.log('Clicking Curriculum on iPhone...');
  await iphonePage.mouse.click(54, 905);
  await iphonePage.waitForTimeout(3000);

  console.log('Capturing iPhone Curriculum...');
  await iphonePage.screenshot({ path: path.join(outDir, 'iphone_6_7/02_curriculum_iphone.png') });

  // Tab 2 (Practice Studio) at x = 430 * 0.625 = 268, y = 905
  console.log('Clicking Practice on iPhone...');
  await iphonePage.mouse.click(268, 905);
  await iphonePage.waitForTimeout(3000);

  console.log('Capturing iPhone Practice...');
  await iphonePage.screenshot({ path: path.join(outDir, 'iphone_6_7/03_practice_iphone.png') });

  await iphoneContext.close();
  await browser.close();
  console.log('All screenshots captured successfully!');
}

main().catch(console.error);
