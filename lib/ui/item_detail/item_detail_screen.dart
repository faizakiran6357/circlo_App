// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';
// import '../chat/chat_screen.dart';
// import 'comments_section.dart';

// class ItemDetailScreen extends StatelessWidget {
//   final Map<String, dynamic> item;

//   const ItemDetailScreen({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(item['title'] ?? 'Item Detail'),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image
//             item['image_url'] != null
//                 ? Image.network(item['image_url'], fit: BoxFit.cover, width: double.infinity, height: 240)
//                 : Container(
//                     color: Colors.grey[300],
//                     height: 240,
//                     child: const Center(child: Icon(Icons.image, size: 80, color: Colors.white)),
//                   ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(item['title'] ?? '', style: Theme.of(context).textTheme.titleLarge),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(Icons.person, size: 18, color: Colors.grey),
//                       const SizedBox(width: 6),
//                       Text(item['owner_name'] ?? 'Unknown user', style: const TextStyle(color: Colors.grey)),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(item['description'] ?? 'No description available.'),
//                   const SizedBox(height: 20),
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kGreen,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => ChatScreen(itemOwnerId: item['user_id'] ?? '')),
//                       );
//                     },
//                     icon: const Icon(Icons.chat_bubble_outline),
//                     label: const Text("Chat with Owner"),
//                   ),
//                   const SizedBox(height: 20),
//                   const Divider(),
//                   const CommentsSection(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import '../../models/item_model.dart';
// import '../../utils/app_theme.dart';
// import '../chat/chat_screen.dart';

// class ItemDetailScreen extends StatelessWidget {
//   final Item item;
//   const ItemDetailScreen({super.key, required this.item});

//   /// Extract a readable text for location
//   String _getLocationText() {
//     final loc = item.location;
//     if (loc == null || loc.isEmpty) return 'Unknown location';

//     // If it has a "name" field (like a place name)
//     if (loc['name'] != null && loc['name'].toString().isNotEmpty) {
//       return loc['name'].toString();
//     }

//     // If it has coordinates
//     if (loc['latitude'] != null && loc['longitude'] != null) {
//       return "${loc['latitude']}, ${loc['longitude']}";
//     }

//     // Fallback to raw map string for debugging
//     return loc.entries.map((e) => "${e.key}: ${e.value}").join(", ");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(item.title),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🖼️ Item image
//             if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
//               Image.network(
//                 item.imageUrl!,
//                 width: double.infinity,
//                 height: 250,
//                 fit: BoxFit.cover,
//               )
//             else
//               Container(
//                 width: double.infinity,
//                 height: 250,
//                 color: Colors.grey[300],
//                 child: const Icon(Icons.image, size: 100, color: Colors.white),
//               ),

//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🏷️ Title
//                   Text(
//                     item.title,
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge
//                         ?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),

//                   // 📝 Description (safe for null)
//                   Text(
//                     item.description ?? 'No description provided.',
//                     style: const TextStyle(fontSize: 15),
//                   ),
//                   const SizedBox(height: 16),

//                   // 📍 Location
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on, color: kGreen, size: 18),
//                       const SizedBox(width: 6),
//                       Text(
//                         _getLocationText(),
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // 💬 Chat Button
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kGreen,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     icon: const Icon(Icons.chat_bubble_outline),
//                     label: const Text("Chat with Owner"),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               ChatScreen(itemOwnerId: item.userId),
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 20),
//                   const Divider(),

//                   // 💭 Comments section (you already have it)
//                   // CommentsSection(itemId: item.id),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import '../../models/item_model.dart';
// import '../../utils/app_theme.dart';
// import '../chat/chat_screen.dart';

// class ItemDetailScreen extends StatelessWidget {
//   final Item item;
//   const ItemDetailScreen({super.key, required this.item});

//   /// Extract a readable text for location
//   String _getLocationText() {
//     final loc = item.location;
//     if (loc == null || loc.isEmpty) return 'Unknown location';

//     // If it has a "name" field (like a place name)
//     if (loc['name'] != null && loc['name'].toString().isNotEmpty) {
//       return loc['name'].toString();
//     }

//     // If it has coordinates
//     if (loc['latitude'] != null && loc['longitude'] != null) {
//       return "${loc['latitude']}, ${loc['longitude']}";
//     }

