
// import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
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
//         child: ListView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           children: const [
//             SizedBox(height: 120),
//             Center(child: Text('No items from your friends yet')),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () => provider.loadFriends(),
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: provider.friendItems.length,
//         itemBuilder: (_, i) {
//           final item = provider.friendItems[i];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
//               );
//             },
//             child: Card(
//               margin: const EdgeInsets.only(bottom: 16),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(12),
//                 leading: item.imageUrl != null
//                     ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
//                     : CircleAvatar(
//                         backgroundColor: kGreen.withOpacity(0.15),
//                         child: const Icon(Icons.people, color: kGreen),
//                       ),
//                 title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
//                 subtitle: Text(item.description ?? ''),
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

class FeedTabFriends extends StatelessWidget {
  const FeedTabFriends({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemsProvider>(context);

    if (provider.loadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }

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
        padding: const EdgeInsets.all(12),
        itemCount: provider.friendItems.length,
        itemBuilder: (_, index) {
          final item = provider.friendItems[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 80,
                            width: 80,
                            color: kGreen.withOpacity(0.15),
                            child: const Icon(Icons.people, color: kGreen, size: 40),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(item.description ?? 'No description',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 6),
                        if (item.tags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            children: item.tags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kGreen.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(tag,
                                          style: const TextStyle(
                                              fontSize: 11, color: kGreen)),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
