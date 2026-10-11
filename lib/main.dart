import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_navigation_scaffold.dart';
import 'screens/onboarding/sliding_onboarding_screen.dart';
import 'services/ad_mob_service.dart';
import 'services/german_speech_service.dart';
import 'services/german_tts_service.dart';
import 'services/hearts_wallet_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize AdMob
  final adMobService = AdMobService();
  adMobService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => HeartsWalletService()),
        ChangeNotifierProvider(create: (_) => GermanTtsService()),
        ChangeNotifierProvider(create: (_) => GermanSpeechService()),
        Provider<AdMobService>.value(value: adMobService),
      ],
      child: const GretaAiApp(),
    ),
  );
}

class GretaAiApp extends StatelessWidget {
  const GretaAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final storage = GetStorage();
    final bool isOnboardingComplete =
        storage.read<bool>(AppConstants.storageKeyOnboardingComplete) ?? false;

    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(isArabic: localeProvider.isArabic),
      home: isOnboardingComplete
          ? const MainNavigationScaffold()
          : const SlidingOnboardingScreen(),
    );
  }
}
