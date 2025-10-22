
  import 'package:supabase_flutter/supabase_flutter.dart';

class FriendService {
  static final SupabaseClient supabase = Supabase.instance.client;

  /// 🟢 Send friend request (avoid duplicates, triggers handle notifications)
  static Future<void> sendFriendRequest(String friendId) async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) throw Exception("User not logged in");
    if (friendId.isEmpty) throw Exception("Invalid friendId");

    // Check existing requests in either direction
    final existingList = await supabase
        .from('friends')
        .select()
        .or(
          'and(user_id.eq.$currentUserId,friend_id.eq.$friendId),'
          'and(user_id.eq.$friendId,friend_id.eq.$currentUserId)',
        );

    if (existingList.isNotEmpty) {
      final pending = existingList.any((e) => e['status'] == 'pending');
      final accepted = existingList.any((e) => e['status'] == 'accepted');

      if (pending) throw Exception('Request already pending');
      if (accepted) throw Exception('You are already friends');
    }

    // Insert new pending request — triggers handle notifications
    await supabase.from('friends').insert({
      'user_id': currentUserId,
      'friend_id': friendId,
      'status': 'pending',
    });
  }
/// 🟢 Accept friend request (fully reliable)
static Future<void> acceptFriendRequest(String requestId, String fromUserId) async {
  final currentUserId = supabase.auth.currentUser?.id;
  if (currentUserId == null) throw Exception("User not logged in");
  if (fromUserId.isEmpty) throw Exception("Invalid fromUserId");

  // 1️⃣ Update both directions to 'accepted'
  await supabase
      .from('friends')
      .update({'status': 'accepted'})
      .or(
        'and(user_id.eq.$fromUserId,friend_id.eq.$currentUserId),'
        'and(user_id.eq.$currentUserId,friend_id.eq.$fromUserId)',
      );

  // 2️⃣ Ensure reciprocal row exists
  final reciprocal = await supabase
      .from('friends')
      .select()
      .eq('user_id', currentUserId)
      .eq('friend_id', fromUserId)
      .maybeSingle();

  if (reciprocal == null) {
    await supabase.from('friends').insert({
      'user_id': currentUserId,
      'friend_id': fromUserId,
      'status': 'accepted',
    });
  }
}


  /// 🟢 Remove friend (both directions)
  static Future<void> removeFriend(String friendId) async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) throw Exception("User not logged in");
    if (friendId.isEmpty) throw Exception("Invalid friendId");

    await supabase.from('friends').delete().or(
          'and(user_id.eq.$currentUserId,friend_id.eq.$friendId),'
          'and(user_id.eq.$friendId,friend_id.eq.$currentUserId)',
        );
  }

  /// 🟢 Get list of friends for current user
  static Future<List<Map<String, dynamic>>> getFriends() async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return [];

    final res = await supabase
        .from('friends')
        .select('friend_id, users!friends_friend_id_fkey(display_name, avatar_url)')
        .eq('user_id', currentUserId)
        .eq('status', 'accepted');

    return List<Map<String, dynamic>>.from(res);
  }

  /// 🟢 Get incoming friend requests
  static Future<List<Map<String, dynamic>>> getIncomingRequests() async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return [];

    final res = await supabase
        .from('friends')
        .select('id, user_id, status, users!friends_user_id_fkey(display_name, avatar_url)')
        .eq('friend_id', currentUserId)
        .eq('status', 'pending');

    return List<Map<String, dynamic>>.from(res);
  }
}