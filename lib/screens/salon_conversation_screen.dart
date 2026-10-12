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
  final TextEditingController _textController = TextEditingController();
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
    _textController.addListener(() => setState(() {}));
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
    _textController.dispose();
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

  void _submitTextTurn() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _submitUserTurn(text);
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
        appBar: _buildTopHeader(loc),
        body: Column(
          children: [
            // 1. Clean, Unobstructed Greta Avatar Portrait (Zero text overlays, zero cards)
            _buildCleanGretaPortrait(),

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

            // 3. Ultra-Slim WhatsApp-Style Bottom Bar (< 10% height)
            _buildWhatsAppStyleInputBar(loc, speech, isListening, isSpeaking),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopHeader(LocaleProvider loc) {
    return AppBar(
      backgroundColor: AppColors.surfaceBase,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            loc.tr('salon_title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 7,
            height: 7,
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
            ),
          ),
        ],
      ),
      actions: [
        const CreditBadge(),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Reset conversation',
          icon: const Icon(
            Icons.refresh_rounded,
            size: 20,
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
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.borderHighlight,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildCleanGretaPortrait() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final stageHeight = isTablet ? 250.0 : 190.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 600 : double.infinity,
        ),
        child: SizedBox(
          width: double.infinity,
          height: stageHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Greta's Clean, Unobstructed Avatar
              AnimatedSwitcher(
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
                  alignment: const Alignment(0.0, -0.25),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surfaceElevated,
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 72,
                          color: AppColors.cyanGlow,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Soft Bottom Gradient Fade into chat background (Zero text, zero buttons over Greta!)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.backgroundBase.withValues(alpha: 0.6),
                        AppColors.backgroundBase,
                      ],
                    ),
                  ),
                ),
              ),

              // Lateral vignettes for tablets
              if (isTablet) ...[
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.backgroundBase,
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
                  width: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          AppColors.backgroundBase,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppStyleInputBar(
      LocaleProvider loc,
      GermanSpeechService speech,
      bool isListening,
      bool isSpeaking) {
    final hasText = _textController.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceBase,
        border: Border(
          top: BorderSide(color: AppColors.borderHighlight, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: isListening
                  // Active Speech Recording Pill (WhatsApp Voice Note style)
                  ? Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.cyanGlow.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.graphic_eq_rounded,
                            size: 18,
                            color: AppColors.cyanGlow,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              speech.currentWords.isNotEmpty
                                  ? speech.currentWords
                                  : loc.tr('ready_to_listen'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cyanSoft,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _handleOrbTap,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.cyanGlow,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.stop_rounded,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  // Normal State: Slim Text Field + Compact Mic/Send Button (< 10% screen height)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // WhatsApp-style Pill Input Field
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppColors.borderHighlight,
                                width: 1.0,
                              ),
                            ),
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              cursorColor: AppColors.cyanGlow,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _submitTextTurn(),
                              decoration: const InputDecoration(
                                hintText: 'Nachricht eingeben...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textLowEmphasis,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 11,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // WhatsApp-style Action Circle (44x44 dp)
                        GestureDetector(
                          onTap: _isAiThinking
                              ? null
                              : (hasText ? _submitTextTurn : _handleOrbTap),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _isAiThinking
                                  ? AppColors.surfaceElevated
                                  : AppColors.cyanGlow,
                              shape: BoxShape.circle,
                              boxShadow: _isAiThinking
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: AppColors.cyanGlow
                                            .withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: _isAiThinking
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.cyanSoft,
                                      ),
                                    )
                                  : Icon(
                                      hasText
                                          ? Icons.send_rounded
                                          : Icons.mic_rounded,
                                      size: 21,
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
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
