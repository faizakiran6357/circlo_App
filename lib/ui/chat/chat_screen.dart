// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';

// class ChatScreen extends StatefulWidget {
//   final String itemOwnerId;
//   const ChatScreen({super.key, required this.itemOwnerId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();

//   final List<Map<String, dynamic>> _messages = [
//     {'sender': 'me', 'text': 'Hey there!', 'time': '10:20 AM'},
//     {'sender': 'other', 'text': 'Hi! How are you?', 'time': '10:21 AM'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat with ${widget.itemOwnerId}"),
//         backgroundColor: kGreen,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final msg = _messages[index];
//                 final isMe = msg['sender'] == 'me';
//                 return Align(
//                   alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     decoration: BoxDecoration(
//                       color: isMe ? kGreen : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       msg['text'],
//                       style: TextStyle(color: isMe ? Colors.white : Colors.black87),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: const BoxDecoration(color: Colors.white, boxShadow: [
//               BoxShadow(color: Colors.black12, blurRadius: 4),
//             ]),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type your message...',
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: kGreen),
//                   onPressed: () {
//                     if (_messageController.text.trim().isEmpty) return;
//                     setState(() {
//                       _messages.add({'sender': 'me', 'text': _messageController.text, 'time': 'Now'});
//                     });
//                     _messageController.clear();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';

// class ChatScreen extends StatefulWidget {
//   final String itemOwnerId;
//   const ChatScreen({super.key, required this.itemOwnerId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final _controller = TextEditingController();
//   final _supabase = Supabase.instance.client;
//   late final String currentUserId;

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = _supabase.auth.currentUser?.id ?? '';
//   }

//   Future<void> sendMessage() async {
//     final msg = _controller.text.trim();
//     if (msg.isEmpty) return;

//     try {
//       await _supabase.from('messages').insert({
//         'sender_id': currentUserId,
//         'receiver_id': widget.itemOwnerId,
//         'message': msg,
//         'created_at': DateTime.now().toIso8601String(),
//       });
//       _controller.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Send failed: $e')));
//     }
//   }

//   bool _isConversationMessage(Map<String, dynamic> m) {
//     final s = (m['sender_id'] ?? '').toString();
//     final r = (m['receiver_id'] ?? '').toString();

//     return (s == currentUserId && r == widget.itemOwnerId) ||
//         (s == widget.itemOwnerId && r == currentUserId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Listen to the full messages stream and filter in the builder for this two-person conversation
//     final stream = _supabase.from('messages').stream(primaryKey: ['id']).map((rows) => rows);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat'),
//         backgroundColor: kGreen,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: stream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 final raw = snapshot.data ?? [];
//                 // Filter for messages between currentUserId and itemOwnerId
//                 final messages = raw.where(_isConversationMessage).toList()
//                   ..sort((a, b) {
//                     final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
//                     final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
//                     return aTime.compareTo(bTime);
//                   });

//                 if (messages.isEmpty) {
//                   return const Center(child: Text('No messages yet. Say hi!'));
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = messages[index];
//                     final isMe = (msg['sender_id'] ?? '') == currentUserId;
//                     final text = (msg['message'] ?? '').toString();
//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isMe ? kTeal : Colors.grey[200],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // input
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: kTeal),
//                   onPressed: sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';

// class ChatScreen extends StatefulWidget {
//   final String itemOwnerId; // receiver id
//   const ChatScreen({super.key, required this.itemOwnerId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final _controller = TextEditingController();
//   final _supabase = Supabase.instance.client;
//   late final String currentUserId;
//   String? _chatId; // ✅ store chat id

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = _supabase.auth.currentUser?.id ?? '';
//     _initializeChat();
//   }

//   /// ✅ Create or find a chat between current user and item owner
//   Future<void> _initializeChat() async {
//     try {
//       final existing = await _supabase
//           .from('chats')
//           .select()
//           .or('and(user1_id.eq.$currentUserId,user2_id.eq.${widget.itemOwnerId}),and(user1_id.eq.${widget.itemOwnerId},user2_id.eq.$currentUserId})')
//           .maybeSingle();

//       if (existing != null) {
//         _chatId = existing['id'];
//       } else {
//         final inserted = await _supabase.from('chats').insert({
//           'user1_id': currentUserId,
//           'user2_id': widget.itemOwnerId,
//           'last_message': 'New chat started',
//         }).select().single();

//         _chatId = inserted['id'];
//       }
//       setState(() {});
//     } catch (e) {
//       debugPrint("⚠️ Chat init error: $e");
//     }
//   }

//   /// ✅ Send message with chat_id
//   Future<void> sendMessage() async {
//     final msg = _controller.text.trim();
//     if (msg.isEmpty || _chatId == null) return;

//     try {
//       await _supabase.from('messages').insert({
//         'chat_id': _chatId, // 👈 important!
//         'sender_id': currentUserId,
//         'receiver_id': widget.itemOwnerId,
//         'message': msg,
//         'created_at': DateTime.now().toIso8601String(),
//       });

//       // Update last_message in chats table
//       await _supabase
//           .from('chats')
//           .update({'last_message': msg, 'updated_at': DateTime.now().toIso8601String()})
//           .eq('id', _chatId!);

//       _controller.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Send failed: $e')));
//     }
//   }

//   bool _isConversationMessage(Map<String, dynamic> m) {
//     final s = (m['sender_id'] ?? '').toString();
//     final r = (m['receiver_id'] ?? '').toString();

//     return (s == currentUserId && r == widget.itemOwnerId) ||
//         (s == widget.itemOwnerId && r == currentUserId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Wait until chat is initialized
//     if (_chatId == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final stream = _supabase
//         .from('messages')
//         .stream(primaryKey: ['id'])
//         .eq('chat_id', _chatId!) // 👈 now filters properly by chat_id
//         .order('created_at');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat'),
//         backgroundColor: kGreen,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: stream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 final messages = snapshot.data ?? [];
//                 if (messages.isEmpty) {
//                   return const Center(child: Text('No messages yet. Say hi!'));
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = messages[index];
//                     final isMe = (msg['sender_id'] ?? '') == currentUserId;
//                     final text = (msg['message'] ?? '').toString();
//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isMe ? kTeal : Colors.grey[200],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           text,
//                           style: TextStyle(color: isMe ? Colors.white : Colors.black87),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // Input Field
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: kTeal),
//                   onPressed: sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';

// class ChatScreen extends StatefulWidget {
//   final String itemOwnerId; // receiver id (the other person)
//   const ChatScreen({super.key, required this.itemOwnerId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final _controller = TextEditingController();
//   final _supabase = Supabase.instance.client;
//   late final String currentUserId;
//   String? _chatId; // to store chat id between two users

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = _supabase.auth.currentUser?.id ?? '';
//     _initializeChat();
//   }

//   /// ✅ Create or find a chat between the current user and item owner
//   Future<void> _initializeChat() async {
//     try {
//       // Fetch chats where both users exist as user1 or user2
//       final chats = await _supabase
//           .from('chats')
//           .select()
//           .inFilter('user1_id', [currentUserId, widget.itemOwnerId])
//           .inFilter('user2_id', [currentUserId, widget.itemOwnerId]);

//       Map<String, dynamic>? existing;

//       for (final c in chats) {
//         if ((c['user1_id'] == currentUserId &&
//                 c['user2_id'] == widget.itemOwnerId) ||
//             (c['user1_id'] == widget.itemOwnerId &&
//                 c['user2_id'] == currentUserId)) {
//           existing = c;
//           break;
//         }
//       }

//       if (existing != null) {
//         _chatId = existing['id'];
//       } else {
//         // No existing chat, create a new one
//         final inserted = await _supabase.from('chats').insert({
//           'user1_id': currentUserId,
//           'user2_id': widget.itemOwnerId,
//           'last_message': 'New chat started',
//           'updated_at': DateTime.now().toIso8601String(),
//         }).select().single();

//         _chatId = inserted['id'];
//       }

//       setState(() {});
//     } catch (e) {
//       debugPrint("⚠️ Chat init error: $e");
//     }
//   }

//   /// ✅ Send message and link to chat_id
//   Future<void> sendMessage() async {
//     final msg = _controller.text.trim();
//     if (msg.isEmpty || _chatId == null) return;

//     try {
//       await _supabase.from('messages').insert({
//         'chat_id': _chatId, // must not be null
//         'sender_id': currentUserId,
//         'receiver_id': widget.itemOwnerId,
//         'message': msg,
//         'created_at': DateTime.now().toIso8601String(),
//       });

