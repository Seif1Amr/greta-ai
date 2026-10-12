import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/locale_provider.dart';
import '../data/german_curriculum_catalog.dart';
import '../services/hearts_wallet_service.dart';
import '../widgets/active_recall_bridge_modal.dart';
import '../widgets/credit_badge.dart';
import '../widgets/fast_scroll_tier_indexer.dart';
import 'grammar_mastery/grammar_mastery_hub_screen.dart';
import 'level_exercise_screen.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  final ScrollController _scrollController = ScrollController();
  late List<LevelSummary> _summaries;
  String _activeTier = 'A1';

  static const double _itemExtent = 98.0;

  @override
  void initState() {
    super.initState();
    _summaries = GermanCurriculumCatalog.getAllLevelSummaries();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final estimatedIndex = (offset / _itemExtent).floor().clamp(0, _summaries.length - 1);
    final currentTier = _summaries[estimatedIndex].tier;
    if (currentTier != _activeTier) {
      setState(() => _activeTier = currentTier);
    }
  }

  void _jumpToTier(String tier) {
    final startLevel = GermanCurriculumCatalog.getStartingLevelForTier(tier);
    final targetIndex = (startLevel - 1).clamp(0, _summaries.length - 1);
    final targetOffset = targetIndex * _itemExtent;

    setState(() => _activeTier = tier);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleLevelTap(LevelSummary summary) {
    final wallet = context.read<HeartsWalletService>();
    final isUnlocked = wallet.isLevelUnlocked(summary.levelNumber);

    if (isUnlocked) {
      final level = GermanCurriculumCatalog.getLevel(summary.levelNumber);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LevelExerciseScreen(level: level),
        ),
      );
    } else {
      // Prompt unlock for 1 heart or watch ad
      _showUnlockDialog(summary);
    }
  }

  void _showUnlockDialog(LevelSummary summary) {
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
            'Lektion ${summary.levelNumber} freischalten',
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
                summary.getTitle(loc.languageCode),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyanSoft,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                summary.grammarFocus,
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
                  wallet.unlockLevel(summary.levelNumber);
                  Navigator.of(dialogCtx).pop();
                  final level =
                      GermanCurriculumCatalog.getLevel(summary.levelNumber);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LevelExerciseScreen(level: level),
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
                child: Text(
                  loc.tr('unlock_for_hearts'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/app_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.tr('curriculum_title'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHighEmphasis,
                    ),
                  ),
                  Text(
                    loc.tr('curriculum_appbar_subtitle'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.cyanSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: const [
            CreditBadge(),
            SizedBox(width: 14),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                // Grammar Mastery Studios Access Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _buildGrammarStudiosBanner(context, loc),
            ),
            Expanded(
              child: Stack(
                children: [
                  // 600-Level ListView with Fixed Extent for Instant 120fps Scrolling
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: _summaries.length,
                    itemExtent: _itemExtent,
                    padding: const EdgeInsets.fromLTRB(16, 8, 60, 24),
              itemBuilder: (context, index) {
                final summary = _summaries[index];
                final isUnlocked = wallet.isLevelUnlocked(summary.levelNumber);
                final isCompleted =
                    wallet.isLevelCompleted(summary.levelNumber);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleLevelTap(summary),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.surfaceElevated
                              : (isUnlocked
                                  ? AppColors.surfaceCard
                                  : AppColors.surfaceBase),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.successGlow.withValues(alpha: 0.6)
                                : (isUnlocked
                                    ? AppColors.borderHighlight
                                    : AppColors.borderSubtle),
                            width: isCompleted ? 1.4 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Level Number Box
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : (isUnlocked
                                        ? AppColors.cyanGlow.withValues(alpha: 0.15)
                                        : AppColors.surfaceElevated),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${summary.levelNumber}',
                                  style: TextStyle(
                                    fontSize: 15,
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

                            // Level details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.blueElectric
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          summary.tier,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.cyanSoft,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          summary.getTitle(loc.languageCode),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isUnlocked
                                                ? AppColors.textHighEmphasis
                                                : AppColors.textLowEmphasis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    summary.grammarFocus,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMediumEmphasis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status Icon
                            if (isCompleted)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.successGlow,
                                size: 22,
                              )
                            else if (isUnlocked)
                              const Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.cyanGlow,
                                size: 22,
                              )
                            else
                              const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Sticky Right-Hand Tier Fast-Scroll Indexer (Full vertical stretch)
            Positioned(
              right: 6,
              top: 8,
              bottom: 12,
              child: FastScrollTierIndexer(
                tiers: GermanCurriculumCatalog.tiers,
                activeTier: _activeTier,
                onTierSelected: _jumpToTier,
              ),
            ),
          ],
        ),
      ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildGrammarStudiosBanner(BuildContext context, LocaleProvider loc) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const GrammarMasteryHubScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cyanGlow.withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyanGlow.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D2FF), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.tr('grammar_studios_title'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHighEmphasis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc.tr('grammar_studios_subtitle'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.cyanSoft,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cyanGlow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.cyanGlow.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  loc.tr('open'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyanGlow,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
