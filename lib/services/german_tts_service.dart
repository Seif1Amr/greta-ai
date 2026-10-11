import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/audio_focus_guard.dart';

class GermanTtsService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  bool _isSpeaking = false;
  double _syntheticDecibel = 0.0;
  Timer? _resonanceSimulationTimer;
  double _currentSpeedMultiplier = 1.0;
  int _currentSpeakGeneration = 0;

  bool get isSpeaking => _isSpeaking;
  double get syntheticDecibel => _syntheticDecibel;
  double get currentSpeedMultiplier => _currentSpeedMultiplier;

  GermanTtsService() {
    _initializeTts();
  }

  double get _baseSpeechRate {
    if (!kIsWeb && Platform.isAndroid) {
      return AppConstants.ttsSpeechRateAndroid; // 0.46
    }
    return AppConstants.ttsSpeechRateIos; // 0.50
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage(AppConstants.germanLocaleTts);
      await _flutterTts.setSpeechRate(_baseSpeechRate);
      await _flutterTts.setPitch(AppConstants.ttsPitch);

      if (!kIsWeb && Platform.isIOS) {
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.duckOthers,
          ],
        );
      }

      // Try selecting a female German voice if available
      try {
        final voices = await _flutterTts.getVoices;
        if (voices is List) {
          for (final voice in voices) {
            if (voice is Map) {
              final locale = (voice['locale'] ?? '').toString().toLowerCase();
              final name = (voice['name'] ?? '').toString().toLowerCase();
              if (locale.contains('de') &&
                  (name.contains('female') ||
                      name.contains('de-de-language') ||
                      name.contains('greta') ||
                      name.contains('vicki') ||
                      name.contains('marlene'))) {
                await _flutterTts.setVoice({
                  'name': voice['name'].toString(),
                  'locale': voice['locale'].toString(),
                });
                break;
              }
            }
          }
        }
      } catch (_) {}

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        AudioFocusGuard.markTtsStarted();
        _startResonanceSimulation();
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        AudioFocusGuard.markTtsFinished();
        _stopResonanceSimulation();
        notifyListeners();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        AudioFocusGuard.markTtsFinished();
        _stopResonanceSimulation();
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('[GermanTtsService] error: $msg');
        _isSpeaking = false;
        AudioFocusGuard.markTtsFinished();
        _stopResonanceSimulation();
        notifyListeners();
      });
    } catch (e) {
      debugPrint('[GermanTtsService] Initialization caught gracefully: $e');
    }
  }

  Future<void> setSpeed(double speedMultiplier) async {
    _currentSpeedMultiplier = speedMultiplier;
    try {
      double rate = _baseSpeechRate;
      if (speedMultiplier <= 0.85) {
        rate = _baseSpeechRate * 0.8;
      } else if (speedMultiplier >= 1.15) {
        rate = _baseSpeechRate * 1.2;
      }
      await _flutterTts.setSpeechRate(rate);
      notifyListeners();
    } catch (e) {
      debugPrint('[GermanTtsService] Error setting speech rate: $e');
    }
  }

  Future<void> speak({
    required String text,
    required Future<void> Function() onHaltMicrophone,
    VoidCallback? onComplete,
  }) async {
    if (text.trim().isEmpty) return;

    final generation = ++_currentSpeakGeneration;

    await AudioFocusGuard.prepareForTts(stopSttAction: onHaltMicrophone);

    if (generation != _currentSpeakGeneration) return;

    try {
      await _flutterTts.stop();

      if (generation != _currentSpeakGeneration) return;

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        AudioFocusGuard.markTtsFinished();
        _stopResonanceSimulation();
        notifyListeners();
        onComplete?.call();
      });

      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('[GermanTtsService] Error speaking: $e');
      _isSpeaking = false;
      AudioFocusGuard.markTtsFinished();
      _stopResonanceSimulation();
      notifyListeners();
      onComplete?.call();
    }
  }

  Future<void> stop() async {
    _currentSpeakGeneration++;
    _isSpeaking = false;
    AudioFocusGuard.markTtsFinished();
    _stopResonanceSimulation();
    notifyListeners();
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('[GermanTtsService] Error stopping TTS: $e');
    }
  }

  void _startResonanceSimulation() {
    _resonanceSimulationTimer?.cancel();
    int tick = 0;
    _resonanceSimulationTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      tick++;
      if (!_isSpeaking) {
        timer.cancel();
        _syntheticDecibel = 0.0;
        notifyListeners();
        return;
      }
      final wave = (tick % 10) / 10.0;
      _syntheticDecibel =
          0.35 + (0.50 * (wave < 0.5 ? wave * 2 : (1.0 - wave) * 2));
      notifyListeners();
    });
  }

  void _stopResonanceSimulation() {
    _resonanceSimulationTimer?.cancel();
    _resonanceSimulationTimer = null;
    _syntheticDecibel = 0.0;
  }

  @override
  void dispose() {
    _stopResonanceSimulation();
    _flutterTts.stop();
    AudioFocusGuard.markTtsFinished();
    super.dispose();
  }
}
