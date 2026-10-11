import 'dart:math' as math;

/// Utility for calculating similarity between expected German text and user spoken transcript.
class TextSimilarity {
  TextSimilarity._();

  /// Calculates a combined character & token similarity score between 0.0 and 1.0.
  static double calculateSimilarity(String expected, String spoken) {
    final cleanExpected = _cleanGermanText(expected);
    final cleanSpoken = _cleanGermanText(spoken);

    if (cleanExpected.isEmpty && cleanSpoken.isEmpty) return 1.0;
    if (cleanExpected.isEmpty || cleanSpoken.isEmpty) return 0.0;
    if (cleanExpected == cleanSpoken) return 1.0;

    // Substring / full match check
    if (cleanSpoken.contains(cleanExpected) || cleanExpected.contains(cleanSpoken)) {
      final ratio = math.min(cleanExpected.length, cleanSpoken.length) /
          math.max(cleanExpected.length, cleanSpoken.length);
      if (ratio > 0.7) return math.max(0.85, ratio);
    }

    final charScore = _levenshteinSimilarity(cleanExpected, cleanSpoken);
    final tokenScore = _tokenOverlapSimilarity(cleanExpected, cleanSpoken);

    // Weighted blend: 60% character Levenshtein + 40% token overlap
    final finalScore = (charScore * 0.6) + (tokenScore * 0.4);
    return finalScore.clamp(0.0, 1.0);
  }

  static String _cleanGermanText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[.,\/#!$%\^&\*;:{}=\-_`~()?"«»„“]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static double _levenshteinSimilarity(String s1, String s2) {
    final maxLen = math.max(s1.length, s2.length);
    if (maxLen == 0) return 1.0;

    final distance = _levenshteinDistance(s1, s2);
    return (1.0 - (distance / maxLen)).clamp(0.0, 1.0);
  }

  static int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;
    List<int> v0 = List<int>.generate(n + 1, (i) => i);
    List<int> v1 = List<int>.filled(n + 1, 0);

    for (int i = 0; i < m; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < n; j++) {
        final cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = math.min(
          v1[j] + 1,
          math.min(v0[j + 1] + 1, v0[j] + cost),
        );
      }
      for (int j = 0; j <= n; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[n];
  }

  static double _tokenOverlapSimilarity(String s1, String s2) {
    final tokens1 = s1.split(' ').where((t) => t.isNotEmpty).toSet();
    final tokens2 = s2.split(' ').where((t) => t.isNotEmpty).toSet();

    if (tokens1.isEmpty || tokens2.isEmpty) return 0.0;

    final intersection = tokens1.intersection(tokens2).length;
    final union = tokens1.union(tokens2).length;

    return (intersection / union).clamp(0.0, 1.0);
  }
}
