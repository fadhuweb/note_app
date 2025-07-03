class NoteModel {
  final String id;
  final String text;
  final DateTime timestamp;
  final String userId;

  NoteModel({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['userId'] ?? '',
    );
  }
}
