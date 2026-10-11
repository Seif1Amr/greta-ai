/// Model representing a single exercise in a curriculum level.
class CurriculumExercise {
  final int index;
  final String germanPhrase;
  final String phoneticIpa;
  final String phoneticBreakdown;
  final String translationEn;
  final String translationDe;
  final String translationAr;
  final String grammarTipEn;
  final String grammarTipDe;
  final String grammarTipAr;
  final String questionEn;
  final String questionDe;
  final String questionAr;
  final List<String> optionsEn;
  final List<String> optionsDe;
  final List<String> optionsAr;
  final int correctOptionIndex;

  const CurriculumExercise({
    required this.index,
    required this.germanPhrase,
    required this.phoneticIpa,
    required this.phoneticBreakdown,
    required this.translationEn,
    required this.translationDe,
    required this.translationAr,
    required this.grammarTipEn,
    required this.grammarTipDe,
    required this.grammarTipAr,
    required this.questionEn,
    required this.questionDe,
    required this.questionAr,
    required this.optionsEn,
    required this.optionsDe,
    required this.optionsAr,
    required this.correctOptionIndex,
  });

  String getTranslation(String langCode) {
    if (langCode == 'de') return translationDe;
    if (langCode == 'ar') return translationAr;
    return translationEn;
  }

  String getGrammarTip(String langCode) {
    if (langCode == 'de') return grammarTipDe;
    if (langCode == 'ar') return grammarTipAr;
    return grammarTipEn;
  }

  String getQuestion(String langCode) {
    if (langCode == 'de') return questionDe;
    if (langCode == 'ar') return questionAr;
    return questionEn;
  }

  List<String> getOptions(String langCode) {
    if (langCode == 'de') return optionsDe;
    if (langCode == 'ar') return optionsAr;
    return optionsEn;
  }
}

/// Model representing a level in the 600-level German curriculum.
class CurriculumLevel {
  final int levelNumber;
  final String tier; // A1, A2, B1, B2, C1, C2
  final String titleEn;
  final String titleDe;
  final String titleAr;
  final String descriptionEn;
  final String descriptionDe;
  final String descriptionAr;
  final String grammarFocus;
  final List<CurriculumExercise> exercises;

  const CurriculumLevel({
    required this.levelNumber,
    required this.tier,
    required this.titleEn,
    required this.titleDe,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionDe,
    required this.descriptionAr,
    required this.grammarFocus,
    required this.exercises,
  });

  String getTitle(String langCode) {
    if (langCode == 'de') return titleDe;
    if (langCode == 'ar') return titleAr;
    return titleEn;
  }

  String getDescription(String langCode) {
    if (langCode == 'de') return descriptionDe;
    if (langCode == 'ar') return descriptionAr;
    return descriptionEn;
  }
}
