import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

const outDir = path.resolve('store_assets/marketing_banners');
fs.mkdirSync(path.join(outDir, 'iphone_6_7'), { recursive: true });
fs.mkdirSync(path.join(outDir, 'ipad_12_9'), { recursive: true });
fs.mkdirSync(path.join(outDir, 'google_play_phone'), { recursive: true });
fs.mkdirSync(path.join(outDir, 'google_play_tablet_10'), { recursive: true });

function getBase64Image(filePath) {
  const bitmap = fs.readFileSync(filePath);
  return `data:image/png;base64,${Buffer.from(bitmap).toString('base64')}`;
}

const slides = [
  {
    badge: 'REAL-TIME AI VOICE TUTOR',
    title: 'Speak German Fluently',
    titleHighlight: 'From Day One',
    subtitle: 'Interactive live German conversations powered by Gemini 2.0 Flash',
    iphoneSrc: 'store_assets/app_store_iphone_6_7/01_greta_voice_salon.png',
    ipadSrc: 'store_assets/app_store_ipad_12_9/01_greta_voice_salon.png',
    phoneSrc: 'store_assets/google_play_phone/01_greta_voice_salon.png',
    tabletSrc: 'store_assets/google_play_tablet_10/01_greta_voice_salon.png',
    filename: 'banner_01_voice_salon.png',
  },
  {
    badge: 'COMPLETE CEFR A1 TO C2',
    title: '600 Immersive Levels',
    titleHighlight: '& Grammar Mastery',
    subtitle: 'From beginner greetings to fluent professional German discussions',
    iphoneSrc: 'store_assets/app_store_iphone_6_7/02_curriculum_600_levels.png',
    ipadSrc: 'store_assets/app_store_ipad_12_9/02_curriculum_600_levels.png',
    phoneSrc: 'store_assets/google_play_phone/02_curriculum_600_levels.png',
    tabletSrc: 'store_assets/google_play_tablet_10/02_curriculum_600_levels.png',
    filename: 'banner_02_curriculum.png',
  },
  {
    badge: 'NATIVE GERMAN ACCENT',
    title: 'Instant Pronunciation',
    titleHighlight: '& Speech Feedback',
    subtitle: 'Phonetic IPA breakdowns, speech recognition & instant scoring',
    iphoneSrc: 'store_assets/app_store_iphone_6_7/03_pronunciation_practice.png',
    ipadSrc: 'store_assets/app_store_ipad_12_9/03_pronunciation_practice.png',
    phoneSrc: 'store_assets/google_play_phone/03_pronunciation_practice.png',
    tabletSrc: 'store_assets/google_play_tablet_10/03_pronunciation_practice.png',
    filename: 'banner_03_pronunciation.png',
  },
  {
    badge: 'MOTIVATION & FREEDOM',
    title: 'Hearts Power System',
    titleHighlight: '& Daily Streaks',
    subtitle: '100% Free learning — unlock levels and earn hearts by active recall',
    iphoneSrc: 'store_assets/app_store_iphone_6_7/04_profile_and_hearts.png',
    ipadSrc: 'store_assets/app_store_ipad_12_9/04_profile_and_hearts.png',
    phoneSrc: 'store_assets/google_play_phone/04_profile_and_hearts.png',
    tabletSrc: 'store_assets/google_play_tablet_10/04_profile_and_hearts.png',
    filename: 'banner_04_profile.png',
  },
  {
    badge: 'CUSTOMIZED PATH',
    title: 'Personalized For',
    titleHighlight: 'Your Exact Goals',
    subtitle: 'Tailored for Career, Travel, University, Citizenship, or Daily Life',
    iphoneSrc: 'store_assets/app_store_iphone_6_7/05_personalized_onboarding.png',
    ipadSrc: 'store_assets/app_store_ipad_12_9/05_personalized_onboarding.png',
    phoneSrc: 'store_assets/google_play_phone/05_personalized_onboarding.png',
    tabletSrc: 'store_assets/google_play_tablet_10/01_greta_voice_salon.png',
    filename: 'banner_05_onboarding.png',
  },
];

function generateIPhoneHtml(slide) {
  const imgSrc = getBase64Image(path.resolve(slide.iphoneSrc));
  return `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 1290px;
    height: 2796px;
    background: radial-gradient(circle at 50% 25%, #15243A 0%, #080E17 65%, #03060A 100%);
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    color: white;
    display: flex;
    flex-direction: column;
    align-items: center;
    overflow: hidden;
    position: relative;
  }
  .glow-circle {
    position: absolute;
    width: 900px;
    height: 900px;
    top: 500px;
    background: radial-gradient(circle, rgba(0, 229, 255, 0.18) 0%, rgba(0,0,0,0) 70%);
    z-index: 1;
    pointer-events: none;
  }
  .header {
    text-align: center;
    padding-top: 130px;
    padding-left: 70px;
    padding-right: 70px;
    z-index: 2;
  }
  .badge {
    display: inline-block;
    padding: 12px 30px;
    border-radius: 40px;
    background: rgba(0, 229, 255, 0.12);
    border: 1.5px solid rgba(0, 229, 255, 0.5);
    color: #00E5FF;
    font-size: 24px;
    font-weight: 800;
    letter-spacing: 3px;
    text-transform: uppercase;
    margin-bottom: 30px;
    box-shadow: 0 0 25px rgba(0, 229, 255, 0.25);
  }
  .title {
    font-size: 80px;
    font-weight: 900;
    line-height: 1.1;
    letter-spacing: -1.5px;
    margin-bottom: 22px;
  }
  .title-highlight {
    background: linear-gradient(135deg, #00E5FF 0%, #38BDF8 60%, #C084FC 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }
  .subtitle {
    font-size: 35px;
    color: #94A3B8;
    font-weight: 500;
    line-height: 1.35;
    max-width: 1050px;
    margin: 0 auto;
  }
  .device-wrapper {
    position: absolute;
    bottom: -60px;
    width: 1040px;
    height: 1980px;
    z-index: 2;
    display: flex;
    justify-content: center;
  }
  .mockup-frame {
    width: 930px;
    height: 2040px;
    background: #000;
    border-radius: 64px;
    border: 12px solid #273549;
    box-shadow: 0 45px 150px rgba(0, 0, 0, 0.9), 0 0 80px rgba(0, 229, 255, 0.25);
    overflow: hidden;
    position: relative;
  }
  .screen-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }
</style>
</head>
<body>
  <div class="glow-circle"></div>
  <div class="header">
    <div class="badge">${slide.badge}</div>
    <div class="title">${slide.title} <br><span class="title-highlight">${slide.titleHighlight}</span></div>
    <div class="subtitle">${slide.subtitle}</div>
  </div>
  <div class="device-wrapper">
    <div class="mockup-frame">
      <img class="screen-img" src="${imgSrc}">
    </div>
  </div>
</body>
</html>`;
}

