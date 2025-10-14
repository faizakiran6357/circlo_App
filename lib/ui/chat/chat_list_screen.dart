// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import '../../utils/app_theme.dart';
// // import 'chat_screen.dart';

// // class ChatListScreen extends StatefulWidget {
// //   const ChatListScreen({super.key});

// //   @override
// //   State<ChatListScreen> createState() => _ChatListScreenState();
// // }

// // class _ChatListScreenState extends State<ChatListScreen> {
// //   final _supabase = Supabase.instance.client;
// //   late final String currentUserId;
// //   List<Map<String, dynamic>> _users = [];
// //   bool _loading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     currentUserId = _supabase.auth.currentUser?.id ?? '';
// //     _loadUsers();
// //   }

// //   Future<void> _loadUsers() async {
// //     try {
// //       final res = await _supabase
// //           .from('users')
// //           .select('id, display_name, avatar_url')
// //           .neq('id', currentUserId); // exclude yourself
// //       setState(() {
// //         _users = List<Map<String, dynamic>>.from(res);
// //         _loading = false;
// //       });
// //     } catch (e) {
// //       debugPrint('❌ Failed to load users: $e');
// //       setState(() => _loading = false);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Chats'),
// //         backgroundColor: kGreen,
// //       ),
// //       body: _loading
// //           ? const Center(child: CircularProgressIndicator(color: kTeal))
// //           : _users.isEmpty
// //               ? const Center(child: Text('No other users yet'))
// //               : ListView.builder(
// //                   itemCount: _users.length,
// //                   itemBuilder: (context, index) {
// //                     final user = _users[index];
// //                     return ListTile(
// //                       leading: CircleAvatar(
// //                         backgroundImage: user['avatar_url'] != null &&
// //                                 user['avatar_url'].toString().isNotEmpty
// //                             ? NetworkImage(user['avatar_url'])
// //                             : null,
// //                         child: (user['avatar_url'] == null ||
// //                                 user['avatar_url'].toString().isEmpty)
// //                             ? const Icon(Icons.person)
// //                             : null,
// //                       ),
// //                       title: Text(user['display_name'] ?? 'Unknown'),
// //                       subtitle:
// //                           const Text('Tap to chat', style: TextStyle(color: Colors.grey)),
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (_) => ChatScreen(
// //                               // 👇 required params
// //                               itemId: 'dummy_item_${user['id']}', // temp dummy id
// //                               itemOwnerId: user['id'],
// //                               itemOwnerName: user['display_name'] ?? '',
// //                               itemOwnerAvatarUrl: user['avatar_url'],
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                     );
// //                   },
// //                 ),
// //     );
// //   }
// // }
// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import '../../utils/app_theme.dart';
// // import 'chat_screen.dart';

// // class ChatListScreen extends StatefulWidget {
// //   const ChatListScreen({super.key});

// //   @override
// //   State<ChatListScreen> createState() => _ChatListScreenState();
// // }

// // class _ChatListScreenState extends State<ChatListScreen> {
// //   final _supabase = Supabase.instance.client;
// //   late final String currentUserId;
// //   List<Map<String, dynamic>> _users = [];
// //   bool _loading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     currentUserId = _supabase.auth.currentUser?.id ?? '';
// //     _loadUsers();
// //   }

// //   // 🔹 Fetch all users except the current one
// //   Future<void> _loadUsers() async {
// //     try {
// //       final res = await _supabase
// //           .from('users')
// //           .select('id, display_name, avatar_url')
// //           .neq('id', currentUserId);

// //       setState(() {
// //         _users = List<Map<String, dynamic>>.from(res);
// //         _loading = false;
// //       });
// //     } catch (e) {
// //       debugPrint('❌ Load users error: $e');
// //       setState(() => _loading = false);
// //     }
// //   }

// //   // 🔹 Create or open chat and navigate to ChatScreen
// //   Future<void> _openChat(Map<String, dynamic> user) async {
// //     final otherUserId = user['id'].toString();
// //     final otherName = user['display_name'] ?? 'Unknown';
// //     final otherAvatar = user['avatar_url'];

// //     try {
// //       final existing = await _supabase
// //           .from('chats')
// //           .select()
// //           .or(
// //               'and(user1_id.eq.$currentUserId,user2_id.eq.$otherUserId),and(user1_id.eq.$otherUserId,user2_id.eq.$currentUserId)')
// //           .limit(1);

// //       String chatId;
// //       if (existing.isNotEmpty) {
// //         chatId = existing.first['id'].toString();
// //       } else {
// //         final newChat = await _supabase
// //             .from('chats')
// //             .insert({
// //               'user1_id': currentUserId,
// //               'user2_id': otherUserId,
// //               'last_message': '',
// //               'created_at': DateTime.now().toIso8601String(),
// //               'updated_at': DateTime.now().toIso8601String(),
// //             })
// //             .select()
// //             .single();
// //         chatId = newChat['id'].toString();
// //       }

