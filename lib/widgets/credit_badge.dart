import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../services/hearts_wallet_service.dart';
import 'refill_hearts_modal.dart';

class CreditBadge extends StatelessWidget {
  final bool showRefillOnTap;

  const CreditBadge({
    super.key,
    this.showRefillOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<HeartsWalletService>();

    return GestureDetector(
      onTap: showRefillOnTap
          ? () => RefillHeartsModal.show(context)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: wallet.hearts <= 2
                ? AppColors.heartRed
                : AppColors.borderHighlight,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: wallet.hearts <= 2
                  ? AppColors.heartRed.withValues(alpha: 0.25)
                  : AppColors.cyanGlow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 16,
              color: wallet.hearts <= 2
                  ? AppColors.heartRed
                  : AppColors.heartGlow,
            ),
            const SizedBox(width: 6),
            Text(
              '${wallet.hearts}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textHighEmphasis,
              ),
            ),
            if (showRefillOnTap) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 14,
                color: AppColors.cyanGlow,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
