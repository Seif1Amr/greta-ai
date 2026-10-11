import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';

/// Guard to check and request microphone permission, with 1-tap Settings modal if denied.
class MicrophonePermissionGuard {
  MicrophonePermissionGuard._();

  static Future<bool> ensurePermission(BuildContext context) async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final requestResult = await Permission.microphone.request();
      if (requestResult.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      if (context.mounted) {
        await showPermissionDeniedModal(context);
      }
      return false;
    }

    final finalCheck = await Permission.microphone.status;
    if (!finalCheck.isGranted && context.mounted) {
      await showPermissionDeniedModal(context);
      return false;
    }

    return finalCheck.isGranted;
  }

  static Future<void> showPermissionDeniedModal(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderHighlight, width: 1),
          ),
          icon: const Icon(
            Icons.mic_off_rounded,
            size: 48,
            color: AppColors.error,
          ),
          title: const Text(
            'Mikrofon-Zugriff erforderlich',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textHighEmphasis,
            ),
          ),
          content: const Text(
            'Greta benötigt Zugriff auf dein Mikrofon, um deine deutsche Aussprache zu hören, zu bewerten und dir Feedback zu geben.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMediumEmphasis,
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text(
                'Später',
                style: TextStyle(color: AppColors.textLowEmphasis),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyanGlow,
                foregroundColor: AppColors.backgroundBase,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Einstellungen öffnen',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