//     // Fallback to raw map string for debugging
//     return loc.entries.map((e) => "${e.key}: ${e.value}").join(", ");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(item.title),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🖼️ Item image
//             if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
//               Image.network(
//                 item.imageUrl!,
//                 width: double.infinity,
//                 height: 250,
//                 fit: BoxFit.cover,
//               )
//             else
//               Container(
//                 width: double.infinity,
//                 height: 250,
//                 color: Colors.grey[300],
//                 child: const Icon(Icons.image, size: 100, color: Colors.white),
//               ),

//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🏷️ Title
//                   Text(
//                     item.title,
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge
//                         ?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),

//                   // 📝 Description
//                   Text(
//                     item.description ?? 'No description provided.',
//                     style: const TextStyle(fontSize: 15),
//                   ),
//                   const SizedBox(height: 16),

//                   // 📍 Location
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on, color: kGreen, size: 18),
//                       const SizedBox(width: 6),
//                       Text(
//                         _getLocationText(),
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // 💬 Chat Button
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kGreen,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     icon: const Icon(Icons.chat_bubble_outline),
//                     label: const Text("Chat with Owner"),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ChatScreen(
//                             itemOwnerId: item.userId, // ✅ required
//                             itemOwnerName: item.title, // ✅ temporary placeholder (replace with real owner name when you fetch user data)
//                             itemOwnerAvatarUrl: item.imageUrl, // optional
//                           ),
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 20),
//                   const Divider(),

//                   // 💭 Comments section (if implemented)
//                   // CommentsSection(itemId: item.id),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../models/item_model.dart';
// import '../../utils/app_theme.dart';
// import '../chat/chat_screen.dart';

// class ItemDetailScreen extends StatelessWidget {
//   final Item item;
//   const ItemDetailScreen({super.key, required this.item});

//   /// Extract a readable text for location
//   String _getLocationText() {
//     final loc = item.location;
//     if (loc == null || loc.isEmpty) return 'Unknown location';

//     // If it has a "name" field (like a place name)
//     if (loc['name'] != null && loc['name'].toString().isNotEmpty) {
//       return loc['name'].toString();
//     }

//     // If it has coordinates
//     if (loc['latitude'] != null && loc['longitude'] != null) {
//       return "${loc['latitude']}, ${loc['longitude']}";
//     }

//     // Fallback to raw map string for debugging
//     return loc.entries.map((e) => "${e.key}: ${e.value}").join(", ");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(item.title),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🖼️ Item image with margin
//             Padding(
//               padding: const EdgeInsets.all(12.0), // 👈 margin from all sides
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12), // optional rounded corners
//                 child: item.imageUrl != null && item.imageUrl!.isNotEmpty
//                     ? Image.network(
//                         item.imageUrl!,
//                         width: double.infinity,
//                         height: 250,
//                         fit: BoxFit.cover,
//                       )
//                     : Container(
//                         width: double.infinity,
//                         height: 250,
//                         color: Colors.grey[300],
//                         child: const Icon(Icons.image,
//                             size: 100, color: Colors.white),
//                       ),
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🏷️ Title
//                   Text(
//                     item.title,
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge
//                         ?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),

//                   // 📝 Description
//                   Text(
//                     item.description ?? 'No description provided.',
//                     style: const TextStyle(fontSize: 15),
//                   ),
//                   const SizedBox(height: 16),

//                   // 📍 Location
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on, color: kGreen, size: 18),
//                       const SizedBox(width: 6),
//                       Text(
//                         _getLocationText(),
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // 💬 Chat Button
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kGreen,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     icon: const Icon(Icons.chat_bubble_outline),
//                     label: const Text("Chat with Owner"),
                   
//                    onPressed: () async {
//   // Fetch owner profile from users table before opening chat
//   final supabase = Supabase.instance.client;
//   final owner = await supabase
//       .from('users')
//       .select('display_name, avatar_url')
//       .eq('id', item.userId)
//       .maybeSingle();