// //       // Navigate to chat
// //       if (!mounted) return;
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (_) => ChatScreen(
// //             itemId: chatId, // Chat ID can act as itemId here
// //             itemOwnerId: otherUserId,
// //             itemOwnerName: otherName,
// //             itemOwnerAvatarUrl: otherAvatar,
// //           ),
// //         ),
// //       );
// //     } catch (e) {
// //       debugPrint('❌ Open chat error: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error opening chat: $e')),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Chats'),
// //         backgroundColor: kGreen,
// //       ),
// //       body: _loading
// //           ? const Center(child: CircularProgressIndicator())
// //           : _users.isEmpty
// //               ? const Center(child: Text('No users found'))
// //               : ListView.builder(
// //                   itemCount: _users.length,
// //                   itemBuilder: (context, i) {
// //                     final user = _users[i];
// //                     return ListTile(
// //                       leading: CircleAvatar(
// //                         backgroundImage: user['avatar_url'] != null &&
// //                                 user['avatar_url'].toString().isNotEmpty
// //                             ? NetworkImage(user['avatar_url'])
// //                             : null,
// //                         child: (user['avatar_url'] == null ||
// //                                 user['avatar_url'].toString().isEmpty)
// //                             ? const Icon(Icons.person)
// //                             : null,
// //                       ),
// //                       title: Text(user['display_name'] ?? 'Unknown'),
// //                       subtitle: const Text('Tap to chat'),
// //                       onTap: () => _openChat(user),
// //                     );
// //                   },
// //                 ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import 'chat_screen.dart';

// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({super.key});

//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }

// class _ChatListScreenState extends State<ChatListScreen> {
//   final _supabase = Supabase.instance.client;
//   late final String currentUserId;
//   List<Map<String, dynamic>> _users = [];
//   bool _loading = true;

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   currentUserId = _supabase.auth.currentUser?.id ?? '';
//   //   _loadUsers();
//   // }
//   @override
// void initState() {
//   super.initState();
//   currentUserId = _supabase.auth.currentUser?.id ?? '';
//   debugPrint('👤 Current user id: $currentUserId');
//   _loadUsers();
// }


//   /// 🔹 Load all users except the logged-in one
//   Future<void> _loadUsers() async {
//     try {
//       final res = await _supabase
//           .from('users')
//           .select('id, display_name, avatar_url')
//           .neq('id', currentUserId)
//           .order('display_name', ascending: true);

//       setState(() {
//         _users = List<Map<String, dynamic>>.from(res);
//         _loading = false;
//       });
//     } catch (e) {
//       debugPrint('❌ Load users error: $e');
//       setState(() => _loading = false);
//     }
    
//   }

//   /// 🔹 Create or open existing chat between current user and selected user
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
//             itemId: chatId, // using chat id
//             itemOwnerId: otherUserId,
//             itemOwnerName: otherName,
//             itemOwnerAvatarUrl: otherAvatar,
//           ),
//         ),
//       );
//     } catch (e) {
//       debugPrint('❌ Open chat error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error opening chat: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chats'),
//         backgroundColor: kGreen,
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _users.isEmpty
//               ? const Center(child: Text('No users found'))
//               : RefreshIndicator(
//                   onRefresh: _loadUsers,
//                   child: ListView.builder(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     itemCount: _users.length,
//                     itemBuilder: (context, i) {
//                       final user = _users[i];
//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: (user['avatar_url'] != null &&
//                                   user['avatar_url'].toString().isNotEmpty)
//                               ? NetworkImage(user['avatar_url'])
//                               : null,
//                           child: (user['avatar_url'] == null ||
//                                   user['avatar_url'].toString().isEmpty)
//                               ? const Icon(Icons.person)
//                               : null,
//                         ),
//                         title: Text(user['display_name'] ?? 'Unknown User'),
//                         subtitle: const Text('Tap to chat'),
//                         onTap: () => _openChat(user),
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }
// }
 import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _supabase = Supabase.instance.client;
  late final String currentUserId;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
void initState() {
  super.initState();
  _initLoad();
}

Future<void> _initLoad() async {
  await Future.delayed(const Duration(milliseconds: 500)); // wait auth init
  final user = _supabase.auth.currentUser;
  if (user == null) {
    debugPrint("⚠️ No logged-in user found yet, retrying...");
    Future.delayed(const Duration(seconds: 1), _initLoad);
    return;
  }
  currentUserId = user.id;
  debugPrint("👤 Current user id: $currentUserId");
  _loadUsers();
}

Future<void> _loadUsers() async {
  debugPrint("📡 Loading users from Supabase...");
  try {
    final res = await _supabase
        .from('users')
        .select('id, display_name, avatar_url')
        .neq('id', currentUserId)
        .order('display_name', ascending: true);

    debugPrint("👥 Loaded ${res.length} users");
    setState(() {
      _users = List<Map<String, dynamic>>.from(res);
      _loading = false;
    });
  } catch (e) {
    debugPrint('❌ Load users error: $e');
    setState(() => _loading = false);
  }
}


  /// 🔹 Create or open existing chat between current user and selected user
  Future<void> _openChat(Map<String, dynamic> user) async {
    final otherUserId = user['id'].toString();
    final otherName = user['display_name'] ?? 'Unknown User';
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
        debugPrint('💬 Existing chat found: $chatId');
      } else {
        final newChat = await _supabase
            .from('chats')
            .insert({
              'user1_id': currentUserId,
              'user2_id': otherUserId,
              'last_message': '',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
        chatId = newChat['id'].toString();
        debugPrint('🆕 New chat created: $chatId');
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            itemId: chatId, // using chat id
            itemOwnerId: otherUserId,
            itemOwnerName: otherName,
            itemOwnerAvatarUrl: otherAvatar,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Open chat error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening chat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: kGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(
                  child: Text(
                    'No users found.\nMake sure other users are signed up.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _users.length,
                    itemBuilder: (context, i) {
                      final user = _users[i];
                      final displayName = user['display_name'] ?? 'Unknown User';
                      final avatarUrl = user['avatar_url']?.toString();

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (avatarUrl != null &&
                                  avatarUrl.isNotEmpty)
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: (avatarUrl == null || avatarUrl.isEmpty)
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                        title: Text(displayName),
                        subtitle: const Text('Tap to chat'),
                        onTap: () => _openChat(user),
                      );
                    },
                  ),
                ),
    );
  }
}
