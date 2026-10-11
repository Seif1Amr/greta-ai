/// Model representing a target phrase for the Active Recall Ad-Bridge.
class ActiveRecallPhrase {
  final String germanText;
  final String phoneticIpa;
  final String phoneticGuide;
  final String englishTranslation;
  final String germanTranslation;
  final String arabicTranslation;
  final String grammarNote;

  const ActiveRecallPhrase({
    required this.germanText,
    required this.phoneticIpa,
    required this.phoneticGuide,
    required this.englishTranslation,
    required this.germanTranslation,
    required this.arabicTranslation,
    required this.grammarNote,
  });

  String getTranslation(String langCode) {
    if (langCode == 'de') return germanTranslation;
    if (langCode == 'ar') return arabicTranslation;
    return englishTranslation;
  }
}
