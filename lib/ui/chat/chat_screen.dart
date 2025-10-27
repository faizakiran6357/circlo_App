
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
//   final FocusNode _inputFocusNode = FocusNode();

//   final List<Map<String, dynamic>> _messages = [];
//   bool _showEmojiPicker = false;

//   String? _ownerName;
//   String? _ownerAvatar;
//   bool _isSendingImage = false; // ✅ new variable for loading indicator

//   final DateFormat _timeFmt = DateFormat.jm(); // 12-hour format
//   String? _editingMessageId;

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = _supabase.auth.currentUser?.id ?? '';
//     _loadOwnerProfile();
//     _initChatAndStream();
//     _inputFocusNode.addListener(() => setState(() {}));
//   }

//   @override
//   void dispose() {
//     _streamSub?.cancel();
//     _controller.dispose();
//     _scrollCtrl.dispose();
//     _inputFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _loadOwnerProfile() async {
//     try {
//       debugPrint("🔍 Loading profile for owner id: ${widget.itemOwnerId}");
//       final res = await _supabase
//           .from('users')
//           .select('display_name, avatar_url')
//           .eq('id', widget.itemOwnerId)
//           .maybeSingle();

//       if (res != null) {
//         debugPrint("✅ Owner found: ${res['display_name']}");
//         setState(() {
//           _ownerName = res['display_name']?.toString() ?? 'Unknown User';
//           _ownerAvatar = res['avatar_url']?.toString();
//         });
//       } else {
//         debugPrint("⚠️ Owner not found in users table");
//         setState(() {
//           _ownerName = widget.itemOwnerName; // fallback
//           _ownerAvatar = widget.itemOwnerAvatarUrl;
//         });
//       }
//     } catch (e) {
//       debugPrint('⚠️ Profile fetch failed: $e');
//     }
//   }

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
//           .order('created_at', ascending: true);
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

//   Future<void> _sendText(String text) async {
//     final trimmed = text.trim();
//     if (_chatId == null || trimmed.isEmpty) return;

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
//           .update({
//             'last_message': trimmed,
//             'updated_at': DateTime.now().toIso8601String()
//           })
//           .eq('id', _chatId!);

