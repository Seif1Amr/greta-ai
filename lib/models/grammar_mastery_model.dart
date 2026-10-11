library;

/// Models for the 4 core German grammar struggle areas (Genus, Kasus, Trennbare Verben, Satzbau).

enum GrammarTopicId {
  genus, // der, die, das
  kasus, // Nominativ, Akkusativ, Dativ, Genitiv
  trennbareVerben, // Separable vs. Inseparable Verbs
  satzbau, // Kausalsätze & Subordinate Word Order (weil, denn, deshalb)
}

class GrammarExerciseItem {
  final int index;
  final String promptGerman;
  final String phoneticIpa;
  final String phoneticBreakdown;
  final String translationEn;
  final String translationDe;
  final String translationAr;
  final String ruleExplanationEn;
  final String ruleExplanationDe;
  final String ruleExplanationAr;
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  const GrammarExerciseItem({
    required this.index,
    required this.promptGerman,
    required this.phoneticIpa,
    required this.phoneticBreakdown,
    required this.translationEn,
    required this.translationDe,
    required this.translationAr,
    required this.ruleExplanationEn,
    required this.ruleExplanationDe,
    required this.ruleExplanationAr,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  String getTranslation(String langCode) {
    if (langCode == 'de') return translationDe;
    if (langCode == 'ar') return translationAr;
    return translationEn;
  }

  String getRule(String langCode) {
    if (langCode == 'de') return ruleExplanationDe;
    if (langCode == 'ar') return ruleExplanationAr;
    return ruleExplanationEn;
  }
}

class GrammarLevelData {
  final int levelNumber;
  final String titleEn;
  final String titleDe;
  final String titleAr;
  final String subtitleEn;
  final String subtitleDe;
  final String subtitleAr;
  final String ruleSummaryEn;
  final String ruleSummaryDe;
  final String ruleSummaryAr;
  final List<GrammarExerciseItem> exercises;

  const GrammarLevelData({
    required this.levelNumber,
    required this.titleEn,
    required this.titleDe,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleDe,
    required this.subtitleAr,
    required this.ruleSummaryEn,
    required this.ruleSummaryDe,
    required this.ruleSummaryAr,
    required this.exercises,
  });

  String getTitle(String langCode) {
    if (langCode == 'de') return titleDe;
    if (langCode == 'ar') return titleAr;
    return titleEn;
  }

  String getSubtitle(String langCode) {
    if (langCode == 'de') return subtitleDe;
    if (langCode == 'ar') return subtitleAr;
    return subtitleEn;
  }

  String getRuleSummary(String langCode) {
    if (langCode == 'de') return ruleSummaryDe;
    if (langCode == 'ar') return ruleSummaryAr;
    return ruleSummaryEn;
  }
}

class GrammarStudioCategory {
  final GrammarTopicId id;
  final String key;
  final String nameEn;
  final String nameDe;
  final String nameAr;
  final String badge;
  final String iconEmoji;
  final String summaryEn;
  final String summaryDe;
  final String summaryAr;
  final List<String> keyRules;
  final List<GrammarLevelData> levels;

  const GrammarStudioCategory({
    required this.id,
    required this.key,
    required this.nameEn,
    required this.nameDe,
    required this.nameAr,
    required this.badge,
    required this.iconEmoji,
    required this.summaryEn,
    required this.summaryDe,
    required this.summaryAr,
    required this.keyRules,
    required this.levels,
  });

  String getName(String langCode) {
    if (langCode == 'de') return nameDe;
    if (langCode == 'ar') return nameAr;
    return nameEn;
  }

  String getSummary(String langCode) {
    if (langCode == 'de') return summaryDe;
    if (langCode == 'ar') return summaryAr;
    return summaryEn;
  }
}
