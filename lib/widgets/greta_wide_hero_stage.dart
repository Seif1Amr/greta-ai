import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/locale_provider.dart';
import 'animated_greta_avatar.dart';

/// A cinematic, widescreen showcase stage for Greta spanning the full width of the phone.
/// Replaces the small circle avatar with a rich, reactive AI video-call style companion header.
class GretaWideHeroStage extends StatelessWidget {
  final GretaAvatarState state;
  final bool isListening;
  final bool isSpeaking;
  final bool isThinking;
  final double soundLevel;
  final String cefrLevel;
  final VoidCallback? onPlayGreeting;
  final LocaleProvider loc;

  const GretaWideHeroStage({
    super.key,
    required this.state,
    required this.isListening,
    required this.isSpeaking,
    required this.isThinking,
    required this.soundLevel,
    required this.cefrLevel,
    required this.loc,
    this.onPlayGreeting,
  });

  String get _assetPath {
    switch (state) {
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

  Color get _glowColor {
    if (isThinking || state == GretaAvatarState.thinking) {
      return const Color(0xFFA855F7); // Purple glow for thinking
    }
    if (isSpeaking || state == GretaAvatarState.speaking) {
      return AppColors.cyanGlow;
    }
    if (state == GretaAvatarState.celebrating) {
      return AppColors.successGlow;
    }
    if (isListening) {
      return AppColors.cyanSoft;
    }
    return AppColors.cyanSoft;
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = _glowColor;
    final isActive = isSpeaking || isListening || isThinking;

    return Container(
      width: double.infinity,
      height: 205,
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: glowColor.withValues(alpha: isActive ? 0.75 : 0.35),
          width: isActive ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: isActive ? 0.35 : 0.15),
            blurRadius: isActive ? 22 : 12,
            spreadRadius: isActive ? 2 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. High-Res Reactive Avatar Image across the full container width
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.asset(
                _assetPath,
                key: ValueKey<String>(_assetPath),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.25), // Optimally framed on Greta's face
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceBase,
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

            // 2. Cinematic Gradient Scrim (Top & Bottom for HUD legibility)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.backgroundBase.withValues(alpha: 0.92),
                    ],
                    stops: const [0.0, 0.28, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Top HUD: CEFR Badge (Left) & Live Reactive Status Pill (Right)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: CEFR & Persona Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBase.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderHighlight,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇩🇪', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          'Greta • $cefrLevel',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.cyanGlow,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Live Status Pill
                  _buildLiveStatusPill(glowColor),
                ],
              ),
            ),

            // 4. Bottom HUD: Persona Title, Reactive State & Audio Wave / Greeting
            Positioned(
              left: 14,
              right: 14,
              bottom: 10,
              child: Row(
                children: [
                  // Persona name & reactive status text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Greta',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.cyanGlow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.cyanGlow.withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'AI TUTOR',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.cyanGlow,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getStatusSubtitle(),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isThinking
                                ? const Color(0xFFC084FC)
                                : (isSpeaking
                                    ? AppColors.cyanGlow
                                    : (isListening
                                        ? AppColors.cyanSoft
                                        : AppColors.textMediumEmphasis)),
                            shadows: const [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Right: Audio visualizer waves or greeting speaker button
                  if (isSpeaking || isListening)
                    _buildActiveWaveBars(glowColor)
                  else if (onPlayGreeting != null)
                    GestureDetector(
                      onTap: onPlayGreeting,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.cyanGlow.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.volume_up_rounded,
                              size: 15,
                              color: AppColors.cyanGlow,
                            ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusPill(Color glowColor) {
    String label;
    IconData icon;

    if (isThinking) {
      label = loc.tr('greta_thinking');
      icon = Icons.auto_awesome_rounded;
    } else if (isSpeaking) {
      label = loc.tr('greta_speaking');
      icon = Icons.graphic_eq_rounded;
    } else if (isListening) {
      label = loc.tr('ready_to_listen');
      icon = Icons.mic_rounded;
    } else if (state == GretaAvatarState.celebrating) {
      label = 'Ausgezeichnet!';
      icon = Icons.check_circle_rounded;
    } else {
      label = 'Gemini 2.0 Flash';
      icon = Icons.fiber_manual_record_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundBase.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: glowColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: glowColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusSubtitle() {
    if (isThinking) {
      return loc.tr('greta_thinking');
    }
    if (isSpeaking) {
      return loc.tr('greta_speaking');
    }
    if (isListening) {
      return loc.tr('ready_to_listen');
    }
    return 'Deutsche Muttersprachlerin & Coach';
  }

  Widget _buildActiveWaveBars(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundBase.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBar(14, color),
          const SizedBox(width: 3),
          _buildBar(22, color),
          const SizedBox(width: 3),
          _buildBar(18, color),
          const SizedBox(width: 3),
          _buildBar(10, color),
        ],
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