//       _messages.removeWhere((m) => m['id'] == tmpId);
//       _messages.add(Map<String, dynamic>.from(insertRes));
//       _messages.sort((a, b) => DateTime.parse(a['created_at'])
//           .compareTo(DateTime.parse(b['created_at'])));
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

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = _editingMessageId != null;
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: AppBar(
//         backgroundColor: kGreen,
//         elevation: 0,
//         centerTitle: false,
//         titleSpacing: 0,
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
//           const SizedBox(width: 10),
//           Text(
//             _ownerName ?? widget.itemOwnerName,
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//           ),
//         ]),
//       ),
//       body: Stack(
//         children: [
//           Column(children: [
//             Expanded(
//               child: _messages.isEmpty
//                   ? const Center(child: Text('No messages yet'))
//                   : ListView.builder(
//                       controller: _scrollCtrl,
//                       padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
//                       itemCount: _messages.length,
//                       itemBuilder: (_, i) {
//                         final msg = _messages[i];
//                         final isMe = (msg['sender_id'] ?? '') == currentUserId;
//                         final text = (msg['message'] ?? '').toString();

//                         final imageUrl = msg['image_url'];
//                         final imageBytes = msg['image_bytes'];
//                         final reaction = msg['reaction'];
//                         final createdAtRaw = msg['created_at']?.toString();
//                         String formattedTime = '';
//                         if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
//                           final parsed = DateTime.tryParse(createdAtRaw);
//                           if (parsed != null)
//                             formattedTime = _timeFmt.format(parsed.toLocal());
//                         }

//                         return GestureDetector(
//                           onLongPress: () => _showMessageActions(msg),
//                           child: Align(
//                             alignment:
//                                 isMe ? Alignment.centerRight : Alignment.centerLeft,
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 6),
//                               child: Stack(
//                                 clipBehavior: Clip.none,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                                     constraints: const BoxConstraints(maxWidth: 280),
//                                     decoration: BoxDecoration(
//                                       gradient: isMe
//                                           ? LinearGradient(colors: [
//                                               kTeal,
//                                               kTeal.withOpacity(0.85),
//                                             ])
//                                           : null,
//                                       color: isMe ? null : Colors.white,
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(isMe ? 12 : 4),
//                                         topRight: Radius.circular(isMe ? 4 : 12),
//                                         bottomLeft: const Radius.circular(12),
//                                         bottomRight: const Radius.circular(12),
//                                       ),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.05),
//                                           blurRadius: 8,
//                                           offset: const Offset(0, 2),
//                                         )
//                                       ],
//                                       border: isMe
//                                           ? null
//                                           : Border.all(color: const Color(0xFFE9EEF5)),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.end,
//                                       children: [
//                                         if (imageUrl != null &&
//                                             imageUrl.toString().isNotEmpty)
//                                           ClipRRect(
//                                             borderRadius: BorderRadius.circular(8),
//                                             child: Image.network(
//                                               imageUrl,
//                                               width: 180,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           )
//                                         else if (imageBytes != null)
//                                           ClipRRect(
//                                             borderRadius: BorderRadius.circular(8),
//                                             child: Image.memory(
//                                               imageBytes,
//                                               width: 180,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           )
//                                         else
//                                           Text(
//                                             text,
//                                             style: TextStyle(
//                                                 fontSize: 15,
//                                                 height: 1.3,
//                                                 color: isMe ? Colors.white : const Color(0xFF0F172A)),
//                                           ),
//                                         const SizedBox(height: 6),
//                                         Text(
//                                           formattedTime,
//                                           style: TextStyle(
//                                               fontSize: 11,
//                                               color: isMe ? Colors.white70 : const Color(0xFF6B7280)),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   if (reaction != null &&
//                                       reaction.toString().isNotEmpty)
//                                     Positioned(
//                                       bottom: -12,
//                                       right: -8,
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 6, vertical: 2),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(20),
//                                           boxShadow: const [
//                                             BoxShadow(
//                                                 color: Colors.black12,
//                                                 blurRadius: 2)
//                                           ],
//                                         ),
//                                         child: Text(reaction.toString(),
//                                             style: const TextStyle(fontSize: 16)),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//             Container(
//               padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//               color: Colors.transparent,
//               child: Row(children: [
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(28),
//                       border: Border.all(
//                         color: _inputFocusNode.hasFocus ? kTeal : const Color(0xFFE9EEF5),
//                         width: _inputFocusNode.hasFocus ? 1.8 : 1,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.04),
//                           blurRadius: 10,
//                           offset: const Offset(0, 2),
//                         )
//                       ],
//                     ),
//                     child: Row(children: [
//                       IconButton(
//                         icon: Icon(
//                           _showEmojiPicker ? Icons.close : Icons.emoji_emotions,
//                           color: kTeal,
//                         ),
//                         iconSize: 24,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints.tightFor(width: 34, height: 34),
//                         onPressed: () =>
//                             setState(() => _showEmojiPicker = !_showEmojiPicker),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.photo, color: kTeal),
//                         iconSize: 24,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints.tightFor(width: 34, height: 34),
//                         onPressed: () => _showMediaOptionsSheet(),
//                       ),
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           focusNode: _inputFocusNode,
//                           textInputAction: TextInputAction.send,
//                           onSubmitted: (v) => _sendText(v),
//                           decoration: InputDecoration(
//                             hintText: isEditing ? 'Editing message...' : 'Type a message...',
//                             hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
//                             border: InputBorder.none,
//                             enabledBorder: InputBorder.none,
//                             focusedBorder: InputBorder.none,
//                             disabledBorder: InputBorder.none,
//                             contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                           ),
//                         ),
//                       ),
//                     ]),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: kTeal,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.12),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       )
//                     ],
//                   ),
//                   child: IconButton(
//                     icon: Icon(isEditing ? Icons.check : Icons.send, color: Colors.white),
//                     onPressed: () => _sendText(_controller.text),
//                   ),
//                 ),
//               ]),
//             ),
//             if (_showEmojiPicker)
//               SizedBox(
//                 height: 250,
//                 child: EmojiPicker(
//                   onEmojiSelected: (_, emoji) =>
//                       setState(() => _controller.text += emoji.emoji),
//                 ),
//               ),
//           ]),
//           if (_isSendingImage)
//             Container(
//               color: Colors.black38,
//               child: const Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircularProgressIndicator(color: Colors.white),
//                     SizedBox(height: 10),
//                     Text(
//                       "Sending image...",
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
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

//     setState(() => _isSendingImage = true); // ✅ show loading overlay

