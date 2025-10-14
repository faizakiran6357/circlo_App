
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../utils/app_theme.dart';
// import '../../providers/items_provider.dart';

// class FeedTabFriends extends StatelessWidget {
//   const FeedTabFriends({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);

//     if (provider.loadingFriends) return const Center(child: CircularProgressIndicator());

//     if (provider.friendItems.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: () => provider.loadFriends(),
//         child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [
//           SizedBox(height: 120),
//           Center(child: Text('No items from your friends yet')),
//         ]),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () => provider.loadFriends(),
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: provider.friendItems.length,
//         itemBuilder: (_, i) {
//           final item = provider.friendItems[i];
//           return Card(
//             margin: const EdgeInsets.only(bottom: 16),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(12),
//               leading: item.imageUrl != null
//                   ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
//                   : CircleAvatar(backgroundColor: kGreen.withOpacity(0.15), child: const Icon(Icons.people, color: kGreen)),
//               title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
//               subtitle: Text(item.description ?? ''),
//               trailing: const Icon(Icons.chevron_right),
//               onTap: () {},
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

class FeedTabFriends extends StatelessWidget {
  const FeedTabFriends({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemsProvider>(context);

    if (provider.loadingFriends) return const Center(child: CircularProgressIndicator());

    if (provider.friendItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.loadFriends(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No items from your friends yet')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadFriends(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.friendItems.length,
        itemBuilder: (_, i) {
          final item = provider.friendItems[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: item.imageUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
                    : CircleAvatar(
                        backgroundColor: kGreen.withOpacity(0.15),
                        child: const Icon(Icons.people, color: kGreen),
                      ),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(item.description ?? ''),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          );
        },
      ),
    );
  }
}
