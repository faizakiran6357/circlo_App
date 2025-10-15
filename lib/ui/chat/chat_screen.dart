
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';

// class ChatScreen extends StatefulWidget {
//   final String itemId;
//   final String itemOwnerId;
//   final String itemOwnerName;
//   final String? itemOwnerAvatarUrl;

//   const ChatScreen({
//     super.key,
//     required this.itemId,
//     required this.itemOwnerId,
//     required this.itemOwnerName,
//     this.itemOwnerAvatarUrl,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final _supabase = Supabase.instance.client;
//   late final String currentUserId;
//   String? _chatId;

//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollCtrl = ScrollController();
//   StreamSubscription? _streamSub;

//   final List<Map<String, dynamic>> _messages = [];
//   bool _showEmojiPicker = false;

//   String? _ownerName;
//   String? _ownerAvatar;

//   final DateFormat _timeFmt = DateFormat.jm(); // 12-hour format
//   String? _editingMessageId;

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = _supabase.auth.currentUser?.id ?? '';
//     _loadOwnerProfile();
//     _initChatAndStream();
//   }

//   @override
//   void dispose() {
//     _streamSub?.cancel();
//     _controller.dispose();
//     _scrollCtrl.dispose();
//     super.dispose();
//   }

// Future<void> _loadOwnerProfile() async {
//   try {
//     debugPrint("🔍 Loading profile for owner id: ${widget.itemOwnerId}");
//     final res = await _supabase
//         .from('users')
//         .select('display_name, avatar_url')
//         .eq('id', widget.itemOwnerId)
//         .maybeSingle();

//     if (res != null) {
//       debugPrint("✅ Owner found: ${res['display_name']}");
//       setState(() {
//         _ownerName = res['display_name']?.toString() ?? 'Unknown User';
//         _ownerAvatar = res['avatar_url']?.toString();
//       });
//     } else {
//       debugPrint("⚠️ Owner not found in users table");
//       setState(() {
//         _ownerName = widget.itemOwnerName; // fallback from navigation
//         _ownerAvatar = widget.itemOwnerAvatarUrl;
//       });
//     }
//   } catch (e) {
//     debugPrint('⚠️ Profile fetch failed: $e');
//   }
// }

//   Future<void> _initChatAndStream() async {
//     try {
//       final chatsRes = await _supabase
//           .from('chats')
//           .select()
//           .or(
//               'and(user1_id.eq.$currentUserId,user2_id.eq.${widget.itemOwnerId}),and(user1_id.eq.${widget.itemOwnerId},user2_id.eq.$currentUserId)')
//           .maybeSingle();

//       if (chatsRes != null) {
//         _chatId = chatsRes['id'].toString();
//       } else {
//         final newChat = await _supabase
//             .from('chats')
//             .insert({
//               'user1_id': currentUserId,
//               'user2_id': widget.itemOwnerId,
//               'last_message': '',
//             })
//             .select()
//             .single();
//         _chatId = newChat['id'].toString();
//       }

//       await _loadHistory();
//       _attachStream();
//       setState(() {});
//     } catch (e) {
//       debugPrint('Chat init error: $e');
//     }
//   }

//   Future<void> _loadHistory() async {
//     if (_chatId == null) return;
//     try {
//       final res = await _supabase
//           .from('messages')
//           .select()
//           .eq('chat_id', _chatId!)
//           .order('created_at', ascending: true); // bottom order
//       _messages
//         ..clear()
//         ..addAll(List<Map<String, dynamic>>.from(res));
//       setState(() {});
//       _scrollToBottom();
//     } catch (e) {
//       debugPrint('Load history error: $e');
//     }
//   }

//   void _attachStream() {
//     if (_chatId == null) return;
//     _streamSub?.cancel();
//     final stream = _supabase
//         .from('messages')
//         .stream(primaryKey: ['id'])
//         .eq('chat_id', _chatId!)
//         .order('created_at', ascending: true);
//     _streamSub = stream.listen((rows) {
//       try {
//         final list = List<Map<String, dynamic>>.from(rows);
//         _messages
//           ..clear()
//           ..addAll(list);
//         setState(() {});
//         _scrollToBottom();
//       } catch (e) {
//         debugPrint('Stream parse error: $e');
//       }
//     }, onError: (err) {
//       debugPrint('Stream error: $err');
//     });
//   }

