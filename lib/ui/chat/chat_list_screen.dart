
//  import 'package:flutter/material.dart';
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

//   @override
// void initState() {
//   super.initState();
//   _initLoad();
// }

// Future<void> _initLoad() async {
//   await Future.delayed(const Duration(milliseconds: 500)); // wait auth init
//   final user = _supabase.auth.currentUser;
//   if (user == null) {
//     debugPrint("⚠️ No logged-in user found yet, retrying...");
//     Future.delayed(const Duration(seconds: 1), _initLoad);
//     return;
//   }
//   currentUserId = user.id;
//   debugPrint("👤 Current user id: $currentUserId");
//   _loadUsers();
// }

// Future<void> _loadUsers() async {
//   debugPrint("📡 Loading users from Supabase...");
//   try {
//     final res = await _supabase
//         .from('users')
//         .select('id, display_name, avatar_url')
//         .neq('id', currentUserId)
//         .order('display_name', ascending: true);

//     debugPrint("👥 Loaded ${res.length} users");
//     setState(() {
//       _users = List<Map<String, dynamic>>.from(res);
//       _loading = false;
//     });
//   } catch (e) {
//     debugPrint('❌ Load users error: $e');
//     setState(() => _loading = false);
//   }
// }


//   /// 🔹 Create or open existing chat between current user and selected user
//   Future<void> _openChat(Map<String, dynamic> user) async {
//     final otherUserId = user['id'].toString();
//     final otherName = user['display_name'] ?? 'Unknown User';
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
//         debugPrint('💬 Existing chat found: $chatId');
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
//         debugPrint('🆕 New chat created: $chatId');
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
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadUsers,
//           )
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _users.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No users found.\nMake sure other users are signed up.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadUsers,
//                   child: ListView.builder(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     itemCount: _users.length,
//                     itemBuilder: (context, i) {
//                       final user = _users[i];
//                       final displayName = user['display_name'] ?? 'Unknown User';
//                       final avatarUrl = user['avatar_url']?.toString();

//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.grey[200],
//                           backgroundImage: (avatarUrl != null &&
//                                   avatarUrl.isNotEmpty)
//                               ? NetworkImage(avatarUrl)
//                               : null,
//                           child: (avatarUrl == null || avatarUrl.isEmpty)
//                               ? const Icon(Icons.person, color: Colors.grey)
//                               : null,
//                         ),
//                         title: Text(displayName),
//                         subtitle: const Text('Tap to chat'),
//                         onTap: () => _openChat(user),
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../../services/friend_service.dart';
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

//   @override
//   void initState() {
//     super.initState();
//     _initLoad();
//   }

//   Future<void> _initLoad() async {
//     await Future.delayed(const Duration(milliseconds: 500)); // wait auth init
//     final user = _supabase.auth.currentUser;
//     if (user == null) {
//       debugPrint("⚠️ No logged-in user found yet, retrying...");
//       Future.delayed(const Duration(seconds: 1), _initLoad);
//       return;
//     }
//     currentUserId = user.id;
//     debugPrint("👤 Current user id: $currentUserId");
//     _loadUsers();
//   }

//   Future<void> _loadUsers() async {
//     debugPrint("📡 Loading users from Supabase...");
//     try {
//       final res = await _supabase
//           .from('users')
//           .select('id, display_name, avatar_url')
//           .neq('id', currentUserId)
//           .order('display_name', ascending: true);

//       debugPrint("👥 Loaded ${res.length} users");
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
//     final otherName = user['display_name'] ?? 'Unknown User';
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
//         debugPrint('💬 Existing chat found: $chatId');
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
//         debugPrint('🆕 New chat created: $chatId');
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
//       debugPrint('❌ Open chat error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error opening chat: $e')),
//       );
//     }
//   }

//   /// 🔹 Send friend request
//   Future<void> _sendFriendRequest(String friendId) async {
//     try {
//       await FriendService.sendFriendRequest(friendId);
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Friend request sent')),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to send friend request: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chats'),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadUsers,
//           )
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _users.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No users found.\nMake sure other users are signed up.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadUsers,
//                   child: ListView.builder(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     itemCount: _users.length,
//                     itemBuilder: (context, i) {
//                       final user = _users[i];
//                       final displayName = user['display_name'] ?? 'Unknown User';
//                       final avatarUrl = user['avatar_url']?.toString();

//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.grey[200],
//                           backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
//                               ? NetworkImage(avatarUrl)
//                               : null,
//                           child: (avatarUrl == null || avatarUrl.isEmpty)
//                               ? const Icon(Icons.person, color: Colors.grey)
//                               : null,
//                         ),
//                         title: Text(displayName),
//                         subtitle: const Text('Tap to chat'),
//                         trailing: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             minimumSize: const Size(80, 36),
//                           ),
//                           onPressed: () => _sendFriendRequest(user['id']),
//                           child: const Text('Add Friend'),
//                         ),
//                         onTap: () => _openChat(user),
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../../services/friend_service.dart';
// import 'chat_screen.dart';

// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({super.key});

//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }

// class _ChatListScreenState extends State<ChatListScreen> {
//   final _supabase = Supabase.instance.client;
//   late String currentUserId;

//   List<Map<String, dynamic>> _users = [];
//   List<Map<String, dynamic>> _requests = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initLoad();
//   }

//   // 🔹 Initialize: load users + requests
//   Future<void> _initLoad() async {
//     setState(() => _loading = true);
//     await Future.delayed(const Duration(milliseconds: 500)); // wait for auth init

//     final user = _supabase.auth.currentUser;
//     if (user == null) {
//       debugPrint("⚠️ No logged-in user found yet, retrying...");
//       Future.delayed(const Duration(seconds: 1), _initLoad);
//       return;
//     }

//     currentUserId = user.id;
//     debugPrint("👤 Current user id: $currentUserId");

//     await _loadUsers();
//     await _loadRequests();

//     setState(() => _loading = false);
//   }

//   // 🔹 Load all other users
//   Future<void> _loadUsers() async {
//     debugPrint("📡 Loading users...");
//     try {
//       final res = await _supabase
//           .from('users')
//           .select('id, display_name, avatar_url')
//           .neq('id', currentUserId)
//           .order('display_name', ascending: true);

//       setState(() {
//         _users = List<Map<String, dynamic>>.from(res);
//       });
//     } catch (e) {
//       debugPrint('❌ Load users error: $e');
//     }
//   }

//   // 🔹 Load friend requests where current user is the receiver
//   Future<void> _loadRequests() async {
//     try {
//       final res = await _supabase
//           .from('friends')
//           .select('id, user_id, status, users!friends_user_id_fkey(display_name, avatar_url)')
//           .eq('friend_id', currentUserId)
//           .eq('status', 'pending');

//       setState(() {
//         _requests = List<Map<String, dynamic>>.from(res);
//       });
//     } catch (e) {
//       debugPrint('❌ Load requests error: $e');
//     }
//   }

//   // 🔹 Open or create chat
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
//         debugPrint('💬 Existing chat found: $chatId');
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
//         debugPrint('🆕 New chat created: $chatId');
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
//       debugPrint('❌ Open chat error: $e');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error opening chat: $e')));
//     }
//   }

//   // 🔹 Send friend request
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

//   // 🔹 Accept friend request
//   Future<void> _acceptRequest(Map<String, dynamic> req) async {
//     try {
//       final requestId = req['id'].toString();
//       final fromUserId = req['user_id'].toString();
//       await FriendService.acceptFriendRequest(requestId, fromUserId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Friend request accepted!')),
//       );
//       await _loadRequests();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Error accepting request: $e')),
//       );
//     }
//   }

//   // 🔹 Build a user tile
//   Widget _buildUserTile(Map<String, dynamic> user) {
//     final displayName = user['display_name'] ?? 'Unknown User';
//     final avatarUrl = user['avatar_url']?.toString();

//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.grey[200],
//         backgroundImage:
//             (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
//         child: (avatarUrl == null || avatarUrl.isEmpty)
//             ? const Icon(Icons.person, color: Colors.grey)
//             : null,
//       ),
//       title: Text(displayName),
//       trailing: ElevatedButton(
//         onPressed: () => _sendFriendRequest(user['id']),
//         style: ElevatedButton.styleFrom(backgroundColor: kGreen),
//         child: const Text('Add Friend'),
//       ),
//       onTap: () => _openChat(user),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chats'),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(icon: const Icon(Icons.refresh), onPressed: _initLoad)
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _initLoad,
//               child: ListView(
//                 children: [
//                   if (_requests.isNotEmpty) ...[
//                     const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text('🧾 Friend Requests',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16)),
//                     ),
//                     ..._requests.map((req) {
//                       final sender = req['users'] ?? {};
//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.grey[200],
//                           backgroundImage: sender['avatar_url'] != null
//                               ? NetworkImage(sender['avatar_url'])
//                               : null,
//                           child: sender['avatar_url'] == null
//                               ? const Icon(Icons.person)
//                               : null,
//                         ),
//                         title: Text(sender['display_name'] ?? 'Unknown'),
//                         subtitle: const Text('sent you a friend request'),
//                         trailing: ElevatedButton(
//                           onPressed: () => _acceptRequest(req),
//                           style: ElevatedButton.styleFrom(backgroundColor: kGreen),
//                           child: const Text('Accept'),
//                         ),
//                       );
//                     }),
//                     const Divider(),
//                   ],
//                   if (_users.isNotEmpty)
//                     ..._users.map((u) => _buildUserTile(u))
//                   else
//                     const Padding(
//                       padding: EdgeInsets.all(20),
//                       child: Center(
//                         child: Text(
//                           'No users found.\nMake sure others are signed up.',
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
// import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../../services/friend_service.dart';
// import 'chat_screen.dart';

// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({super.key});

//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }

// class _ChatListScreenState extends State<ChatListScreen> {
//   final _supabase = Supabase.instance.client;
//   late String currentUserId;

//   List<Map<String, dynamic>> _users = [];
//   List<Map<String, dynamic>> _requests = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initLoad();
//   }

//   // 🔹 Initialize: load users + requests
//   Future<void> _initLoad() async {
//     setState(() => _loading = true);
//     await Future.delayed(const Duration(milliseconds: 500)); // wait for auth init

//     final user = _supabase.auth.currentUser;
//     if (user == null) {
//       debugPrint("⚠️ No logged-in user found yet, retrying...");
//       Future.delayed(const Duration(seconds: 1), _initLoad);
//       return;
//     }

//     currentUserId = user.id;
//     debugPrint("👤 Current user id: $currentUserId");

//     await _loadUsers();
//     await _loadRequests();

//     setState(() => _loading = false);
//   }

//   // 🔹 Load all other users (with email)
//   Future<void> _loadUsers() async {
//     debugPrint("📡 Loading users...");
//     try {
//       final res = await _supabase
//           .from('users')
//           .select('id, display_name, email, avatar_url')
//           .neq('id', currentUserId)
//           .order('display_name', ascending: true);

//       setState(() {
//         _users = List<Map<String, dynamic>>.from(res);
//       });
//     } catch (e) {
//       debugPrint('❌ Load users error: $e');
//     }
//   }

//   // 🔹 Load friend requests where current user is the receiver
//   Future<void> _loadRequests() async {
//     try {
//       final res = await _supabase
//           .from('friends')
//           .select(
//               'id, user_id, status, users!friends_user_id_fkey(display_name, avatar_url, email)')
//           .eq('friend_id', currentUserId)
//           .eq('status', 'pending');

//       setState(() {
//         _requests = List<Map<String, dynamic>>.from(res);
//       });
//     } catch (e) {
//       debugPrint('❌ Load requests error: $e');
//     }
//   }

//   // 🔹 Open or create chat
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
//         debugPrint('💬 Existing chat found: $chatId');
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
//         debugPrint('🆕 New chat created: $chatId');
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
//       debugPrint('❌ Open chat error: $e');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error opening chat: $e')));
//     }
//   }

//   // 🔹 Send friend request
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

//   // 🔹 Accept friend request
//   Future<void> _acceptRequest(Map<String, dynamic> req) async {
//     try {
//       final requestId = req['id'].toString();
//       final fromUserId = req['user_id'].toString();
//       await FriendService.acceptFriendRequest(requestId, fromUserId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Friend request accepted!')),
//       );
//       await _loadRequests();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Error accepting request: $e')),
//       );
//     }
//   }

//   // 🔹 Build a user tile (now shows email)
//   Widget _buildUserTile(Map<String, dynamic> user) {
//     final displayName = user['display_name'] ?? 'Unknown User';
//     final email = user['email'] ?? 'No email';
//     final avatarUrl = user['avatar_url']?.toString();