//       // Update the last message in chats
//       await _supabase
//           .from('chats')
//           .update({
//             'last_message': msg,
//             'updated_at': DateTime.now().toIso8601String(),
//           })
//           .eq('id', _chatId!);

//       _controller.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Send failed: $e')));
//     }
//   }

//   bool _isMyMessage(Map<String, dynamic> message) {
//     return (message['sender_id'] ?? '') == currentUserId;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Wait until chat is initialized
//     if (_chatId == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     // Real-time stream for this chat’s messages
//     final stream = _supabase
//         .from('messages')
//         .stream(primaryKey: ['id'])
//         .eq('chat_id', _chatId!)
//         .order('created_at');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat'),
//         backgroundColor: kGreen,
//       ),
//       body: Column(
//         children: [
//           // 🟢 Messages List
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: stream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 final messages = snapshot.data ?? [];
//                 if (messages.isEmpty) {
//                   return const Center(child: Text('No messages yet. Say hi!'));
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = messages[index];
//                     final isMe = _isMyMessage(msg);
//                     final text = (msg['message'] ?? '').toString();

//                     return Align(
//                       alignment:
//                           isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isMe ? kTeal : Colors.grey[200],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           text,
//                           style: TextStyle(
//                             color: isMe ? Colors.white : Colors.black87,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // 🟢 Message Input Field
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: kTeal),
//                   onPressed: sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';

// class ChatScreen extends StatefulWidget {
//   final String itemOwnerId; // Receiver ID
//   const ChatScreen({super.key, required this.itemOwnerId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final _controller = TextEditingController();
//   final _supabase = Supabase.instance.client;
//   late final String currentUserId;

//   String _partnerName = 'Chat';
//   String? _chatId;
//   bool _loading = true;
//   List<Map<String, dynamic>> _localMessages = [];

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = _supabase.auth.currentUser?.id ?? '';
//     _initChat();
//   }

//   Future<void> _initChat() async {
//     try {
//       // fetch partner name
//       final profile = await _supabase
//           .from('profiles')
//           .select('full_name')
//           .eq('id', widget.itemOwnerId)
//           .maybeSingle();
//       _partnerName = profile?['full_name'] ?? 'Chat';

//       // find or create chat
//       final existing = await _supabase
//           .from('chats')
//           .select('id')
//           .or('and(user1_id.eq.$currentUserId,user2_id.eq.${widget.itemOwnerId}),and(user1_id.eq.${widget.itemOwnerId},user2_id.eq.$currentUserId)')
//           .maybeSingle();

//       if (existing != null) {
//         _chatId = existing['id'].toString();
//       } else {
//         final inserted = await _supabase
//             .from('chats')
//             .insert({
//               'user1_id': currentUserId,
//               'user2_id': widget.itemOwnerId,
//               'last_message': '',
//             })
//             .select()
//             .single();
//         _chatId = inserted['id'].toString();
//       }
//     } catch (e) {
//       debugPrint('Chat init error: $e');
//     }

//     setState(() => _loading = false);
//   }

//   Future<void> _sendMessage({String? imageUrl}) async {
//     final msg = _controller.text.trim();
//     if (msg.isEmpty && imageUrl == null) return;

//     final messageData = {
//       'chat_id': _chatId,
//       'sender_id': currentUserId,
//       'receiver_id': widget.itemOwnerId,
//       'message': imageUrl != null ? '[image]' : msg,
//       'image_url': imageUrl,
//       'created_at': DateTime.now().toIso8601String(),
//     };

//     // add locally for instant feel
//     setState(() => _localMessages.add(messageData));

//     _controller.clear();

//     try {
//       await _supabase.from('messages').insert(messageData);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Send failed: $e')),
//       );
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final file = await picker.pickImage(source: source);
//     if (file == null) return;

//     final bytes = await file.readAsBytes();
//     final path = 'chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

//     try {
//       await _supabase.storage.from('chat-images').uploadBinary(path, bytes);
//       final imageUrl =
//           _supabase.storage.from('chat-images').getPublicUrl(path);
//       await _sendMessage(imageUrl: imageUrl);
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
//     }
//   }

//   void _showMessageOptions(Map<String, dynamic> msg) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => Padding(
//         padding: const EdgeInsets.all(12),
//         child: GridView.count(
//           crossAxisCount: 4,
//           shrinkWrap: true,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () async {
//                 Navigator.pop(context);
//                 _controller.text = msg['message'] ?? '';
//                 await _supabase
//                     .from('messages')
//                     .update({'message': _controller.text})
//                     .eq('id', msg['id']);
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await _supabase.from('messages').delete().eq('id', msg['id']);
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.emoji_emotions_outlined),
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await _supabase
//                     .from('messages')
//                     .update({'reaction': '❤️'})
//                     .eq('id', msg['id']);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final stream = _supabase
//         .from('messages')
//         .stream(primaryKey: ['id'])
//         .eq('chat_id', _chatId!)
//         .order('created_at');

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_partnerName),
//         backgroundColor: kGreen,
//         elevation: 1,
//       ),
//       body: Column(
//         children: [
//           // messages
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: stream,
//               builder: (context, snapshot) {
//                 final serverMessages = snapshot.data ?? [];
//                 final allMessages = [
//                   ...serverMessages,
//                   ..._localMessages.where((m) => !serverMessages.contains(m))
//                 ];

//                 allMessages.sort((a, b) {
//                   final aTime = DateTime.tryParse(a['created_at'] ?? '') ??
//                       DateTime.fromMillisecondsSinceEpoch(0);
//                   final bTime = DateTime.tryParse(b['created_at'] ?? '') ??
//                       DateTime.fromMillisecondsSinceEpoch(0);
//                   return aTime.compareTo(bTime);
//                 });

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: allMessages.length,
//                   itemBuilder: (context, index) {
//                     final msg = allMessages[index];
//                     final isMe = msg['sender_id'] == currentUserId;
//                     final text = msg['message'] ?? '';
//                     final imageUrl = msg['image_url'];
//                     final reaction = msg['reaction'];

//                     return Align(
//                       alignment:
//                           isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: GestureDetector(
//                         onLongPress: () => _showMessageOptions(msg),
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: isMe ? kTeal : Colors.grey[200],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (imageUrl != null)
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.network(imageUrl,
//                                       width: 200, fit: BoxFit.cover),
//                                 ),
//                               if (imageUrl != null) const SizedBox(height: 6),
//                               if (text.isNotEmpty)
//                                 Text(
//                                   text,
//                                   style: TextStyle(
//                                     color: isMe ? Colors.white : Colors.black87,
//                                   ),
//                                 ),
//                               if (reaction != null)
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 4),
//                                   child: Text(
//                                     reaction,
//                                     style: const TextStyle(fontSize: 18),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // input row
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.photo, color: kTeal),
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.camera_alt, color: kTeal),
//                   onPressed: () => _pickImage(ImageSource.camera),
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: kTeal),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../utils/app_theme.dart';

// class ChatScreen extends StatefulWidget {
//   final String itemOwnerId;
//   final String itemOwnerName;
//   final String? itemOwnerAvatarUrl;

//   const ChatScreen({
//     super.key,
//     required this.itemOwnerId,
//     required this.itemOwnerName,
//     this.itemOwnerAvatarUrl,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollCtrl = ScrollController();

//   bool _showEmojiPicker = false;
//   final List<Map<String, dynamic>> _messages = [];

//   // ------------------- UI / Helpers -------------------

//   Future<void> _scrollToBottom() async {
//     await Future.delayed(const Duration(milliseconds: 100));
//     if (_scrollCtrl.hasClients) {
//       _scrollCtrl.animateTo(
//         _scrollCtrl.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   // ------------------- Send Text -------------------

//   void _sendText(String text) {
//     if (text.trim().isEmpty) return;
//     _messages.add({
//       'id': DateTime.now().millisecondsSinceEpoch.toString(),
//       'text': text,
//       'isMe': true,
//       'type': 'text',
//       'time': TimeOfDay.now().format(context),
//     });
//     _controller.clear();
//     setState(() {});
//     _scrollToBottom();
//   }

//   // ------------------- Send Image -------------------

//   Future<void> _sendImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: source, imageQuality: 75);
//     if (picked == null) return;

//     final bytes = await picked.readAsBytes();
//     _messages.add({
//       'id': DateTime.now().millisecondsSinceEpoch.toString(),
//       'imageBytes': bytes,
//       'isMe': true,
//       'type': 'image',
//       'time': TimeOfDay.now().format(context),
//     });
//     setState(() {});
//     _scrollToBottom();
//   }

