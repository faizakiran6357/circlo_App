// // import 'package:flutter/material.dart';
// // import '../../utils/app_theme.dart';

// // class FeedTabNearby extends StatelessWidget {
// //   const FeedTabNearby({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return ListView.builder(
// //       padding: const EdgeInsets.all(16),
// //       itemCount: 8,
// //       itemBuilder: (_, i) => Card(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         elevation: 3,
// //         margin: const EdgeInsets.only(bottom: 16),
// //         child: ListTile(
// //           leading: CircleAvatar(
// //             backgroundColor: kTeal.withOpacity(0.2),
// //             child: const Icon(Icons.category, color: kTeal),
// //           ),
// //           title: Text("Nearby Item #${i + 1}",
// //               style: const TextStyle(fontWeight: FontWeight.w600)),
// //           subtitle: const Text("2 km away · Good condition"),
// //           trailing: const Icon(Icons.chevron_right),
// //           onTap: () {},
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';
// import '../../services/supabase_item_service.dart';

// class FeedTabNearby extends StatefulWidget {
//   const FeedTabNearby({super.key});

//   @override
//   State<FeedTabNearby> createState() => _FeedTabNearbyState();
// }

// class _FeedTabNearbyState extends State<FeedTabNearby> {
//   List<Map<String, dynamic>> items = [];
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadItems();
//   }

//   Future<void> _loadItems() async {
//     final result = await SupabaseItemService.fetchNearbyItems(10); // 10km radius
//     setState(() {
//       items = result;
//       loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) return const Center(child: CircularProgressIndicator());

//     if (items.isEmpty) {
//       return const Center(child: Text("No nearby items found"));
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: items.length,
//       itemBuilder: (_, i) {
//         final item = items[i];
//         return Card(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           margin: const EdgeInsets.only(bottom: 16),
//           child: ListTile(
//             title: Text(item['title'] ?? 'Untitled'),
//             subtitle: Text(item['condition'] ?? 'Unknown condition'),
//             trailing: const Icon(Icons.chevron_right),
//           ),
//         );
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';

// class FeedTabNearby extends StatelessWidget {
//   final List<Map<String, dynamic>> items;
//   final bool isLoading;
//   final Future<void> Function() onRefresh;

//   const FeedTabNearby({
//     super.key,
//     required this.items,
//     required this.isLoading,
//     required this.onRefresh,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) return const Center(child: CircularProgressIndicator());

//     if (items.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: onRefresh,
//         child: ListView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           children: const [
//             SizedBox(height: 120),
//             Center(child: Text('No nearby items found')),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: onRefresh,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: items.length,
//         itemBuilder: (_, i) {
//           final item = items[i];
//           final title = item['title'] ?? 'Untitled';
//           final subtitle = item['description'] ?? '';
//           final distance = item['radius_km']?.toString() ?? '-';
//           final img = item['image_url'] as String?;

//           return Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             elevation: 3,
//             margin: const EdgeInsets.only(bottom: 16),
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(12),
//               leading: img != null && img.isNotEmpty
//                   ? CircleAvatar(backgroundImage: NetworkImage(img))
//                   : CircleAvatar(backgroundColor: kTeal.withOpacity(0.15), child: const Icon(Icons.category, color: kTeal)),
//               title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//               subtitle: Text("$subtitle · ${distance} km"),
//               trailing: const Icon(Icons.chevron_right),
//               onTap: () {
//                 // TODO: navigate to item detail screen (Module 3)
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/items_provider.dart';

class FeedTabNearby extends StatelessWidget {
  const FeedTabNearby({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemsProvider>(context);

    if (provider.loadingNearby) return const Center(child: CircularProgressIndicator());

    if (provider.nearbyItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.loadNearby(),
        child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [
          SizedBox(height: 120),
          Center(child: Text('No nearby items found')),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadNearby(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.nearbyItems.length,
        itemBuilder: (_, i) {
          final item = provider.nearbyItems[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: item.imageUrl != null
                  ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
                  : CircleAvatar(backgroundColor: kTeal.withOpacity(0.15), child: const Icon(Icons.category, color: kTeal)),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text("${item.description ?? ''} · ${item.radiusKm} km"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
