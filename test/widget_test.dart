import 'package:flutter_test/flutter_test.dart';
import 'package:greta_ai_german/core/utils/text_similarity.dart';
import 'package:greta_ai_german/data/active_recall_catalog.dart';
import 'package:greta_ai_german/data/german_curriculum_catalog.dart';
import 'package:greta_ai_german/data/grammar_mastery_catalog.dart';
import 'package:greta_ai_german/models/grammar_mastery_model.dart';

void main() {
  group('Greta AI Core Verification Tests', () {
    test('GermanCurriculumCatalog has 600 levels and correct tier distribution', () {
      final summaries = GermanCurriculumCatalog.getAllLevelSummaries();
      expect(summaries.length, 600);

      expect(summaries.first.levelNumber, 1);
      expect(summaries.first.tier, 'A1');

      expect(summaries[100].levelNumber, 101);
      expect(summaries[100].tier, 'A2');

      expect(summaries[200].levelNumber, 201);
      expect(summaries[200].tier, 'B1');

      expect(summaries[300].levelNumber, 301);
      expect(summaries[300].tier, 'B2');

      expect(summaries[400].levelNumber, 401);
      expect(summaries[400].tier, 'C1');

      expect(summaries[500].levelNumber, 501);
      expect(summaries[500].tier, 'C2');

      expect(summaries.last.levelNumber, 600);
      expect(summaries.last.tier, 'C2');

      final sampleLevel = GermanCurriculumCatalog.getLevel(1);
      expect(sampleLevel.exercises.length, 10);
    });

    test('TextSimilarity calculates German pronunciation accuracy correctly', () {
      const target = 'Ich hätte gerne einen Kaffee, bitte.';
      const spokenExact = 'Ich hätte gerne einen Kaffee bitte';
      const spokenClose = 'Ich hätte gern ein Kaffee bitte';
      const spokenWrong = 'Bonjour je voudrais un cafe';

      final exactScore = TextSimilarity.calculateSimilarity(target, spokenExact);
      expect(exactScore, greaterThanOrEqualTo(0.90));

      final closeScore = TextSimilarity.calculateSimilarity(target, spokenClose);
      expect(closeScore, greaterThan(0.65));

      final wrongScore = TextSimilarity.calculateSimilarity(target, spokenWrong);
      expect(wrongScore, lessThan(0.40));
    });

    test('ActiveRecallCatalog returns valid German phrases', () {
      final phrase = ActiveRecallCatalog.getRandomPhrase();
      expect(phrase.germanText.isNotEmpty, true);
      expect(phrase.phoneticIpa.isNotEmpty, true);
      expect(phrase.phoneticGuide.isNotEmpty, true);
      expect(phrase.englishTranslation.isNotEmpty, true);
    });

    test('GrammarMasteryCatalog contains all 4 high-friction German studios', () {
      final studios = GrammarMasteryCatalog.studios;
      expect(studios.length, 4);

      final genus = studios.firstWhere((s) => s.id == GrammarTopicId.genus);
      expect(genus.levels.length, 4);
      expect(genus.keyRules.isNotEmpty, true);

      final kasus = studios.firstWhere((s) => s.id == GrammarTopicId.kasus);
      expect(kasus.levels.length, 4);

      final verbs = studios.firstWhere((s) => s.id == GrammarTopicId.trennbareVerben);
      expect(verbs.levels.length, 4);

      final satzbau = studios.firstWhere((s) => s.id == GrammarTopicId.satzbau);
      expect(satzbau.levels.length, 4);

      // Test level 1 of genus
      final genusL1 = genus.levels.first;
      expect(genusL1.exercises.length, 3);
      expect(genusL1.exercises.first.options.length, 4);
      expect(genusL1.exercises.first.correctOptionIndex, inInclusiveRange(0, 3));
    });
  });
}