//   // ------------------- Message Long Press Menu -------------------

//   void _onMessageLongPress(Map<String, dynamic> msg) async {
//     await showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => _buildMessageActions(msg),
//     );
//   }

//   Widget _buildMessageActions(Map<String, dynamic> msg) {
//     return SafeArea(
//       child: Wrap(
//         children: [
//           ListTile(
//             leading: const Icon(Icons.edit, color: Colors.blueAccent),
//             title: const Text('Edit'),
//             onTap: () {
//               Navigator.pop(context);
//               _editMessage(msg);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.delete, color: Colors.redAccent),
//             title: const Text('Delete'),
//             onTap: () {
//               Navigator.pop(context);
//               _deleteMessage(msg);
//             },
//           ),
//           const Divider(),
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Wrap(
//               spacing: 10,
//               children: [
//                 for (final emoji in ['❤️', '😂', '👍', '🔥', '😢'])
//                   GestureDetector(
//                     onTap: () {
//                       msg['reaction'] = emoji;
//                       Navigator.pop(context);
//                       setState(() {});
//                     },
//                     child: Text(emoji, style: const TextStyle(fontSize: 26)),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _editMessage(Map<String, dynamic> msg) {
//     _controller.text = msg['text'] ?? '';
//     _messages.remove(msg);
//     setState(() {});
//   }

//   void _deleteMessage(Map<String, dynamic> msg) {
//     _messages.remove(msg);
//     setState(() {});
//   }

//   // ------------------- UI -------------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kGreen,
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: widget.itemOwnerAvatarUrl != null
//                   ? NetworkImage(widget.itemOwnerAvatarUrl!)
//                   : null,
//               child: widget.itemOwnerAvatarUrl == null
//                   ? const Icon(Icons.person)
//                   : null,
//             ),
//             const SizedBox(width: 8),
//             Text(widget.itemOwnerName),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollCtrl,
//               padding: const EdgeInsets.all(12),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final msg = _messages[index];
//                 final isMe = msg['isMe'] == true;
//                 final isImage = msg['type'] == 'image';

//                 return GestureDetector(
//                   onLongPress: () => _onMessageLongPress(msg),
//                   child: Align(
//                     alignment:
//                         isMe ? Alignment.centerRight : Alignment.centerLeft,
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: isMe ? kTeal : Colors.grey[200],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           if (isImage)
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.memory(
//                                 msg['imageBytes'] as Uint8List,
//                                 width: 200,
//                                 fit: BoxFit.cover,
//                               ),
//                             )
//                           else
//                             Text(
//                               msg['text'] ?? '',
//                               style: TextStyle(
//                                 color: isMe ? Colors.white : Colors.black87,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (msg['reaction'] != null)
//                                 Text(msg['reaction'],
//                                     style: const TextStyle(fontSize: 18)),
//                               const SizedBox(width: 6),
//                               Text(
//                                 msg['time'] ?? '',
//                                 style: TextStyle(
//                                   color: isMe
//                                       ? Colors.white70
//                                       : Colors.grey.shade600,
//                                   fontSize: 10,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           _inputBar(),
//           if (_showEmojiPicker) _emojiPicker(),
//         ],
//       ),
//     );
//   }

//   Widget _inputBar() {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//         color: Colors.white,
//         child: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.emoji_emotions, color: kTeal),
//               onPressed: () => setState(() {
//                 _showEmojiPicker = !_showEmojiPicker;
//               }),
//             ),
//             IconButton(
//               icon: const Icon(Icons.photo, color: kTeal),
//               onPressed: () => _sendImage(ImageSource.gallery),
//             ),
//             IconButton(
//               icon: const Icon(Icons.camera_alt, color: kTeal),
//               onPressed: () => _sendImage(ImageSource.camera),
//             ),
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 decoration: const InputDecoration(
//                   hintText: 'Type a message...',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.send, color: kTeal),
//               onPressed: () => _sendText(_controller.text),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _emojiPicker() {
//     return SizedBox(
//       height: 250,
//       child: EmojiPicker(
//         onEmojiSelected: (category, emoji) {
//           _controller.text += emoji.emoji;
//         },
//       ),
//     );
//   }
// }
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';

// class ChatScreen extends StatefulWidget {
//   final String itemOwnerId;
//   final String itemOwnerName;
//   final String? itemOwnerAvatarUrl;

//   const ChatScreen({
//     super.key,
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
//   bool _sending = false;
//   bool _showEmojiPicker = false;
//     // 🧍 Owner info fetched from Supabase users table
//   String? _ownerName;
//   String? _ownerAvatar;


//   final DateFormat _timeFmt = DateFormat.jm(); // 12-hour format e.g. 3:30 PM


//     @override
//   void initState() {
//     super.initState();
//     currentUserId = _supabase.auth.currentUser?.id ?? '';
//     _loadOwnerProfile(); // 👈 fetch user name + avatar
//     _initChatAndStream();
//   }


//   @override
//   void dispose() {
//     _streamSub?.cancel();
//     _controller.dispose();
//     _scrollCtrl.dispose();
//     super.dispose();
//   }
//     Future<void> _loadOwnerProfile() async {
//     try {
//       final res = await _supabase
//           .from('users') // ✅ use your actual users table
//           .select('display_name, avatar_url')
//           .eq('id', widget.itemOwnerId)
//           .maybeSingle();

//       if (res != null) {
//         setState(() {
//           _ownerName = res['display_name']?.toString();
//           _ownerAvatar = res['avatar_url']?.toString();
//         });
//       }
//     } catch (e) {
//       debugPrint('⚠️ Profile fetch failed: $e');
//     }
//   }


//   // ---------------- Initialize chat + realtime stream ----------------
//   Future<void> _initChatAndStream() async {
//     try {
//       final chatsRes = await _supabase
//           .from('chats')
//           .select()
//           .or(
//               'and(user1_id.eq.$currentUserId,user2_id.eq.${widget.itemOwnerId}),and(user1_id.eq.${widget.itemOwnerId},user2_id.eq.$currentUserId)');

//       if (chatsRes != null && chatsRes.isNotEmpty) {
//         _chatId = chatsRes.first['id'].toString();
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
//       if (res != null) {
//         _messages
//           ..clear()
//           ..addAll(List<Map<String, dynamic>>.from(res));
//       } else {
//         _messages.clear();
//       }
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
//         .order('created_at');
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

//   // ---------------- Send Text (optimistic + DB) ----------------
//   Future<void> _sendText(String text) async {
//     final trimmed = text.trim();
//     if (_chatId == null || trimmed.isEmpty) return;

//     // optimistic local message
//     final tmpId = 'tmp-${DateTime.now().millisecondsSinceEpoch}';
//     final nowIso = DateTime.now().toIso8601String();
//     final localMsg = {
//       'id': tmpId,
//       'chat_id': _chatId,
//       'sender_id': currentUserId,
//       'receiver_id': widget.itemOwnerId,
//       'message': trimmed,
//       'image_url': null,
//       'reaction': null,
//       'created_at': nowIso,
//       'pending': true,
//     };

//     // add locally and clear input
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

//       // update chat last_message
//       await _supabase
//           .from('chats')
//           .update({'last_message': trimmed, 'updated_at': DateTime.now().toIso8601String()})
//           .eq('id', _chatId!);

//       // remove optimistic tmp (stream will also sync but remove tmp to avoid duplicates)
//       _messages.removeWhere((m) => m['id'] == tmpId);
//       // add server result if present
//       if (insertRes != null) {
//         _messages.add(Map<String, dynamic>.from(insertRes));
//       }
//       setState(() {});
//       _scrollToBottom();
//     } catch (e) {
//       // remove optimistic and show error
//       _messages.removeWhere((m) => m['id'] == tmpId);
//       setState(() {});
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Send failed: $e')));
//     }
//   }

//   // ---------------- Send Image (open sheet separate) ----------------
//   Future<void> _sendImage(ImageSource source) async {
//     if (_chatId == null) return;
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: source, imageQuality: 75);
//     if (picked == null) return;

//     final bytes = await picked.readAsBytes();
//     final fileName = '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final filePath = 'chat-images/$fileName';

//     // optimistic local image message
//     final tmpId = 'tmp-img-${DateTime.now().millisecondsSinceEpoch}';
//     final localMsg = {
//       'id': tmpId,
//       'chat_id': _chatId,
//       'sender_id': currentUserId,
//       'receiver_id': widget.itemOwnerId,
//       'message': '[image]',
//       'image_url': null,
//       'reaction': null,
//       'created_at': DateTime.now().toIso8601String(),
//       'pending': true,
//       'image_bytes': bytes, // show locally until server returns
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

//       // update chat last_message
//       await _supabase
//           .from('chats')
//           .update({'last_message': '[image]', 'updated_at': DateTime.now().toIso8601String()})
//           .eq('id', _chatId!);

//       // remove optimistic
//       _messages.removeWhere((m) => m['id'] == tmpId);
//       if (insertRes != null) _messages.add(Map<String, dynamic>.from(insertRes));
//       setState(() {});
//       _scrollToBottom();
//     } catch (e) {
//       _messages.removeWhere((m) => m['id'] == tmpId);
//       setState(() {});
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
//     }
//   }

//   // ---------------- Show bottom sheet for media (camera/gallery) ----------------
//   void _showMediaOptionsSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//       builder: (ctx) {
//         return SafeArea(
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library, color: kTeal),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 _sendImage(ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt, color: kTeal),
//               title: const Text('Take a Photo'),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 _sendImage(ImageSource.camera);
//               },
//             ),
//             const SizedBox(height: 8),
//           ]),
//         );
//       },
//     );
//   }

//   // ---------------- Long press message actions (edit/delete/react) ----------------
//   void _showMessageActions(Map<String, dynamic> msg) {
//     showModalBottomSheet(context: context, builder: (_) => _buildMessageActions(msg));
//   }

//   Widget _buildMessageActions(Map<String, dynamic> msg) {
//     final emojis = [
//       '❤️', '💖', '💗', '💞', '💕', '💘', '💝',
//       '😂', '🤣', '😅', '😊', '😇', '🥰', '😍',
//       '🤩', '😘', '😎', '😢', '😭', '😡', '😤',
//       '👍', '👎', '👏', '🙌', '🔥', '💪', '✨',
//       '😮', '🤔', '🤭', '😏', '🤫', '🥺', '😱',
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
//             height: 220,
//             child: GridView.builder(
//               shrinkWrap: true,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 7,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: emojis.length,
//               itemBuilder: (context, i) {
//                 final e = emojis[i];
//                 return GestureDetector(
//                   onTap: () {
//                     // set reaction locally; for backend you would update the row
//                     setState(() => msg['reaction'] = e);
//                     Navigator.pop(context);
//                   },
//                   child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
//                 );
//               },
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   void _editMessage(Map<String, dynamic> msg) {
//     // fill input with message text and remove the message to replace on save
//     _controller.text = (msg['message'] ?? '').toString();
//     _messages.remove(msg);
//     setState(() {});
//   }

//   void _deleteMessage(Map<String, dynamic> msg) async {
//     final id = msg['id']?.toString();
//     if (id == null) {
//       _messages.remove(msg);
//       setState(() {});
//       return;
//     }

//     // optimistic remove locally
//     _messages.removeWhere((m) => m['id'] == id);
//     setState(() {});

//     // if message exists on server, attempt delete there too
//     try {
//       await _supabase.from('messages').delete().eq('id', id);
//     } catch (e) {
//       debugPrint('Delete failed: $e');
//       // reload history to resync
//       await _loadHistory();
//     }
//   }

//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//   backgroundColor: kGreen,
//   title: Row(
//     children: [
//       CircleAvatar(
//         radius: 18,
//         backgroundImage: (_ownerAvatar != null && _ownerAvatar!.isNotEmpty)
//             ? NetworkImage(_ownerAvatar!)
//             : (widget.itemOwnerAvatarUrl != null
//                 ? NetworkImage(widget.itemOwnerAvatarUrl!)
//                 : null),
//         child: (_ownerAvatar == null && widget.itemOwnerAvatarUrl == null)
//             ? const Icon(Icons.person)
//             : null,
//       ),
//       const SizedBox(width: 8),
//       Text(
//         _ownerName ?? widget.itemOwnerName,
//         style: const TextStyle(fontWeight: FontWeight.w600),
//       ),
//     ],
//   ),
// ),

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
//                     final imageUrl = msg['image_url'];
//                     final reaction = msg['reaction'];
//                     final createdAtRaw = msg['created_at']?.toString();
//                     String formattedTime = '';
//                     if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
//                       final parsed = DateTime.tryParse(createdAtRaw);
//                       if (parsed != null) formattedTime = _timeFmt.format(parsed.toLocal());
//                     } else {
//                       // fallback to now
//                       formattedTime = _timeFmt.format(DateTime.now());
//                     }

//                     return GestureDetector(
//                       onLongPress: () => _showMessageActions(msg),
//                       child: Align(
//                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 6),
//                           child: Stack(clipBehavior: Clip.none, children: [
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: isMe ? kTeal : Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                                 if (imageUrl != null && imageUrl.toString().isNotEmpty)
//                                   Image.network(imageUrl.toString(), width: 220, fit: BoxFit.cover)
//                                 else if (msg['image_bytes'] != null)
//                                   Image.memory(msg['image_bytes'] as Uint8List, width: 220, fit: BoxFit.cover)
//                                 else
//                                   Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
//                                 const SizedBox(height: 6),
//                                 Text(formattedTime, style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : Colors.black45)),
//                               ]),
//                             ),

//                             // reaction small white bubble slightly below the message (bottom-right)
//                             if (reaction != null && reaction.toString().isNotEmpty)
//                               Positioned(
//                                 bottom: -12, // slightly below
//                                 right: -8,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(20),
//                                     boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
//                                   ),
//                                   child: Text(reaction.toString(), style: const TextStyle(fontSize: 16)),
//                                 ),
//                               ),
//                           ]),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),

//         // input + controls
//         Container(
//           padding: const EdgeInsets.all(8),
//           color: Colors.white,
//           child: Row(children: [
//             IconButton(
//               icon: Icon(_showEmojiPicker ? Icons.close : Icons.emoji_emotions, color: kTeal),
//               onPressed: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
//             ),
//             // <-- gallery icon that opens bottom sheet with both options
//             IconButton(icon: const Icon(Icons.photo, color: kTeal), onPressed: _showMediaOptionsSheet),
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 textInputAction: TextInputAction.send,
//                 onSubmitted: (v) => _sendText(v),
//                 decoration: const InputDecoration(hintText: 'Type a message...', border: OutlineInputBorder()),
//               ),
//             ),
//             IconButton(icon: const Icon(Icons.send, color: kTeal), onPressed: () => _sendText(_controller.text)),
//           ]),
//         ),

//         if (_showEmojiPicker)
//           SizedBox(
//             height: 250,
//             child: EmojiPicker(
//               onEmojiSelected: (_, emoji) => setState(() => _controller.text += emoji.emoji),
//             ),
//           ),
//       ]),
//     );
//   }

//   Widget _actionIcon(IconData icon, String label, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(children: [
//         CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
//         const SizedBox(height: 6),
//         Text(label),
//       ]),
//     );
//   }
// }
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';

// class ChatScreen extends StatefulWidget {
//   final String itemId; // 👈 Added for unique chat per item
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
//   bool _sending = false;
//   bool _showEmojiPicker = false;

//   String? _otherUserName;
//   String? _otherUserAvatar;

//   final DateFormat _timeFmt = DateFormat.jm(); // 12-hour format

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = _supabase.auth.currentUser?.id ?? '';
//     _initChatAndStream();
//     _loadOtherUserProfile();
//   }

//   @override
//   void dispose() {
//     _streamSub?.cancel();
//     _controller.dispose();
//     _scrollCtrl.dispose();
//     super.dispose();
//   }

//   // 🧠 Load correct user for AppBar
//   Future<void> _loadOtherUserProfile() async {
//     try {
//       final otherUserId = (currentUserId == widget.itemOwnerId)
//           ? await _getOtherChatUserId()
//           : widget.itemOwnerId;

//       if (otherUserId == null) return;

//       final res = await _supabase
//           .from('users')
//           .select('display_name, avatar_url')
//           .eq('id', otherUserId)
//           .maybeSingle();

//       if (res != null) {
//         setState(() {
//           _otherUserName = res['display_name'] ?? widget.itemOwnerName;
//           _otherUserAvatar = res['avatar_url'] ?? widget.itemOwnerAvatarUrl;
//         });
//       }
//     } catch (e) {
//       debugPrint('⚠️ Profile fetch failed: $e');
//     }
//   }

//   Future<String?> _getOtherChatUserId() async {
//     if (_chatId == null) return null;
//     try {
//       final chat = await _supabase
//           .from('chats')
//           .select('user1_id, user2_id')
//           .eq('id', _chatId!)
//           .maybeSingle();
//       if (chat == null) return null;
//       return chat['user1_id'] == currentUserId
//           ? chat['user2_id']
//           : chat['user1_id'];
//     } catch (_) {
//       return null;
//     }
//   }

//   // ---------------- Initialize chat + realtime stream ----------------
//   Future<void> _initChatAndStream() async {
//     try {
//       // find or create chat for this item only
//       final chatsRes = await _supabase
//           .from('chats')
//           .select()
//           .eq('item_id', widget.itemId)
//           .or(
//               'and(user1_id.eq.$currentUserId,user2_id.eq.${widget.itemOwnerId}),and(user1_id.eq.${widget.itemOwnerId},user2_id.eq.$currentUserId)');

//       if (chatsRes != null && chatsRes.isNotEmpty) {
//         _chatId = chatsRes.first['id'].toString();
//       } else {
//         final newChat = await _supabase
//             .from('chats')
//             .insert({
//               'item_id': widget.itemId,
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
//         .order('created_at');
//     _streamSub = stream.listen((rows) {
//       _messages
//         ..clear()
//         ..addAll(List<Map<String, dynamic>>.from(rows));
//       setState(() {});
//       _scrollToBottom();
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

//   // ---------------- Send Text ----------------
//   Future<void> _sendText(String text) async {
//     final trimmed = text.trim();
//     if (_chatId == null || trimmed.isEmpty) return;

//     final tmpId = 'tmp-${DateTime.now().millisecondsSinceEpoch}';
//     final nowIso = DateTime.now().toIso8601String();

//     final localMsg = {
//       'id': tmpId,
//       'chat_id': _chatId,
//       'item_id': widget.itemId,
//       'sender_id': currentUserId,
//       'receiver_id': widget.itemOwnerId,
//       'message': trimmed,
//       'created_at': nowIso,
//       'pending': true,
//     };

//     _messages.add(localMsg);
//     _controller.clear();
//     setState(() {});
//     _scrollToBottom();

//     try {
//       final insertRes = await _supabase.from('messages').insert({
//         'chat_id': _chatId!,
//         'item_id': widget.itemId,
//         'sender_id': currentUserId,
//         'receiver_id': widget.itemOwnerId,
//         'message': trimmed,
//       }).select().single();

//       await _supabase
//           .from('chats')
//           .update({'last_message': trimmed, 'updated_at': nowIso})
//           .eq('id', _chatId!);

//       _messages.removeWhere((m) => m['id'] == tmpId);
//       if (insertRes != null) _messages.add(Map<String, dynamic>.from(insertRes));
//       setState(() {});
//       _scrollToBottom();
//     } catch (e) {
//       debugPrint('Send failed: $e');
//     }
//   }

//   // ---------------- Send Image ----------------
//   Future<void> _sendImage(ImageSource source) async {
//     if (_chatId == null) return;
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: source, imageQuality: 75);
//     if (picked == null) return;

//     final bytes = await picked.readAsBytes();
//     final fileName =
//         '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final filePath = 'chat-images/$fileName';

//     try {
//       final storage = _supabase.storage.from('item-images');
//       await storage.uploadBinary(filePath, Uint8List.fromList(bytes));
//       final publicUrl = storage.getPublicUrl(filePath);

//       await _supabase.from('messages').insert({
//         'chat_id': _chatId!,
//         'item_id': widget.itemId,
//         'sender_id': currentUserId,
//         'receiver_id': widget.itemOwnerId,
//         'message': '[image]',
//         'image_url': publicUrl,
//       });

//       await _supabase
//           .from('chats')
//           .update({'last_message': '[image]', 'updated_at': DateTime.now().toIso8601String()})
//           .eq('id', _chatId!);
//     } catch (e) {
//       debugPrint('Image upload failed: $e');
//     }
//   }

//   void _showMediaOptionsSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//       builder: (ctx) {
//         return SafeArea(
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library, color: kTeal),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 _sendImage(ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt, color: kTeal),
//               title: const Text('Take a Photo'),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 _sendImage(ImageSource.camera);
//               },
//             ),
//           ]),
//         );
//       },
//     );
//   }