function generateIPadHtml(slide) {
  const imgSrc = getBase64Image(path.resolve(slide.ipadSrc));
  return `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 2048px;
    height: 2732px;
    background: radial-gradient(circle at 50% 25%, #15243A 0%, #080E17 65%, #03060A 100%);
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    color: white;
    display: flex;
    flex-direction: column;
    align-items: center;
    overflow: hidden;
    position: relative;
  }
  .glow-circle {
    position: absolute;
    width: 1300px;
    height: 1300px;
    top: 550px;
    background: radial-gradient(circle, rgba(0, 229, 255, 0.16) 0%, rgba(0,0,0,0) 70%);
    z-index: 1;
    pointer-events: none;
  }
  .header {
    text-align: center;
    padding-top: 110px;
    padding-left: 90px;
    padding-right: 90px;
    z-index: 2;
  }
  .badge {
    display: inline-block;
    padding: 14px 36px;
    border-radius: 40px;
    background: rgba(0, 229, 255, 0.12);
    border: 2px solid rgba(0, 229, 255, 0.5);
    color: #00E5FF;
    font-size: 27px;
    font-weight: 800;
    letter-spacing: 3px;
    text-transform: uppercase;
    margin-bottom: 28px;
    box-shadow: 0 0 30px rgba(0, 229, 255, 0.25);
  }
  .title {
    font-size: 96px;
    font-weight: 900;
    line-height: 1.12;
    letter-spacing: -2px;
    margin-bottom: 22px;
  }
  .title-highlight {
    background: linear-gradient(135deg, #00E5FF 0%, #38BDF8 60%, #C084FC 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }
  .subtitle {
    font-size: 40px;
    color: #94A3B8;
    font-weight: 500;
    line-height: 1.35;
    max-width: 1500px;
    margin: 0 auto;
  }
  .device-wrapper {
    position: absolute;
    bottom: -80px;
    width: 1680px;
    height: 1980px;
    z-index: 2;
    display: flex;
    justify-content: center;
  }
  .mockup-frame {
    width: 1560px;
    height: 2060px;
    background: #000;
    border-radius: 52px;
    border: 15px solid #273549;
    box-shadow: 0 55px 170px rgba(0, 0, 0, 0.9), 0 0 100px rgba(0, 229, 255, 0.25);
    overflow: hidden;
    position: relative;
  }
  .screen-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }
</style>
</head>
<body>
  <div class="glow-circle"></div>
  <div class="header">
    <div class="badge">${slide.badge}</div>
    <div class="title">${slide.title} <br><span class="title-highlight">${slide.titleHighlight}</span></div>
    <div class="subtitle">${slide.subtitle}</div>
  </div>
  <div class="device-wrapper">
    <div class="mockup-frame">
      <img class="screen-img" src="${imgSrc}">
    </div>
  </div>
</body>
</html>`;
}

async function renderBanners() {
  const browser = await chromium.launch({
    channel: 'chrome',
    headless: true,
  });

  console.log('--- Generating iPhone 6.7" App Store Presentation Banners (1290x2796) ---');
  for (let i = 0; i < slides.length; i++) {
    const slide = slides[i];
    const page = await browser.newPage({
      viewport: { width: 1290, height: 2796 },
    });
    const html = generateIPhoneHtml(slide);
    await page.setContent(html);
    await page.waitForTimeout(400);
    const targetFile = path.join(outDir, 'iphone_6_7', slide.filename);
    await page.screenshot({ path: targetFile });
    console.log(`Saved: ${targetFile}`);
    await page.close();
  }

  console.log('--- Generating iPad Pro 12.9" App Store Presentation Banners (2048x2732) ---');
  for (let i = 0; i < slides.length; i++) {
    const slide = slides[i];
    const page = await browser.newPage({
      viewport: { width: 2048, height: 2732 },
    });
    const html = generateIPadHtml(slide);
    await page.setContent(html);
    await page.waitForTimeout(400);
    const targetFile = path.join(outDir, 'ipad_12_9', slide.filename);
    await page.screenshot({ path: targetFile });
    console.log(`Saved: ${targetFile}`);
    await page.close();
  }

  await browser.close();
  console.log('\nAll App Store Marketing Banners Rendered Successfully!');
}

renderBanners().catch(console.error);
