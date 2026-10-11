import '../models/curriculum_level.dart';

class LevelSummary {
  final int levelNumber;
  final String tier;
  final String titleEn;
  final String titleDe;
  final String titleAr;
  final String grammarFocus;

  const LevelSummary({
    required this.levelNumber,
    required this.tier,
    required this.titleEn,
    required this.titleDe,
    required this.titleAr,
    required this.grammarFocus,
  });

  String getTitle(String langCode) {
    if (langCode == 'de') return titleDe;
    if (langCode == 'ar') return titleAr;
    return titleEn;
  }
}

class GermanCurriculumCatalog {
  GermanCurriculumCatalog._();

  static const List<String> tiers = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  static String getTierForLevel(int levelNumber) {
    if (levelNumber <= 100) return 'A1';
    if (levelNumber <= 200) return 'A2';
    if (levelNumber <= 300) return 'B1';
    if (levelNumber <= 400) return 'B2';
    if (levelNumber <= 500) return 'C1';
    return 'C2';
  }

  static int getStartingLevelForTier(String tier) {
    switch (tier) {
      case 'A1':
        return 1;
      case 'A2':
        return 101;
      case 'B1':
        return 201;
      case 'B2':
        return 301;
      case 'C1':
        return 401;
      case 'C2':
        return 501;
      default:
        return 1;
    }
  }