//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kGreen,
//         title: Row(children: [
//           CircleAvatar(
//             radius: 18,
//             backgroundImage: (_otherUserAvatar != null &&
//                     _otherUserAvatar!.isNotEmpty)
//                 ? NetworkImage(_otherUserAvatar!)
//                 : (widget.itemOwnerAvatarUrl != null
//                     ? NetworkImage(widget.itemOwnerAvatarUrl!)
//                     : null),
//             child: (_otherUserAvatar == null &&
//                     widget.itemOwnerAvatarUrl == null)
//                 ? const Icon(Icons.person)
//                 : null,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             _otherUserName ?? widget.itemOwnerName,
//             style: const TextStyle(fontWeight: FontWeight.w600),
//           ),
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
//                     final imageUrl = msg['image_url'];
//                     final createdAtRaw = msg['created_at']?.toString();
//                     String formattedTime = '';
//                     if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
//                       final parsed = DateTime.tryParse(createdAtRaw);
//                       if (parsed != null) {
//                         formattedTime = _timeFmt.format(parsed.toLocal());
//                       }
//                     }

//                     return Align(
//                       alignment: isMe
//                           ? Alignment.centerRight
//                           : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isMe ? kTeal : Colors.grey[200],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               if (imageUrl != null &&
//                                   imageUrl.toString().isNotEmpty)
//                                 Image.network(imageUrl.toString(),
//                                     width: 220, fit: BoxFit.cover)
//                               else
//                                 Text(
//                                   text,
//                                   style: TextStyle(
//                                       color: isMe
//                                           ? Colors.white
//                                           : Colors.black87),
//                                 ),
//                               const SizedBox(height: 6),
//                               Text(formattedTime,
//                                   style: TextStyle(
//                                       fontSize: 11,
//                                       color: isMe
//                                           ? Colors.white70
//                                           : Colors.black45)),
//                             ]),
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
//                 onPressed: _showMediaOptionsSheet),
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 textInputAction: TextInputAction.send,
//                 onSubmitted: (v) => _sendText(v),
//                 decoration: const InputDecoration(
//                     hintText: 'Type a message...',
//                     border: OutlineInputBorder()),
//               ),
//             ),
//             IconButton(
//                 icon: const Icon(Icons.send, color: kTeal),
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
// }
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';

