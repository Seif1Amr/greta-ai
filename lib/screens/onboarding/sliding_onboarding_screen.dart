import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../services/german_tts_service.dart';
import '../../services/hearts_wallet_service.dart';
import '../../widgets/animated_greta_avatar.dart';
import '../main_navigation_scaffold.dart';

class SlidingOnboardingScreen extends StatefulWidget {
  const SlidingOnboardingScreen({super.key});

  @override
  State<SlidingOnboardingScreen> createState() =>
      _SlidingOnboardingScreenState();
}

class _SlidingOnboardingScreenState extends State<SlidingOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _selectedGoal = 'Career & Job in Germany 💼';
  String _selectedLevel = 'A1';
  bool _isPlayingGreeting = false;

  final List<String> _goals = [
    'Career & Job in Germany 💼',
    'Travel & Living ✈️',
    'Studying & University 🎓',
    'German Citizenship / Visa 🏛️',
    'Daily Conversation ☕',
  ];

  final List<Map<String, String>> _levels = [
    {
      'key': 'A1',
      'titleKey': 'level_a1_title',
      'descKey': 'level_a1_desc',
      'badge': 'Anfänger',
    },
    {
      'key': 'A2',
      'titleKey': 'level_a2_title',
      'descKey': 'level_a2_desc',
      'badge': 'Grundlegend',
    },
    {
      'key': 'B1',
      'titleKey': 'level_b1_title',
      'descKey': 'level_b1_desc',
      'badge': 'Mittelstufe',
    },
    {
      'key': 'B2',
      'titleKey': 'level_b2_title',
      'descKey': 'level_b2_desc',
      'badge': 'Gehoben',
    },
    {
      'key': 'C1',
      'titleKey': 'level_c1_c2_title',
      'descKey': 'level_c1_c2_desc',
      'badge': 'Fließend',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    final storage = GetStorage();
    storage.write(AppConstants.storageKeyOnboardingComplete, true);

    final wallet = context.read<HeartsWalletService>();
    wallet.setLearningGoal(_selectedGoal);
    wallet.setCefrLevel(_selectedLevel);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScaffold()),
    );
  }

  Future<void> _playGretaGreeting() async {
    final tts = context.read<GermanTtsService>();
    setState(() => _isPlayingGreeting = true);

    await tts.speak(
      text: 'Hallo! Ich bin Greta. Lass uns gemeinsam Deutsch lernen!',
      onHaltMicrophone: () async {},
      onComplete: () {
        if (mounted) {
          setState(() => _isPlayingGreeting = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _currentPage > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: AppColors.textMediumEmphasis),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                )
              : null,
          actions: [
            if (_currentPage < 2)
              TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  loc.tr('btn_skip'),
                  style: const TextStyle(
                    color: AppColors.textMediumEmphasis,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildSlide1Motivation(loc),
                    _buildSlide2Proficiency(loc),
                    _buildSlide3HabitAndGreeting(loc),
                  ],
                ),
              ),
              _buildBottomControls(loc),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide1Motivation(LocaleProvider loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Center(
            child: AnimatedGretaAvatar(
              state: GretaAvatarState.neutral,
              size: 110,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.tr('onboarding_slide1_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textHighEmphasis,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.tr('onboarding_slide1_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMediumEmphasis,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = _selectedGoal == goal;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedGoal = goal);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.cyanGlow.withValues(alpha: 0.12)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.cyanGlow
                            : AppColors.borderSubtle,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.cyanGlow.withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.textHighEmphasis
                                  : AppColors.textMediumEmphasis,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.cyanGlow,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide2Proficiency(LocaleProvider loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Text(
            loc.tr('onboarding_slide2_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textHighEmphasis,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.tr('onboarding_slide2_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMediumEmphasis,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: _levels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _levels[index];
                final lvlKey = item['key']!;
                final isSelected = _selectedLevel == lvlKey;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedLevel = lvlKey);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.cyanGlow.withValues(alpha: 0.12)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.cyanGlow
                            : AppColors.borderSubtle,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.cyanGlow.withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.cyanGlow
                                : AppColors.surfaceBase,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              lvlKey,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? AppColors.backgroundBase
                                    : AppColors.cyanGlow,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.tr(item['titleKey']!),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: AppColors.textHighEmphasis,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                loc.tr(item['descKey']!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMediumEmphasis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.cyanGlow,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide3HabitAndGreeting(LocaleProvider loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: AnimatedGretaAvatar(
              state: _isPlayingGreeting
                  ? GretaAvatarState.speaking
                  : GretaAvatarState.celebrating,
              size: 130,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            loc.tr('onboarding_slide3_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textHighEmphasis,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.tr('onboarding_slide3_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMediumEmphasis,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // 1-tap interactive voice greeting button
          OutlinedButton.icon(
            onPressed: _isPlayingGreeting ? null : _playGretaGreeting,
            icon: Icon(
              _isPlayingGreeting
                  ? Icons.volume_up_rounded
                  : Icons.play_circle_fill_rounded,
              color: AppColors.cyanGlow,
              size: 24,
            ),
            label: Text(
              _isPlayingGreeting
                  ? loc.tr('onboarding_greeting_playing')
                  : loc.tr('onboarding_greeting_btn'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.cyanGlow,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.cyanGlow, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Welcome bonus grant banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.heartRed.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.heartRed.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.heartRed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 26,
                    color: AppColors.heartRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.tr('onboarding_bonus_banner'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHighEmphasis,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '15 kostenlose Sprechturns sofort verfügbar.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMediumEmphasis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomControls(LocaleProvider loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          // Smooth indicator pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isCurrent = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isCurrent ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.cyanGlow
                      : AppColors.borderHighlight,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.cyanGlow.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 18),

          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyanGlow,
              foregroundColor: AppColors.backgroundBase,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _currentPage == 2
                  ? loc.tr('onboarding_get_started')
                  : loc.tr('btn_continue'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