  // Unit themes per tier (10 units per tier, 10 levels per unit)
  static const Map<String, List<Map<String, String>>> _tierThemes = {
    'A1': [
      {'en': 'Greetings & Polite Phrases', 'de': 'Begrüßungen & Höflichkeit', 'ar': 'التحيات والعبارات المهذبة', 'grammar': 'Subjektpronomen (ich, du, Sie)'},
      {'en': 'The Alphabet & Sound System', 'de': 'Alphabet & Lautsystem', 'ar': 'الأبجدية والأصوات الألمانية', 'grammar': 'Umlaute & Diphthonge'},
      {'en': 'Numbers, Time & Days', 'de': 'Zahlen, Uhrzeit & Wochentage', 'ar': 'الأرقام، الوقت وأيام الأسبوع', 'grammar': 'Kardinalzahlen & Ordinalzahlen'},
      {'en': 'Articles (der, die, das)', 'de': 'Artikel (der, die, das)', 'ar': 'أدوات التعريف (der, die, das)', 'grammar': 'Genus & Bestimmte Artikel'},
      {'en': 'Essential Verbs (sein & haben)', 'de': 'Verben sein & haben', 'ar': 'الأفعال الأساسية (sein و haben)', 'grammar': 'Präsens Konjugation'},
      {'en': 'Family & Personal Details', 'de': 'Familie & Steckbrief', 'ar': 'العائلة والبيانات الشخصية', 'grammar': 'Possessivartikel (mein, dein)'},
      {'en': 'Food, Drinks & Ordering', 'de': 'Essen, Trinken & Bestellen', 'ar': 'الطعام، المشروبات والطلب', 'grammar': 'Akkusativ Einführung'},
      {'en': 'Daily Routine & Home Life', 'de': 'Tagesablauf & Wohnen', 'ar': 'الروتين اليومي والمنزل', 'grammar': 'Trennbare Verben (aufstehen)'},
      {'en': 'Hobbies & Free Time', 'de': 'Hobbys & Freizeit', 'ar': 'الهوايات وأوقات الفراغ', 'grammar': 'Modalverb können'},
      {'en': 'Simple Questions & Negation', 'de': 'W-Fragen & Verneinung', 'ar': 'الأسئلة والنفي', 'grammar': 'nicht vs. kein'},
    ],
    'A2': [
      {'en': 'Accusative & Dative Cases', 'de': 'Akkusativ- und Dativobjekte', 'ar': 'حالات النصب والجر (Akkusativ & Dativ)', 'grammar': 'Wechselpräpositionen'},
      {'en': 'Modal Verbs Mastery', 'de': 'Modalverben im Alltag', 'ar': 'إتقان الأفعال الناقصة (Modalverben)', 'grammar': 'müssen, dürfen, sollen, wollen'},
      {'en': 'Shopping & City Life', 'de': 'Einkaufen & Stadtleben', 'ar': 'التسوق وحياة المدينة', 'grammar': 'Komparativ & Superlativ'},
      {'en': 'Asking & Giving Directions', 'de': 'Wegbeschreibungen', 'ar': 'طلب ووصف الاتجاهات', 'grammar': 'Lokale Präpositionen (zu, nach, an)'},
      {'en': 'Past Tense (Das Perfekt)', 'de': 'Perfekt mit haben & sein', 'ar': 'الماضي التام (Perfekt)', 'grammar': 'Partizip II Bildung'},
      {'en': 'Health, Body & Doctor Visit', 'de': 'Gesundheit & Arztbesuch', 'ar': 'الصحة وزيارة الطبيب', 'grammar': 'Imperativ & Ratschläge'},
      {'en': 'Travel, Train & Airports', 'de': 'Reisen, Bahn & Flughafen', 'ar': 'السفر، القطار والمطارات', 'grammar': 'Temporale Präpositionen'},
      {'en': 'Workplace & Daily Office', 'de': 'Arbeitsplatz & Büroalltag', 'ar': 'مكان العمل والروتين المكتبي', 'grammar': 'Dativ Verben (helfen, danken)'},
      {'en': 'Celebrations & Invitations', 'de': 'Feste & Einladungen', 'ar': 'الاحتفالات والدعوات', 'grammar': 'Personalpronomen im Dativ'},
      {'en': 'Housing & Moving in Germany', 'de': 'Wohnungssuche & Umzug', 'ar': 'البحث عن سكن والانتقال', 'grammar': 'Adjektivdeklination Einführung'},
    ],
    'B1': [
      {'en': 'Subordinate Clauses (weil, dass)', 'de': 'Nebensätze mit weil & dass', 'ar': 'الجمل الفرعية (weil, dass)', 'grammar': 'Verb-Letzt-Stellung'},
      {'en': 'Concessive & Temporal Clauses', 'de': 'obwohl, wenn & als', 'ar': 'الجمل التناقضية والزمنية', 'grammar': 'Konnektoren der Unterordnung'},
      {'en': 'Work Life & Job Inquiries', 'de': 'Berufsleben & Anfragen', 'ar': 'بيئة العمل والاستفسارات الوظيفية', 'grammar': 'Höflichkeitsform Konjunktiv II'},
      {'en': 'Expressing Opinions & Debates', 'de': 'Meinungen & Argumentation', 'ar': 'إبداء الرأي والنقاش', 'grammar': 'Meiner Meinung nach...'},
      {'en': 'The Future Tense (Futur I)', 'de': 'Futur I & Absichten', 'ar': 'المستقبل البسيط (Futur I)', 'grammar': 'werden + Infinitiv'},
      {'en': 'Relative Clauses', 'de': 'Relativsätze im Nominativ/Akkusativ', 'ar': 'جمل الصلة والموصول', 'grammar': 'Relativpronomen (der, die, das)'},
      {'en': 'Environment & Modern Life', 'de': 'Umwelt, Natur & Nachhaltigkeit', 'ar': 'البيئة والحياة المعاصرة', 'grammar': 'Infinitiv mit zu'},
      {'en': 'Media, News & Culture', 'de': 'Medien, Nachrichten & Kultur', 'ar': 'الإعلام، الأخبار والثقافة', 'grammar': 'Zweiteilige Konnektoren (sowohl... als auch)'},
      {'en': 'Customer Service & Complaints', 'de': 'Kundenservice & Reklamationen', 'ar': 'خدمة العملاء والشكاوى', 'grammar': 'Indirekte Fragesätze'},
      {'en': 'Interviews & Career Resumes', 'de': 'Vorstellungsgespräche & Lebenslauf', 'ar': 'المقابلات والسيرة الذاتية', 'grammar': 'Präteritum von sein/haben & Modalverben'},
    ],
    'B2': [
      {'en': 'Passive Voice (Vorgangspassiv)', 'de': 'Vorgangspassiv & Zustandspassiv', 'ar': 'المبني للمجهول في الألمانية', 'grammar': 'werden + Partizip II'},
      {'en': 'Idiomatic & Spoken Colloquialisms', 'de': 'Redewendungen & Sprichwörter', 'ar': 'التعبيرات الاصطلاحية والأمثال', 'grammar': 'Feste Nomen-Verb-Verbindungen'},
      {'en': 'Formal Business Correspondence', 'de': 'Geschäftskorrespondenz & E-Mails', 'ar': 'المراسلات الرسمية والبريد الإلكتروني', 'grammar': 'Sehr geehrte Damen und Herren'},
      {'en': 'Complex Adjective Endings', 'de': 'Erweiterte Adjektivdeklination', 'ar': 'تصريف الصفات المتقدم', 'grammar': 'Schwache, starke & gemischte Flexion'},
      {'en': 'Subjunctive II in Negotiation', 'de': 'Konjunktiv II in Verhandlungen', 'ar': 'صيغة الشرط الثانية في المفاوضات', 'grammar': 'hätte / wäre / würde + Infinitiv'},
      {'en': 'Scientific & Tech German', 'de': 'Wissenschaft & Technologie', 'ar': 'الألمانية التقنية والعلمية', 'grammar': 'Partizip I & II als Adjektiv'},
      {'en': 'Bureaucracy & Administration', 'de': 'Behördendeutsch & Verträge', 'ar': 'المعاملات الإدارية والعقود', 'grammar': 'Nominalstil & Passiversatzformen'},
      {'en': 'Advanced Debate & Rhetoric', 'de': 'Rhetorik & Überzeugung', 'ar': 'البلاغة والإقناع في الحوار', 'grammar': 'Kausal-, Konzessiv- & Finalsätze'},
      {'en': 'German History & Society', 'de': 'Geschichte & Gesellschaft', 'ar': 'التاريخ والمجتمع الألماني', 'grammar': 'Präteritum im Fließtext'},
      {'en': 'Leading Professional Meetings', 'de': 'Meetings & Präsentationen leiten', 'ar': 'إدارة الاجتماعات والعروض المهنية', 'grammar': 'Redemittel für Moderation'},
    ],
    'C1': [
      {'en': 'Nuanced Academic Discourse', 'de': 'Akademischer Diskurs & Argumentation', 'ar': 'الخطاب الأكاديمي المتقدم والتحليل', 'grammar': 'Substantivierung & Verbalstil'},
      {'en': 'Bureaucracy Mastery (Bürgeramt)', 'de': 'Bürgeramt & Behördenanträge', 'ar': 'معاملات البلدية والدوائر الحكومية', 'grammar': 'Amtsdeutsch & Rechtsbegriffe'},
      {'en': 'Subjunctive I (Reported Speech)', 'de': 'Konjunktiv I in der indirekten Rede', 'ar': 'صيغة نقل الكلام (Konjunktiv I)', 'grammar': 'Distanzierende Redewiedergabe'},
      {'en': 'Economics & Financial Politics', 'de': 'Wirtschafts- & Finanzpolitik', 'ar': 'الاقتصاد والسياسات المالية', 'grammar': 'Komplexe Konditionalsätze'},
      {'en': 'Legal Frameworks & Contracts', 'de': 'Rechtliche Rahmenbedingungen', 'ar': 'الأطر القانونية وبنود العقود', 'grammar': 'Modalitätsverben (haben/sein + zu + Inf.)'},
      {'en': 'High Literature & Stylistics', 'de': 'Stilistik & Literatursprache', 'ar': 'الأسلوبية والأدب الرفيع', 'grammar': 'Inversion & Satzbauvariationen'},
      {'en': 'Philosophy, Ethics & Debates', 'de': 'Philosophie, Ethik & Grundwerte', 'ar': 'الفلسفة، الأخلاق والقضايا الكبرى', 'grammar': 'Konzessive Partikeln (wenngleich)'},
      {'en': 'Advanced Media Criticism', 'de': 'Medienanalyse & Diskurskritik', 'ar': 'النقد الإعلامي والتحليل الثقافي', 'grammar': 'Modalpartikeln (ja, doch, wohl)'},
      {'en': 'Scientific Paper Structuring', 'de': 'Verfassen wissenschaftlicher Arbeiten', 'ar': 'كتابة الأوراق والبحوث العلمية', 'grammar': 'Unpersönliche Ausdrucksweisen'},
      {'en': 'Diplomatic Negotiations', 'de': 'Diplomatie & Verhandlungsführung', 'ar': 'المفاوضات الدبلوماسية العليا', 'grammar': 'Rhetorische Stilmittel & Taktik'},
    ],
    'C2': [
      {'en': 'Native Colloquialisms & Dialects', 'de': 'Dialekte & Umgangssprache', 'ar': 'اللهجات المحلية واللغة الدارجة العميقة', 'grammar': 'Regionale Spracheigenheiten'},
      {'en': 'German Literary Masterpieces', 'de': 'Klassische Meisterwerke (Goethe & Schiller)', 'ar': 'روائع الأدب الكلاسيكي الألماني', 'grammar': 'Historischer Satzbau & Archaismen'},
      {'en': 'Master-Level Executive Fluency', 'de': 'Vorstandsebene & Führungssprache', 'ar': 'لغة القيادة التنفيذية العليا', 'grammar': 'Präzisionslexik & Konnotationen'},
      {'en': 'Subtle Irony & Dark Humor', 'de': 'Ironie, Sarkasmus & Sprachwitz', 'ar': 'السخرية الأدبية والتلميح اللغوي الذكي', 'grammar': 'Tonalitätsnuancen & Wortspiele'},
      {'en': 'Specialized High-Stakes Negotiations', 'de': 'Strategische Schiedsverfahren', 'ar': 'المفاوضات والتحكيم الإستراتيجي', 'grammar': 'Juristische Feinsinnigkeit'},
      {'en': 'Poetics, Metaphor & Symbolism', 'de': 'Metaphorik & Symbolsprache', 'ar': 'الشعرية، الاستعارات والرمزية', 'grammar': 'Bildhafte Spracharchitektur'},
      {'en': 'Socio-Political Philosophy', 'de': 'Sozialphilosophische Abhandlungen', 'ar': 'الفلسفة السياسية والاجتماعية', 'grammar': 'Syntaktische Verschachtelung'},
      {'en': 'Advanced Cross-Cultural Pragmatics', 'de': 'Interkulturelle Tiefenpragmatik', 'ar': 'التداولية الثقافية العميقة', 'grammar': 'Kontextuelle Höflichkeitsmatrix'},
      {'en': 'Spontaneous Native Oratory', 'de': 'Freie Rede & Spontane Eloquenz', 'ar': 'الخطابة الارتجالية والفصاحة العالية', 'grammar': 'Spontane Syntaxreorganisation'},
      {'en': 'Absolute Native Linguistic Mastery', 'de': 'Vollendete Sprachvirtuosität', 'ar': 'الإتقان اللغوي المطلق لمستوى المتحدث الأصلي', 'grammar': 'Volle Beherrschung aller Register'},
    ],
  };

