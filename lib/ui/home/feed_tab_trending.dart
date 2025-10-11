// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';

// class FeedTabTrending extends StatelessWidget {
//   const FeedTabTrending({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 6,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 0.85,
//       ),
//       itemBuilder: (_, i) => Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             colors: [kTeal.withOpacity(0.15), Colors.white],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 4,
//               offset: Offset(2, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.trending_up_rounded, color: kTeal, size: 40),
//             const SizedBox(height: 12),
//             Text("Trending Item #${i + 1}",
//                 style: const TextStyle(fontWeight: FontWeight.bold)),
//             const Text("Popular this week",
//                 style: TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';

// class FeedTabTrending extends StatelessWidget {
//   final List<Map<String, dynamic>> items;
//   final bool isLoading;
//   final Future<void> Function() onRefresh;

//   const FeedTabTrending({
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
//             Center(child: Text('No trending items yet')),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: onRefresh,
//       child: GridView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: items.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: 0.85,
//         ),
//         itemBuilder: (_, i) {
//           final item = items[i];
//           final title = item['title'] ?? 'Untitled';
//           final score = item['trust_score']?.toString() ?? '0';
//           final img = item['image_url'] as String?;

//           return Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               gradient: LinearGradient(colors: [kTeal.withOpacity(0.08), Colors.white]),
//               boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 3))],
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 img != null && img.isNotEmpty
//                     ? Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(img, fit: BoxFit.cover, width: double.infinity)))
//                     : const SizedBox(height: 40, child: Icon(Icons.trending_up_rounded, color: kTeal, size: 40)),
//                 const SizedBox(height: 8),
//                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 Text('Trust: $score', style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                 const SizedBox(height: 8),
//               ],
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

class FeedTabTrending extends StatelessWidget {
  const FeedTabTrending({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemsProvider>(context);

    if (provider.loadingTrending) return const Center(child: CircularProgressIndicator());

    if (provider.trendingItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.loadTrending(),
        child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [
          SizedBox(height: 120),
          Center(child: Text('No trending items yet')),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadTrending(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.trendingItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
        itemBuilder: (_, i) {
          final item = provider.trendingItems[i];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [kTeal.withOpacity(0.08), Colors.white]),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 3))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                item.imageUrl != null ? Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(item.imageUrl!, fit: BoxFit.cover, width: double.infinity))) : const SizedBox(height: 40, child: Icon(Icons.trending_up_rounded, color: kTeal, size: 40)),
                const SizedBox(height: 8),
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Trust: ${item.trustScore}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
