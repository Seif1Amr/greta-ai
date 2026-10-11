import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/constants/app_constants.dart';
import '../core/utils/audio_focus_guard.dart';

class GermanSpeechService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  String _selectedLocaleId = AppConstants.germanLocaleStt;
  double _soundLevel = 0.0;
  String _currentWords = '';

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get selectedLocaleId => _selectedLocaleId;
  double get soundLevel => _soundLevel;
  String get currentWords => _currentWords;

  static bool get isMobilePlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      if (isMobilePlatform) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          debugPrint('[GermanSpeechService] Microphone permission not granted.');
          return false;
        }
      }

      final available = await _speech.initialize(
        onError: (val) {
          debugPrint('[GermanSpeechService] onError: ${val.errorMsg}');
          _isListening = false;
          _soundLevel = 0.0;
          AudioFocusGuard.markSttFinished();
          notifyListeners();
        },
        onStatus: (val) {
          debugPrint('[GermanSpeechService] onStatus: $val');
          if (val == 'done' || val == 'notListening') {
            _isListening = false;
            _soundLevel = 0.0;
            AudioFocusGuard.markSttFinished();
            notifyListeners();
          }
        },
      );

      if (available) {
        final locales = await _speech.locales();
        final hasDeDe = locales.any((l) =>
            l.localeId.startsWith('de_DE') || l.localeId.startsWith('de-DE'));
        final hasDeAt = locales.any((l) =>
            l.localeId.startsWith('de_AT') || l.localeId.startsWith('de-AT'));
        final hasDeCh = locales.any((l) =>
            l.localeId.startsWith('de_CH') || l.localeId.startsWith('de-CH'));

        if (hasDeDe) {
          _selectedLocaleId = 'de_DE';
        } else if (hasDeAt) {
          _selectedLocaleId = 'de_AT';
        } else if (hasDeCh) {
          _selectedLocaleId = 'de_CH';
        } else {
          final anyDe = locales.firstWhere(
            (l) => l.localeId.toLowerCase().startsWith('de'),
            orElse: () => locales.isNotEmpty
                ? locales.first
                : stt.LocaleName('de_DE', 'German'),
          );
          _selectedLocaleId = anyDe.localeId;
        }

        _isInitialized = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[GermanSpeechService] Initialization exception: $e');
      return false;
    }
  }

  Future<bool> startListening({
    required Function(String text, bool isFinal) onResult,
    required Future<void> Function() onHaltTts,
    VoidCallback? onPermissionDenied,
  }) async {
    if (isMobilePlatform) {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        final requested = await Permission.microphone.request();
        if (!requested.isGranted) {
          debugPrint('[GermanSpeechService] Microphone permission denied.');
          _isListening = false;
          notifyListeners();
          onPermissionDenied?.call();
          return false;
        }
      }
    }

    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) {
        debugPrint('[GermanSpeechService] Speech engine not initialized.');
        onPermissionDenied?.call();
        return false;
      }
    }

    // Audio interlock: ensure TTS is fully stopped before opening microphone
    await AudioFocusGuard.prepareForStt(stopTtsAction: onHaltTts);

    _currentWords = '';
    _isListening = true;
    AudioFocusGuard.markSttStarted();
    notifyListeners();

    try {
      await _speech.listen(
        onResult: (result) {
          _currentWords = result.recognizedWords;
          notifyListeners();
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: _selectedLocaleId,
          pauseFor: const Duration(seconds: 4),
          listenFor: const Duration(seconds: 30),
          cancelOnError: true,
          partialResults: true,
        ),
        onSoundLevelChange: (level) {
          _soundLevel = (level / 10.0).clamp(0.0, 1.0);
          notifyListeners();
        },
      );
      return true;
    } catch (e) {
      debugPrint('[GermanSpeechService] Error during listen: $e');
      _isListening = false;
      _soundLevel = 0.0;
      AudioFocusGuard.markSttFinished();
      notifyListeners();
      return false;
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('[GermanSpeechService] Error stopping speech capture: $e');
    } finally {
      _isListening = false;
      _soundLevel = 0.0;
      AudioFocusGuard.markSttFinished();
      notifyListeners();
    }
  }

  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } catch (e) {
      debugPrint('[GermanSpeechService] Error cancelling speech capture: $e');
    } finally {
      _isListening = false;
      _soundLevel = 0.0;
      AudioFocusGuard.markSttFinished();
      notifyListeners();
    }
  }
}
