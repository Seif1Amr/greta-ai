import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/conversation_turn.dart';

class GeminiGermanResponse {
  final String fullResponse;
  final String speechText;
  final String? correction;
  final String usedModel;
  final bool isFallback;

  const GeminiGermanResponse({
    required this.fullResponse,
    required this.speechText,
    this.correction,
    required this.usedModel,
    this.isFallback = false,
  });
}

class GeminiGermanService {
  final GetStorage _storage = GetStorage();
  final http.Client _client = http.Client();

  // Storage key for user custom API key
  String get apiKey {
    try {
      final customKey =
          _storage.read<String>(AppConstants.storageKeyCustomApiKey);
      if (customKey != null && customKey.trim().isNotEmpty) {
        return customKey.trim();
      }
    } catch (_) {}
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    return AppConstants.defaultGeminiApiKey;
  }

  /// Returns only the user-provided custom key (never exposes default private key)
  String get customApiKey {
    try {
      final customKey =
          _storage.read<String>(AppConstants.storageKeyCustomApiKey);
      if (customKey != null && customKey.trim().isNotEmpty) {
        return customKey.trim();
      }
    } catch (_) {}
    return '';
  }

  /// Whether an active API key (custom or built-in) is available
  bool get hasActiveKey => apiKey.trim().isNotEmpty;

  void setCustomApiKey(String key) {
    try {
      _storage.write(AppConstants.storageKeyCustomApiKey, key.trim());
    } catch (_) {}
  }

  /// Sends conversation history to Gemini with cascading model fallback.
  Future<GeminiGermanResponse> generateGermanReply({
    required List<ConversationTurn> history,
    required String userSpokenText,
    required String cefrLevel,
    required String learningGoal,
  }) async {
    final fallbackPool = [
      "Das ist sehr interessant! Könntest du mir mehr darüber auf Deutsch erzählen?",
      "Sehr gut formuliert! Wie würdest du das in deinen eigenen Worten noch genauer beschreiben?",
      "Verstehe ich vollkommen! Was denkst du, was der nächste logische Schritt wäre?",
      "Gute Bemerkung! Kannst du mir ein passendes Alltagsbeispiel dazu geben?",
      "Ausgezeichnet! Was gefällt dir daran am meisten?",
    ];
    final selectedFallback = fallbackPool[
        (DateTime.now().millisecondsSinceEpoch % fallbackPool.length).abs()];

    try {
      final effectiveKey = apiKey;

      if (effectiveKey.isEmpty) {
        debugPrint('[GeminiGermanService] API key empty. Using German conversational fallback.');
        return GeminiGermanResponse(
          fullResponse: selectedFallback,
          speechText: selectedFallback,
          usedModel: 'offline_fallback',
          isFallback: true,
        );
      }

      final systemInstruction =
          '${AppConstants.gretaSystemPrompt}\n'
          'Aktuelles CEFR-Sprachniveau des Lernenden: $cefrLevel.\n'
          'Hauptlernziel des Lernenden: $learningGoal.';

      final contents = <Map<String, dynamic>>[];

      // Keep recent turns for fast latency and strict token budgeting
      final recentHistory =
          history.length > 8 ? history.sublist(history.length - 8) : history;

      String? lastRole;

      for (final turn in recentHistory) {
        final text = turn.germanText.trim();
        if (text.isEmpty) continue;

        final role = turn.isUser ? 'user' : 'model';

        if (contents.isEmpty && role == 'model') {
          contents.add({
            'role': 'user',
            'parts': [
              {'text': 'Hallo Greta! Lass uns auf Deutsch sprechen.'}
            ]
          });
          lastRole = 'user';
        }

        if (role != lastRole) {
          contents.add({
            'role': role,
            'parts': [
              {'text': text}
            ]
          });
          lastRole = role;
        }
      }

      // Append the current user spoken turn
      if (lastRole == 'user' && contents.isNotEmpty) {
        final lastParts = contents.last['parts'] as List<dynamic>;
        lastParts.add({'text': userSpokenText.trim()});
      } else {
        contents.add({
          'role': 'user',
          'parts': [
            {'text': userSpokenText.trim()}
          ]
        });
      }

      // Cascade across candidate models: gemini-2.0-flash -> gemini-2.5-flash-lite -> gemini-1.5-flash
      for (final model in AppConstants.candidateModels) {
        try {
          final uri = Uri.parse(
            '${AppConstants.defaultGeminiEndpoint}/$model:generateContent?key=$effectiveKey',
          );

          final Map<String, dynamic> genConfig = {
            'temperature': 0.7,
            'maxOutputTokens': AppConstants.geminiMaxTokens,
            'thinkingConfig': {
              'thinkingBudget': AppConstants.geminiThinkingBudget,
            },
          };

          final requestBody = jsonEncode({
            'system_instruction': {
              'parts': [
                {'text': systemInstruction}
              ]
            },
            'contents': contents,
            'generationConfig': genConfig,
          });

          final response = await _client
              .post(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'x-goog-api-key': effectiveKey,
                },
                body: requestBody,
              )
              .timeout(Duration(milliseconds: AppConstants.geminiTimeoutMs));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final candidates = data['candidates'] as List<dynamic>?;
            if (candidates != null && candidates.isNotEmpty) {
              final firstCandidate = candidates[0] as Map<String, dynamic>;
              final content =
                  firstCandidate['content'] as Map<String, dynamic>?;
              final parts = content?['parts'] as List<dynamic>?;
              if (parts != null && parts.isNotEmpty) {
                final text = parts
                    .map((p) => p['text'] as String? ?? '')
                    .where((t) => t.isNotEmpty)
                    .join('')
                    .trim();
                if (text.isNotEmpty) {
                  return _parseAiResponse(text, model);
                }
              }
            }
          } else {
            debugPrint(
              '[GeminiGermanService] Model $model returned status ${response.statusCode}. Trying next candidate...',
            );
          }
        } on SocketException catch (e) {
          debugPrint('[GeminiGermanService] SocketException with $model: $e');
        } on TimeoutException catch (e) {
          debugPrint('[GeminiGermanService] TimeoutException with $model: $e');
        } catch (e) {
          debugPrint('[GeminiGermanService] Exception with $model: $e');
        }
      }

      // If all candidate models failed, return graceful German conversational turn
      return GeminiGermanResponse(
        fullResponse: selectedFallback,
        speechText: selectedFallback,
        usedModel: 'graceful_fallback',
        isFallback: true,
      );
    } catch (e, stack) {
      debugPrint('[GeminiGermanService] Top-level fallback triggered: $e\n$stack');
      return GeminiGermanResponse(
        fullResponse: selectedFallback,
        speechText: selectedFallback,
        usedModel: 'offline_fallback',
        isFallback: true,
      );
    }
  }

  GeminiGermanResponse _parseAiResponse(String rawText, String model) {
    // Regex looking for [Korrektur: ...] or [Korrektur : ...]
    final correctionRegex =
        RegExp(r'\[Korrektur\s*:\s*([^\]]+)\]', caseSensitive: false);
    final match = correctionRegex.firstMatch(rawText);

    String? correction;
    String speechText = rawText;

    if (match != null) {
      correction = match.group(1)?.trim();
      speechText = rawText.replaceAll(match.group(0)!, '').trim();
    }

    speechText = speechText.replaceAll(RegExp(r'\n+'), ' ').trim();

    return GeminiGermanResponse(
      fullResponse: rawText,
      speechText: speechText.isEmpty ? rawText : speechText,
      correction: correction,
      usedModel: model,
    );
  }
}
