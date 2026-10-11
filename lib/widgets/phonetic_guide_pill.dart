import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class PhoneticGuidePill extends StatelessWidget {
  final String germanPhrase;
  final String phoneticIpa;
  final String phoneticBreakdown;

  const PhoneticGuidePill({
    super.key,
    required this.germanPhrase,
    required this.phoneticIpa,
    required this.phoneticBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cyanGlow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                size: 15,
                color: AppColors.cyanGlow,
              ),
              const SizedBox(width: 6),
              const Text(
                'IPA & Aussprache',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyanGlow,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                phoneticIpa,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: AppColors.textHighEmphasis,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            phoneticBreakdown,
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.cyanSoft,
            ),
          ),
        ],
      ),
    );
  }
}
