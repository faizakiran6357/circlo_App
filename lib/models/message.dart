
class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> m) {
    return Message(
      id: m['id']?.toString() ?? '',
      chatId: m['chat_id']?.toString() ?? '',
      senderId: m['sender_id']?.toString() ?? '',
      receiverId: m['receiver_id']?.toString() ?? '',
      text: m['message']?.toString() ?? '',
      createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now(),
    );
  }
}