// class ChatScreen extends StatefulWidget {
//   final String itemId; // chat id from ChatList
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

//   Future<void> _loadOwnerProfile() async {
//     try {
//       final res = await _supabase
//           .from('users')
//           .select('display_name, avatar_url')
//           .eq('id', widget.itemOwnerId)
//           .maybeSingle();
//       if (res != null) {
//         setState(() {
//           _ownerName = res['display_name']?.toString();
//           _ownerAvatar = res['avatar_url']?.toString();
//         });
//       }
//     } catch (e) {
//       debugPrint('⚠️ Profile fetch failed: $e');
//     }
//   }

//   // 🔹 Initialize or fetch existing chat
//   Future<void> _initChatAndStream() async {
//     try {
//       final existing = await _supabase
//           .from('chats')
//           .select()
//           .or(
//               'and(user1_id.eq.$currentUserId,user2_id.eq.${widget.itemOwnerId}),and(user1_id.eq.${widget.itemOwnerId},user2_id.eq.$currentUserId)')
//           .limit(1);

//       if (existing.isNotEmpty) {
//         _chatId = existing.first['id'].toString();
//       } else {
//         final newChat = await _supabase
//             .from('chats')
//             .insert({
//               'user1_id': currentUserId,
//               'user2_id': widget.itemOwnerId,
//               'last_message': '',
//               'created_at': DateTime.now().toIso8601String(),
//               'updated_at': DateTime.now().toIso8601String(),
//             })
//             .select()
//             .single();
//         _chatId = newChat['id'].toString();
//       }

//       await _loadHistory();
//       _attachStream();
//       setState(() {});
//     } catch (e) {
//       debugPrint('❌ Chat init error: $e');
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
//       setState(() {
//         _messages
//           ..clear()
//           ..addAll(List<Map<String, dynamic>>.from(res));
//       });
//       _scrollToBottom();
//     } catch (e) {
//       debugPrint('❌ Load history error: $e');
//     }
//   }

