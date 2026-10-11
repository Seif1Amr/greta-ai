import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/locale_provider.dart';
import '../core/utils/microphone_permission_guard.dart';
import '../core/utils/text_similarity.dart';
import '../data/active_recall_catalog.dart';
import '../models/active_recall_phrase.dart';
import '../services/ad_mob_service.dart';
import '../services/german_speech_service.dart';
import '../services/german_tts_service.dart';
import '../services/hearts_wallet_service.dart';
import 'animated_greta_avatar.dart';
import 'phonetic_guide_pill.dart';

enum AdBridgeStage {
  preAdBriefing,
  adPlaying,
  oralVerification,
  challengePassed,
  challengeFailed,
}

class ActiveRecallBridgeModal extends StatefulWidget {
  final ActiveRecallPhrase? specificPhrase;

  const ActiveRecallBridgeModal({
    super.key,
    this.specificPhrase,
  });

  static Future<bool?> show(
    BuildContext context, {
    ActiveRecallPhrase? specificPhrase,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActiveRecallBridgeModal(
        specificPhrase: specificPhrase,
      ),
    );
  }

  @override
  State<ActiveRecallBridgeModal> createState() => _ActiveRecallBridgeModalState();
}

class _ActiveRecallBridgeModalState extends State<ActiveRecallBridgeModal> {
  late ActiveRecallPhrase _phrase;
  AdBridgeStage _stage = AdBridgeStage.preAdBriefing;
  String _spokenText = '';
  double _similarityScore = 0.0;
  bool _isPlayingSampleAudio = false;

  GermanTtsService? _ttsService;
  GermanSpeechService? _speechService;

  @override
  void initState() {
    super.initState();
    _phrase = widget.specificPhrase ?? ActiveRecallCatalog.getRandomPhrase();
  }

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

  Future<void> _playSampleAudio() async {
    final tts = context.read<GermanTtsService>();
    final speech = context.read<GermanSpeechService>();

    setState(() => _isPlayingSampleAudio = true);

    await tts.speak(
      text: _phrase.germanText,
      onHaltMicrophone: () async {
        await speech.cancelListening();
      },
      onComplete: () {
        if (mounted) {
          setState(() => _isPlayingSampleAudio = false);
        }
      },
    );
  }

  void _startAdFlow() {
    final tts = context.read<GermanTtsService>();
    tts.stop();

    setState(() => _stage = AdBridgeStage.adPlaying);

    final adMob = context.read<AdMobService>();

    // Pre-warm speech service in background while sponsor clip starts
    context.read<GermanSpeechService>().initialize();

    adMob.showRewardedAd(
      onRewardEarned: () {
        if (mounted) {
          // Unconditionally grant hearts on rewarded ad completion
          context.read<HeartsWalletService>().grantAdRewardHearts();
          _beginOralVerification();
        }
      },
      onDismissed: () {
        if (mounted && _stage == AdBridgeStage.adPlaying) {
          _beginOralVerification();
        }
      },
      onAdNotReady: () {
        // Graceful offline fallback: grant hearts and proceed to oral check
        if (mounted) {
          context.read<HeartsWalletService>().grantAdRewardHearts();
          _beginOralVerification();
        }
      },
    );
  }