//     final bytes = await picked.readAsBytes();
//     final fileName =
//         '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
//     } finally {
//       setState(() => _isSendingImage = false); // ✅ hide loading overlay
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
  bool _isSendingImage = false; // loading overlay

  final DateFormat _timeFmt = DateFormat.jm();
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
      final res = await _supabase
          .from('users')
          .select('display_name, avatar_url')
          .eq('id', widget.itemOwnerId)
          .maybeSingle();

      if (res != null) {
        setState(() {
          _ownerName = res['display_name']?.toString() ?? 'Unknown User';
          _ownerAvatar = res['avatar_url']?.toString();
        });
      } else {
        setState(() {
          _ownerName = widget.itemOwnerName;
          _ownerAvatar = widget.itemOwnerAvatarUrl;
        });
      }
    } catch (e) {
      debugPrint('Profile fetch failed: $e');
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
        await _supabase.from('messages').update({'message': trimmed}).eq('id', editingId);

        final idx = _messages.indexWhere((m) => m['id'].toString() == editingId);
        if (idx != -1) _messages[idx]['message'] = trimmed;

        _editingMessageId = null;
        _controller.clear();
        setState(() {});
        _scrollToBottom();
      } catch (e) {
        debugPrint('Edit update failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update message')),
        );
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
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _chatId!);

      _messages.removeWhere((m) => m['id'] == tmpId);
      _messages.add(Map<String, dynamic>.from(insertRes));
      _messages.sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
      setState(() {});
      _scrollToBottom();
    } catch (e) {
      debugPrint('Send failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Send failed')));
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
                        await _supabase.from('messages').update({'reaction': e}).eq('id', id);
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
        elevation: 0,
        surfaceTintColor: kGreen,
        centerTitle: false,
        titleSpacing: 8,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: (_ownerAvatar != null && _ownerAvatar!.isNotEmpty)
                ? NetworkImage(_ownerAvatar!)
                : (widget.itemOwnerAvatarUrl != null ? NetworkImage(widget.itemOwnerAvatarUrl!) : null),
            child: (_ownerAvatar == null && widget.itemOwnerAvatarUrl == null)
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _ownerName ?? widget.itemOwnerName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
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
                          if (parsed != null) formattedTime = _timeFmt.format(parsed.toLocal());
                        }

                        return GestureDetector(
                          onLongPress: () => _showMessageActions(msg),
                          child: Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isMe ? kGreen : Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(14),
                                        topRight: const Radius.circular(14),
                                        bottomLeft: Radius.circular(isMe ? 14 : 4),
                                        bottomRight: Radius.circular(isMe ? 4 : 14),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                      border: isMe ? null : Border.all(color: Colors.black12, width: 0.8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (imageUrl != null && imageUrl.toString().isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              imageUrl,
                                              width: 220,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        else if (imageBytes != null)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.memory(
                                              imageBytes,
                                              width: 220,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        else
                                          Text(
                                            text,
                                            style: TextStyle(
                                              color: isMe ? Colors.white : kTextDark,
                                              fontSize: 15,
                                              height: 1.3,
                                            ),
                                          ),
                                        const SizedBox(height: 6),
                                        Text(
                                          formattedTime,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isMe ? Colors.white70 : Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (reaction != null && reaction.toString().isNotEmpty)
                                    Positioned(
                                      bottom: -14,
                                      right: -6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                            )
                                          ],
                                          border: Border.all(color: Colors.black12),
                                        ),
                                        child: Text(
                                          reaction.toString(),
                                          style: const TextStyle(fontSize: 16),
                                        ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(_showEmojiPicker ? Icons.close : Icons.emoji_emotions_outlined, color: kTeal),
                            onPressed: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (v) => _sendText(v),
                              minLines: 1,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: const TextStyle(fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.attach_file, color: kTeal),
                            onPressed: _showMediaOptionsSheet,
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.camera_alt, color: kTeal),
                            onPressed: () => _sendImage(ImageSource.camera),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sendButton(isEditing: isEditing),
                ],
              ),
            ),
            if (_showEmojiPicker)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (_, emoji) => setState(() => _controller.text += emoji.emoji),
                  config: Config(
                    emojiViewConfig: EmojiViewConfig(
                      emojiSizeMax: 24.0,
                      backgroundColor: kBg,
                      gridPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
          ]),

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

  Widget _actionIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
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
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(ctx);
              _sendImage(ImageSource.gallery);
            },
          ),
        ]),
      ),
    );
  }

  Widget _roundIconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: CircleBorder(side: BorderSide(color: Colors.black12, width: 1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: kTeal, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _sendButton({required bool isEditing}) {
    return Material(
      color: isEditing ? kGreen : kTeal,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _sendText(_controller.text),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(isEditing ? Icons.check : Icons.send, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Future<void> _sendImage(ImageSource src) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: src, imageQuality: 75);
    if (picked == null || _chatId == null) return;

    setState(() => _isSendingImage = true);

    final bytes = await picked.readAsBytes();
    final fileName = '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
      await _supabase.from('chats').update({'last_message': '[image]'}).eq('id', _chatId!);
      _messages.removeWhere((m) => m['id'] == tmpId);
      _messages.add(Map<String, dynamic>.from(insertRes));
      setState(() {});
      _scrollToBottom();
    } catch (e) {
      debugPrint('Image send failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image send failed: $e')));
    } finally {
      setState(() => _isSendingImage = false);
    }
  }
}