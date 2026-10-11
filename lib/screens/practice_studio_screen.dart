import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/locale_provider.dart';
import '../core/utils/microphone_permission_guard.dart';
import '../core/utils/text_similarity.dart';
import '../data/active_recall_catalog.dart';
import '../models/active_recall_phrase.dart';
import '../services/german_speech_service.dart';
import '../services/german_tts_service.dart';
import '../services/hearts_wallet_service.dart';
import '../widgets/active_recall_bridge_modal.dart';
import '../widgets/credit_badge.dart';
import '../widgets/phonetic_guide_pill.dart';
import 'grammar_mastery/grammar_mastery_hub_screen.dart';

class PracticeStudioScreen extends StatefulWidget {
  const PracticeStudioScreen({super.key});

  @override
  State<PracticeStudioScreen> createState() => _PracticeStudioScreenState();
}

class _PracticeStudioScreenState extends State<PracticeStudioScreen> {
  int _activePhraseIndex = 0;
  String _spokenText = '';
  double _similarityScore = 0.0;
  bool _isPlayingAudio = false;

  final List<ActiveRecallPhrase> _phrases = ActiveRecallCatalog.pool;

  ActiveRecallPhrase get _currentPhrase => _phrases[_activePhraseIndex];

  Future<void> _playCurrentAudio() async {
    final tts = context.read<GermanTtsService>();
    final speech = context.read<GermanSpeechService>();

    setState(() => _isPlayingAudio = true);

    await tts.speak(
      text: _currentPhrase.germanText,
      onHaltMicrophone: () async {
        await speech.cancelListening();
      },
      onComplete: () {
        if (mounted) {
          setState(() => _isPlayingAudio = false);
        }
      },
    );
  }

  Future<void> _recordPracticeSpeech() async {
    final hasPermission =
        await MicrophonePermissionGuard.ensurePermission(context);
    if (!hasPermission || !mounted) return;

    final speech = context.read<GermanSpeechService>();
    final tts = context.read<GermanTtsService>();

    setState(() {
      _spokenText = '';
      _similarityScore = 0.0;
    });

    await speech.startListening(
      onHaltTts: () async {
        await tts.stop();
      },
      onPermissionDenied: () {
        if (mounted) {
          MicrophonePermissionGuard.showPermissionDeniedModal(context);
        }
      },
      onResult: (text, isFinal) {
        if (mounted) {
          setState(() => _spokenText = text);
          if (isFinal && text.trim().isNotEmpty) {
            _evaluatePractice(text);
          }
        }
      },
    );
  }

  Future<void> _evaluatePractice(String text) async {
    final speech = context.read<GermanSpeechService>();
    await speech.stopListening();

    final score = TextSimilarity.calculateSimilarity(
      _currentPhrase.germanText,
      text,
    );

    setState(() {
      _spokenText = text;
      _similarityScore = score;
    });
  }

  void _nextPhrase() {
    setState(() {
      _activePhraseIndex = (_activePhraseIndex + 1) % _phrases.length;
      _spokenText = '';
      _similarityScore = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final wallet = context.watch<HeartsWalletService>();
    final speech = context.watch<GermanSpeechService>();

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        appBar: AppBar(
          title: Text(
            loc.tr('nav_practice'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textHighEmphasis,
            ),
          ),
          actions: const [
            CreditBadge(),
            SizedBox(width: 14),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick Stats Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderHighlight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        Icons.local_fire_department_rounded,
                        '${wallet.streakDays}',
                        loc.tr('daily_streak'),
                        AppColors.warning,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: AppColors.borderSubtle,
                      ),
                      _buildStatItem(
                        Icons.mic_rounded,
                        '${wallet.totalSpeakingTurns}',
                        loc.tr('total_turns'),
                        AppColors.cyanGlow,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: AppColors.borderSubtle,
                      ),
                      _buildStatItem(
                        Icons.favorite_rounded,
                        '${wallet.hearts}',
                        loc.tr('hearts'),
                        AppColors.heartRed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Active Recall Challenge Quick Trigger Banner
                GestureDetector(
                  onTap: () => ActiveRecallBridgeModal.show(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyanGlow.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.tr('ad_bridge_title'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                loc.tr('get_free_hearts'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // German Grammar Mastery Studios Banner
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GrammarMasteryHubScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.cyanGlow.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyanGlow.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00D2FF), Color(0xFF6366F1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      loc.languageCode == 'ar'
                                          ? 'استوديوهات القواعد المتقدمة'
                                          : (loc.languageCode == 'de'
                                              ? 'Grammatik-Meisterstudios'
                                              : 'Grammar Mastery Studios'),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textHighEmphasis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.cyanGlow
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '4 STUDIOS',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.cyanGlow,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  loc.languageCode == 'ar'
                                      ? 'der/die/das • 4 حالات • أفعال منفصلة • Satzbau'
                                      : 'der/die/das • 4 Fälle • Verben • Kausalsätze',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMediumEmphasis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.cyanGlow,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Pronunciation Practice Studio Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Aussprache-Studio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHighEmphasis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _nextPhrase,
                      icon: const Icon(Icons.shuffle_rounded,
                          size: 16, color: AppColors.cyanGlow),
                      label: const Text(
                        'Nächster Satz',
                        style: TextStyle(
                          color: AppColors.cyanGlow,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Practice Phrase Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderHighlight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _currentPhrase.germanText,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textHighEmphasis,
                                height: 1.3,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed:
                                _isPlayingAudio ? null : _playCurrentAudio,
                            icon: Icon(
                              _isPlayingAudio
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_down_rounded,
                              color: AppColors.cyanGlow,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _currentPhrase.getTranslation(loc.languageCode),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMediumEmphasis,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PhoneticGuidePill(
                        germanPhrase: _currentPhrase.germanText,
                        phoneticIpa: _currentPhrase.phoneticIpa,
                        phoneticBreakdown: _currentPhrase.phoneticGuide,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Speech Input & Feedback Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBase,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _spokenText.isEmpty
                            ? (speech.isListening
                                ? loc.tr('recording')
                                : 'Tippe auf das Mikrofon und sprich...')
                            : _spokenText,
                        style: TextStyle(
                          fontSize: 14,
                          color: _spokenText.isEmpty
                              ? AppColors.textLowEmphasis
                              : AppColors.textHighEmphasis,
                        ),
                      ),
                      if (_similarityScore > 0.0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${loc.tr('similarity_score')}: ${(_similarityScore * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _similarityScore >= 0.65
                                ? AppColors.successGlow
                                : AppColors.warning,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: speech.isListening
                            ? () => _evaluatePractice(_spokenText)
                            : _recordPracticeSpeech,
                        icon: Icon(
                          speech.isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                        ),
                        label: Text(
                          speech.isListening
                              ? 'Auswerten'
                              : loc.tr('tap_to_record'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: speech.isListening
                              ? AppColors.heartRed
                              : AppColors.cyanGlow,
                          foregroundColor: AppColors.backgroundBase,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textHighEmphasis,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMediumEmphasis,
          ),
        ),
      ],
    );
  }
}
