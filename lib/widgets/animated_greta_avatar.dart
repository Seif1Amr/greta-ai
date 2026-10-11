import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum GretaAvatarState {
  neutral,
  speaking,
  thinking,
  celebrating,
}

class AnimatedGretaAvatar extends StatelessWidget {
  final GretaAvatarState state;
  final double size;
  final bool showGlowRing;

  const AnimatedGretaAvatar({
    super.key,
    this.state = GretaAvatarState.neutral,
    this.size = 130.0,
    this.showGlowRing = true,
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
    switch (state) {
      case GretaAvatarState.speaking:
        return AppColors.cyanGlow;
      case GretaAvatarState.thinking:
        return const Color(0xFFA855F7);
      case GretaAvatarState.celebrating:
        return AppColors.successGlow;
      case GretaAvatarState.neutral:
        return AppColors.cyanSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: showGlowRing
              ? [
                  BoxShadow(
                    color: _glowColor.withValues(alpha: 0.45),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ]
              : null,
          border: Border.all(
            color: _glowColor.withValues(alpha: 0.8),
            width: 2.5,
          ),
        ),
        child: ClipOval(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Image.asset(
              _assetPath,
              key: ValueKey<String>(_assetPath),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surfaceElevated,
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: AppColors.cyanGlow,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