  // Cache for level summaries (600 items)
  static List<LevelSummary>? _cachedSummaries;

  static List<LevelSummary> getAllLevelSummaries() {
    if (_cachedSummaries != null) return _cachedSummaries!;

    final list = <LevelSummary>[];

    for (int lvl = 1; lvl <= 600; lvl++) {
      final tier = getTierForLevel(lvl);
      final tierLevelIndex = (lvl - 1) % 100; // 0 to 99
      final unitIndex = tierLevelIndex ~/ 10; // 0 to 9
      final subIndex = (tierLevelIndex % 10) + 1; // 1 to 10

      final themeList = _tierThemes[tier]!;
      final theme = themeList[unitIndex];

      final titleEn = '${theme['en']!} • Part $subIndex';
      final titleDe = '${theme['de']!} • Teil $subIndex';
      final titleAr = '${theme['ar']!} • جزء $subIndex';
      final grammar = theme['grammar']!;

      list.add(
        LevelSummary(
          levelNumber: lvl,
          tier: tier,
          titleEn: titleEn,
          titleDe: titleDe,
          titleAr: titleAr,
          grammarFocus: grammar,
        ),
      );
    }

    _cachedSummaries = list;
    return list;
  }

  // Pre-curated core phrase bank to seed procedural generation
  static const List<Map<String, String>> _phraseSeeds = [
    {
      'de': 'Guten Tag, wie geht es Ihnen?',
      'ipa': '[ˈɡuːtn̩ taːk viː ɡeːt ɛs ˈiːnən]',
      'ph': 'GOO-tn tahk, vee gayt es EE-nen?',
      'en': 'Good day, how are you?',
      'ar': 'طاب يومك، كيف حالك؟',
      'tip_en': 'Formal greeting using the polite capitalized "Ihnen".',
      'tip_de': 'Höfliche Anrede mit Dativpronomen "Ihnen".',
      'tip_ar': 'صيغة مهذبة ورسمية باستخدام الضمير Ihnen.',
      'q_en': 'What does "Guten Tag" mean?',
      'q_de': 'Was bedeutet "Guten Tag"?',
      'q_ar': 'ما معنى Guten Tag؟',
      'opt_en': 'Good day|Good night|See you tomorrow|Please',
      'opt_de': 'Guten Tag|Gute Nacht|Bis morgen|Bitte',
      'opt_ar': 'طاب يومك|تصبح على خير|أراك غداً|من فضلك',
      'ans': '0',
    },
    {
      'de': 'Ich heiße Greta und ich lerne Deutsch.',
      'ipa': '[ɪç ˈhaɪ̯sə ˈɡʁeːta ʊnt ɪç ˈlɛʁnə dɔɪ̯tʃ]',
      'ph': 'Ikh HY-suh Greta oont ikh LAIR-nuh DOYTCH.',
      'en': 'My name is Greta and I am learning German.',
      'ar': 'اسمي غريتا وأنا أتعلم الألمانية.',
      'tip_en': 'Verb "heißen" takes the first person ending "-e" (ich heiße).',
      'tip_de': '1. Person Singular Präsens Endung "-e".',
      'tip_ar': 'تصريف الفعل مع ضمير المتكلم ich ينتهي بالحرف e.',
      'q_en': 'Which verb expresses "my name is"?',
      'q_de': 'Welches Verb drückt den Namen aus?',
      'q_ar': 'أي فعل يعبر عن "اسمي هو"؟',
      'opt_en': 'heißen|kommen|wohnen|gehen',
      'opt_de': 'heißen|kommen|wohnen|gehen',
      'opt_ar': 'heißen|kommen|wohnen|gehen',
      'ans': '0',
    },
    {
      'de': 'Woher kommen Sie, bitte?',
      'ipa': '[voːˈheːɐ̯ ˈkɔmən ziː ˈbɪtə]',
      'ph': 'Voh-HAIR KOM-men zee, BIT-tuh?',
      'en': 'Where do you come from, please?',
      'ar': 'من أين حضرتك، من فضلك؟',
      'tip_en': '"Woher" specifically asks for origin or direction of departure.',
      'tip_de': '"Woher" fragt nach der Herkunft.',
      'tip_ar': 'أداة الاستفهام Woher تسأل عن الأصل أو البلد القادم منه.',
      'q_en': 'What does "Woher" ask about?',
      'q_de': 'Wonach fragt "Woher"?',
      'q_ar': 'عن ماذا تسأل Woher؟',
      'opt_en': 'Origin / Where from|Where to|At what time|Why',
      'opt_de': 'Herkunft|Zielort|Uhrzeit|Grund',
      'opt_ar': 'مكان القدوم / الأصل|مكان الذهاب|الوقت|السبب',
      'ans': '0',
    },
    {
      'de': 'Ich wohne in Berlin in Deutschland.',
      'ipa': '[ɪç ˈvoːnə ɪn bɛʁˈliːn ɪn ˈdɔɪ̯tʃlant]',
      'ph': 'Ikh VOH-nuh in Bair-LEEN in DOYTCH-lahnt.',
      'en': 'I live in Berlin in Germany.',
      'ar': 'أنا أعيش في برلين في ألمانيا.',
      'tip_en': 'Preposition "in" indicates static location with Dative city/country.',
      'tip_de': 'Präposition "in" für feste Ortsangaben.',
      'tip_ar': 'حرف الجر in يستخدم للموقع الثابت مع المدن والدول.',
      'q_en': 'Which preposition is used for "living in a city"?',
      'q_de': 'Welche Präposition steht vor Städten?',
      'q_ar': 'أي حرف جر يسبق اسم المدينة عند السكن؟',
      'opt_en': 'in|aus|nach|zu',
      'opt_de': 'in|aus|nach|zu',
      'opt_ar': 'in|aus|nach|zu',
      'ans': '0',
    },
    {
      'de': 'Sprechen Sie vielleicht Englisch oder Deutsch?',
      'ipa': '[ˈʃpʁɛçn̩ ziː fiːˈlaɪ̯çt ˈɛŋlɪʃ ˈoːdɐ dɔɪ̯tʃ]',
      'ph': 'SHPREKH-en zee fee-LYKHT ENG-leesh OH-der DOYTCH?',
      'en': 'Do you perhaps speak English or German?',
      'ar': 'هل تتحدث حضرتك ربما الإنجليزية أو الألمانية؟',
      'tip_en': 'In German questions, the verb precedes the subject.',
      'tip_de': 'In Ja/Nein-Fragen steht das Verb an Position 1.',
      'tip_ar': 'في الأسئلة المباشرة، يأتي الفعل في الموقع الأول في الجملة.',
      'q_en': 'Where is the verb positioned in German yes/no questions?',
      'q_de': 'Wo steht das Verb in einer Entscheidungsfrage?',
      'q_ar': 'أين يقع الفعل في السؤال الاستفهامي بنعم أو لا؟',
      'opt_en': 'Position 1 (At the beginning)|At the end|Position 3|Position 4',
      'opt_de': 'Position 1 (Ganz am Anfang)|Am Ende|Position 3|Position 4',
      'opt_ar': 'الموقع الأول (في بداية الجملة)|في النهاية|الموقع الثالث|الموقع الرابع',
      'ans': '0',
    },
    {
      'de': 'Entschuldigung, wie viel kostet die Fahrkarte?',
      'ipa': '[ɛntˈʃʊldɪɡʊŋ viː fiːl ˈkɔstət diː ˈfaːɐ̯ˌkaʁtə]',
      'ph': 'Ent-SHOOL-dee-goong, vee feel KOS-tet dee FAHR-kar-tuh?',
      'en': 'Excuse me, how much is the ticket?',
      'ar': 'عفواً، كم تكلف تذكرة السفر؟',
      'tip_en': 'Die Fahrkarte is feminine nominative subject.',
      'tip_de': '"Die Fahrkarte" ist ein feminines Nomen im Nominativ.',
      'tip_ar': 'تذكرة السفر مؤنثة تأخذ أداة التعريف die.',
      'q_en': 'What gender is "Fahrkarte"?',
      'q_de': 'Welches Genus hat "Fahrkarte"?',
      'q_ar': 'ما هو جنس كلمة Fahrkarte النحوي؟',
      'opt_en': 'Feminine (die)|Masculine (der)|Neuter (das)|Plural only',
      'opt_de': 'Feminin (die)|Maskulin (der)|Neutral (das)|Nur Plural',
      'opt_ar': 'مؤنث (die)|مذكر (der)|محايد (das)|جمع فقط',
      'ans': '0',
    },
    {
      'de': 'Der Zug fährt pünktlich um zehn Uhr ab.',
      'ipa': '[deːɐ̯ tsuːk fɛːɐ̯t ˈpʏŋktlɪç ʊm tseːn uːɐ̯ ˈap]',
      'ph': 'Dair TSOOK fairt POONKT-likh oom tsayn oor AHP.',
      'en': 'The train departs punctually at ten o\'clock.',
      'ar': 'القطار يغادر في الموعد المحدد عند الساعة العاشرة.',
      'tip_en': 'Separable verb "abfahren": the prefix "ab" moves to sentence end.',
      'tip_de': 'Trennbares Verb "abfahren": Präfix am Satzende.',
      'tip_ar': 'فعل منفصل abfahren: البادئة ab تذهب إلى نهاية الجملة تماماً.',
      'q_en': 'Where does the separable prefix "ab" go in present tense?',
      'q_de': 'Wo steht das Präfix bei trennbaren Verben?',
      'q_ar': 'أين توضع السابقة المنفصلة ab في زمن الحاضر؟',
      'opt_en': 'At the very end of the clause|Next to the subject|In front of the verb|Anywhere',
      'opt_de': 'Ganz am Satzende|Direkt beim Subjekt|Vor dem Verb|Beliebig',
      'opt_ar': 'في نهاية الجملة تماماً|بجانب الفاعل|قبل الفعل مباشرة|في أي مكان',
      'ans': '0',
    },
    {
      'de': 'Können Sie mir bitte den Weg zum Rathaus erklären?',
      'ipa': '[ˈkœnən ziː miːɐ̯ ˈbɪtə deːn veːk tsuːm ˈʁaːtˌhaʊ̯s ɛɐ̯ˈklɛːʁən]',
      'ph': 'KUR-nen zee meer BIT-tuh dayn vayk tsoom RAHT-hows air-KLAIR-en?',
      'en': 'Could you please explain the way to city hall to me?',
      'ar': 'هل يمكنك من فضلك أن تشرح لي الطريق إلى دار البلدية؟',
      'tip_en': 'Den Weg is masculine accusative object; zum Rathaus is Dative contraction (zu + dem).',
      'tip_de': 'Akkusativ "den Weg" und Kontraktion "zu dem = zum".',
      'tip_ar': 'den Weg منصوب للمذكر، و zum هو دمج لحرف الجر zu مع dem.',
      'q_en': 'What does "zum" contract from?',
      'q_de': 'Woraus besteht die Verschmelzung "zum"?',
      'q_ar': 'مما يتكون الاختصار zum؟',
      'opt_en': 'zu + dem|zu + der|zu + das|zu + den',
      'opt_de': 'zu + dem|zu + der|zu + das|zu + den',
      'opt_ar': 'zu + dem|zu + der|zu + das|zu + den',
      'ans': '0',
    },
    {
      'de': 'Ich freue mich darauf, neues Wissen zu erwerben.',
      'ipa': '[ɪç ˈfʁɔɪ̯ə mɪç daˈʁaʊ̯f ˈnɔɪ̯əs ˈvɪsn̩ tsuː ɛɐ̯ˈvɛʁbn̩]',
      'ph': 'Ikh FROY-uh mikh dah-ROWF, NOY-es VIS-sen tsoo air-VAIR-ben.',
      'en': 'I look forward to acquiring new knowledge.',
      'ar': 'إنني أتطلع بشغف لاكتساب معارف جديدة.',
      'tip_en': 'Reflexive verb "sich freuen auf" + prepositional adverb "darauf" + infinitive with "zu".',
      'tip_de': 'Reflexives Verb mit Präpositionaladverb "darauf".',
      'tip_ar': 'فعل انعكاسي sich freuen auf مقترن بالظرف darauf مع جملة مصدرية بـ zu.',
      'q_en': 'What preposition does "sich freuen" take for future anticipation?',
      'q_de': 'Welche Präposition steht bei Vorfreude auf die Zukunft?',
      'q_ar': 'أي حرف جر يأتي مع sich freuen للتعبير عن التطلع المستقبلي؟',
      'opt_en': 'auf|über|für|mit',
      'opt_de': 'auf|über|für|mit',
      'opt_ar': 'auf|über|für|mit',
      'ans': '0',
    },
    {
      'de': 'Obwohl es regnet, mache ich einen produktiven Spaziergang.',
      'ipa': '[ɔpˈvoːl ɛs ˈʁeːɡnət ˈmaxə ɪç ˈaɪ̯nən pʁodʊkˈtiːvn̩ ʃpaˈtsiːɐ̯ˌɡaŋ]',
      'ph': 'Op-VOHL es REG-net, MAKH-uh ikh EYE-nen pro-dook-TEE-ven shpah-TSEER-gahng.',
      'en': 'Although it is raining, I am taking a productive walk.',
      'ar': 'على الرغم من أنها تمطر، فإنني أقوم بجولة مشي مثمرة.',
      'tip_en': 'Concessive subordinate clause with "obwohl" pushes the verb to the end.',
      'tip_de': 'Konzessiver Nebensatz mit "obwohl" und Verb-Endstellung.',
      'tip_ar': 'الجملة التناقضية مع obwohl ترسل الفعل إلى نهاية الشطر الأول، ثم يبدأ الشطر الثاني بالفعل مباشرة.',
      'q_en': 'What does "obwohl" introduce?',
      'q_de': 'Was leitet die Konjunktion "obwohl" ein?',
      'q_ar': 'ماذا تقدم أداة الربط obwohl؟',
      'opt_en': 'A concessive subordinate clause (contrast / although)|A question|A direct order|A time condition',
      'opt_de': 'Einen konzessiven Nebensatz (Gegensatz)|Eine Frage|Einen Befehl|Eine Zeitangabe',
      'opt_ar': 'جملة تناقضية (على الرغم من)|سؤالاً|أمراً مباشراً|ظرف زمان',
      'ans': '0',
    },
  ];

