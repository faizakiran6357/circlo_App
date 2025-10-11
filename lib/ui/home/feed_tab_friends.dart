// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';

// class FeedTabFriends extends StatelessWidget {
//   const FeedTabFriends({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 5,
//       itemBuilder: (_, i) => Card(
//         margin: const EdgeInsets.only(bottom: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: ListTile(
//           leading: CircleAvatar(
//             backgroundColor: kGreen.withOpacity(0.2),
//             child: const Icon(Icons.people, color: kGreen),
//           ),
//           title: Text("Friend’s Item #${i + 1}",
//               style: const TextStyle(fontWeight: FontWeight.w600)),
//           subtitle: const Text("Offered by a friend"),
//           trailing: const Icon(Icons.chevron_right),
//           onTap: () {},
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';

// class FeedTabFriends extends StatelessWidget {
//   final List<Map<String, dynamic>> items;
//   final bool isLoading;
//   final Future<void> Function() onRefresh;

//   const FeedTabFriends({
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
//             Center(child: Text('No items from your friends yet')),
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
//           final img = item['image_url'] as String?;

//           return Card(
//             margin: const EdgeInsets.only(bottom: 16),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(12),
//               leading: img != null && img.isNotEmpty
//                   ? CircleAvatar(backgroundImage: NetworkImage(img))
//                   : CircleAvatar(backgroundColor: kGreen.withOpacity(0.15), child: const Icon(Icons.people, color: kGreen)),
//               title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//               subtitle: Text(subtitle),
//               trailing: const Icon(Icons.chevron_right),
//               onTap: () {
//                 // TODO: navigate to item detail
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

class FeedTabFriends extends StatelessWidget {
  const FeedTabFriends({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemsProvider>(context);

    if (provider.loadingFriends) return const Center(child: CircularProgressIndicator());

    if (provider.friendItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.loadFriends(),
        child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [
          SizedBox(height: 120),
          Center(child: Text('No items from your friends yet')),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadFriends(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.friendItems.length,
        itemBuilder: (_, i) {
          final item = provider.friendItems[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: item.imageUrl != null
                  ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
                  : CircleAvatar(backgroundColor: kGreen.withOpacity(0.15), child: const Icon(Icons.people, color: kGreen)),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(item.description ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
