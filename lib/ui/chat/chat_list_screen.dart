
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

  /// 🔹 Load current user + data
  Future<void> _initLoad() async {
    setState(() => _loading = true);

    final user = _supabase.auth.currentUser;
    if (user == null) {
      await Future.delayed(const Duration(seconds: 1));
      return _initLoad();
    }

    currentUserId = user.id;
    await _loadUsers();
    await _loadRequests();
    setState(() => _loading = false);
  }

  /// 🔹 Load all users (excluding self)
  Future<void> _loadUsers() async {
    try {
      final res = await _supabase
          .from('users')
          .select('id, display_name, email, avatar_url')
          .neq('id', currentUserId)
          .order('display_name', ascending: true);
      _users = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('❌ Load users error: $e');
    }
  }

  /// 🔹 Load incoming friend requests
  Future<void> _loadRequests() async {
    try {
      final res = await _supabase
          .from('friends')
          .select(
              'id, user_id, status, users!friends_user_id_fkey(display_name, avatar_url, email)')
          .eq('friend_id', currentUserId)
          .eq('status', 'pending');
      _requests = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('❌ Load requests error: $e');
    }
  }

  /// 🔹 Open chat between current + selected user
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

  /// 🔹 Send a friend request
  Future<void> _sendFriendRequest(String friendId) async {
    try {
      await FriendService.sendFriendRequest(friendId);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Friend request sent')));
      await _loadRequests();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Failed: $e')));
    }
  }

  /// 🔹 Accept a friend request
  Future<void> _acceptRequest(Map<String, dynamic> req) async {
    try {
      final requestId = req['id'].toString();
      final fromUserId = req['user_id'].toString();
      await FriendService.acceptFriendRequest(requestId, fromUserId);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Friend request accepted!')));
      await _loadRequests();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Error accepting request: $e')));
    }
  }

  /// 🔹 User Card Widget
  Widget _buildUserCard(Map<String, dynamic> user, {bool isRequest = false}) {
    final displayName = user['display_name'] ?? 'Unknown User';
    final email = user['email'] ?? 'No email';
    final avatarUrl = user['avatar_url']?.toString();

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
        onTap: () => !isRequest ? _openChat(user) : null,
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
            : ElevatedButton(
                onPressed: () => _sendFriendRequest(user['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add', style: TextStyle(fontSize: 14)),
              ),
      ),
    );
  }

  /// 🔹 Show Filter & Refresh Menu
  void _showMoreMenu() async {
    final result = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 80, 20, 0),
      items: const [
        PopupMenuItem<String>(
          value: 'refresh',
          child: Text('🔄 Refresh'),
        ),
        PopupMenuItem<String>(
          value: 'filter',
          child: Text('⚙️ Filters'),
        ),
      ],
    );

    if (result == 'refresh') {
      _initLoad();
    } else if (result == 'filter') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filter options coming soon!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen,
        elevation: 0,
        titleSpacing: 16,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Chats',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreMenu,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _initLoad,
              child: ListView(
                children: [
                  if (_requests.isNotEmpty) ...[
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        '🧾 Friend Requests',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    ..._requests.map((req) {
                      final sender = req['users'] ?? {};
                      return _buildUserCard(sender, isRequest: true);
                    }),
                    const Divider(),
                  ],
                  if (_users.isNotEmpty)
                    ..._users.map((u) => _buildUserCard(u))
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
    );
  }
}
