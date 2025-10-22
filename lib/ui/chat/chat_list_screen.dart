
//  import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../../services/friend_service.dart';
// import 'chat_screen.dart';

// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({super.key});

//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }

// class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
//   final _supabase = Supabase.instance.client;
//   late String currentUserId;

//   List<Map<String, dynamic>> _friends = [];
//   List<Map<String, dynamic>> _requests = [];
//   List<Map<String, dynamic>> _otherUsers = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initLoad();
//   }

//   Future<void> _initLoad() async {
//     setState(() => _loading = true);

//     final user = _supabase.auth.currentUser;
//     if (user == null) {
//       await Future.delayed(const Duration(seconds: 1));
//       return _initLoad();
//     }

//     currentUserId = user.id;

//     await _loadFriends();
//     await _loadRequests();
//     await _loadOtherUsers();

//     setState(() => _loading = false);
//   }

//   /// 🔹 Load accepted friends
//   Future<void> _loadFriends() async {
//     try {
//       final res = await _supabase
//           .from('friends')
//           .select(
//             '''
//             id, user_id, friend_id, status,
//             users!friends_user_id_fkey(id, display_name, email, avatar_url),
//             friend_user:friend_id(id, display_name, email, avatar_url)
//             ''',
//           )
//           .or('user_id.eq.$currentUserId,friend_id.eq.$currentUserId')
//           .eq('status', 'accepted');

//       _friends = [];

//       for (var r in res) {
//         final u = (r['user_id'] == currentUserId)
//             ? r['friend_user']
//             : r['users'];
//         if (u != null) _friends.add(Map<String, dynamic>.from(u));
//       }
//     } catch (e) {
//       debugPrint('❌ Load friends error: $e');
//     }
//   }

//   /// 🔹 Load incoming friend requests
//   Future<void> _loadRequests() async {
//     try {
//       final res = await _supabase
//           .from('friends')
//           .select(
//             '''
//             id, user_id, status,
//             users!friends_user_id_fkey(display_name, avatar_url, email)
//             ''',
//           )
//           .eq('friend_id', currentUserId)
//           .eq('status', 'pending');
//       _requests = List<Map<String, dynamic>>.from(res);
//     } catch (e) {
//       debugPrint('❌ Load requests error: $e');
//     }
//   }

//   /// 🔹 Load all other users (not self or friends)
//   Future<void> _loadOtherUsers() async {
//     try {
//       final allUsers = await _supabase
//           .from('users')
//           .select('id, display_name, email, avatar_url')
//           .neq('id', currentUserId)
//           .order('display_name', ascending: true);

//       final friendIds = _friends.map((f) => f['id']).toSet();

//       _otherUsers = List<Map<String, dynamic>>.from(allUsers)
//           .where((u) => !friendIds.contains(u['id']))
//           .toList();
//     } catch (e) {
//       debugPrint('❌ Load other users error: $e');
//     }
//   }

//   /// 🔹 Open chat between current + selected friend
//   Future<void> _openChat(Map<String, dynamic> user) async {
//     final otherUserId = user['id'].toString();
//     final otherName = user['display_name'] ?? 'Unknown';
//     final otherAvatar = user['avatar_url'];

//     try {
//       final existing = await _supabase
//           .from('chats')
//           .select()
//           .or(
//             'and(user1_id.eq.$currentUserId,user2_id.eq.$otherUserId),'
//             'and(user1_id.eq.$otherUserId,user2_id.eq.$currentUserId)',
//           )
//           .limit(1);

//       String chatId;
//       if (existing.isNotEmpty) {
//         chatId = existing.first['id'].toString();
//       } else {
//         final newChat = await _supabase
//             .from('chats')
//             .insert({
//               'user1_id': currentUserId,
//               'user2_id': otherUserId,
//               'last_message': '',
//               'created_at': DateTime.now().toIso8601String(),
//               'updated_at': DateTime.now().toIso8601String(),
//             })
//             .select()
//             .single();
//         chatId = newChat['id'].toString();
//       }

//       if (!mounted) return;
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => ChatScreen(
//             itemId: chatId,
//             itemOwnerId: otherUserId,
//             itemOwnerName: otherName,
//             itemOwnerAvatarUrl: otherAvatar,
//           ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error opening chat: $e')));
//     }
//   }

//   /// 🔹 Send friend request
//   Future<void> _sendFriendRequest(String friendId) async {
//     try {
//       await FriendService.sendFriendRequest(friendId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Friend request sent')),
//       );
//       await _loadRequests();
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('❌ Failed: $e')));
//     }
//   }

