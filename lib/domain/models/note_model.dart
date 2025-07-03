class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String userId;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.userId,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? timestamp,
    String? userId,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['userId'] ?? '',
    );
  }
}
