// import '../models/comment.dart';

// class CommentService {
//   static Future<List<Comment>> fetchComments(String itemId) async {
//     return [
//       Comment(
//         id: '1',
//         itemId: itemId,
//         userId: 'faiza',
//         text: 'This looks great!',
//         createdAt: DateTime.now(),
//       ),
//     ];
//   }
// }
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment.dart';

class SupabaseCommentService {
  static final _client = Supabase.instance.client;

  static Future<List<Comment>> fetchComments(String itemId) async {
    final res = await _client
        .from('comments')
        .select()
        .eq('item_id', itemId)
        .order('created_at', ascending: true);

    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map((r) => Comment.fromMap(r)).toList();
  }

  static Future<void> addComment({required String itemId, required String text}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client.from('comments').insert({
      'item_id': itemId,
      'user_id': user.id,
      'text': text,
    });
  }

  /// Stream comments for an item
  static Stream<List<Comment>> commentsStream(String itemId) {
    return _client
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('item_id', itemId)
        .map((rows) {
      final list = (rows as List).cast<Map<String, dynamic>>();
      list.sort((a, b) {
        final aT = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bT = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aT.compareTo(bT);
      });
      return list.map((r) => Comment.fromMap(r)).toList();
    });
  }
}
