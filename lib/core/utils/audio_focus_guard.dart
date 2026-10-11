import 'dart:async';
import 'package:flutter/foundation.dart';

/// Clean audio coordinator to prevent audio collisions between TTS and Speech-to-Text.
class AudioFocusGuard {
  AudioFocusGuard._();

  static bool _isTtsActive = false;
  static bool _isSttActive = false;

  static bool get isTtsActive => _isTtsActive;
  static bool get isSttActive => _isSttActive;

  static void markTtsStarted() {
    _isTtsActive = true;
    debugPrint('[AudioFocusGuard] TTS active');
  }

  static void markTtsFinished() {
    _isTtsActive = false;
    debugPrint('[AudioFocusGuard] TTS inactive');
  }

  static void markSttStarted() {
    _isSttActive = true;
    debugPrint('[AudioFocusGuard] STT active');
  }

  static void markSttFinished() {
    _isSttActive = false;
    debugPrint('[AudioFocusGuard] STT inactive');
  }

  /// Ensures microphone STT cancels before TTS starts speaking.
  static Future<void> prepareForTts({required Future<void> Function() stopSttAction}) async {
    if (_isSttActive) {
      debugPrint('[AudioFocusGuard] Halting STT for TTS playback');
      await stopSttAction();
      _isSttActive = false;
      // Allow audio hardware to release microphone stream
      await Future.delayed(const Duration(milliseconds: 120));
    }
  }

  /// Ensures TTS stops before microphone STT starts listening.
  static Future<void> prepareForStt({required Future<void> Function() stopTtsAction}) async {
    if (_isTtsActive) {
      debugPrint('[AudioFocusGuard] Halting TTS for STT listening');
      await stopTtsAction();
      _isTtsActive = false;
      // Brief pause to clear audio speaker queue
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }
}