  static CurriculumLevel getLevel(int levelNumber) {
    final summaries = getAllLevelSummaries();
    final summary = summaries[(levelNumber - 1).clamp(0, summaries.length - 1)];

    final exercises = <CurriculumExercise>[];

    // Build exactly 10 exercises per level!
    for (int i = 0; i < 10; i++) {
      // Deterministic pseudo-random seed based on level number and exercise index
      final seedIndex = ((levelNumber * 7) + (i * 3)) % _phraseSeeds.length;
      final seed = _phraseSeeds[seedIndex];

      final optsEn = seed['opt_en']!.split('|');
      final optsDe = seed['opt_de']!.split('|');
      final optsAr = seed['opt_ar']!.split('|');

      exercises.add(
        CurriculumExercise(
          index: i + 1,
          germanPhrase: seed['de']!,
          phoneticIpa: seed['ipa']!,
          phoneticBreakdown: seed['ph']!,
          translationEn: seed['en']!,
          translationDe: seed['de']!,
          translationAr: seed['ar']!,
          grammarTipEn: seed['tip_en']!,
          grammarTipDe: seed['tip_de']!,
          grammarTipAr: seed['tip_ar']!,
          questionEn: seed['q_en']!,
          questionDe: seed['q_de']!,
          questionAr: seed['q_ar']!,
          optionsEn: optsEn,
          optionsDe: optsDe,
          optionsAr: optsAr,
          correctOptionIndex: int.parse(seed['ans']!),
        ),
      );
    }

    return CurriculumLevel(
      levelNumber: summary.levelNumber,
      tier: summary.tier,
      titleEn: summary.titleEn,
      titleDe: summary.titleDe,
      titleAr: summary.titleAr,
      descriptionEn: 'Master German ${summary.tier} skills: ${summary.grammarFocus}.',
      descriptionDe: 'Meistere deutsche ${summary.tier}-Fähigkeiten: ${summary.grammarFocus}.',
      descriptionAr: 'أتقن مهارات المستوى ${summary.tier}: ${summary.grammarFocus}.',
      grammarFocus: summary.grammarFocus,
      exercises: exercises,
    );
  }
}
