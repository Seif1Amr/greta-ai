import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Glowing pulsating voice orb reacting dynamically to speaking, listening, and thinking states.
class GlowingVoiceOrb extends StatefulWidget {
  final bool isListening;
  final bool isSpeaking;
  final bool isThinking;
  final double soundLevel;
  final double size;
  final VoidCallback? onTap;

  const GlowingVoiceOrb({
    super.key,
    this.isListening = false,
    this.isSpeaking = false,
    this.isThinking = false,
    this.soundLevel = 0.0,
    this.size = 110.0,
    this.onTap,
  });

  @override
  State<GlowingVoiceOrb> createState() => _GlowingVoiceOrbState();
}

class _GlowingVoiceOrbState extends State<GlowingVoiceOrb>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = widget.size;

    return GestureDetector(
      onTap: widget.isThinking ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _rotationController]),
        builder: (context, child) {
          final pulseVal = _pulseAnimation.value;
          final rotVal = _rotationController.value * 2 * math.pi;

          Color coreGlowColor;
          Color outerGlowColor;
          IconData centerIcon;
          double dynamicScale = 1.0;

          if (widget.isListening) {
            coreGlowColor = AppColors.cyanGlow;
            outerGlowColor = AppColors.cyanGlow.withValues(alpha: 0.55);
            centerIcon = Icons.graphic_eq_rounded;
            final soundFactor = (widget.soundLevel * 0.4).clamp(0.0, 0.4);
            dynamicScale = 1.05 + (pulseVal * 0.12) + soundFactor;
          } else if (widget.isSpeaking) {
            coreGlowColor = AppColors.cyanSoft;
            outerGlowColor = AppColors.blueElectric.withValues(alpha: 0.5);
            centerIcon = Icons.volume_up_rounded;
            dynamicScale = 1.0 + (pulseVal * 0.15);
          } else if (widget.isThinking) {
            coreGlowColor = const Color(0xFFA855F7);
            outerGlowColor = const Color(0xFFA855F7).withValues(alpha: 0.4);
            centerIcon = Icons.auto_awesome_rounded;
            dynamicScale = 0.98 + (pulseVal * 0.08);
          } else {
            coreGlowColor = AppColors.cyanGlow;
            outerGlowColor = AppColors.cyanGlow.withValues(alpha: 0.2);
            centerIcon = Icons.mic_none_rounded;
            dynamicScale = 0.96 + (pulseVal * 0.04);
          }

          return Center(
            child: SizedBox(
              width: effectiveSize * 1.5,
              height: effectiveSize * 1.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Ambient Glow Aura
                  Container(
                    width: effectiveSize * dynamicScale * 1.35,
                    height: effectiveSize * dynamicScale * 1.35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: outerGlowColor
                          .withValues(alpha: 0.15 + (pulseVal * 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: coreGlowColor.withValues(alpha: 0.35),
                          blurRadius: 36 * dynamicScale,
                          spreadRadius: 8 * dynamicScale,
                        ),
                      ],
                    ),
                  ),

                  // Concentric Sound Ring (for listening or speaking)
                  if (widget.isListening || widget.isSpeaking)
                    Container(
                      width: effectiveSize *
                          (dynamicScale + (1.0 - pulseVal) * 0.25),
                      height: effectiveSize *
                          (dynamicScale + (1.0 - pulseVal) * 0.25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: coreGlowColor
                              .withValues(alpha: (1.0 - pulseVal) * 0.6),
                          width: 2.0,
                        ),
                      ),
                    ),

                  // Rotating gradient orb container
                  Transform.rotate(
                    angle: widget.isThinking ? rotVal : 0.0,
                    child: Container(
                      width: effectiveSize,
                      height: effectiveSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: widget.isThinking
                              ? [
                                  const Color(0xFFE9D5FF),
                                  const Color(0xFFA855F7),
                                  const Color(0xFF6B21A8),
                                  AppColors.backgroundBase,
                                ]
                              : [
                                  const Color(0xFFE0F2FE),
                                  coreGlowColor,
                                  AppColors.blueElectric,
                                  AppColors.backgroundBase,
                                ],
                          stops: const [0.0, 0.4, 0.8, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: coreGlowColor.withValues(alpha: 0.6),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: widget.isThinking
                            ? SizedBox(
                                width: effectiveSize * 0.38,
                                height: effectiveSize * 0.38,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(
                                centerIcon,
                                color: Colors.white,
                                size: effectiveSize * 0.42,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
