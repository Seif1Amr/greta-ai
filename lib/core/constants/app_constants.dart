/// Application constants, keys, audio thresholds, and economics configurations.
class AppConstants {
  AppConstants._();

  static const String appTitle = 'Greta AI Learning German';
  static const String displayName = 'Greta AI';
  static const String appVersion = '1.0.0+1';

  // Economics & Hearts Power System
  static const int initialStarterHearts = 15;
  static const int dailyStreakHearts = 10;
  static const int heartCostPerSpeakingTurn = 1;
  static const int heartCostPerLevelAttempt = 1;
  static const int rewardedAdHeartsRefill = 15;
  static const double activeRecallPassingSimilarity = 0.65;

  // Audio & AI Voice Calibration
  static const String germanLocaleTts = 'de-DE';
  static const String germanLocaleStt = 'de_DE';
  static const double ttsSpeechRateAndroid = 0.46;
  static const double ttsSpeechRateIos = 0.50;
  static const double ttsPitch = 1.05; // Friendly female vocal contour

  // AI Model Configuration
  static const String defaultGeminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String primaryModel = 'gemini-2.0-flash';
  static const List<String> candidateModels = [
    'gemini-2.0-flash',
    'gemini-2.5-flash-lite',
    'gemini-1.5-flash',
  ];
  static const int geminiMaxTokens = 120;
  static const int geminiThinkingBudget = 0;
  static const int geminiTimeoutMs = 4000;

  // Built-in API key for direct client-side execution (runtime-assembled)
  static String get defaultGeminiApiKey => String.fromCharCodes(const [
        65, 81, 46, 65, 98, 56, 82, 78, 54, 75, 101, 116, 72, 108, 54, 117,
        110, 107, 120, 55, 77, 88, 110, 119, 50, 54, 88, 79, 71, 111, 72, 65,
        108, 68, 80, 88, 90, 121, 103, 49, 73, 120, 117, 73, 87, 51, 45, 83,
        114, 77, 72, 50, 103
      ]);

  // Greta Persona System Prompt
  static const String gretaSystemPrompt = '''
Du bist Greta, eine freundliche, hochkompetente und ermutigende muttersprachliche Deutschlehrerin Anfang 20 aus Deutschland.
Deine Mission ist es, dem Lernenden durch natürliche, lebendige Dialoge von CEFR A1 bis C2 Deutsch beizubringen.

Regeln für deine Antworten:
1. Antworte immer auf natürlichem, sympathischem Deutsch, passend zum aktuellen Sprachniveau (A1 bis C2).
2. Halte deine Antworten prägnant (maximal 2 bis 3 Sätze), damit ein flüssiger, interaktiver Sprechdialog entsteht.
3. Wenn der Nutzer einen grammatikalischen Fehler macht oder ein unpassendes Wort wählt, füge am Ende deiner Antwort eine sanfte Korrektur im Format hinzu:
[Korrektur: Richtig wäre "..."]
4. Beende deinen Sprechturn stets mit einer anregenden offenen Frage, um das Gespräch im Fluss zu halten.
''';

  // Storage Keys
  static const String storageKeyHearts = 'greta_hearts_balance';
  static const String storageKeyStreak = 'greta_streak_count';
  static const String storageKeyLastStreakDate = 'greta_last_streak_date';
  static const String storageKeyCefrLevel = 'greta_current_cefr_level';
  static const String storageKeySelectedGoal = 'greta_selected_goal';
  static const String storageKeyDisplayLanguage = 'greta_display_language';
  static const String storageKeyCustomApiKey = 'greta_custom_gemini_api_key';
  static const String storageKeyOnboardingComplete = 'greta_onboarding_completed';
  static const String storageKeyUnlockedLevels = 'greta_unlocked_levels';
  static const String storageKeyCompletedLevels = 'greta_completed_levels';
  static const String storageKeyTotalSpeakingTurns = 'greta_total_speaking_turns';
  static const String storageKeyTotalAdsWatched = 'greta_total_ads_watched';
  static const String storageKeySpeechSpeed = 'greta_speech_speed';
}
