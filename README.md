# Greta AI Learning German 🇩🇪

[![Flutter](https://img.shields.io/badge/Flutter-3.35.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.0-0175C2?logo=dart)](https://dart.dev)
[![Gemini 2.0 Flash](https://img.shields.io/badge/AI-Gemini%202.0%20Flash-4285F4?logo=google)](https://ai.google.dev)
[![iOS Target](https://img.shields.io/badge/iOS-15.0%2B-black?logo=apple)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-Proprietary-blue.svg)]()

> **Greta AI Learning German** (home screen display: **Greta AI**) is a production-grade, conversational spoken German tutor powered directly by Google's **Gemini 2.0 Flash** engine, designed for mastering German from CEFR **A1 to C2**.

---

## 🌟 Key Highlights

### 1. Avatar Identity & Reactive Visual Polish
- **Greta**: An articulate, encouraging native German speaking coach in her early 20s with blue eyes, brown hair, modern European styling, and an engaging smile.
- **4 Reactive Emotional States**:
  - `avatar_greta_neutral.jpg` (ready / listening state)
  - `avatar_greta_speaking.jpg` (talking state)
  - `avatar_greta_thinking.jpg` (processing AI turn)
  - `avatar_greta_celebrating.jpg` (pronunciation success / streak complete)
- **GlowingVoiceOrb**: Radial glow audio orb reacting dynamically to sound level decibels, breathing pulses, and thinking rotations.

### 2. Redesigned 3-Screen Sliding Onboarding
- **Slide 1 — Motivation & Goals**: Selectable chips for *Career & Job in Germany 💼*, *Travel & Living ✈️*, *Studying & University 🎓*, *German Citizenship / Visa 🏛️*, and *Daily Conversation ☕*.
- **Slide 2 — Proficiency Benchmark**: Interactive placement benchmark from A1 to C2.
- **Slide 3 — Daily Habit & Audio Greeting**: 1-tap interactive voice greeting from Greta via native German TTS (*"Hallo! Ich bin Greta. Lass uns gemeinsam Deutsch lernen!"*) + **+15 Free Hearts Welcome Bonus**.

### 3. 600-Level German Curriculum (A1 – C2) with Fast-Scroll
- 600 comprehensive levels spanning all 6 CEFR tiers (100 levels each: A1, A2, B1, B2, C1, C2).
- Exactly **10 exercises per level**:
  1. Phrase listen (German native TTS).
  2. Phonetic breakdown & IPA guide.
  3. User speech practice with real-time similarity evaluation (`speech_to_text` with locale `de_DE`).
  4. Multiple-choice grammar/context reinforcement.
- **Right-Hand Fast-Scroll Indexer**: Sticky vertical indexer `[ A1 • A2 • B1 • B2 • C1 • C2 ]` supporting drag and tap jump animations.

### 4. Trilingual Display Localization
- **English** (Default), **Deutsch** (German), and **العربية** (Arabic with full RTL support and `GoogleFonts.readexPro()`).
- Instant runtime switching from Profile settings without app restarts.

### 5. Monetization & Active Recall Ad-Bridge Hearts System
- **Unit Economics**:
  - Starter Bonus: **15 Hearts**
  - 24-Hour Streak Daily Bonus: **+10 Hearts**
  - 1 Speaking Turn = **1 Heart**
  - 1 Level Attempt / Unlock = **1 Heart**
  - Rewarded Ad Refill = **+15 Hearts**
- **4-Step Active Recall Sequence**:
  1. *Target German Phrase Pull*: Key practical German phrase with IPA and translation.
  2. *Pre-Ad Challenge Dialog*: Rehearsal prompt + native audio sample.
  3. *Rehearsal During Sponsor Clip*: Full-screen AdMob Rewarded Video plays while STT pre-warms.
  4. *Immediate Post-Ad Speech Check*: "Sprich jetzt!" mic prompt -> pronunciation match -> **+15 Hearts granted**.

### 6. AI Engine & Audio Pipeline Calibration
- Direct client-side execution via `gemini-2.0-flash` with cascading fallback: `gemini-2.0-flash` -> `gemini-2.5-flash-lite` -> `gemini-1.5-flash`.
- Parameters: `maxOutputTokens: 120`, `thinkingBudget: 0`, HTTP timeout: 4000ms.
- Calibrated female German TTS (`de-DE`, rate 0.46 Android / 0.50 iOS).
- Strict audio focus guard preventing TTS and STT hardware collisions.

---

## 📱 Platform & iOS Compliance
- **Swift Package Manager**: Explicitly disabled in `pubspec.yaml` (`enable-swift-package-manager: false`).
- **iOS Target**: 15.0 minimum deployment target enforced in `ios/Podfile` and `project.pbxproj`.
- **Permissions**: `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`, `NSUserTrackingUsageDescription`, `NSAppTransportSecurity`.
- **AdMob**: Configured `GADApplicationIdentifier` and SKAdNetwork items.
- **CI/CD**: `codemagic.yaml` configured for zero-friction iOS builds.

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/Seif1Amr/greta-ai.git

# Install dependencies
flutter pub get

# Generate app icons
dart run flutter_launcher_icons

# Run static analysis
flutter analyze

# Run unit tests
flutter test

# Run app
flutter run
```