//   /// 🔹 Accept friend request
//   Future<void> _acceptRequest(Map<String, dynamic> req) async {
//     final requestId = req['id']?.toString() ?? '';
//     final fromUserId = req['user_id']?.toString() ?? '';
//     if (requestId.isEmpty || fromUserId.isEmpty) return;

//     try {
//       setState(() {
//         _requests.removeWhere((r) => r['id'].toString() == requestId);
//       });

//       await FriendService.acceptFriendRequest(requestId, fromUserId);
//       await _loadFriends();

//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('✅ Friend request accepted!')));
//     } catch (e) {
//       await _loadRequests();
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('❌ Error accepting request: $e')));
//     }
//   }

//   /// 🔹 User Card Widget
//   Widget _buildUserCard(Map<String, dynamic> user,
//       {bool isRequest = false, bool isFriend = false}) {
//     final nested = isRequest ? (user['users'] as Map<String, dynamic>? ?? {}) : user;
//     final displayName = nested['display_name'] ?? 'Unknown User';
//     final email = nested['email'] ?? 'No email';
//     final avatarUrl = nested['avatar_url']?.toString();

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.15),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: ListTile(
//         onTap: isFriend ? () => _openChat(nested) : null,
//         contentPadding: const EdgeInsets.all(12),
//         leading: CircleAvatar(
//           radius: 28,
//           backgroundColor: kGreen.withOpacity(0.1),
//           backgroundImage:
//               (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
//           child: (avatarUrl == null || avatarUrl.isEmpty)
//               ? const Icon(Icons.person, color: kGreen)
//               : null,
//         ),
//         title: Text(
//           displayName,
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//         ),
//         subtitle: Text(email, style: const TextStyle(color: Colors.grey)),
//         trailing: isRequest
//             ? ElevatedButton(
//                 onPressed: () => _acceptRequest(user),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: kGreen,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: const Text('Accept', style: TextStyle(fontSize: 14)),
//               )
//             : isFriend
//                 ? const Icon(Icons.chat, color: kGreen)
//                 : ElevatedButton(
//                     onPressed: () => _sendFriendRequest(user['id']),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kGreen,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: const Text('Add Friend', style: TextStyle(fontSize: 14)),
//                   ),
//       ),
//     );
//   }

//   Widget _buildTabContent(List<Map<String, dynamic>> list,
//       {bool isRequest = false, bool isFriend = false}) {
//     if (list.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Text('No data found.'),
//         ),
//       );
//     }
//     return RefreshIndicator(
//       onRefresh: _initLoad,
//       child: ListView.builder(
//         itemCount: list.length,
//         itemBuilder: (ctx, i) =>
//             _buildUserCard(list[i], isRequest: isRequest, isFriend: isFriend),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         backgroundColor: kBg,
//         appBar: AppBar(
//           backgroundColor: kGreen,
//           elevation: 0,
//           titleSpacing: 16,
//           title: const Text(
//             'Friends & Chats',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           bottom: const TabBar(
//             labelColor: Colors.white,
//             indicatorColor: Colors.white,
//             tabs: [
//               Tab(text: 'Requests'),
//               Tab(text: 'Friends'),
//               Tab(text: 'All Users'),
//             ],
//           ),
//         ),
//         body: _loading
//             ? const Center(child: CircularProgressIndicator())
//             : TabBarView(
//                 children: [
//                   _buildTabContent(_requests, isRequest: true),
//                   _buildTabContent(_friends, isFriend: true),
//                   _buildTabContent(_otherUsers),
//                 ],
//               ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import '../../services/friend_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late String currentUserId;

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _otherUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    setState(() => _loading = true);

    final user = _supabase.auth.currentUser;
    if (user == null) {
      await Future.delayed(const Duration(seconds: 1));
      return _initLoad();
    }

    currentUserId = user.id;

    await _loadFriends();
    await _loadRequests();
    await _loadOtherUsers();

    setState(() => _loading = false);
  }

  /// 🔹 Load accepted friends
  Future<void> _loadFriends() async {
    try {
      final res = await _supabase
          .from('friends')
          .select('''
            id, user_id, friend_id, status,
            users!friends_user_id_fkey(id, display_name, email, avatar_url),
            friend_user:friend_id(id, display_name, email, avatar_url)
          ''')
          .or('user_id.eq.$currentUserId,friend_id.eq.$currentUserId')
          .eq('status', 'accepted');

      _friends = [];

      for (var r in res) {
        final u =
            (r['user_id'] == currentUserId) ? r['friend_user'] : r['users'];
        if (u != null) _friends.add(Map<String, dynamic>.from(u));
      }
    } catch (e) {
      debugPrint('❌ Load friends error: $e');
    }
  }

  /// 🔹 Load incoming friend requests
  Future<void> _loadRequests() async {
    try {
      final res = await _supabase
          .from('friends')
          .select('''
            id, user_id, status,
            users!friends_user_id_fkey(display_name, avatar_url, email)
          ''')
          .eq('friend_id', currentUserId)
          .eq('status', 'pending');
      _requests = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('❌ Load requests error: $e');
    }
  }

  /// 🔹 Load all other users (not self or friends)
  Future<void> _loadOtherUsers() async {
    try {
      final allUsers = await _supabase
          .from('users')
          .select('id, display_name, email, avatar_url')
          .neq('id', currentUserId)
          .order('display_name', ascending: true);

      final friendIds = _friends.map((f) => f['id']).toSet();

      _otherUsers = List<Map<String, dynamic>>.from(allUsers)
          .where((u) => !friendIds.contains(u['id']))
          .toList();
    } catch (e) {
      debugPrint('❌ Load other users error: $e');
    }
  }

  /// 🔹 Open chat between current + selected friend
  Future<void> _openChat(Map<String, dynamic> user) async {
    final otherUserId = user['id'].toString();
    final otherName = user['display_name'] ?? 'Unknown';
    final otherAvatar = user['avatar_url'];

    try {
      final existing = await _supabase
          .from('chats')
          .select()
          .or(
            'and(user1_id.eq.$currentUserId,user2_id.eq.$otherUserId),'
            'and(user1_id.eq.$otherUserId,user2_id.eq.$currentUserId)',
          )
          .limit(1);

      String chatId;
      if (existing.isNotEmpty) {
        chatId = existing.first['id'].toString();
      } else {
        final newChat = await _supabase.from('chats').insert({
          'user1_id': currentUserId,
          'user2_id': otherUserId,
          'last_message': '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).select().single();

        chatId = newChat['id'].toString();
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            itemId: chatId,
            itemOwnerId: otherUserId,
            itemOwnerName: otherName,
            itemOwnerAvatarUrl: otherAvatar,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error opening chat: $e')));
    }
  }

  /// 🔹 Send friend request
  Future<void> _sendFriendRequest(String friendId) async {
    try {
      await FriendService.sendFriendRequest(friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Friend request sent')),
      );
      await _loadRequests();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Failed: $e')));
    }
  }

  /// ✅ FIXED — Accept friend request
  Future<void> _acceptRequest(Map<String, dynamic> req) async {
    final requestId = req['id']?.toString() ?? '';
    final fromUserId = req['user_id']?.toString() ?? '';
    if (requestId.isEmpty || fromUserId.isEmpty) return;

    try {
      // ✅ Wait for backend update first
      await FriendService.acceptFriendRequest(requestId, fromUserId);

      // ✅ Then update UI locally
      setState(() {
        _requests.removeWhere((r) => r['id'].toString() == requestId);
      });

      // ✅ Reload friends to update the Friends tab
      await _loadFriends();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Friend request accepted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Error accepting request: $e')));
    }
  }

  /// 🔹 User Card Widget
  Widget _buildUserCard(Map<String, dynamic> user,
      {bool isRequest = false, bool isFriend = false}) {
    final nested =
        isRequest ? (user['users'] as Map<String, dynamic>? ?? {}) : user;
    final displayName = nested['display_name'] ?? 'Unknown User';
    final email = nested['email'] ?? 'No email';
    final avatarUrl = nested['avatar_url']?.toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: isFriend ? () => _openChat(nested) : null,
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: kGreen.withOpacity(0.1),
          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
              ? NetworkImage(avatarUrl)
              : null,
          child: (avatarUrl == null || avatarUrl.isEmpty)
              ? const Icon(Icons.person, color: kGreen)
              : null,
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(email, style: const TextStyle(color: Colors.grey)),
        trailing: isRequest
            ? ElevatedButton(
                onPressed: () => _acceptRequest(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 14)),
              )
            : isFriend
                ? const Icon(Icons.chat, color: kGreen)
                : ElevatedButton(
                    onPressed: () => _sendFriendRequest(user['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Friend',
                        style: TextStyle(fontSize: 14)),
                  ),
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, dynamic>> list,
      {bool isRequest = false, bool isFriend = false}) {
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No data found.'),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _initLoad,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (ctx, i) =>
            _buildUserCard(list[i], isRequest: isRequest, isFriend: isFriend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kGreen,
          elevation: 0,
          titleSpacing: 16,
          title: const Text(
            'Friends & Chats',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'Friends'),
              Tab(text: 'All Users'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildTabContent(_requests, isRequest: true),
                  _buildTabContent(_friends, isFriend: true),
                  _buildTabContent(_otherUsers),
                ],
              ),
      ),
    );
  }
}
