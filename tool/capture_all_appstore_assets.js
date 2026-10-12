import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

async function captureDevice({ browser, name, viewport, scale, outSubdir }) {
  const outDir = path.resolve('store_assets', outSubdir);
  fs.mkdirSync(outDir, { recursive: true });

  console.log(`\n========================================`);
  console.log(`Capturing for: ${name} (${viewport.width}x${viewport.height} @ ${scale}x => ${viewport.width * scale}x${viewport.height * scale}px)`);
  console.log(`========================================`);

  const context = await browser.newContext({
    viewport,
    deviceScaleFactor: scale,
  });

  const page = await context.newPage();

  // Pre-seed storage so app boots cleanly into MainNavigationScaffold
  await page.addInitScript(() => {
    try {
      localStorage.setItem('greta_onboarding_completed', 'true');
      localStorage.setItem('GetStorage', JSON.stringify({
        greta_onboarding_completed: true,
        greta_hearts_balance: 15,
        greta_streak_count: 7,
        greta_total_speaking_turns: 48,
        greta_current_cefr_level: 'A1',
      }));
    } catch (e) {}
  });

  await page.goto('http://localhost:8089', { waitUntil: 'networkidle' });
  await page.waitForTimeout(3500);

  const bottomY = viewport.height - 30;
  const tab0X = viewport.width * 0.125;
  const tab1X = viewport.width * 0.375;
  const tab2X = viewport.width * 0.625;
  const tab3X = viewport.width * 0.875;

  // 1. Voice Salon (Tab 1 - Greta Hero Experience)
  console.log(`  -> Switching to Tab 1 (Greta Voice Salon)...`);
  await page.mouse.click(tab1X, bottomY);
  await page.waitForTimeout(2500);
  const voiceFile = path.join(outDir, '01_greta_voice_salon.png');
  await page.screenshot({ path: voiceFile });
  console.log(`     Saved: ${voiceFile}`);

  // 2. German Curriculum (Tab 0 - 600 Levels & Grammar)
  console.log(`  -> Switching to Tab 0 (German Curriculum)...`);
  await page.mouse.click(tab0X, bottomY);
  await page.waitForTimeout(2500);
  const curriculumFile = path.join(outDir, '02_curriculum_600_levels.png');
  await page.screenshot({ path: curriculumFile });
  console.log(`     Saved: ${curriculumFile}`);

  // 3. Practice Studio (Tab 2 - Pronunciation & Speech Studio)
  console.log(`  -> Switching to Tab 2 (Practice Studio)...`);
  await page.mouse.click(tab2X, bottomY);
  await page.waitForTimeout(2500);
  const practiceFile = path.join(outDir, '03_pronunciation_practice.png');
  await page.screenshot({ path: practiceFile });
  console.log(`     Saved: ${practiceFile}`);

  // 4. Profile & Settings (Tab 3 - CEFR Level & Hearts)
  console.log(`  -> Switching to Tab 3 (Profile & Settings)...`);
  await page.mouse.click(tab3X, bottomY);
  await page.waitForTimeout(2500);
  const profileFile = path.join(outDir, '04_profile_and_hearts.png');
  await page.screenshot({ path: profileFile });
  console.log(`     Saved: ${profileFile}`);

  await context.close();
}

async function captureOnboarding({ browser, viewport, scale, outSubdir }) {
  const outDir = path.resolve('store_assets', outSubdir);
  fs.mkdirSync(outDir, { recursive: true });

  const context = await browser.newContext({
    viewport,
    deviceScaleFactor: scale,
  });
  const page = await context.newPage();

  // Clear storage so Onboarding renders
  await page.addInitScript(() => {
    try {
      localStorage.clear();
    } catch (e) {}
  });

  await page.goto('http://localhost:8089', { waitUntil: 'networkidle' });
  await page.waitForTimeout(3000);

  const file = path.join(outDir, '05_personalized_onboarding.png');
  await page.screenshot({ path: file });
  console.log(`     Saved Onboarding: ${file}`);

  await context.close();
}

async function run() {
  const browser = await chromium.launch({
    channel: 'chrome',
    headless: true,
  });

  // 1. iPhone 6.7" (iPhone 16 Pro Max / 15 Pro Max) -> 1290 x 2796 px (App Store Required)
  await captureDevice({
    browser,
    name: 'iPhone 6.7" Pro Max',
    viewport: { width: 430, height: 932 },
    scale: 3,
    outSubdir: 'app_store_iphone_6_7',
  });
  await captureOnboarding({
    browser,
    viewport: { width: 430, height: 932 },
    scale: 3,
    outSubdir: 'app_store_iphone_6_7',
  });

  // 2. iPad Pro 12.9" / 13" (6th Gen / M4) -> 2048 x 2732 px (App Store Required)
  await captureDevice({
    browser,
    name: 'iPad Pro 12.9"',
    viewport: { width: 1024, height: 1366 },
    scale: 2,
    outSubdir: 'app_store_ipad_12_9',
  });
  await captureOnboarding({
    browser,
    viewport: { width: 1024, height: 1366 },
    scale: 2,
    outSubdir: 'app_store_ipad_12_9',
  });

  // 3. Android Phone (1080 x 2400 px - Google Play Required)
  await captureDevice({
    browser,
    name: 'Android Phone Flagship',
    viewport: { width: 412, height: 915 },
    scale: 2.625,
    outSubdir: 'google_play_phone',
  });

  // 4. Android 10" Tablet / Foldable (1600 x 2560 px - Google Play Required)
  await captureDevice({
    browser,
    name: 'Android 10" Tablet',
    viewport: { width: 800, height: 1280 },
    scale: 2,
    outSubdir: 'google_play_tablet_10',
  });

  await browser.close();
  console.log('\n========================================');
  console.log('All Device Screenshot Suites Successfully Generated!');
  console.log('========================================');
}

run().catch(console.error);