//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.grey[200],
//         backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
//             ? NetworkImage(avatarUrl)
//             : null,
//         child: (avatarUrl == null || avatarUrl.isEmpty)
//             ? const Icon(Icons.person, color: Colors.grey)
//             : null,
//       ),
//       title: Text(displayName),
//       subtitle: Text(email, style: const TextStyle(color: Colors.grey)),
//       trailing: ElevatedButton(
//         onPressed: () => _sendFriendRequest(user['id']),
//         style: ElevatedButton.styleFrom(backgroundColor: kGreen),
//         child: const Text('Add Friend'),
//       ),
//       onTap: () => _openChat(user),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chats'),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(icon: const Icon(Icons.refresh), onPressed: _initLoad)
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _initLoad,
//               child: ListView(
//                 children: [
//                   if (_requests.isNotEmpty) ...[
//                     const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         '🧾 Friend Requests',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                     ),
//                     ..._requests.map((req) {
//                       final sender = req['users'] ?? {};
//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.grey[200],
//                           backgroundImage: sender['avatar_url'] != null
//                               ? NetworkImage(sender['avatar_url'])
//                               : null,
//                           child: sender['avatar_url'] == null
//                               ? const Icon(Icons.person)
//                               : null,
//                         ),
//                         title: Text(sender['display_name'] ?? 'Unknown'),
//                         subtitle: Text(
//                           sender['email'] ?? 'No email',
//                           style: const TextStyle(color: Colors.grey),
//                         ),
//                         trailing: ElevatedButton(
//                           onPressed: () => _acceptRequest(req),
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: kGreen),
//                           child: const Text('Accept'),
//                         ),
//                       );
//                     }),
//                     const Divider(),
//                   ],
//                   if (_users.isNotEmpty)
//                     ..._users.map((u) => _buildUserTile(u))
//                   else
//                     const Padding(
//                       padding: EdgeInsets.all(20),
//                       child: Center(
//                         child: Text(
//                           'No users found.\nMake sure others are signed up.',
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//     );
//   }
// }  
import 'package:circlo_app/ui/home/search_screen.dart';
import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import '../../services/friend_service.dart';
import 'chat_screen.dart';
import '../home/home_feed_screen.dart';
import '../profile/profile_overview_screen.dart';
import '../home/offer_item_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _supabase = Supabase.instance.client;
  late String currentUserId;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // wait for auth init

    final user = _supabase.auth.currentUser;
    if (user == null) {
      Future.delayed(const Duration(seconds: 1), _initLoad);
      return;
    }

    currentUserId = user.id;
    await _loadUsers();
    await _loadRequests();
    setState(() => _loading = false);
  }

  Future<void> _loadUsers() async {
    try {
      final res = await _supabase
          .from('users')
          .select('id, display_name, email, avatar_url')
          .neq('id', currentUserId)
          .order('display_name', ascending: true);
      setState(() {
        _users = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      debugPrint('❌ Load users error: $e');
    }
  }

  Future<void> _loadRequests() async {
    try {
      final res = await _supabase
          .from('friends')
          .select(
              'id, user_id, status, users!friends_user_id_fkey(display_name, avatar_url, email)')
          .eq('friend_id', currentUserId)
          .eq('status', 'pending');
      setState(() {
        _requests = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      debugPrint('❌ Load requests error: $e');
    }
  }

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

  Future<void> _sendFriendRequest(String friendId) async {
    try {
      await FriendService.sendFriendRequest(friendId);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('✅ Friend request sent')));
      await _loadRequests();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Failed: $e')));
    }
  }

  Future<void> _acceptRequest(Map<String, dynamic> req) async {
    try {
      final requestId = req['id'].toString();
      final fromUserId = req['user_id'].toString();
      await FriendService.acceptFriendRequest(requestId, fromUserId);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('✅ Friend request accepted!')));
      await _loadRequests();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Error accepting request: $e')));
    }
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final displayName = user['display_name'] ?? 'Unknown User';
    final email = user['email'] ?? 'No email';
    final avatarUrl = user['avatar_url']?.toString();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
            ? NetworkImage(avatarUrl)
            : null,
        child: (avatarUrl == null || avatarUrl.isEmpty)
            ? const Icon(Icons.person, color: Colors.grey)
            : null,
      ),
      title: Text(displayName),
      subtitle: Text(email, style: const TextStyle(color: Colors.grey)),
      trailing: ElevatedButton(
        onPressed: () => _sendFriendRequest(user['id']),
        style: ElevatedButton.styleFrom(backgroundColor: kGreen),
        child: const Text('Add Friend'),
      ),
      onTap: () => _openChat(user),
    );
  }

  void _handleNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeFeedScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
        break;
      case 3:
        // Already on ChatListScreen
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileOverviewScreen()),
        );
        break;
    }
  }

  void _handleFabPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OfferItemScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: kGreen,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _initLoad)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _initLoad,
              child: ListView(
                children: [
                  if (_requests.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('🧾 Friend Requests',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    ..._requests.map((req) {
                      final sender = req['users'] ?? {};
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          backgroundImage: sender['avatar_url'] != null
                              ? NetworkImage(sender['avatar_url'])
                              : null,
                          child: sender['avatar_url'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(sender['display_name'] ?? 'Unknown'),
                        subtitle: Text(sender['email'] ?? 'No email',
                            style: const TextStyle(color: Colors.grey)),
                        trailing: ElevatedButton(
                          onPressed: () => _acceptRequest(req),
                          style: ElevatedButton.styleFrom(backgroundColor: kGreen),
                          child: const Text('Accept'),
                        ),
                      );
                    }),
                    const Divider(),
                  ],
                  if (_users.isNotEmpty)
                    ..._users.map((u) => _buildUserTile(u))
                  else
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No users found.\nMake sure others are signed up.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      // ✅ Fixed BottomNavBar
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3, // Chat tab index
        onTap: _handleNavTap,
        onFabPressed: _handleFabPressed,
      ),
    );
  }
}