  Future<void> _beginOralVerification() async {
    final hasPermission =
        await MicrophonePermissionGuard.ensurePermission(context);
    if (!hasPermission || !mounted) {
      return;
    }

    setState(() {
      _stage = AdBridgeStage.oralVerification;
      _spokenText = '';
      _similarityScore = 0.0;
    });

    final speech = context.read<GermanSpeechService>();
    final tts = context.read<GermanTtsService>();

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
            _evaluateSpokenPronunciation(text);
          }
        }
      },
    );
  }

  Future<void> _evaluateSpokenPronunciation(String spoken) async {
    final speech = context.read<GermanSpeechService>();
    await speech.stopListening();

    final score = TextSimilarity.calculateSimilarity(
      _phrase.germanText,
      spoken,
    );

    setState(() {
      _spokenText = spoken;
      _similarityScore = score;
    });

    if (score >= AppConstants.activeRecallPassingSimilarity) {
      setState(() => _stage = AdBridgeStage.challengePassed);

      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 120);
        }
      } catch (_) {}
    } else {
      setState(() => _stage = AdBridgeStage.challengeFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();

    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(
          color: AppColors.borderHighlight,
          width: 1.2,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Directionality(
        textDirection: loc.textDirection,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(loc),
                const SizedBox(height: 16),
                if (_stage == AdBridgeStage.preAdBriefing)
                  _buildPreAdBriefing(loc),
                if (_stage == AdBridgeStage.adPlaying) _buildAdPlayingState(loc),
                if (_stage == AdBridgeStage.oralVerification)
                  _buildOralVerification(loc),
                if (_stage == AdBridgeStage.challengePassed)
                  _buildChallengePassed(loc),
                if (_stage == AdBridgeStage.challengeFailed)
                  _buildChallengeFailed(loc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LocaleProvider loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cyanGlow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: AppColors.cyanGlow,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.tr('ad_bridge_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHighEmphasis,
                  ),
                ),
                Text(
                  loc.tr('ad_bridge_reward'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cyanGlow,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (_stage != AdBridgeStage.adPlaying)
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textMediumEmphasis),
            onPressed: () {
              final speech = context.read<GermanSpeechService>();
              final tts = context.read<GermanTtsService>();
              tts.stop();
              speech.cancelListening();
              Navigator.of(context).pop(_stage == AdBridgeStage.challengePassed);
            },
          ),
      ],
    );
  }

  Widget _buildPreAdBriefing(LocaleProvider loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Target German Phrase Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cyanGlow.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.tr('phrase_to_memorize'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.cyanSoft,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _phrase.germanText,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHighEmphasis,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _phrase.getTranslation(loc.languageCode),
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMediumEmphasis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Phonetic Guide Pill
        PhoneticGuidePill(
          germanPhrase: _phrase.germanText,
          phoneticIpa: _phrase.phoneticIpa,
          phoneticBreakdown: _phrase.phoneticGuide,
        ),
        const SizedBox(height: 12),

        // Audio preview button
        OutlinedButton.icon(
          onPressed: _isPlayingSampleAudio ? null : _playSampleAudio,
          icon: Icon(
            _isPlayingSampleAudio
                ? Icons.volume_up_rounded
                : Icons.play_arrow_rounded,
            size: 18,
            color: AppColors.cyanGlow,
          ),
          label: Text(
            _isPlayingSampleAudio
                ? loc.tr('playing_sample')
                : loc.tr('listen_sample'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.cyanGlow,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.cyanGlow),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),

        // Disclaimer Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blueElectric.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.blueElectric.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.cyanSoft,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.tr('ad_disclaimer'),
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: AppColors.textMediumEmphasis,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: _startAdFlow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyanGlow,
            foregroundColor: AppColors.backgroundBase,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            loc.tr('launch_challenge_btn'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdPlayingState(LocaleProvider loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyanGlow),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            loc.tr('ad_loading'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textHighEmphasis,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Audio-Engine für deutsche Aussprache wird vorbereitet...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMediumEmphasis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOralVerification(LocaleProvider loc) {
    final speech = context.watch<GermanSpeechService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.cyanGlow,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.tr('speak_now_title'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyanGlow,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _phrase.germanText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHighEmphasis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Live Captured Speech Container
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundBase,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderHighlight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.tr('captured_speech'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMediumEmphasis,
                    ),
                  ),
                  if (speech.isListening)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.cyanGlow,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          loc.tr('listening_active'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.cyanGlow,
                            fontWeight: FontWeight.w600,
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
                        ? loc.tr('speak_now_prompt')
                        : loc.tr('no_speech_yet'))
                    : _spokenText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _spokenText.isEmpty
                      ? AppColors.textLowEmphasis
                      : AppColors.textHighEmphasis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: _spokenText.trim().isEmpty
              ? null
              : () => _evaluateSpokenPronunciation(_spokenText),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyanGlow,
            foregroundColor: AppColors.backgroundBase,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            loc.tr('validate_pronunciation'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengePassed(LocaleProvider loc) {
    final percent = (_similarityScore * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AnimatedGretaAvatar(
          state: GretaAvatarState.celebrating,
          size: 90,
        ),
        const SizedBox(height: 14),
        Text(
          loc.tr('excellent_job'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textHighEmphasis,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${loc.tr('accuracy')} $percent%',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.successGlow,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.tr('hearts_added'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMediumEmphasis,
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyanGlow,
            foregroundColor: AppColors.backgroundBase,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            loc.tr('back_to_speaking'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeFailed(LocaleProvider loc) {
    final percent = (_similarityScore * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.replay_rounded,
          size: 48,
          color: AppColors.warning,
        ),
        const SizedBox(height: 12),
        Text(
          loc.tr('try_again_title'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textHighEmphasis,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          loc.tr('score_achieved', {'score': '$percent'}),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMediumEmphasis,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _phrase.germanText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.cyanSoft,
            ),
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: _beginOralVerification,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyanGlow,
            foregroundColor: AppColors.backgroundBase,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            loc.tr('retry_speaking'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
