import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/locale_provider.dart';
import '../services/hearts_wallet_service.dart';
import 'active_recall_bridge_modal.dart';

class RefillHeartsModal extends StatelessWidget {
  const RefillHeartsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const RefillHeartsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final wallet = context.watch<HeartsWalletService>();

    return Directionality(
      textDirection: loc.textDirection,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.borderHighlight, width: 1.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.heartRed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 28,
                    color: AppColors.heartRed,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.tr('hearts_balance'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHighEmphasis,
                      ),
                    ),
                    Text(
                      '${wallet.hearts} ${loc.tr('hearts')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cyanGlow,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Streak & Economics explanation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceBase,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 20,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            loc.tr('daily_streak'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHighEmphasis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${wallet.streakDays} Tage (+10/Tag)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.borderSubtle, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.mic_rounded,
                            size: 18,
                            color: AppColors.cyanSoft,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            loc.tr('hearts_cost_turn'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMediumEmphasis,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        '-1 Herz',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heartRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Refill Action Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ActiveRecallBridgeModal.show(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyanGlow,
                foregroundColor: AppColors.backgroundBase,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    loc.tr('watch_ad_refill'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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
}
