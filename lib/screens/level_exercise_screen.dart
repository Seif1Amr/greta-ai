import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/locale_provider.dart';
import '../core/utils/microphone_permission_guard.dart';
import '../core/utils/text_similarity.dart';
import '../models/curriculum_level.dart';
import '../services/german_speech_service.dart';
import '../services/german_tts_service.dart';
import '../services/hearts_wallet_service.dart';
import '../widgets/animated_greta_avatar.dart';
import '../widgets/credit_badge.dart';
import '../widgets/phonetic_guide_pill.dart';

class LevelExerciseScreen extends StatefulWidget {
  final CurriculumLevel level;

  const LevelExerciseScreen({
    super.key,
    required this.level,
  });

  @override
  State<LevelExerciseScreen> createState() => _LevelExerciseScreenState();
}

class _LevelExerciseScreenState extends State<LevelExerciseScreen> {
  int _currentExerciseIndex = 0;
  bool _isPlayingAudio = false;

  String _spokenText = '';
  double _similarityScore = 0.0;
  bool _hasPassedSpeech = false;

  int? _selectedOptionIndex;
  bool? _isAnswerCorrect;

  GermanTtsService? _ttsService;
  GermanSpeechService? _speechService;

  CurriculumExercise get _currentExercise =>
      widget.level.exercises[_currentExerciseIndex];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsService = context.read<GermanTtsService>();
    _speechService = context.read<GermanSpeechService>();
  }

  @override
  void dispose() {
    try {
      _ttsService?.stop();
      _speechService?.cancelListening();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _playPhraseAudio() async {
    final tts = context.read<GermanTtsService>();
    final speech = context.read<GermanSpeechService>();

    setState(() => _isPlayingAudio = true);

    await tts.speak(
      text: _currentExercise.germanPhrase,
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

  Future<void> _startRecordingSpeech() async {
    final hasPermission =
        await MicrophonePermissionGuard.ensurePermission(context);
    if (!hasPermission || !mounted) return;

    final speech = context.read<GermanSpeechService>();
    final tts = context.read<GermanTtsService>();

    setState(() {
      _spokenText = '';
      _similarityScore = 0.0;
      _hasPassedSpeech = false;
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
            _evaluateSpokenSpeech(text);
          }
        }
      },
    );
  }

  Future<void> _evaluateSpokenSpeech(String text) async {
    final speech = context.read<GermanSpeechService>();
    await speech.stopListening();

    final score = TextSimilarity.calculateSimilarity(
      _currentExercise.germanPhrase,
      text,
    );

    final passed = score >= AppConstants.activeRecallPassingSimilarity;

    setState(() {
      _spokenText = text;
      _similarityScore = score;
      _hasPassedSpeech = passed;
    });

    if (passed) {
      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 80);
        }
      } catch (_) {}
    }
  }

  void _onOptionSelected(int index) {
    if (_selectedOptionIndex != null) return; // Answer already chosen

    final isCorrect = index == _currentExercise.correctOptionIndex;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswerCorrect = isCorrect;
    });

    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _goToNextExercise() {
    if (_currentExerciseIndex < widget.level.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _spokenText = '';
        _similarityScore = 0.0;
        _hasPassedSpeech = false;
        _selectedOptionIndex = null;
        _isAnswerCorrect = null;
        _isPlayingAudio = false;
      });
    } else {
      _finishLevel();
    }
  }

  void _finishLevel() {
    final wallet = context.read<HeartsWalletService>();
    wallet.completeLevel(widget.level.levelNumber);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final loc = dialogCtx.read<LocaleProvider>();
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.borderHighlight, width: 1.5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const AnimatedGretaAvatar(
                state: GretaAvatarState.celebrating,
                size: 110,
              ),
              const SizedBox(height: 18),
              Text(
                loc.tr('level_finished'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHighEmphasis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lektion ${widget.level.levelNumber} (${widget.level.tier}) erfolgreich abgeschlossen!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMediumEmphasis,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyanGlow,
                  foregroundColor: AppColors.backgroundBase,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text(
                  'Zurück zur Übersicht',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final speech = context.watch<GermanSpeechService>();
    final exercise = _currentExercise;

    final progressPercent =
        (_currentExerciseIndex + 1) / widget.level.exercises.length;

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        appBar: AppBar(
          title: Text(
            '${widget.level.tier} • Lektion ${widget.level.levelNumber}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textHighEmphasis,
            ),
          ),
          actions: const [
            CreditBadge(),
            SizedBox(width: 14),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: AppColors.surfaceCard,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyanGlow),
              minHeight: 4,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Exercise Counter Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${loc.tr('exercise')} ${_currentExerciseIndex + 1} / 10',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cyanGlow,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      widget.level.grammarFocus,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMediumEmphasis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // German Target Phrase Box with Listen CTA
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderHighlight,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                exercise.germanPhrase,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textHighEmphasis,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed:
                                _isPlayingAudio ? null : _playPhraseAudio,
                            icon: Icon(
                              _isPlayingAudio
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_down_rounded,
                              color: AppColors.cyanGlow,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.getTranslation(loc.languageCode),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMediumEmphasis,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Phonetic Breakdown & IPA Guide
                PhoneticGuidePill(
                  germanPhrase: exercise.germanPhrase,
                  phoneticIpa: exercise.phoneticIpa,
                  phoneticBreakdown: exercise.phoneticBreakdown,
                ),
                const SizedBox(height: 14),

                // Speaking Practice Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBase,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _hasPassedSpeech
                          ? AppColors.successGlow
                          : AppColors.borderSubtle,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.tr('user_speech_practice'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyanSoft,
                            ),
                          ),
                          if (_hasPassedSpeech)
                            const Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 16, color: AppColors.successGlow),
                                SizedBox(width: 4),
                                Text(
                                  'Sehr gut!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.successGlow,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _spokenText.isEmpty
                            ? (speech.isListening
                                ? loc.tr('recording')
                                : 'Sprich den deutschen Satz laut nach...')
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
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _hasPassedSpeech
                                ? AppColors.successGlow
                                : AppColors.warning,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: speech.isListening
                            ? () => _evaluateSpokenSpeech(_spokenText)
                            : _startRecordingSpeech,
                        icon: Icon(
                          speech.isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          size: 20,
                        ),
                        label: Text(
                          speech.isListening
                              ? 'Prüfen'
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Multiple Choice Grammar & Context Reinforcement
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderHighlight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.quiz_rounded,
                              size: 16, color: AppColors.cyanGlow),
                          const SizedBox(width: 6),
                          Text(
                            loc.tr('grammar_check'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyanGlow,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        exercise.getQuestion(loc.languageCode),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHighEmphasis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        exercise.getOptions(loc.languageCode).length,
                        (optIdx) {
                          final optText =
                              exercise.getOptions(loc.languageCode)[optIdx];
                          final isSelected = _selectedOptionIndex == optIdx;
                          final isCorrectAnswer =
                              optIdx == exercise.correctOptionIndex;

                          Color itemBg = AppColors.surfaceBase;
                          Color itemBorder = AppColors.borderSubtle;

                          if (_selectedOptionIndex != null) {
                            if (isCorrectAnswer) {
                              itemBg = AppColors.success.withValues(alpha: 0.15);
                              itemBorder = AppColors.successGlow;
                            } else if (isSelected) {
                              itemBg = AppColors.error.withValues(alpha: 0.15);
                              itemBorder = AppColors.error;
                            }
                          }

                          return GestureDetector(
                            onTap: () => _onOptionSelected(optIdx),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: itemBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: itemBorder, width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      optText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: AppColors.textHighEmphasis,
                                      ),
                                    ),
                                  ),
                                  if (_selectedOptionIndex != null &&
                                      isCorrectAnswer)
                                    const Icon(Icons.check_circle_rounded,
                                        size: 18, color: AppColors.successGlow),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (_isAnswerCorrect != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _isAnswerCorrect == true
                              ? loc.tr('correct_answer')
                              : loc.tr('incorrect_answer'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isAnswerCorrect == true
                                ? AppColors.successGlow
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Next Exercise Action Button
                ElevatedButton(
                  onPressed: _goToNextExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyanGlow,
                    foregroundColor: AppColors.backgroundBase,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentExerciseIndex < widget.level.exercises.length - 1
                        ? loc.tr('next_exercise')
                        : loc.tr('complete_level'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
