import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/locale_provider.dart';
import '../../data/grammar_mastery_catalog.dart';
import '../../models/grammar_mastery_model.dart';
import '../../services/hearts_wallet_service.dart';
import '../../widgets/active_recall_bridge_modal.dart';
import '../../widgets/credit_badge.dart';
import 'grammar_lesson_screen.dart';

class GrammarMasteryHubScreen extends StatelessWidget {
  const GrammarMasteryHubScreen({super.key});

  void _showRuleSheet(BuildContext context, GrammarStudioCategory studio, LocaleProvider loc) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      studio.iconEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studio.getName(loc.languageCode),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textHighEmphasis,
                            ),
                          ),
                          Text(
                            'Regeln & Differenzierungs-Leitfaden',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.cyanSoft,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...studio.keyRules.map((rule) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBase,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: AppColors.cyanGlow,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            rule,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textHighEmphasis,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(sheetCtx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyanGlow,
                    foregroundColor: AppColors.backgroundBase,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Verstanden',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLevelTap(
    BuildContext context,
    GrammarStudioCategory studio,
    GrammarLevelData levelData,
  ) {
    final wallet = context.read<HeartsWalletService>();
    final isUnlocked = wallet.isGrammarLevelUnlocked(studio.key, levelData.levelNumber);

    if (isUnlocked) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GrammarLessonScreen(
            studio: studio,
            levelData: levelData,
          ),
        ),
      );
    } else {
      _showUnlockDialog(context, studio, levelData);
    }
  }

  void _showUnlockDialog(
    BuildContext context,
    GrammarStudioCategory studio,
    GrammarLevelData levelData,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final loc = dialogCtx.read<LocaleProvider>();
        final wallet = dialogCtx.watch<HeartsWalletService>();

        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderHighlight, width: 1.2),
          ),
          title: Text(
            'Level ${levelData.levelNumber} freischalten',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textHighEmphasis,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                levelData.getTitle(loc.languageCode),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyanSoft,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                levelData.getSubtitle(loc.languageCode),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMediumEmphasis,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.favorite_rounded,
                      size: 16, color: AppColors.heartRed),
                  const SizedBox(width: 6),
                  Text(
                    'Kosten: 1 Herz (Guthaben: ${wallet.hearts})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHighEmphasis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                loc.tr('cancel'),
                style: const TextStyle(color: AppColors.textLowEmphasis),
              ),
            ),
            if (wallet.hearts > 0)
              ElevatedButton(
                onPressed: () {
                  wallet.deductLevelHeart();
                  wallet.unlockGrammarLevel(studio.key, levelData.levelNumber);
                  Navigator.of(dialogCtx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GrammarLessonScreen(
                        studio: studio,
                        levelData: levelData,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyanGlow,
                  foregroundColor: AppColors.backgroundBase,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Freischalten (1 Herz)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  ActiveRecallBridgeModal.show(context);
                },
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Herzen aufladen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyanGlow,
                  foregroundColor: AppColors.backgroundBase,
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final wallet = context.watch<HeartsWalletService>();
    final studios = GrammarMasteryCatalog.studios;

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deutsche Kernmeisterei',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHighEmphasis,
                ),
              ),
              Text(
                'Die 4 größten Hürden meistern',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.cyanSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: const [
            CreditBadge(),
            SizedBox(width: 14),
          ],
        ),
        body: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            itemCount: studios.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final studio = studios[index];

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.borderHighlight,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: Emoji + Name + Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceBase,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.cyanGlow.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              studio.iconEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      studio.getName(loc.languageCode),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textHighEmphasis,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.blueElectric
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      studio.badge,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.cyanSoft,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                studio.getSummary(loc.languageCode),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMediumEmphasis,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Rule guide action
                    InkWell(
                      onTap: () => _showRuleSheet(context, studio, loc),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cyanGlow.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.cyanGlow.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 15,
                              color: AppColors.cyanGlow,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Regeln & Spickzettel öffnen',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cyanGlow,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: AppColors.cyanGlow,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Levels Map
                    const Text(
                      'Stufen-Trainingspfad:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLowEmphasis,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: studio.levels.map((lvl) {
                        final isUnlocked = wallet.isGrammarLevelUnlocked(
                            studio.key, lvl.levelNumber);
                        final isCompleted = wallet.isGrammarLevelCompleted(
                            studio.key, lvl.levelNumber);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  _handleLevelTap(context, studio, lvl),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? AppColors.surfaceBase
                                      : (isUnlocked
                                          ? AppColors.surfaceCard
                                          : AppColors.surfaceBase),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCompleted
                                        ? AppColors.successGlow
                                            .withValues(alpha: 0.5)
                                        : (isUnlocked
                                            ? AppColors.borderHighlight
                                            : AppColors.borderSubtle),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? AppColors.success
                                                .withValues(alpha: 0.2)
                                            : (isUnlocked
                                                ? AppColors.cyanGlow
                                                    .withValues(alpha: 0.15)
                                                : AppColors.surfaceElevated),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${lvl.levelNumber}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: isCompleted
                                                ? AppColors.successGlow
                                                : (isUnlocked
                                                    ? AppColors.cyanGlow
                                                    : AppColors.textLowEmphasis),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lvl.getTitle(loc.languageCode),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: isUnlocked
                                                  ? AppColors.textHighEmphasis
                                                  : AppColors.textLowEmphasis,
                                            ),
                                          ),
                                          Text(
                                            lvl.getSubtitle(loc.languageCode),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color:
                                                  AppColors.textMediumEmphasis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isCompleted)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.successGlow,
                                        size: 20,
                                      )
                                    else if (isUnlocked)
                                      const Icon(
                                        Icons.play_circle_fill_rounded,
                                        color: AppColors.cyanGlow,
                                        size: 22,
                                      )
                                    else
                                      const Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppColors.textMuted,
                                        size: 18,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
