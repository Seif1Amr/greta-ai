import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/locale_provider.dart';

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
    final loc = context.watch<LocaleProvider>();

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
              Text(
                loc.tr('ipa_guide'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyanGlow,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  phoneticIpa,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: AppColors.textHighEmphasis,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (phoneticBreakdown.isNotEmpty) ...[
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                phoneticBreakdown,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.cyanSoft,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