//   Future<void> _scrollToBottom() async {
//     await Future.delayed(const Duration(milliseconds: 150));
//     if (_scrollCtrl.hasClients) {
//       _scrollCtrl.animateTo(
//         _scrollCtrl.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   // ---------- Send / Edit ----------
//   Future<void> _sendText(String text) async {
//     final trimmed = text.trim();
//     if (_chatId == null || trimmed.isEmpty) return;

//     // ✏️ Editing existing message
//     if (_editingMessageId != null) {
//       final editingId = _editingMessageId!;
//       try {
//         await _supabase
//             .from('messages')
//             .update({'message': trimmed})
//             .eq('id', editingId);

//         final idx =
//             _messages.indexWhere((m) => m['id'].toString() == editingId);
//         if (idx != -1) _messages[idx]['message'] = trimmed;

//         _editingMessageId = null;
//         _controller.clear();
//         setState(() {});
//         _scrollToBottom();
//       } catch (e) {
//         debugPrint('Edit update failed: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to update message')));
//       }
//       return;
//     }

//     // 📨 Sending new message
//     final tmpId = 'tmp-${DateTime.now().millisecondsSinceEpoch}';
//     final localMsg = {
//       'id': tmpId,
//       'chat_id': _chatId,
//       'sender_id': currentUserId,
//       'receiver_id': widget.itemOwnerId,
//       'message': trimmed,
//       'created_at': DateTime.now().toIso8601String(),
//       'pending': true,
//     };

//     _messages.add(localMsg);
//     _controller.clear();
//     setState(() {});
//     _scrollToBottom();

//     try {
//       final insertRes = await _supabase.from('messages').insert({
//         'chat_id': _chatId!,
//         'sender_id': currentUserId,
//         'receiver_id': widget.itemOwnerId,
//         'message': trimmed,
//       }).select().single();

//       await _supabase
//           .from('chats')
//           .update({'last_message': trimmed, 'updated_at': DateTime.now().toIso8601String()})
//           .eq('id', _chatId!);

//       _messages.removeWhere((m) => m['id'] == tmpId);
//       _messages.add(Map<String, dynamic>.from(insertRes));
//       _messages.sort((a, b) =>
//           DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
//       setState(() {});
//       _scrollToBottom();
//     } catch (e) {
//       debugPrint('Send failed: $e');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Send failed')));
//     }
//   }

//   void _editMessage(Map<String, dynamic> msg) {
//     final id = msg['id']?.toString();
//     _editingMessageId = id;
//     _controller.text = msg['message'] ?? '';
//     setState(() {});
//   }

//   void _deleteMessage(Map<String, dynamic> msg) async {
//     final id = msg['id']?.toString();
//     if (id == null) return;
//     if (_editingMessageId == id) {
//       _editingMessageId = null;
//       _controller.clear();
//     }
//     _messages.removeWhere((m) => m['id'] == id);
//     setState(() {});
//     try {
//       await _supabase.from('messages').delete().eq('id', id);
//     } catch (e) {
//       debugPrint('Delete failed: $e');
//       _loadHistory();
//     }
//   }

//   // ---------- Long Press ----------
//   void _showMessageActions(Map<String, dynamic> msg) {
//     showModalBottomSheet(context: context, builder: (_) => _buildMessageActions(msg));
//   }

//   Widget _buildMessageActions(Map<String, dynamic> msg) {
//     final emojis = [
//       '❤️','💖','💗','💞','💕','💘','💝','💓','💟','❣️','💜','🧡','💛','💚','🩵','🩷','🤍',
//       '😂','🤣','😊','😇','🙂','😉','😌','😍','😘','😗','😙','😚','🤩','🥰','😅','😆','😎','🤓',
//       '😏','🤔','🤨','😐','😑','🙄','😒','😬','😭','😢','😤','😠','😡','🤬','😳','🥺','😱',
//       '😨','😰','😥','😓','👍','👎','👏','🙌','🤝','🙏','💪','🔥','✨','💯','🎉','🎊','🎈',
//       '🤗','🤡','🤠','🥳','🤲','🫡','🫶','💃','🕺','🫰','🫵','😴','🤤','🤧','😵','🤯'
//     ];

