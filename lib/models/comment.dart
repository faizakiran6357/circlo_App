
class Comment {
  final String id;
  final String itemId;
  final String userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> m) {
    return Comment(
      id: m['id']?.toString() ?? '',
      itemId: m['item_id']?.toString() ?? '',
      userId: m['user_id']?.toString() ?? '',
      text: m['text']?.toString() ?? '',
      createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now(),
    );
  }
}
