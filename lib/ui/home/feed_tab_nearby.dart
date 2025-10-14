
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../utils/app_theme.dart';
// import '../../providers/items_provider.dart';

// class FeedTabNearby extends StatelessWidget {
//   const FeedTabNearby({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);

//     if (provider.loadingNearby) return const Center(child: CircularProgressIndicator());

//     if (provider.nearbyItems.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: () => provider.loadNearby(),
//         child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [
//           SizedBox(height: 120),
//           Center(child: Text('No nearby items found')),
//         ]),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () => provider.loadNearby(),
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: provider.nearbyItems.length,
//         itemBuilder: (_, i) {
//           final item = provider.nearbyItems[i];
//           return Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             elevation: 3,
//             margin: const EdgeInsets.only(bottom: 16),
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(12),
//               leading: item.imageUrl != null
//                   ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
//                   : CircleAvatar(backgroundColor: kTeal.withOpacity(0.15), child: const Icon(Icons.category, color: kTeal)),
//               title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
//               subtitle: Text("${item.description ?? ''} · ${item.radiusKm} km"),
//               trailing: const Icon(Icons.chevron_right),
//               onTap: () {
                
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../utils/app_theme.dart';
// import '../../providers/items_provider.dart';


// class FeedTabNearby extends StatelessWidget {
//   const FeedTabNearby({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);

//     if (provider.loadingNearby) return const Center(child: CircularProgressIndicator());

//     if (provider.nearbyItems.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: () => provider.loadNearby(),
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
//       onRefresh: () => provider.loadNearby(),
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: provider.nearbyItems.length,
//         itemBuilder: (_, i) {
//           final item = provider.nearbyItems[i];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
//               );
//             },
//             child: Card(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               elevation: 3,
//               margin: const EdgeInsets.only(bottom: 16),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(12),
//                 leading: item.imageUrl != null
//                     ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
//                     : CircleAvatar(
//                         backgroundColor: kTeal.withOpacity(0.15),
//                         child: const Icon(Icons.category, color: kTeal),
//                       ),
//                 title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
//                 subtitle: Text("${item.description ?? ''} · ${item.radiusKm} km"),
//                 trailing: const Icon(Icons.chevron_right),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/items_provider.dart';

class FeedTabNearby extends StatelessWidget {
  const FeedTabNearby({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemsProvider>(context);

    if (provider.loadingNearby) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.nearbyItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.loadNearby(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No nearby items found')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadNearby(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.nearbyItems.length,
        itemBuilder: (_, i) {
          final item = provider.nearbyItems[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: item.imageUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
                    : CircleAvatar(
                        backgroundColor: kTeal.withOpacity(0.15),
                        child: const Icon(Icons.category, color: kTeal),
                      ),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text("${item.description ?? ''} · ${item.radiusKm} km"),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          );
        },
      ),
    );
  }
}
