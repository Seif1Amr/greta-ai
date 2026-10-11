/// Model representing a single conversational exchange turn between Greta and the user.
class ConversationTurn {
  final String id;
  final String germanText;
  final bool isUser;
  final DateTime timestamp;
  final String? correction;
  final String? translation;
  final bool isFallback;

  const ConversationTurn({
    required this.id,
    required this.germanText,
    required this.isUser,
    required this.timestamp,
    this.correction,
    this.translation,
    this.isFallback = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'germanText': germanText,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'correction': correction,
        'translation': translation,
        'isFallback': isFallback,
      };

  factory ConversationTurn.fromJson(Map<String, dynamic> json) =>
      ConversationTurn(
        id: json['id'] as String,
        germanText: json['germanText'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
        correction: json['correction'] as String?,
        translation: json['translation'] as String?,
        isFallback: json['isFallback'] as bool? ?? false,
      );
}
