
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
//                         child: const Icon(
//                           Icons.image,
//                           size: 100,
//                           color: Colors.white,
//                         ),
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

//                   // 📍 Location (✅ Fixed overflow)
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Icon(Icons.location_on, color: kGreen, size: 18),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           _getLocationText(),
//                           style: const TextStyle(color: Colors.grey),
//                           softWrap: true,
//                           overflow: TextOverflow.visible,
//                         ),
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

import 'package:circlo_app/ui/exchange/propose_exchange_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/item_model.dart';
import '../../utils/app_theme.dart';
import '../chat/chat_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  LatLng? itemLatLng;
  String ownerName = 'Unknown User';
  String? ownerAvatar;

  @override
  void initState() {
    super.initState();
    _loadOwner();
    _setItemLatLng();
  }

  void _setItemLatLng() {
    final loc = widget.item.location;
    if (loc != null && loc['lat'] != null && loc['lng'] != null) {
      itemLatLng = LatLng(loc['lat'], loc['lng']);
    }
  }

  Future<void> _loadOwner() async {
    try {
      final supabase = Supabase.instance.client;
      final owner = await supabase
          .from('users')
          .select('display_name, avatar_url')
          .eq('id', widget.item.userId)
          .maybeSingle();

      if (owner != null) {
        setState(() {
          ownerName = owner['display_name'] ?? 'Unknown User';
          ownerAvatar = owner['avatar_url'];
        });
      }
    } catch (_) {}
  }

  String _getLocationText() {
    final loc = widget.item.location;
    if (loc == null || loc.isEmpty) return 'Unknown location';
    if (loc['name'] != null && loc['name'].toString().isNotEmpty) {
      return loc['name'].toString();
    }
    if (loc['lat'] != null && loc['lng'] != null) {
      return "${loc['lat']}, ${loc['lng']}";
    }
    return loc.entries.map((e) => "${e.key}: ${e.value}").join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        backgroundColor: kGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty
                  ? Image.network(widget.item.imageUrl!,
                      width: double.infinity, height: 250, fit: BoxFit.cover)
                  : Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 100, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 16),

            // Title (plain text)
            Text(widget.item.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Description (plain text)
            Text(widget.item.description ?? "No description provided",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // 📍 Location with icon and label
            Row(
              children: [
                const Icon(Icons.location_on, color: kGreen),
                const SizedBox(width: 8),
                const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(_getLocationText(), style: TextStyle(fontSize: 16, color: Colors.grey[700]!)),
            const Divider(height: 32),

            // 👤 Owner with icon and label
            Row(
              children: [
                const Icon(Icons.person, color: kGreen),
                const SizedBox(width: 8),
                const Text("Owner", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (ownerAvatar != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(ownerAvatar!),
                    radius: 16,
                  ),
                if (ownerAvatar != null) const SizedBox(width: 8),
                Text(ownerName, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(height: 32),

            // 🗺️ Map
            if (itemLatLng != null)
              SizedBox(
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: itemLatLng!, zoom: 14),
                    markers: {
                      Marker(
                        markerId: const MarkerId('itemLocation'),
                        position: itemLatLng!,
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                ),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      itemId: widget.item.id,
                      itemOwnerId: widget.item.userId,
                      itemOwnerName: ownerName,
                      itemOwnerAvatarUrl: ownerAvatar,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
//             ElevatedButton(
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ProposeExchangeScreen(
//           targetItemId: widget.item.id,
//         ),
//       ),
//     );
//   },
//   child: const Text("Propose Exchange"),
// ),
   ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProposeExchangeScreen(
          targetItemId: widget.item.id,
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF00BCD4),
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  icon: const Icon(Icons.swap_horiz), // example icon for exchange
  label: const Text("Propose Exchange"),
)

          ],
        ),
      ),
    );
  }
}