//   void _attachStream() {
//     if (_chatId == null) return;
//     _streamSub?.cancel();
//     final stream = _supabase
//         .from('messages')
//         .stream(primaryKey: ['id'])
//         .eq('chat_id', _chatId!)
//         .order('created_at');
//     _streamSub = stream.listen((rows) {
//       _messages
//         ..clear()
//         ..addAll(List<Map<String, dynamic>>.from(rows));
//       setState(() {});
//       _scrollToBottom();
//     });
//   }

//   Future<void> _scrollToBottom() async {
//     await Future.delayed(const Duration(milliseconds: 100));
//     if (_scrollCtrl.hasClients) {
//       _scrollCtrl.animateTo(
//         _scrollCtrl.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   // 🔹 Send text message
//   Future<void> _sendText(String text) async {
//     final msg = text.trim();
//     if (msg.isEmpty || _chatId == null) return;
//     _controller.clear();

//     final tempId = 'local-${DateTime.now().millisecondsSinceEpoch}';
//     final now = DateTime.now().toIso8601String();
//     final localMsg = {
//       'id': tempId,
//       'chat_id': _chatId,
//       'sender_id': currentUserId,
//       'receiver_id': widget.itemOwnerId,
//       'message': msg,
//       'created_at': now,
//     };
//     _messages.add(localMsg);
//     setState(() {});
//     _scrollToBottom();

//     try {
//       final inserted = await _supabase.from('messages').insert({
//         'chat_id': _chatId!,
//         'sender_id': currentUserId,
//         'receiver_id': widget.itemOwnerId,
//         'message': msg,
//       }).select().single();

//       await _supabase.from('chats').update({
//         'last_message': msg,
//         'updated_at': DateTime.now().toIso8601String(),
//       }).eq('id', _chatId!);

//       _messages.removeWhere((m) => m['id'] == tempId);
//       _messages.add(inserted);
//       setState(() {});
//       _scrollToBottom();
//     } catch (e) {
//       debugPrint('❌ Send failed: $e');
//     }
//   }

//   // 🔹 Send image
//   Future<void> _sendImage(ImageSource source) async {
//     if (_chatId == null) return;
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: source, imageQuality: 70);
//     if (picked == null) return;

//     final bytes = await picked.readAsBytes();
//     final fileName =
//         '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final filePath = 'chat-images/$fileName';
//     try {
//       final storage = _supabase.storage.from('item-images');
//       await storage.uploadBinary(filePath, Uint8List.fromList(bytes));
//       final imageUrl = storage.getPublicUrl(filePath);

//       final inserted = await _supabase.from('messages').insert({
//         'chat_id': _chatId!,
//         'sender_id': currentUserId,
//         'receiver_id': widget.itemOwnerId,
//         'message': '[image]',
//         'image_url': imageUrl,
//       }).select().single();

//       await _supabase.from('chats').update({
//         'last_message': '[image]',
//         'updated_at': DateTime.now().toIso8601String(),
//       }).eq('id', _chatId!);

//       _messages.add(inserted);
//       setState(() {});
//       _scrollToBottom();
//     } catch (e) {
//       debugPrint('❌ Image send failed: $e');
//     }
//   }

//   // 🔹 Show image/camera sheet
//   void _showMediaSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (ctx) => SafeArea(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           ListTile(
//             leading: const Icon(Icons.photo_library, color: kTeal),
//             title: const Text('Gallery'),
//             onTap: () {
//               Navigator.pop(ctx);
//               _sendImage(ImageSource.gallery);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.camera_alt, color: kTeal),
//             title: const Text('Camera'),
//             onTap: () {
//               Navigator.pop(ctx);
//               _sendImage(ImageSource.camera);
//             },
//           ),
//           const SizedBox(height: 8),
//         ]),
//       ),
//     );
//   }

//   // ---------------- Long press message actions (edit/delete/react) ----------------
//   void _showMessageActions(Map<String, dynamic> msg) {
//     showModalBottomSheet(context: context, builder: (_) => _buildMessageActions(msg));
//   }

//   Widget _buildMessageActions(Map<String, dynamic> msg) {
//     final emojis = [
//       '❤️','💖','💗','💞','💕','💘','💝',
//       '😂','🤣','😅','😊','😇','🥰','😍',
//       '🤩','😘','😎','😢','😭','😡','😤',
//       '👍','👎','👏','🙌','🔥','💪','✨',
//       '😮','🤔','🤭','😏','🤫','🥺','😱',
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
//             height: 220,
//             child: GridView.builder(
//               shrinkWrap: true,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 7,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: emojis.length,
//               itemBuilder: (context, i) {
//                 final e = emojis[i];
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() => msg['reaction'] = e);
//                     Navigator.pop(context);
//                   },
//                   child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
//                 );
//               },
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   void _editMessage(Map<String, dynamic> msg) {
//     _controller.text = (msg['message'] ?? '').toString();
//     _messages.remove(msg);
//     setState(() {});
//   }

//   void _deleteMessage(Map<String, dynamic> msg) async {
//     final id = msg['id']?.toString();
//     if (id == null) {
//       _messages.remove(msg);
//       setState(() {});
//       return;
//     }
//     _messages.removeWhere((m) => m['id'] == id);
//     setState(() {});
//     try {
//       await _supabase.from('messages').delete().eq('id', id);
//     } catch (e) {
//       debugPrint('Delete failed: $e');
//       await _loadHistory();
//     }
//   }

//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
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
//             child: (_ownerAvatar == null &&
//                     (widget.itemOwnerAvatarUrl == null ||
//                         widget.itemOwnerAvatarUrl!.isEmpty))
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
//                     final isMe = msg['sender_id'] == currentUserId;
//                     final text = msg['message'] ?? '';
//                     final image = msg['image_url'];
//                     final reaction = msg['reaction'];
//                     final createdAt = msg['created_at'] ?? '';
//                     final formatted = createdAt.isNotEmpty
//                         ? _timeFmt.format(DateTime.parse(createdAt).toLocal())
//                         : '';

//                     return GestureDetector(
//                       onLongPress: () => _showMessageActions(msg),
//                       child: Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Stack(
//                           clipBehavior: Clip.none,
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.symmetric(vertical: 6),
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: isMe ? kTeal : Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   if (image != null &&
//                                       image.toString().isNotEmpty)
//                                     Image.network(image, width: 220)
//                                   else
//                                     Text(text,
//                                         style: TextStyle(
//                                             color: isMe
//                                                 ? Colors.white
//                                                 : Colors.black87)),
//                                   const SizedBox(height: 5),
//                                   Text(formatted,
//                                       style: TextStyle(
//                                           fontSize: 11,
//                                           color: isMe
//                                               ? Colors.white70
//                                               : Colors.black45)),
//                                 ],
//                               ),
//                             ),
//                             if (reaction != null && reaction.toString().isNotEmpty)
//                               Positioned(
//                                 bottom: -12,
//                                 right: -8,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 6, vertical: 2),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(20),
//                                     boxShadow: const [
//                                       BoxShadow(
//                                           color: Colors.black12, blurRadius: 2)
//                                     ],
//                                   ),
//                                   child: Text(reaction.toString(),
//                                       style: const TextStyle(fontSize: 16)),
//                                 ),
//                               ),
//                           ],
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
//               icon: Icon(
//                   _showEmojiPicker ? Icons.close : Icons.emoji_emotions,
//                   color: kTeal),
//               onPressed: () =>
//                   setState(() => _showEmojiPicker = !_showEmojiPicker),
//             ),
//             IconButton(
//                 icon: const Icon(Icons.photo, color: kTeal),
//                 onPressed: _showMediaSheet),
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 textInputAction: TextInputAction.send,
//                 onSubmitted: (v) => _sendText(v),
//                 decoration: const InputDecoration(
//                     hintText: 'Type a message...',
//                     border: OutlineInputBorder()),
//               ),
//             ),
//             IconButton(
//                 icon: const Icon(Icons.send, color: kTeal),
//                 onPressed: () => _sendText(_controller.text)),
//           ]),
//         ),
//         if (_showEmojiPicker)
//           SizedBox(
//             height: 250,
//             child: EmojiPicker(
//                 onEmojiSelected: (_, emoji) =>
//                     setState(() => _controller.text += emoji.emoji)),
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
// }
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

//   Future<void> _loadOwnerProfile() async {
//     try {
//       final res = await _supabase
//           .from('users')
//           .select('display_name, avatar_url')
//           .eq('id', widget.itemOwnerId)
//           .maybeSingle();

//       if (res != null) {
//         setState(() {
//           _ownerName = res['display_name']?.toString();
//           _ownerAvatar = res['avatar_url']?.toString();
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
//           .eq('user1_id', currentUserId)
//           .eq('user2_id', widget.itemOwnerId)
//           .maybeSingle();

//       if (chatsRes != null) {
//         _chatId = chatsRes['id'].toString();
//       } else {
//         final reverseChat = await _supabase
//             .from('chats')
//             .select()
//             .eq('user1_id', widget.itemOwnerId)
//             .eq('user2_id', currentUserId)
//             .maybeSingle();

//         if (reverseChat != null) {
//           _chatId = reverseChat['id'].toString();
//         } else {
//           final newChat = await _supabase
//               .from('chats')
//               .insert({
//                 'user1_id': currentUserId,
//                 'user2_id': widget.itemOwnerId,
//                 'last_message': '',
//               })
//               .select()
//               .single();
//           _chatId = newChat['id'].toString();
//         }
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
//     final res = await _supabase
//         .from('messages')
//         .select()
//         .eq('chat_id', _chatId!)
//         .order('created_at', ascending: true);
//     _messages
//       ..clear()
//       ..addAll(List<Map<String, dynamic>>.from(res));
//     setState(() {});
//     _scrollToBottom();
//   }

//   void _attachStream() {
//     if (_chatId == null) return;
//     _streamSub?.cancel();
//     final stream = _supabase
//         .from('messages')
//         .stream(primaryKey: ['id'])
//         .eq('chat_id', _chatId!)
//         .order('created_at');
//     _streamSub = stream.listen((rows) {
//       _messages
//         ..clear()
//         ..addAll(List<Map<String, dynamic>>.from(rows));
//       setState(() {});
//       _scrollToBottom();
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
//           .update({'last_message': trimmed})
//           .eq('id', _chatId!);

//       _messages.removeWhere((m) => m['id'] == tmpId);
//       _messages.add(Map<String, dynamic>.from(insertRes));
//       setState(() {});
//       _scrollToBottom();
//     } catch (e) {
//       debugPrint('Send failed: $e');
//     }
//   }

//   // 🟢 IMAGE SENDING
//   Future<void> _sendImage(ImageSource source) async {
//     if (_chatId == null) return;
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: source, imageQuality: 75);
//     if (picked == null) return;

//     final bytes = await picked.readAsBytes();
//     final fileName =
//         '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final filePath = 'chat-images/$fileName';

//     try {
//       final storage = _supabase.storage.from('item-images');
//       await storage.uploadBinary(filePath, Uint8List.fromList(bytes));
//       final publicUrl = storage.getPublicUrl(filePath);

//       await _supabase.from('messages').insert({
//         'chat_id': _chatId!,
//         'sender_id': currentUserId,
//         'receiver_id': widget.itemOwnerId,
//         'message': '[image]',
//         'image_url': publicUrl,
//       });
//     } catch (e) {
//       debugPrint('Image upload failed: $e');
//     }
//   }

//   void _showMediaOptionsSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//       builder: (ctx) {
//         return SafeArea(
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library, color: kTeal),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 _sendImage(ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt, color: kTeal),
//               title: const Text('Take a Photo'),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 _sendImage(ImageSource.camera);
//               },
//             ),
//           ]),
//         );
//       },
//     );
//   }

