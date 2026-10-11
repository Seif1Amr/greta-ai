import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';

class FastScrollTierIndexer extends StatelessWidget {
  final List<String> tiers;
  final String activeTier;
  final ValueChanged<String> onTierSelected;

  const FastScrollTierIndexer({
    super.key,
    required this.tiers,
    required this.activeTier,
    required this.onTierSelected,
  });

  void _handleDrag(DragUpdateDetails details, BuildContext context, BoxConstraints constraints) {
    final localY = details.localPosition.dy.clamp(0.0, constraints.maxHeight);
    final itemHeight = constraints.maxHeight / tiers.length;
    final index = (localY / itemHeight).floor().clamp(0, tiers.length - 1);
    final selected = tiers[index];
    if (selected != activeTier) {
      HapticFeedback.selectionClick();
      onTierSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderHighlight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(-2, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) =>
                _handleDrag(details, context, constraints),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tiers.map((tier) {
                final isSelected = tier == activeTier;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTierSelected(tier);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.cyanGlow
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.cyanGlow.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        tier,
                        style: TextStyle(
                          fontSize: isSelected ? 12 : 11,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.backgroundBase
                              : AppColors.textMediumEmphasis,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
