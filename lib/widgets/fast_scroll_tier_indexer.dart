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

  void _handleDrag(DragUpdateDetails details, BoxConstraints constraints) {
    if (constraints.maxHeight <= 0 || tiers.isEmpty) return;
    final localY = details.localPosition.dy.clamp(0.0, constraints.maxHeight - 1);
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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.borderHighlight.withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(-2, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (details) => _handleDrag(details, constraints),
              onVerticalDragDown: (details) {
                final localY = details.localPosition.dy.clamp(0.0, constraints.maxHeight - 1);
                final itemHeight = constraints.maxHeight / tiers.length;
                final index = (localY / itemHeight).floor().clamp(0, tiers.length - 1);
                final selected = tiers[index];
                if (selected != activeTier) {
                  HapticFeedback.lightImpact();
                  onTierSelected(selected);
                }
              },
              child: Column(
                children: tiers.map((tier) {
                  final isSelected = tier == activeTier;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTierSelected(tier);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.cyanGlow
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.cyanGlow.withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              tier,
                              style: TextStyle(
                                fontSize: isSelected ? 13 : 11,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                color: isSelected
                                    ? AppColors.backgroundBase
                                    : AppColors.textMediumEmphasis,
                                letterSpacing: 0.5,
                              ),
                            ),
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
      ),
    );
  }
}