//   // 🟢 LONG PRESS — edit/delete/react
//   void _showMessageActions(Map<String, dynamic> msg) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => _buildMessageActions(msg),
//     );
//   }

//   Widget _buildMessageActions(Map<String, dynamic> msg) {
//     final emojis = [
//       '❤️', '😂', '🔥', '👍', '👏', '😢', '😍', '😡', '😭', '💯'
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
//           const Divider(),
//           Wrap(
//             alignment: WrapAlignment.center,
//             spacing: 12,
//             children: emojis.map((e) {
//               return GestureDetector(
//                 onTap: () async {
//                   setState(() => msg['reaction'] = e);
//                   Navigator.pop(context);
//                   try {
//                     await _supabase
//                         .from('messages')
//                         .update({'reaction': e}).eq('id', msg['id']);
//                   } catch (err) {
//                     debugPrint('Reaction update failed: $err');
//                   }
//                 },
//                 child: Text(e, style: const TextStyle(fontSize: 26)),
//               );
//             }).toList(),
//           ),
//         ]),
//       ),
//     );
//   }

//   void _editMessage(Map<String, dynamic> msg) {
//     _controller.text = msg['message'] ?? '';
//     _messages.remove(msg);
//     setState(() {});
//     _scrollToBottom();

//     // update on send again
//   }

//   void _deleteMessage(Map<String, dynamic> msg) async {
//     final id = msg['id']?.toString();
//     if (id == null) return;
//     _messages.removeWhere((m) => m['id'] == id);
//     setState(() {});

//     try {
//       await _supabase.from('messages').delete().eq('id', id);
//     } catch (e) {
//       debugPrint('Delete failed: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
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
//                     final imageUrl = msg['image_url'];
//                     final reaction = msg['reaction'];
//                     final createdAtRaw = msg['created_at']?.toString();

//                     String formattedTime = '';
//                     if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
//                       final parsed = DateTime.tryParse(createdAtRaw);
//                       if (parsed != null) {
//                         formattedTime = _timeFmt.format(parsed.toLocal());
//                       }
//                     }

//                     return GestureDetector(
//                       onLongPress: () => _showMessageActions(msg),
//                       child: Align(
//                         alignment: isMe
//                             ? Alignment.centerRight
//                             : Alignment.centerLeft,
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
//                                     if (imageUrl != null &&
//                                         imageUrl.toString().isNotEmpty)
//                                       Image.network(imageUrl.toString(),
//                                           width: 220, fit: BoxFit.cover)
//                                     else
//                                       Text(
//                                         text,
//                                         style: TextStyle(
//                                             color: isMe
//                                                 ? Colors.white
//                                                 : Colors.black87),
//                                       ),
//                                     const SizedBox(height: 6),
//                                     Text(formattedTime,
//                                         style: TextStyle(
//                                             fontSize: 11,
//                                             color: isMe
//                                                 ? Colors.white70
//                                                 : Colors.black45)),
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
//                   }),
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
//                 onPressed: _showMediaOptionsSheet),
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 textInputAction: TextInputAction.send,
//                 onSubmitted: (v) => _sendText(v),
//                 decoration: const InputDecoration(
//                     hintText: 'Type a message...', border: OutlineInputBorder()),
//               ),
//             ),
//             IconButton(
//                 icon: const Icon(Icons.send, color: kTeal),
//                 onPressed: () => _sendText(_controller.text)),
//           ]),
//         ),
//         if (_showEmojiPicker)
//           SizedBox(
//             height: 250,
//             child: EmojiPicker(
//                 onEmojiSelected: (_, emoji) =>
//                     setState(() => _controller.text += emoji.emoji)),
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
// }
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

//   // ✳️ Editing state
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

//   Future<void> _loadOwnerProfile() async {
//     try {
//       final res = await _supabase
//           .from('users')
//           .select('display_name, avatar_url')
//           .eq('id', widget.itemOwnerId)
//           .maybeSingle();

//       if (res != null) {
//         setState(() {
//           _ownerName = res['display_name']?.toString();
//           _ownerAvatar = res['avatar_url']?.toString();
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
//           .eq('user1_id', currentUserId)
//           .eq('user2_id', widget.itemOwnerId)
//           .maybeSingle();

//       if (chatsRes != null) {
//         _chatId = chatsRes['id'].toString();
//       } else {
//         final reverseChat = await _supabase
//             .from('chats')
//             .select()
//             .eq('user1_id', widget.itemOwnerId)
//             .eq('user2_id', currentUserId)
//             .maybeSingle();

//         if (reverseChat != null) {
//           _chatId = reverseChat['id'].toString();
//         } else {
//           final newChat = await _supabase
//               .from('chats')
//               .insert({
//                 'user1_id': currentUserId,
//                 'user2_id': widget.itemOwnerId,
//                 'last_message': '',
//               })
//               .select()
//               .single();
//           _chatId = newChat['id'].toString();
//         }
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
//         .order('created_at');
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

//   // ---------------- Send Text (insert or update if editing) ----------------
//   Future<void> _sendText(String text) async {
//     final trimmed = text.trim();
//     if (_chatId == null || trimmed.isEmpty) return;

//     // If we are editing a message -> update it
//     if (_editingMessageId != null) {
//       final editingId = _editingMessageId!;
//       try {
//         // update in DB
//         await _supabase
//             .from('messages')
//             .update({'message': trimmed, 'updated_at': DateTime.now().toIso8601String()})
//             .eq('id', editingId);

