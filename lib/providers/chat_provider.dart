// import 'package:flutter/material.dart';
// import '../models/message.dart';

// class ChatProvider extends ChangeNotifier {
//   final List<Message> _messages = [];

//   List<Message> get messages => _messages;

//   /// 🟢 Send a new chat message (locally + later via Supabase)
//   void sendMessage({
//     required String chatId,
//     required String senderId,
//     required String receiverId,
//     required String text,
//   }) {
//     if (text.trim().isEmpty) return;

//     final newMessage = Message(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       chatId: chatId,
//       senderId: senderId,
//       receiverId: receiverId,
//       text: text.trim(),
//       createdAt: DateTime.now(),
//     );

//     _messages.add(newMessage);
//     notifyListeners();

//     // 🔜 Later we’ll add Supabase insert here
//     // Supabase.instance.client.from('messages').insert(newMessage.toMap());
//   }

//   /// 🟢 Clear messages (optional helper)
//   void clearMessages() {
//     _messages.clear();
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  final List<Message> _messages = [];

  List<Message> get messages => _messages;

  /// 🟢 Send a new chat message (saves to Supabase)
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    // 1️⃣ Create local message instance
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    _messages.add(newMessage);
    notifyListeners();

    // 2️⃣ Send to Supabase
    try {
      await supabase.from('messages').insert({
        'chat_id': chatId, // 👈 make sure this is passed from chat screen
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': text.trim(),
      });
    } on PostgrestException catch (e) {
      debugPrint("❌ Send failed: ${e.message}");
      _messages.remove(newMessage); // rollback locally
      notifyListeners();
      rethrow;
    } catch (e) {
      debugPrint("❌ Unexpected send error: $e");
      _messages.remove(newMessage);
      notifyListeners();
      rethrow;
    }
  }

  /// 🟢 Fetch all messages for a chat
  Future<void> loadMessages(String chatId) async {
    try {
      final res = await supabase
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      _messages
        ..clear()
        ..addAll(res.map((m) => Message.fromMap(m)).toList());
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Error loading messages: $e");
    }
  }

  /// 🧹 Optional helper to clear chat locally
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
