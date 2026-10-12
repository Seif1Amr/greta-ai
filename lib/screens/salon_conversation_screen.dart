import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/locale_provider.dart';
import '../core/utils/microphone_permission_guard.dart';
import '../models/conversation_turn.dart';
import '../services/gemini_german_service.dart';
import '../services/german_speech_service.dart';
import '../services/german_tts_service.dart';
import '../services/hearts_wallet_service.dart';
import '../widgets/animated_greta_avatar.dart';
import '../widgets/credit_badge.dart';
import '../widgets/glowing_voice_orb.dart';
import '../widgets/refill_hearts_modal.dart';

class SalonConversationScreen extends StatefulWidget {
  const SalonConversationScreen({super.key});

  @override
  State<SalonConversationScreen> createState() =>
      _SalonConversationScreenState();
}

class _SalonConversationScreenState extends State<SalonConversationScreen> {
  final List<ConversationTurn> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final GeminiGermanService _geminiService = GeminiGermanService();

  bool _isAiThinking = false;
  bool _isSubmittingTurn = false;
  String? _lastSubmittedText;
  DateTime? _lastSubmitTime;
  GretaAvatarState _avatarState = GretaAvatarState.neutral;

  GermanTtsService? _ttsService;
  GermanSpeechService? _speechService;

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      ConversationTurn(
        id: 'welcome_0',
        germanText:
            'Hallo! Ich bin Greta, deine Deutschlehrerin. Worüber möchtest du heute sprechen?',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(seconds: 40)),
      ),
      ConversationTurn(
        id: 'sample_user_1',
        germanText:
            'Ich möchte mein Vorstellungsgespräch für einen Job in Berlin üben!',
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(seconds: 25)),
      ),
      ConversationTurn(
        id: 'sample_ai_1',
        germanText:
            'Ausgezeichnet! Lass uns anfangen. Erzähl mir zuerst: Was sind deine größten beruflichen Stärken?',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
        correction:
            'Tipp: "Ich bewerbe mich um eine Stelle als..." klingt besonders professionell.',
      ),
    ]);
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
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleOrbTap() async {
    final speech = context.read<GermanSpeechService>();
    final tts = context.read<GermanTtsService>();
    final wallet = context.read<HeartsWalletService>();

    // If currently speaking TTS, stop it
    if (tts.isSpeaking) {
      await tts.stop();
      setState(() => _avatarState = GretaAvatarState.neutral);
      return;
    }

    // Ignore tap if AI is actively processing or thinking
    if (_isAiThinking || _isSubmittingTurn) {
      return;
    }

    // If already listening, stop capture, cancel listening to avoid duplicate callbacks, and submit
    if (speech.isListening) {
      final captured = speech.currentWords.trim();
      await speech.cancelListening();
      if (captured.isNotEmpty) {
        _submitUserTurn(captured);
      } else {
        setState(() => _avatarState = GretaAvatarState.neutral);
      }
      return;
    }

    // Check hearts balance first!
    if (!wallet.hasHearts) {
      RefillHeartsModal.show(context);
      return;
    }

    // Check microphone permission
    final hasPermission =
        await MicrophonePermissionGuard.ensurePermission(context);
    if (!hasPermission || !mounted) return;

    setState(() => _avatarState = GretaAvatarState.neutral);

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
        if (mounted && isFinal && text.trim().isNotEmpty) {
          _submitUserTurn(text.trim());
        }
      },
    );
  }

  Future<void> _submitUserTurn(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    // Concurrency guard: ignore if already submitting or thinking
    if (_isSubmittingTurn || _isAiThinking) {
      debugPrint('[SalonConversation] Ignored duplicate turn submission: "$cleanText"');
      return;
    }

    // Rapid duplicate debounce: ignore identical submissions within 2.5s
    final now = DateTime.now();
    if (_lastSubmittedText == cleanText &&
        _lastSubmitTime != null &&
        now.difference(_lastSubmitTime!).inMilliseconds < 2500) {
      debugPrint('[SalonConversation] Ignored rapid duplicate phrase submission: "$cleanText"');
      return;
    }

    _isSubmittingTurn = true;
    _lastSubmittedText = cleanText;
    _lastSubmitTime = now;

    final speech = context.read<GermanSpeechService>();
    final wallet = context.read<HeartsWalletService>();
    final tts = context.read<GermanTtsService>();

    // Immediately cancel listening to flush & kill any pending recognizer callbacks
    try {
      await speech.cancelListening();
    } catch (_) {}

    if (!mounted) {
      _isSubmittingTurn = false;
      return;
    }

    try {
      // Deduct 1 Heart for speaking turn
      final deducted = wallet.deductSpeakingTurnHeart();
      if (!deducted) {
        RefillHeartsModal.show(context);
        return;
      }

      setState(() {
        _messages.add(
          ConversationTurn(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            germanText: cleanText,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
        _isAiThinking = true;
        _avatarState = GretaAvatarState.thinking;
      });
      _scrollToBottom();

      // Direct Gemini 2.0 Flash execution with fallbacks
      final response = await _geminiService.generateGermanReply(
        history: _messages,
        userSpokenText: cleanText,
        cefrLevel: wallet.cefrLevel,
        learningGoal: wallet.learningGoal,
      );

      if (!mounted) return;

      setState(() {
        _isAiThinking = false;
        _messages.add(
          ConversationTurn(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            germanText: response.speechText,
            isUser: false,
            timestamp: DateTime.now(),
            correction: response.correction,
            isFallback: response.isFallback,
          ),
        );
        _avatarState = GretaAvatarState.speaking;
      });
      _scrollToBottom();

      // Speak AI response in calibrated female German voice
      await tts.speak(
        text: response.speechText,
        onHaltMicrophone: () async {
          await speech.cancelListening();
        },
        onComplete: () {
          if (mounted) {
            setState(() {
              _avatarState = response.correction != null
                  ? GretaAvatarState.neutral
                  : GretaAvatarState.celebrating;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('[SalonConversation] Error during turn submission: $e');
      if (mounted) {
        setState(() {
          _isAiThinking = false;
          _avatarState = GretaAvatarState.neutral;
        });
      }
    } finally {
      _isSubmittingTurn = false;
    }
  }

  Future<void> _speakTurnText(String text) async {
    final tts = context.read<GermanTtsService>();
    final speech = context.read<GermanSpeechService>();

    setState(() => _avatarState = GretaAvatarState.speaking);

    await tts.speak(
      text: text,
      onHaltMicrophone: () async {
        await speech.cancelListening();
      },
      onComplete: () {
        if (mounted) {
          setState(() => _avatarState = GretaAvatarState.neutral);
        }
      },
    );
  }

  String get _avatarAssetPath {
    switch (_avatarState) {
      case GretaAvatarState.speaking:
        return 'assets/images/avatar_greta_speaking.jpg';
      case GretaAvatarState.thinking:
        return 'assets/images/avatar_greta_thinking.jpg';
      case GretaAvatarState.celebrating:
        return 'assets/images/avatar_greta_celebrating.jpg';
      case GretaAvatarState.neutral:
        return 'assets/images/avatar_greta_neutral.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final speech = context.watch<GermanSpeechService>();
    final tts = context.watch<GermanTtsService>();

    final isListening = speech.isListening;
    final isSpeaking = tts.isSpeaking;

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        body: Column(
          children: [
            // 1. Immersive Edge-to-Edge Greta Hero Stage (Unboxed, bigger, overlaid title and hearts)
            _buildImmersiveGretaStage(loc, isListening, isSpeaking),

            // 2. Conversation Messages List (Maximized middle space, responsive tablet width)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(msg, loc);
                    },
                  ),
                ),
              ),
            ),

            // 3. Ultra-Compact Bottom Voice Interaction Stage (Minimal height)
            _buildCompactVoiceOrbStage(loc, speech, isListening, isSpeaking),
          ],
        ),
      ),
    );
  }

  Widget _buildImmersiveGretaStage(
      LocaleProvider loc, bool isListening, bool isSpeaking) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final stageHeight = isTablet ? 340.0 : 260.0;

    return SizedBox(
      width: double.infinity,
      height: stageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Greta Portrait - Extended edge-to-edge on mobile, elegantly centered on tablet
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 640 : double.infinity,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  _avatarAssetPath,
                  key: ValueKey<String>(_avatarAssetPath),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.15),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surfaceElevated,
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 80,
                          color: AppColors.cyanGlow,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Lateral soft gradient vignettes for wide/tablet displays
          if (isTablet) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.backgroundBase,
                      AppColors.backgroundBase.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      AppColors.backgroundBase,
                      AppColors.backgroundBase.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Top subtle gradient scrim for status/controls legibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 95,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.72),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom smooth gradient fade blending Greta's body into the black background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: isTablet ? 130 : 110,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.backgroundBase.withValues(alpha: 0.5),
                    AppColors.backgroundBase.withValues(alpha: 0.9),
                    AppColors.backgroundBase,
                  ],
                  stops: const [0.0, 0.45, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // Floating Top Controls (Inside SafeArea, in top corners so face is 100% CLEAR, centered on tablet)
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top-Left: "Greta Voice Salon" Title & clean online dot (No Gemini badge!)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            loc.tr('salon_title'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.successGlow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.cyanSoft,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 6),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Top-Right: Hearts CreditBadge & Reset button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CreditBadge(),
                          const SizedBox(width: 6),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundBase
                                  .withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.borderHighlight
                                    .withValues(alpha: 0.6),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                size: 19,
                                color: AppColors.textMediumEmphasis,
                              ),
                              onPressed: () {
                                setState(() {
                                  _messages.clear();
                                  _messages.add(
                                    ConversationTurn(
                                      id: 'welcome_reset',
                                      germanText:
                                          'Hallo! Wie kann ich dir heute beim Deutschlernen helfen?',
                                      isUser: false,
                                      timestamp: DateTime.now(),
                                    ),
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Dynamic State Indicator (Clean, positioned at bottom over the fade)
          Positioned(
            left: 16,
            right: 16,
            bottom: 8,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _buildStageBottomSubtitle(loc, isListening, isSpeaking),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageBottomSubtitle(
      LocaleProvider loc, bool isListening, bool isSpeaking) {
    if (_isAiThinking) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundBase.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFA855F7).withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 13, color: Color(0xFFA855F7)),
              const SizedBox(width: 6),
              Text(
                loc.tr('greta_thinking'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC084FC),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isSpeaking) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundBase.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cyanGlow.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_up_rounded,
                  size: 14, color: AppColors.cyanGlow),
              const SizedBox(width: 6),
              Text(
                loc.tr('greta_speaking'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyanGlow,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isListening) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundBase.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cyanSoft.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.graphic_eq_rounded,
                  size: 14, color: AppColors.cyanSoft),
              const SizedBox(width: 6),
              Text(
                loc.tr('ready_to_listen'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyanSoft,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default neutral state: clean subtle tap to greet on right
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          _speakTurnText(
              'Hallo! Ich bin Greta, deine Deutschlehrerin. Lass uns sprechen!');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.backgroundBase.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.cyanGlow.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up_rounded,
                  size: 13, color: AppColors.cyanGlow),
              SizedBox(width: 4),
              Text(
                'Hallo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyanGlow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactVoiceOrbStage(
      LocaleProvider loc,
      GermanSpeechService speech,
      bool isListening,
      bool isSpeaking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: AppColors.borderHighlight, width: 0.8),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isListening && speech.currentWords.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.cyanGlow.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    speech.currentWords,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cyanSoft,
                    ),
                  ),
                ),
              ],
              GlowingVoiceOrb(
                isListening: isListening,
                isSpeaking: isSpeaking,
                isThinking: _isAiThinking,
                soundLevel: speech.soundLevel,
                size: 48,
                onTap: _handleOrbTap,
              ),
              const SizedBox(height: 3),
              Text(
                isListening
                    ? loc.tr('tap_orb_stop')
                    : (_isAiThinking
                        ? loc.tr('greta_thinking')
                        : loc.tr('tap_orb_speak')),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMediumEmphasis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ConversationTurn msg, LocaleProvider loc) {
    final isUser = msg.isUser;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/avatar_greta_neutral.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.blueElectric.withValues(alpha: 0.25)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.cyanGlow.withValues(alpha: 0.4)
                      : AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            msg.germanText,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textHighEmphasis,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _speakTurnText(msg.germanText),
                          child: const Icon(
                            Icons.volume_down_rounded,
                            size: 18,
                            color: AppColors.cyanGlow,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (msg.correction != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded,
                              size: 15, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              msg.correction!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(
                color: AppColors.cyanGlow.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  size: 18, color: AppColors.cyanGlow),
            ),
          ],
        ],
      ),
    );
  }
}
