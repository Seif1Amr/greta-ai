import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/locale_provider.dart';
import 'curriculum_screen.dart';
import 'practice_studio_screen.dart';
import 'profile_settings_screen.dart';
import 'salon_conversation_screen.dart';

class MainNavigationScaffold extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    CurriculumScreen(),
    SalonConversationScreen(),
    PracticeStudioScreen(),
    ProfileSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceBase,
            border: Border(
              top: BorderSide(color: AppColors.borderHighlight, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surfaceBase,
            selectedItemColor: AppColors.cyanGlow,
            unselectedItemColor: AppColors.textLowEmphasis,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.school_outlined),
                activeIcon: const Icon(Icons.school_rounded),
                label: loc.tr('nav_learn'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: const Icon(Icons.chat_bubble_rounded),
                label: loc.tr('nav_speak'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.graphic_eq_rounded),
                activeIcon: const Icon(Icons.mic_rounded),
                label: loc.tr('nav_practice'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                activeIcon: const Icon(Icons.person_rounded),
                label: loc.tr('nav_profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
