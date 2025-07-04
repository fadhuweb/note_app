class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String userId;
  final String tag; // ✅ NEW: tag field

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.userId,
    required this.tag, // ✅
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? timestamp,
    String? userId,
    String? tag, // ✅
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      tag: tag ?? this.tag, // ✅
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'tag': tag, // ✅
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['userId'] ?? '',
      tag: map['tag'] ?? 'General', // ✅ default tag
    );
  }
}
