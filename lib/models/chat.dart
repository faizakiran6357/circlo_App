class Chat {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? lastMessage;
  final DateTime? updatedAt;

  Chat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.lastMessage,
    this.updatedAt,
  });
}