//   final ownerName = owner?['display_name'] ?? 'Unknown User';
//   final ownerAvatar = owner?['avatar_url'];
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => ChatScreen(
//       itemId: item.id, // 👈 important for unique chat
//       itemOwnerId: item.userId,
//       itemOwnerName: ownerName,
//       itemOwnerAvatarUrl: ownerAvatar,
//     ),
//   ),
// );
// },
//   ),

//                   const SizedBox(height: 20),
//                   const Divider(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../models/item_model.dart';
// import '../../utils/app_theme.dart';
// import '../chat/chat_screen.dart';

// class ItemDetailScreen extends StatelessWidget {
//   final Item item;
//   const ItemDetailScreen({super.key, required this.item});

//   /// ✅ Extract a readable text for location
//   String _getLocationText() {
//     final loc = item.location;
//     if (loc == null || loc.isEmpty) return 'Unknown location';

//     // If it has a "name" field (like a place name)
//     if (loc['name'] != null && loc['name'].toString().isNotEmpty) {
//       return loc['name'].toString();
//     }

//     // If it has coordinates
//     if (loc['lat'] != null && loc['lng'] != null) {
//       return "${loc['lat']}, ${loc['lng']}";
//     }

//     // Fallback to raw map string for debugging
//     return loc.entries.map((e) => "${e.key}: ${e.value}").join(", ");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(item.title),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🖼️ Item image with margin
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: item.imageUrl != null && item.imageUrl!.isNotEmpty
//                     ? Image.network(
//                         item.imageUrl!,
//                         width: double.infinity,
//                         height: 250,
//                         fit: BoxFit.cover,
//                       )
//                     : Container(
//                         width: double.infinity,
//                         height: 250,
//                         color: Colors.grey[300],
//                         child: const Icon(Icons.image,
//                             size: 100, color: Colors.white),
//                       ),
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🏷️ Title
//                   Text(
//                     item.title,
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge
//                         ?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),

//                   // 📝 Description
//                   Text(
//                     item.description ?? 'No description provided.',
//                     style: const TextStyle(fontSize: 15),
//                   ),
//                   const SizedBox(height: 16),

//                   // 📍 Location
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on, color: kGreen, size: 18),
//                       const SizedBox(width: 6),
//                       Text(
//                         _getLocationText(),
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // 💬 Chat Button
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kGreen,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     icon: const Icon(Icons.chat_bubble_outline),
//                     label: const Text("Chat with Owner"),
//                     onPressed: () async {
//                       final supabase = Supabase.instance.client;
//                       final owner = await supabase
//                           .from('users')
//                           .select('display_name, avatar_url')
//                           .eq('id', item.userId)
//                           .maybeSingle();

//                       final ownerName = owner?['display_name'] ?? 'Unknown User';
//                       final ownerAvatar = owner?['avatar_url'];
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ChatScreen(
//                             itemId: item.id,
//                             itemOwnerId: item.userId,
//                             itemOwnerName: ownerName,
//                             itemOwnerAvatarUrl: ownerAvatar,
//                           ),
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 20),
//                   const Divider(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/item_model.dart';
import '../../utils/app_theme.dart';
import '../chat/chat_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  final Item item;
  const ItemDetailScreen({super.key, required this.item});

  /// ✅ Extract a readable text for location
  String _getLocationText() {
    final loc = item.location;
    if (loc == null || loc.isEmpty) return 'Unknown location';

    // If it has a "name" field (like a place name)
    if (loc['name'] != null && loc['name'].toString().isNotEmpty) {
      return loc['name'].toString();
    }

    // If it has coordinates
    if (loc['lat'] != null && loc['lng'] != null) {
      return "${loc['lat']}, ${loc['lng']}";
    }

    // Fallback to raw map string for debugging
    return loc.entries.map((e) => "${e.key}: ${e.value}").join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: kGreen,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Item image with margin
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏷️ Title
                  Text(
                    item.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // 📝 Description
                  Text(
                    item.description ?? 'No description provided.',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),

                  // 📍 Location (✅ Fixed overflow)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: kGreen, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _getLocationText(),
                          style: const TextStyle(color: Colors.grey),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 💬 Chat Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text("Chat with Owner"),
                    onPressed: () async {
                      final supabase = Supabase.instance.client;
                      final owner = await supabase
                          .from('users')
                          .select('display_name, avatar_url')
                          .eq('id', item.userId)
                          .maybeSingle();

                      final ownerName = owner?['display_name'] ?? 'Unknown User';
                      final ownerAvatar = owner?['avatar_url'];

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            itemId: item.id,
                            itemOwnerId: item.userId,
                            itemOwnerName: ownerName,
                            itemOwnerAvatarUrl: ownerAvatar,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}