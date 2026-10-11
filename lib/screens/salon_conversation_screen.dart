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
  GretaAvatarState _avatarState = GretaAvatarState.neutral;

  GermanTtsService? _ttsService;
  GermanSpeechService? _speechService;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ConversationTurn(
        id: 'welcome_0',
        germanText:
            'Hallo! Ich bin Greta, deine Deutschlehrerin. Worüber möchtest du heute sprechen?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
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

    // If already listening, stop and send
    if (speech.isListening) {
      await speech.stopListening();
      final captured = speech.currentWords.trim();
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
    final wallet = context.read<HeartsWalletService>();
    final tts = context.read<GermanTtsService>();

    // Deduct 1 Heart for speaking turn
    final deducted = wallet.deductSpeakingTurnHeart();
    if (!deducted) {
      if (mounted) RefillHeartsModal.show(context);
      return;
    }

    setState(() {
      _messages.add(
        ConversationTurn(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          germanText: text,
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
      userSpokenText: text,
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
        await context.read<GermanSpeechService>().cancelListening();
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
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.tr('salon_title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHighEmphasis,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.successGlow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Gemini 2.0 Flash • Online',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.cyanSoft,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            const CreditBadge(),
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.textMediumEmphasis),
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
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Greta Coach Stage with Reactive Avatar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    AnimatedGretaAvatar(
                      state: _avatarState,
                      size: 96,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isAiThinking
                          ? loc.tr('greta_thinking')
                          : (isSpeaking
                              ? loc.tr('greta_speaking')
                              : (isListening
                                  ? loc.tr('ready_to_listen')
                                  : 'Greta • Deutsche Sprachpartnerin')),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isAiThinking
                            ? const Color(0xFFA855F7)
                            : (isSpeaking
                                ? AppColors.cyanGlow
                                : AppColors.textMediumEmphasis),
                      ),
                    ),
                  ],
                ),
              ),

              // Conversation Messages List
              Expanded(
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

              // Bottom Voice Interaction Stage with GlowingVoiceOrb
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceBase,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    top: BorderSide(
                        color: AppColors.borderHighlight, width: 1.2),
                  ),
                ),
                child: Column(
                  children: [
                    if (isListening && speech.currentWords.isNotEmpty) ...[
                      Text(
                        speech.currentWords,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cyanSoft,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    GlowingVoiceOrb(
                      isListening: isListening,
                      isSpeaking: isSpeaking,
                      isThinking: _isAiThinking,
                      soundLevel: speech.soundLevel,
                      size: 72,
                      onTap: _handleOrbTap,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isListening
                          ? loc.tr('tap_orb_stop')
                          : (_isAiThinking
                              ? 'Greta antwortet...'
                              : loc.tr('tap_orb_speak')),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLowEmphasis,
                      ),
                    ),
                  ],
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
                        child: Text(
                          msg.germanText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textHighEmphasis,
                            height: 1.35,
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