//         // update local list
//         final idx = _messages.indexWhere((m) => m['id']?.toString() == editingId);
//         if (idx != -1) {
//           _messages[idx]['message'] = trimmed;
//           _messages[idx]['updated_at'] = DateTime.now().toIso8601String();
//         }

//         // clear editing state
//         _editingMessageId = null;
//         _controller.clear();
//         setState(() {});
//         _scrollToBottom();
//       } catch (e) {
//         debugPrint('Edit update failed: $e');
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update message')));
//       }
//       return;
//     }

//     // Normal send (insert)
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
//           .update({'last_message': trimmed})
//           .eq('id', _chatId!);

//       _messages.removeWhere((m) => m['id'] == tmpId);
//       _messages.add(Map<String, dynamic>.from(insertRes));
//       setState(() {});
//       _scrollToBottom();
//     } catch (e) {
//       debugPrint('Send failed: $e');
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Send failed')));
//     }
//   }

//   // 🟢 IMAGE SENDING
//   Future<void> _sendImage(ImageSource source) async {
//     if (_chatId == null) return;
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: source, imageQuality: 75);
//     if (picked == null) return;

//     final bytes = await picked.readAsBytes();
//     final fileName = '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final filePath = 'chat-images/$fileName';

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
//           .update({'last_message': '[image]'})
//           .eq('id', _chatId!);

//       if (insertRes != null) {
//         _messages.add(Map<String, dynamic>.from(insertRes));
//         setState(() {});
//         _scrollToBottom();
//       }
//     } catch (e) {
//       debugPrint('Image upload failed: $e');
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed')));
//     }
//   }

//   void _showMediaOptionsSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//       builder: (ctx) {
//         return SafeArea(
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library, color: kTeal),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 _sendImage(ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt, color: kTeal),
//               title: const Text('Take a Photo'),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 _sendImage(ImageSource.camera);
//               },
//             ),
//             const SizedBox(height: 8),
//           ]),
//         );
//       },
//     );
//   }

//   // ---------------- Long press message actions (edit/delete/react) ----------------
//   void _showMessageActions(Map<String, dynamic> msg) {
//     showModalBottomSheet(context: context, builder: (_) => _buildMessageActions(msg));
//   }

//   Widget _buildMessageActions(Map<String, dynamic> msg) {
//     // Expanded emoji set
//     final emojis = [
//       '❤️','💖','💗','💞','💕','💘','💝','💓','💟','❣️','💜','🧡','💛','💚',
//       '😂','🤣','😊','😇','🙂','😉','😌','😍','😘','😗','😙','😚','🤩','🥰',
//       '😅','😆','😎','🤓','🧐','😏','😕','🤔','🤨','😐','😑','🙄','😒','😬',
//       '😭','😢','😤','😠','😡','🤬','😳','🥺','😱','😨','😰','😥','😓',
//       '👍','👎','👏','🙌','🤝','🙏','💪','🔥','✨','⭐','💯','🎉','🎊','🎈',
//       '😴','🤤','🤢','🤮','🤧','😵','🤯','🤠','🥳','🤗','🤡','👀','🤲','🫡'
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
//                     // set reaction locally; update backend
//                     setState(() => msg['reaction'] = e);
//                     Navigator.pop(context);

//                     final id = msg['id']?.toString();
//                     if (id == null) return;
//                     try {
//                       await _supabase.from('messages').update({'reaction': e}).eq('id', id);
//                     } catch (err) {
//                       debugPrint('Reaction update failed: $err');
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save reaction')));
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

//   void _editMessage(Map<String, dynamic> msg) {
//     // set editing id and put message text into input
//     final id = msg['id']?.toString();
//     _editingMessageId = id;
//     _controller.text = msg['message'] ?? '';
//     setState(() {});
//     // optionally focus the input
//     Future.delayed(const Duration(milliseconds: 120), () {
//       if (mounted) {
//         FocusScope.of(context).requestFocus(FocusNode()); // keep behavior same; adjust if you want autofocus
//       }
//     });
//   }

//   void _deleteMessage(Map<String, dynamic> msg) async {
//     final id = msg['id']?.toString();
//     if (id == null) {
//       _messages.remove(msg);
//       setState(() {});
//       return;
//     }

//     // if we are editing same message, cancel edit
//     if (_editingMessageId != null && _editingMessageId == id) {
//       _editingMessageId = null;
//       _controller.clear();
//     }

//     // optimistic remove locally
//     _messages.removeWhere((m) => m['id']?.toString() == id);
//     setState(() {});

//     // delete from server
//     try {
//       await _supabase.from('messages').delete().eq('id', id);
//     } catch (e) {
//       debugPrint('Delete failed: $e');
//       // reload history to resync
//       await _loadHistory();
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete failed')));
//     }
//   }

//   // ---------------- UI ----------------
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
//                 : (widget.itemOwnerAvatarUrl != null ? NetworkImage(widget.itemOwnerAvatarUrl!) : null),
//             child: (_ownerAvatar == null && widget.itemOwnerAvatarUrl == null) ? const Icon(Icons.person) : null,
//           ),
//           const SizedBox(width: 8),
//           Text(_ownerName ?? widget.itemOwnerName, style: const TextStyle(fontWeight: FontWeight.w600)),
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
//                     final imageUrl = msg['image_url'];
//                     final reaction = msg['reaction'];
//                     final createdAtRaw = msg['created_at']?.toString();
//                     String formattedTime = '';
//                     if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
//                       final parsed = DateTime.tryParse(createdAtRaw);
//                       if (parsed != null) formattedTime = _timeFmt.format(parsed.toLocal());
//                     }

//                     return GestureDetector(
//                       onLongPress: () => _showMessageActions(msg),
//                       child: Align(
//                         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 6),
//                           child: Stack(clipBehavior: Clip.none, children: [
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: isMe ? kTeal : Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                                 if (imageUrl != null && imageUrl.toString().isNotEmpty)
//                                   Image.network(imageUrl.toString(), width: 220, fit: BoxFit.cover)
//                                 else
//                                   Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
//                                 const SizedBox(height: 6),
//                                 Text(formattedTime, style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : Colors.black45)),
//                               ]),
//                             ),

//                             // reaction small white bubble slightly below the message (bottom-right)
//                             if (reaction != null && reaction.toString().isNotEmpty)
//                               Positioned(
//                                 bottom: -12,
//                                 right: -8,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(20),
//                                     boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
//                                   ),
//                                   child: Text(reaction.toString(), style: const TextStyle(fontSize: 16)),
//                                 ),
//                               ),
//                           ]),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),

//         // input + controls
//         Container(
//           padding: const EdgeInsets.all(8),
//           color: Colors.white,
//           child: Row(children: [
//             IconButton(
//               icon: Icon(_showEmojiPicker ? Icons.close : Icons.emoji_emotions, color: kTeal),
//               onPressed: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
//             ),
//             IconButton(icon: const Icon(Icons.photo, color: kTeal), onPressed: _showMediaOptionsSheet),
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 textInputAction: TextInputAction.send,
//                 onSubmitted: (v) => _sendText(v),
//                 decoration: InputDecoration(
//                   hintText: isEditing ? 'Editing message...' : 'Type a message...',
//                   border: const OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             IconButton(
//               icon: Icon(isEditing ? Icons.check : Icons.send, color: kTeal),
//               onPressed: () => _sendText(_controller.text),
//             ),
//           ]),
//         ),

//         if (_showEmojiPicker)
//           SizedBox(
//             height: 250,
//             child: EmojiPicker(
//               onEmojiSelected: (_, emoji) => setState(() => _controller.text += emoji.emoji),
//             ),
//           ),
//       ]),
//     );
//   }

//   Widget _actionIcon(IconData icon, String label, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(children: [
//         CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
//         const SizedBox(height: 6),
//         Text(label),
//       ]),
//     );
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
        _ownerName = widget.itemOwnerName; // fallback from navigation
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
          .order('created_at', ascending: true); // bottom order
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

  // ---------- Send / Edit ----------
  Future<void> _sendText(String text) async {
    final trimmed = text.trim();
    if (_chatId == null || trimmed.isEmpty) return;

    // ✏️ Editing existing message
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

    // 📨 Sending new message
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
          .update({'last_message': trimmed, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', _chatId!);

      _messages.removeWhere((m) => m['id'] == tmpId);
      _messages.add(Map<String, dynamic>.from(insertRes));
      _messages.sort((a, b) =>
          DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
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

  // ---------- Long Press ----------
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

  // ---------- UI ----------
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
      body: Column(children: [
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
    }
  }
}
