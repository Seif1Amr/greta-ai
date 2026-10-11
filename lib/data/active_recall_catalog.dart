import 'dart:math';
import '../models/active_recall_phrase.dart';

class ActiveRecallCatalog {
  ActiveRecallCatalog._();

  static const List<ActiveRecallPhrase> pool = [
    ActiveRecallPhrase(
      germanText: 'Ich hätte gerne einen Kaffee, bitte.',
      phoneticIpa: '[ɪç ˈhɛtə ˈɡɛʁnə ˈaɪ̯nən ˈkafeː ˈbɪtə]',
      phoneticGuide: 'Ikh HEH-tuh GAIR-nuh EYE-nen KAH-fay, BIT-tuh',
      englishTranslation: 'I would like to have a coffee, please.',
      germanTranslation: 'Ich möchte gerne einen Kaffee bestellen, bitte.',
      arabicTranslation: 'أود الحصول على قهوة من فضلك.',
      grammarNote: 'Konjunktiv II (hätte gern) is the most polite form for ordering in German.',
    ),
    ActiveRecallPhrase(
      germanText: 'Könnten Sie mir bitte helfen?',
      phoneticIpa: '[ˈkœntn̩ ziː miːɐ̯ ˈbɪtə ˈhɛlfn̩]',
      phoneticGuide: 'KURN-tn zee meer BIT-tuh HEL-fn?',
      englishTranslation: 'Could you please help me?',
      germanTranslation: 'Wären Sie so freundlich, mir zu helfen?',
      arabicTranslation: 'هل يمكنك مساعدتي من فضلك؟',
      grammarNote: 'Könnten Sie + Dative pronoun (mir) + infinitive (helfen).',
    ),
    ActiveRecallPhrase(
      germanText: 'Wie viel kostet das, bitte?',
      phoneticIpa: '[viː fiːl ˈkɔstət das ˈbɪtə]',
      phoneticGuide: 'Vee feel KOS-tet dahs, BIT-tuh?',
      englishTranslation: 'How much does this cost, please?',
      germanTranslation: 'Was ist der Preis von diesem Artikel?',
      arabicTranslation: 'كم يكلف هذا من فضلك؟',
      grammarNote: 'Standard question structure for prices in shops and markets.',
    ),
    ActiveRecallPhrase(
      germanText: 'Entschuldigung, wo ist der Bahnhof?',
      phoneticIpa: '[ɛntˈʃʊldɪɡʊŋ voː ɪst deːɐ̯ ˈbaːnhoːf]',
      phoneticGuide: 'Ent-SHOOL-dee-goong, vo ist dair BAHN-hohf?',
      englishTranslation: 'Excuse me, where is the train station?',
      germanTranslation: 'Verzeihung, in welcher Richtung liegt der Bahnhof?',
      arabicTranslation: 'عفواً، أين تقع محطة القطار؟',
      grammarNote: 'Der Bahnhof is masculine nominative after "ist".',
    ),
    ActiveRecallPhrase(
      germanText: 'Es freut mich sehr, Sie kennenzulernen.',
      phoneticIpa: '[ɛs fʁɔɪ̯t mɪç zeːɐ̯ ziː ˈkɛnəntsuˌlɛʁnən]',
      phoneticGuide: 'Es froyt mikh zair, zee KEN-nen-tsoo-LAIR-nen',
      englishTranslation: 'It is a pleasure to meet you.',
      germanTranslation: 'Sehr angenehm, Ihre Bekanntschaft zu machen.',
      arabicTranslation: 'يسرني جداً التعرف عليك.',
      grammarNote: 'Formal polite greeting with separable infinitive construction.',
    ),
    ActiveRecallPhrase(
      germanText: 'Können wir die Rechnung haben?',
      phoneticIpa: '[ˈkœnən viːɐ̯ diː ˈʁɛçnʊŋ ˈhaːbn̩]',
      phoneticGuide: 'KUR-nen veer dee REKH-noong HAH-ben?',
      englishTranslation: 'Can we have the bill, please?',
      germanTranslation: 'Wir möchten bitte bezahlen.',
      arabicTranslation: 'هل يمكننا الحصول على الفاتورة؟',
      grammarNote: 'Die Rechnung is feminine accusative object of haben.',
    ),
    ActiveRecallPhrase(
      germanText: 'Ich verstehe das leider nicht ganz.',
      phoneticIpa: '[ɪç fɛɐ̯ˈʃteːə das ˈlaɪ̯dɐ nɪçt ɡants]',
      phoneticGuide: 'Ikh fair-SHTAY-uh dahs LY-der nikht gahnts',
      englishTranslation: 'Unfortunately, I don\'t quite understand that.',
      germanTranslation: 'Es tut mir leid, das war mir nicht ganz klar.',
      arabicTranslation: 'للأسف لم أفهم ذلك تماماً.',
      grammarNote: 'Leider indicates polite regret in spoken German.',
    ),
    ActiveRecallPhrase(
      germanText: 'Ich lerne jeden Tag fleißig Deutsch.',
      phoneticIpa: '[ɪç ˈlɛʁnə ˈjeːdn̩ taːk ˈflaɪ̯sɪç dɔɪ̯tʃ]',
      phoneticGuide: 'Ikh LAIR-nuh YAY-dn tahk FLY-sikh DOYTCH',
      englishTranslation: 'I study German diligently every day.',
      germanTranslation: 'Ich übe täglich regelmäßig die deutsche Sprache.',
      arabicTranslation: 'أنا أتعلم الألمانية باجتهاد كل يوم.',
      grammarNote: 'Time element (jeden Tag) precedes manner (fleißig).',
    ),
  ];

  static ActiveRecallPhrase getRandomPhrase() {
    final rand = Random();
    return pool[rand.nextInt(pool.length)];
  }
}
