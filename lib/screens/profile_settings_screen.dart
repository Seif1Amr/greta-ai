import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/locale_provider.dart';
import '../services/gemini_german_service.dart';
import '../services/german_tts_service.dart';
import '../services/hearts_wallet_service.dart';
import '../widgets/animated_greta_avatar.dart';
import '../widgets/credit_badge.dart';
import '../widgets/refill_hearts_modal.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final GeminiGermanService _geminiService = GeminiGermanService();

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = _geminiService.apiKey;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey() {
    _geminiService.setCustomApiKey(_apiKeyController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API-Schlüssel erfolgreich gespeichert.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _confirmResetData() {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final loc = dialogCtx.read<LocaleProvider>();
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderHighlight),
          ),
          title: Text(
            loc.tr('reset_data'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textHighEmphasis,
            ),
          ),
          content: Text(
            loc.tr('reset_confirm'),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMediumEmphasis,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(loc.tr('cancel'),
                  style: const TextStyle(color: AppColors.textLowEmphasis)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.read<HeartsWalletService>().resetAllProgress();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fortschritt zurückgesetzt.'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(loc.tr('confirm')),
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
    final tts = context.watch<GermanTtsService>();

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        appBar: AppBar(
          title: Text(
            loc.tr('profile_title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textHighEmphasis,
            ),
          ),
          actions: const [
            CreditBadge(),
            SizedBox(width: 14),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderHighlight),
                  ),
                  child: Row(
                    children: [
                      const AnimatedGretaAvatar(
                        state: GretaAvatarState.neutral,
                        size: 72,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppConstants.displayName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textHighEmphasis,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Level ${wallet.cefrLevel} • ${wallet.learningGoal}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.cyanSoft,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.favorite_rounded,
                                    size: 14, color: AppColors.heartRed),
                                const SizedBox(width: 4),
                                Text(
                                  '${wallet.hearts} ${loc.tr('hearts')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textHighEmphasis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.local_fire_department_rounded,
                                    size: 14, color: AppColors.warning),
                                const SizedBox(width: 4),
                                Text(
                                  '${wallet.streakDays} ${loc.tr('streak_days')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textHighEmphasis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Language Switcher Section
                _buildSectionHeader(loc.tr('display_language')),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      _buildLangPill('en', 'English 🇬🇧', loc),
                      _buildLangPill('de', 'Deutsch 🇩🇪', loc),
                      _buildLangPill('ar', 'العربية 🇸🇦', loc),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // CEFR Level Selector (Responsive Single Row)
                _buildSectionHeader(loc.tr('current_level')),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((lvl) {
                      final isSelected = wallet.cefrLevel == lvl;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => wallet.setCefrLevel(lvl),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.cyanGlow
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                lvl,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? AppColors.backgroundBase
                                      : AppColors.textHighEmphasis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Speech Speed Multiplier
                _buildSectionHeader(loc.tr('audio_speech_speed')),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      _buildSpeedChip(0.8, loc.tr('speed_slow'), tts),
                      const SizedBox(width: 8),
                      _buildSpeedChip(1.0, loc.tr('speed_normal'), tts),
                      const SizedBox(width: 8),
                      _buildSpeedChip(1.2, loc.tr('speed_fast'), tts),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Hearts Refill Card
                _buildSectionHeader(loc.tr('credits_and_ad_bridge')),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded,
                          size: 24, color: AppColors.cyanGlow),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.tr('refill_hearts'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHighEmphasis,
                              ),
                            ),
                            Text(
                              loc.tr('refill_description'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMediumEmphasis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => RefillHeartsModal.show(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyanGlow,
                          foregroundColor: AppColors.backgroundBase,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        child: Text(loc.tr('refill')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Custom Gemini API Key Section
                _buildSectionHeader(loc.tr('custom_api_key')),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.tr('optional_api_key_desc'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMediumEmphasis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _apiKeyController,
                        obscureText: true,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textHighEmphasis,
                          fontFamily: 'monospace',
                        ),
                        decoration: InputDecoration(
                          hintText: 'AIzaSy...',
                          hintStyle: const TextStyle(
                            color: AppColors.textLowEmphasis,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceBase,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.borderSubtle),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _saveApiKey,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyanGlow,
                            foregroundColor: AppColors.backgroundBase,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(loc.tr('save_key')),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Reset Progress Action
                OutlinedButton.icon(
                  onPressed: _confirmResetData,
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.error),
                  label: Text(
                    loc.tr('reset_data'),
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 30),

                // App Branding Info
                Center(
                  child: Text(
                    '${AppConstants.appTitle} • v${AppConstants.appVersion}\nWSO Tech AI Systems',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.cyanGlow,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLangPill(String code, String label, LocaleProvider loc) {
    final isSelected = loc.languageCode == code;

    return Expanded(
      child: GestureDetector(
        onTap: () => loc.setLocale(code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cyanGlow : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AppColors.backgroundBase
                    : AppColors.textMediumEmphasis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedChip(
      double speed, String label, GermanTtsService tts) {
    final isSelected =
        (tts.currentSpeedMultiplier - speed).abs() < 0.05;

    return Expanded(
      child: GestureDetector(
        onTap: () => tts.setSpeed(speed),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.cyanGlow.withValues(alpha: 0.15)
                : AppColors.surfaceBase,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.cyanGlow : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? AppColors.cyanGlow
                    : AppColors.textMediumEmphasis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