//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(14.0),
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             _actionIcon(Icons.edit, 'Edit', Colors.blue, () {
//               Navigator.pop(context);
//               _editMessage(msg);
//             }),
//             const SizedBox(width: 28),
//             _actionIcon(Icons.delete, 'Delete', Colors.red, () {
//               Navigator.pop(context);
//               _deleteMessage(msg);
//             }),
//           ]),
//           const SizedBox(height: 12),
//           const Divider(),
//           SizedBox(
//             height: 260,
//             child: GridView.builder(
//               shrinkWrap: true,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 8,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: emojis.length,
//               itemBuilder: (context, i) {
//                 final e = emojis[i];
//                 return GestureDetector(
//                   onTap: () async {
//                     setState(() => msg['reaction'] = e);
//                     Navigator.pop(context);
//                     final id = msg['id']?.toString();
//                     if (id != null) {
//                       try {
//                         await _supabase
//                             .from('messages')
//                             .update({'reaction': e})
//                             .eq('id', id);
//                       } catch (err) {
//                         debugPrint('Reaction update failed: $err');
//                       }
//                     }
//                   },
//                   child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
//                 );
//               },
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   // ---------- UI ----------
//   @override
//   Widget build(BuildContext context) {
//     final isEditing = _editingMessageId != null;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kGreen,
//         title: Row(children: [
//           CircleAvatar(
//             radius: 18,
//             backgroundImage: (_ownerAvatar != null && _ownerAvatar!.isNotEmpty)
//                 ? NetworkImage(_ownerAvatar!)
//                 : (widget.itemOwnerAvatarUrl != null
//                     ? NetworkImage(widget.itemOwnerAvatarUrl!)
//                     : null),
//             child: (_ownerAvatar == null && widget.itemOwnerAvatarUrl == null)
//                 ? const Icon(Icons.person)
//                 : null,
//           ),
//           const SizedBox(width: 8),
//           Text(_ownerName ?? widget.itemOwnerName,
//               style: const TextStyle(fontWeight: FontWeight.w600)),
//         ]),
//       ),
//       body: Column(children: [
//         Expanded(
//           child: _messages.isEmpty
//               ? const Center(child: Text('No messages yet'))
//               : ListView.builder(
//                   controller: _scrollCtrl,
//                   padding: const EdgeInsets.all(10),
//                   itemCount: _messages.length,
//                   itemBuilder: (_, i) {
//                     final msg = _messages[i];
//                     final isMe = (msg['sender_id'] ?? '') == currentUserId;
//                     final text = (msg['message'] ?? '').toString();
//                     final reaction = msg['reaction'];
//                     final createdAtRaw = msg['created_at']?.toString();
//                     String formattedTime = '';
//                     if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
//                       final parsed = DateTime.tryParse(createdAtRaw);
//                       if (parsed != null)
//                         formattedTime = _timeFmt.format(parsed.toLocal());
//                     }

//                     return GestureDetector(
//                       onLongPress: () => _showMessageActions(msg),
//                       child: Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 6),
//                           child: Stack(
//                             clipBehavior: Clip.none,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(10),
//                                 decoration: BoxDecoration(
//                                   color: isMe ? kTeal : Colors.grey[200],
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       text,
//                                       style: TextStyle(
//                                           color: isMe
//                                               ? Colors.white
//                                               : Colors.black87),
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Text(
//                                       formattedTime,
//                                       style: TextStyle(
//                                           fontSize: 11,
//                                           color: isMe
//                                               ? Colors.white70
//                                               : Colors.black45),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               if (reaction != null &&
//                                   reaction.toString().isNotEmpty)
//                                 Positioned(
//                                   bottom: -12,
//                                   right: -8,
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 6, vertical: 2),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(20),
//                                       boxShadow: const [
//                                         BoxShadow(
//                                             color: Colors.black12,
//                                             blurRadius: 2)
//                                       ],
//                                     ),
//                                     child: Text(reaction.toString(),
//                                         style: const TextStyle(fontSize: 16)),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//         Container(
//           padding: const EdgeInsets.all(8),
//           color: Colors.white,
//           child: Row(children: [
//             IconButton(
//               icon: Icon(_showEmojiPicker ? Icons.close : Icons.emoji_emotions,
//                   color: kTeal),
//               onPressed: () =>
//                   setState(() => _showEmojiPicker = !_showEmojiPicker),
//             ),
//             IconButton(
//                 icon: const Icon(Icons.photo, color: kTeal),
//                 onPressed: () => _showMediaOptionsSheet()),
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 textInputAction: TextInputAction.send,
//                 onSubmitted: (v) => _sendText(v),
//                 decoration: InputDecoration(
//                     hintText: isEditing
//                         ? 'Editing message...'
//                         : 'Type a message...',
//                     border: const OutlineInputBorder()),
//               ),
//             ),
//             IconButton(
//                 icon:
//                     Icon(isEditing ? Icons.check : Icons.send, color: kTeal),
//                 onPressed: () => _sendText(_controller.text)),
//           ]),
//         ),
//         if (_showEmojiPicker)
//           SizedBox(
//             height: 250,
//             child: EmojiPicker(
//               onEmojiSelected: (_, emoji) =>
//                   setState(() => _controller.text += emoji.emoji),
//             ),
//           ),
//       ]),
//     );
//   }

//   Widget _actionIcon(
//       IconData icon, String label, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(children: [
//         CircleAvatar(
//             backgroundColor: color.withOpacity(0.1),
//             child: Icon(icon, color: color)),
//         const SizedBox(height: 6),
//         Text(label),
//       ]),
//     );
//   }

//   void _showMediaOptionsSheet() {
//     showModalBottomSheet(
//       context: context,
//       builder: (ctx) => SafeArea(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           ListTile(
//             leading: const Icon(Icons.photo_library, color: kTeal),
//             title: const Text('Choose from Gallery'),
//             onTap: () {
//               Navigator.pop(ctx);
//               _sendImage(ImageSource.gallery);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.camera_alt, color: kTeal),
//             title: const Text('Take a Photo'),
//             onTap: () {
//               Navigator.pop(ctx);
//               _sendImage(ImageSource.camera);
//             },
//           ),
//         ]),
//       ),
//     );
//   }

//   Future<void> _sendImage(ImageSource src) async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: src, imageQuality: 75);
//     if (picked == null || _chatId == null) return;
//     final bytes = await picked.readAsBytes();
//     final fileName = '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final filePath = 'chat-images/$fileName';

//     final tmpId = 'tmp-img-${DateTime.now().millisecondsSinceEpoch}';
//     final localMsg = {
//       'id': tmpId,
//       'chat_id': _chatId,
//       'sender_id': currentUserId,
//       'receiver_id': widget.itemOwnerId,
//       'message': '[image]',
//       'image_bytes': bytes,
//       'created_at': DateTime.now().toIso8601String(),
//       'pending': true,
//     };
//     _messages.add(localMsg);
//     setState(() {});
//     _scrollToBottom();

//     try {
//       final storage = _supabase.storage.from('item-images');
//       await storage.uploadBinary(filePath, Uint8List.fromList(bytes));
//       final publicUrl = storage.getPublicUrl(filePath);
//       final insertRes = await _supabase.from('messages').insert({
//         'chat_id': _chatId!,
//         'sender_id': currentUserId,
//         'receiver_id': widget.itemOwnerId,
//         'message': '[image]',
//         'image_url': publicUrl,
//       }).select().single();
//       await _supabase
//           .from('chats')
//           .update({'last_message': '[image]'}).eq('id', _chatId!);
//       _messages.removeWhere((m) => m['id'] == tmpId);
//       _messages.add(Map<String, dynamic>.from(insertRes));
//       setState(() {});
//       _scrollToBottom();
//     } catch (e) {
//       debugPrint('Image send failed: $e');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Image send failed: $e')));
//     }
//   }
// }
import 'dart:async';
import 'dart:typed_data';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String itemId;
  final String itemOwnerId;
  final String itemOwnerName;
  final String? itemOwnerAvatarUrl;

  const ChatScreen({
    super.key,
    required this.itemId,
    required this.itemOwnerId,
    required this.itemOwnerName,
    this.itemOwnerAvatarUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _supabase = Supabase.instance.client;
  late final String currentUserId;
  String? _chatId;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  StreamSubscription? _streamSub;

  final List<Map<String, dynamic>> _messages = [];
  bool _showEmojiPicker = false;

  String? _ownerName;
  String? _ownerAvatar;
  bool _isSendingImage = false; // ✅ new variable for loading indicator

  final DateFormat _timeFmt = DateFormat.jm(); // 12-hour format
  String? _editingMessageId;

  @override
  void initState() {
    super.initState();
    currentUserId = _supabase.auth.currentUser?.id ?? '';
    _loadOwnerProfile();
    _initChatAndStream();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOwnerProfile() async {
    try {
      debugPrint("🔍 Loading profile for owner id: ${widget.itemOwnerId}");
      final res = await _supabase
          .from('users')
          .select('display_name, avatar_url')
          .eq('id', widget.itemOwnerId)
          .maybeSingle();

      if (res != null) {
        debugPrint("✅ Owner found: ${res['display_name']}");
        setState(() {
          _ownerName = res['display_name']?.toString() ?? 'Unknown User';
          _ownerAvatar = res['avatar_url']?.toString();
        });
      } else {
        debugPrint("⚠️ Owner not found in users table");
        setState(() {
          _ownerName = widget.itemOwnerName; // fallback
          _ownerAvatar = widget.itemOwnerAvatarUrl;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Profile fetch failed: $e');
    }
  }

  Future<void> _initChatAndStream() async {
    try {
      final chatsRes = await _supabase
          .from('chats')
          .select()
          .or(
              'and(user1_id.eq.$currentUserId,user2_id.eq.${widget.itemOwnerId}),and(user1_id.eq.${widget.itemOwnerId},user2_id.eq.$currentUserId)')
          .maybeSingle();

      if (chatsRes != null) {
        _chatId = chatsRes['id'].toString();
      } else {
        final newChat = await _supabase
            .from('chats')
            .insert({
              'user1_id': currentUserId,
              'user2_id': widget.itemOwnerId,
              'last_message': '',
            })
            .select()
            .single();
        _chatId = newChat['id'].toString();
      }

      await _loadHistory();
      _attachStream();
      setState(() {});
    } catch (e) {
      debugPrint('Chat init error: $e');
    }
  }

  Future<void> _loadHistory() async {
    if (_chatId == null) return;
    try {
      final res = await _supabase
          .from('messages')
          .select()
          .eq('chat_id', _chatId!)
          .order('created_at', ascending: true);
      _messages
        ..clear()
        ..addAll(List<Map<String, dynamic>>.from(res));
      setState(() {});
      _scrollToBottom();
    } catch (e) {
      debugPrint('Load history error: $e');
    }
  }

  void _attachStream() {
    if (_chatId == null) return;
    _streamSub?.cancel();
    final stream = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', _chatId!)
        .order('created_at', ascending: true);
    _streamSub = stream.listen((rows) {
      try {
        final list = List<Map<String, dynamic>>.from(rows);
        _messages
          ..clear()
          ..addAll(list);
        setState(() {});
        _scrollToBottom();
      } catch (e) {
        debugPrint('Stream parse error: $e');
      }
    }, onError: (err) {
      debugPrint('Stream error: $err');
    });
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendText(String text) async {
    final trimmed = text.trim();
    if (_chatId == null || trimmed.isEmpty) return;

    if (_editingMessageId != null) {
      final editingId = _editingMessageId!;
      try {
        await _supabase
            .from('messages')
            .update({'message': trimmed})
            .eq('id', editingId);

        final idx =
            _messages.indexWhere((m) => m['id'].toString() == editingId);
        if (idx != -1) _messages[idx]['message'] = trimmed;

        _editingMessageId = null;
        _controller.clear();
        setState(() {});
        _scrollToBottom();
      } catch (e) {
        debugPrint('Edit update failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update message')));
      }
      return;
    }

    final tmpId = 'tmp-${DateTime.now().millisecondsSinceEpoch}';
    final localMsg = {
      'id': tmpId,
      'chat_id': _chatId,
      'sender_id': currentUserId,
      'receiver_id': widget.itemOwnerId,
      'message': trimmed,
      'created_at': DateTime.now().toIso8601String(),
      'pending': true,
    };

    _messages.add(localMsg);
    _controller.clear();
    setState(() {});
    _scrollToBottom();

    try {
      final insertRes = await _supabase.from('messages').insert({
        'chat_id': _chatId!,
        'sender_id': currentUserId,
        'receiver_id': widget.itemOwnerId,
        'message': trimmed,
      }).select().single();

      await _supabase
          .from('chats')
          .update({
            'last_message': trimmed,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', _chatId!);

      _messages.removeWhere((m) => m['id'] == tmpId);
      _messages.add(Map<String, dynamic>.from(insertRes));
      _messages.sort((a, b) => DateTime.parse(a['created_at'])
          .compareTo(DateTime.parse(b['created_at'])));
      setState(() {});
      _scrollToBottom();
    } catch (e) {
      debugPrint('Send failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Send failed')));
    }
  }

  void _editMessage(Map<String, dynamic> msg) {
    final id = msg['id']?.toString();
    _editingMessageId = id;
    _controller.text = msg['message'] ?? '';
    setState(() {});
  }

  void _deleteMessage(Map<String, dynamic> msg) async {
    final id = msg['id']?.toString();
    if (id == null) return;
    if (_editingMessageId == id) {
      _editingMessageId = null;
      _controller.clear();
    }
    _messages.removeWhere((m) => m['id'] == id);
    setState(() {});
    try {
      await _supabase.from('messages').delete().eq('id', id);
    } catch (e) {
      debugPrint('Delete failed: $e');
      _loadHistory();
    }
  }

  void _showMessageActions(Map<String, dynamic> msg) {
    showModalBottomSheet(context: context, builder: (_) => _buildMessageActions(msg));
  }

  Widget _buildMessageActions(Map<String, dynamic> msg) {
    final emojis = [
      '❤️','💖','💗','💞','💕','💘','💝','💓','💟','❣️','💜','🧡','💛','💚','🩵','🩷','🤍',
      '😂','🤣','😊','😇','🙂','😉','😌','😍','😘','😗','😙','😚','🤩','🥰','😅','😆','😎','🤓',
      '😏','🤔','🤨','😐','😑','🙄','😒','😬','😭','😢','😤','😠','😡','🤬','😳','🥺','😱',
      '😨','😰','😥','😓','👍','👎','👏','🙌','🤝','🙏','💪','🔥','✨','💯','🎉','🎊','🎈',
      '🤗','🤡','🤠','🥳','🤲','🫡','🫶','💃','🕺','🫰','🫵','😴','🤤','🤧','😵','🤯'
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _actionIcon(Icons.edit, 'Edit', Colors.blue, () {
              Navigator.pop(context);
              _editMessage(msg);
            }),
            const SizedBox(width: 28),
            _actionIcon(Icons.delete, 'Delete', Colors.red, () {
              Navigator.pop(context);
              _deleteMessage(msg);
            }),
          ]),
          const SizedBox(height: 12),
          const Divider(),
          SizedBox(
            height: 260,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, i) {
                final e = emojis[i];
                return GestureDetector(
                  onTap: () async {
                    setState(() => msg['reaction'] = e);
                    Navigator.pop(context);
                    final id = msg['id']?.toString();
                    if (id != null) {
                      try {
                        await _supabase
                            .from('messages')
                            .update({'reaction': e})
                            .eq('id', id);
                      } catch (err) {
                        debugPrint('Reaction update failed: $err');
                      }
                    }
                  },
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingMessageId != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kGreen,
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: (_ownerAvatar != null && _ownerAvatar!.isNotEmpty)
                ? NetworkImage(_ownerAvatar!)
                : (widget.itemOwnerAvatarUrl != null
                    ? NetworkImage(widget.itemOwnerAvatarUrl!)
                    : null),
            child: (_ownerAvatar == null && widget.itemOwnerAvatarUrl == null)
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 8),
          Text(_ownerName ?? widget.itemOwnerName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      ),
      body: Stack(
        children: [
          Column(children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(child: Text('No messages yet'))
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(10),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final msg = _messages[i];
                        final isMe = (msg['sender_id'] ?? '') == currentUserId;
                        final text = (msg['message'] ?? '').toString();
                        final imageUrl = msg['image_url'];
                        final imageBytes = msg['image_bytes'];
                        final reaction = msg['reaction'];
                        final createdAtRaw = msg['created_at']?.toString();
                        String formattedTime = '';
                        if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
                          final parsed = DateTime.tryParse(createdAtRaw);
                          if (parsed != null)
                            formattedTime = _timeFmt.format(parsed.toLocal());
                        }

                        return GestureDetector(
                          onLongPress: () => _showMessageActions(msg),
                          child: Align(
                            alignment:
                                isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isMe ? kTeal : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (imageUrl != null &&
                                            imageUrl.toString().isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              imageUrl,
                                              width: 180,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        else if (imageBytes != null)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.memory(
                                              imageBytes,
                                              width: 180,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        else
                                          Text(
                                            text,
                                            style: TextStyle(
                                                color: isMe
                                                    ? Colors.white
                                                    : Colors.black87),
                                          ),
                                        const SizedBox(height: 6),
                                        Text(
                                          formattedTime,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: isMe
                                                  ? Colors.white70
                                                  : Colors.black45),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (reaction != null &&
                                      reaction.toString().isNotEmpty)
                                    Positioned(
                                      bottom: -12,
                                      right: -8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 2)
                                          ],
                                        ),
                                        child: Text(reaction.toString(),
                                            style: const TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Row(children: [
                IconButton(
                  icon: Icon(_showEmojiPicker ? Icons.close : Icons.emoji_emotions,
                      color: kTeal),
                  onPressed: () =>
                      setState(() => _showEmojiPicker = !_showEmojiPicker),
                ),
                IconButton(
                    icon: const Icon(Icons.photo, color: kTeal),
                    onPressed: () => _showMediaOptionsSheet()),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (v) => _sendText(v),
                    decoration: InputDecoration(
                        hintText: isEditing
                            ? 'Editing message...'
                            : 'Type a message...',
                        border: const OutlineInputBorder()),
                  ),
                ),
                IconButton(
                    icon:
                        Icon(isEditing ? Icons.check : Icons.send, color: kTeal),
                    onPressed: () => _sendText(_controller.text)),
              ]),
            ),
            if (_showEmojiPicker)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (_, emoji) =>
                      setState(() => _controller.text += emoji.emoji),
                ),
              ),
          ]),

          // ✅ IMAGE SENDING INDICATOR OVERLAY
          if (_isSendingImage)
            Container(
              color: Colors.black38,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      "Sending image...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionIcon(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color)),
        const SizedBox(height: 6),
        Text(label),
      ]),
    );
  }

  void _showMediaOptionsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: kTeal),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(ctx);
              _sendImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: kTeal),
            title: const Text('Take a Photo'),
            onTap: () {
              Navigator.pop(ctx);
              _sendImage(ImageSource.camera);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _sendImage(ImageSource src) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: src, imageQuality: 75);
    if (picked == null || _chatId == null) return;

    setState(() => _isSendingImage = true); // ✅ show loading overlay

    final bytes = await picked.readAsBytes();
    final fileName =
        '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = 'chat-images/$fileName';

    final tmpId = 'tmp-img-${DateTime.now().millisecondsSinceEpoch}';
    final localMsg = {
      'id': tmpId,
      'chat_id': _chatId,
      'sender_id': currentUserId,
      'receiver_id': widget.itemOwnerId,
      'message': '[image]',
      'image_bytes': bytes,
      'created_at': DateTime.now().toIso8601String(),
      'pending': true,
    };
    _messages.add(localMsg);
    setState(() {});
    _scrollToBottom();

    try {
      final storage = _supabase.storage.from('item-images');
      await storage.uploadBinary(filePath, Uint8List.fromList(bytes));
      final publicUrl = storage.getPublicUrl(filePath);
      final insertRes = await _supabase.from('messages').insert({
        'chat_id': _chatId!,
        'sender_id': currentUserId,
        'receiver_id': widget.itemOwnerId,
        'message': '[image]',
        'image_url': publicUrl,
      }).select().single();
      await _supabase
          .from('chats')
          .update({'last_message': '[image]'}).eq('id', _chatId!);
      _messages.removeWhere((m) => m['id'] == tmpId);
      _messages.add(Map<String, dynamic>.from(insertRes));
      setState(() {});
      _scrollToBottom();
    } catch (e) {
      debugPrint('Image send failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image send failed: $e')));
    } finally {
      setState(() => _isSendingImage = false); // ✅ hide loading overlay
    }
  }
}