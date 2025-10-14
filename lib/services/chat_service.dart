// import '../models/chat.dart';
// import '../models/message.dart';

// class ChatService {
//   static Future<List<Chat>> fetchChats() async {
//     return [
//       Chat(
//         id: '1',
//         user1Id: 'faiza',
//         user2Id: 'aniqa',
//         lastMessage: 'Hey, still available?',
//         updatedAt: DateTime.now(),
//       ),
//     ];
//   }

//   static Future<List<Message>> fetchMessages(String chatId) async {
//     return [
//       Message(
//         id: '1',
//         chatId: chatId,
//         senderId: 'faiza',
//         text: 'Hello!',
//         createdAt: DateTime.now(),
//       ),
//       Message(
//         id: '2',
//         chatId: chatId,
//         senderId: 'aniqa',
//         text: 'Hi! How are you?',
//         createdAt: DateTime.now(),
//       ),
//     ];
//   }
// }
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat.dart';
import '../models/message.dart';

class SupabaseChatService {
  static final _client = Supabase.instance.client;

  /// Find existing chat between two users or create a new chat
  /// Returns the chat id
  static Future<String> createOrGetChat(String otherUserId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final myId = currentUser.id;

    // Try to find existing chat (either ordering)
    final res = await _client
        .from('chats')
        .select()
        .or('and(user1_id.eq.$myId,user2_id.eq.$otherUserId),and(user1_id.eq.$otherUserId,user2_id.eq.$myId)')
        .maybeSingle();

    if (res != null) {
      return res['id'].toString();
    }

    // No chat - create new
    final insert = await _client.from('chats').insert({
      'user1_id': myId,
      'user2_id': otherUserId,
      'last_message': null
    }).select().maybeSingle();

    if (insert == null) throw Exception('Failed to create chat');
    return insert['id'].toString();
  }

  /// Send a message into a chat. If chatId is null, it will create or get chat
  static Future<void> sendMessage({
    String? chatId,
    required String otherUserId,
    required String text,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');
    final myId = currentUser.id;

    String targetChatId = chatId ?? await createOrGetChat(otherUserId);

    await _client.from('messages').insert({
      'chat_id': targetChatId,
      'sender_id': myId,
      'receiver_id': otherUserId,
      'message': text,
    });
    // trigger will update chats.last_message & updated_at
  }

  /// Fetch messages for a chat (paginated)
  static Future<List<Message>> fetchMessages(String chatId, {int limit = 100, int offset = 0}) async {
    final res = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .limit(limit)
        .range(offset, offset + limit - 1);

    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map((r) => Message.fromMap(r)).toList();
  }

  /// Stream messages for a single chat (server-side filtered)
  /// Usage: supabase.from('messages').select().eq('chat_id', chatId).stream(primaryKey: ['id'])
  static Stream<List<Message>> messagesStream(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .map((rows) {
      final list = (rows as List).cast<Map<String, dynamic>>();
      list.sort((a, b) {
        final aT = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bT = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aT.compareTo(bT);
      });
      return list.map((r) => Message.fromMap(r)).toList();
    });
  }
}
