
// import 'package:circlo_app/ui/chat/chat_list_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../utils/app_theme.dart';
// import 'filter_bottom_sheet.dart';
// import 'offer_item_fab.dart';
// import '../home/feed_tab_nearby.dart';
// import '../home/feed_tab_friends.dart';
// import '../home/feed_tab_trending.dart';
// import '../../providers/items_provider.dart';

// class HomeFeedScreen extends StatefulWidget {
//   const HomeFeedScreen({super.key});

//   @override
//   State<HomeFeedScreen> createState() => _HomeFeedScreenState();
// }

// class _HomeFeedScreenState extends State<HomeFeedScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   void _openFilters(ItemsProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (_) => FilterBottomSheet(
//         initialFilters: provider.appliedFilters,
//         onApply: (filters) {
//           Navigator.pop(context);
//           provider.applyFilters(filters);
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _refreshCurrent(ItemsProvider provider) async {
//     await provider.refreshCurrent(_tabController.index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Circlo'),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(icon: const Icon(Icons.filter_alt_rounded), onPressed: () => _openFilters(provider)),
//           IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => _refreshCurrent(provider)),
//   IconButton(
//     icon: const Icon(Icons.chat),
//     onPressed: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const ChatListScreen()),
//       );
//     },
//   ),


//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [Tab(text: 'Nearby'), Tab(text: 'Friends'), Tab(text: 'Trending')],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: const [
//           FeedTabNearby(),
//           FeedTabFriends(),
//           FeedTabTrending(),
//         ],
//       ),
//       floatingActionButton: const OfferItemFAB(),
//     );
//   }
// }
// import 'package:circlo_app/ui/chat/chat_list_screen.dart';
// import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:provider/provider.dart';
// import '../../utils/app_theme.dart';
// import 'filter_bottom_sheet.dart';
// import 'offer_item_fab.dart';
// import '../home/feed_tab_nearby.dart';
// import '../home/feed_tab_friends.dart';
// import '../home/feed_tab_trending.dart';
// import '../../providers/items_provider.dart';
// import '../../models/item_model.dart';

// class HomeFeedScreen extends StatefulWidget {
//   const HomeFeedScreen({super.key});

//   @override
//   State<HomeFeedScreen> createState() => _HomeFeedScreenState();
// }

// class _HomeFeedScreenState extends State<HomeFeedScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   void _openFilters(ItemsProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => FilterBottomSheet(
//         initialFilters: provider.appliedFilters,
//         onApply: (filters) {
//           Navigator.pop(context);
//           provider.applyFilters(filters);
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _refreshCurrent(ItemsProvider provider) async {
//     await provider.refreshCurrent(_tabController.index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);
//     // final items = provider.items;
// final items = provider.nearbyItems; // or provider.trendingItems

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Circlo'),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.filter_alt_rounded),
//               onPressed: () => _openFilters(provider)),
//           IconButton(
//               icon: const Icon(Icons.refresh_rounded),
//               onPressed: () => _refreshCurrent(provider)),
//                IconButton(
//     icon: const Icon(Icons.chat),
//     onPressed: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const ChatListScreen()),
//       );
//     },
//   ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(text: 'Nearby'),
//             Tab(text: 'Friends'),
//             Tab(text: 'Trending')
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildSwipeableList(items, provider),
//           const FeedTabFriends(),
//           const FeedTabTrending(),
//         ],
//       ),
//       floatingActionButton: const OfferItemFAB(),
//     );
//   }

//   /// 🧩 Swipeable list of cards with confirmation dialog before delete
//   Widget _buildSwipeableList(List<Item> items, ItemsProvider provider) {
//     if (items.isEmpty) {
//       return const Center(child: Text('No items found.'));
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final item = items[index];
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Slidable(
//             key: ValueKey(item.id),

//             // ✅ Only Right Side (Edit + Delete)
//             endActionPane: ActionPane(
//               motion: const DrawerMotion(),
//               extentRatio: 0.50, // width for both buttons
//               children: [
//                 // ✏️ Edit Action
//                 SlidableAction(
//                   onPressed: (context) => provider.editItem(context, item),
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   icon: Icons.edit,
//                   label: 'Edit',
//                 ),

//                 // 🗑️ Delete Action with confirmation dialog
//                 SlidableAction(
//                   onPressed: (context) async {
//                     final shouldDelete = await showDialog<bool>(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: const Text('Confirm Deletion'),
//                         content: const Text(
//                             'Are you sure you want to delete this item?'),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context, false),
//                             child: const Text('Cancel'),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                             ),
//                             onPressed: () => Navigator.pop(context, true),
//                             child: const Text('Delete'),
//                           ),
//                         ],
//                       ),
//                     );

//                     if (shouldDelete == true) {
//                       provider.deleteItem(item.id);
//                     }
//                   },
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   icon: Icons.delete,
//                   label: 'Delete',
//                 ),
//               ],
//             ),

//             // 📦 Item Card
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 3,
//               child: ListTile(
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                 leading: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: item.imageUrl != null && item.imageUrl!.isNotEmpty
//                       ? Image.network(
//                           item.imageUrl!,
//                           width: 60,
//                           height: 60,
//                           fit: BoxFit.cover,
//                         )
//                       : Container(
//                           width: 60,
//                           height: 60,
//                           color: Colors.grey[300],
//                           child: const Icon(Icons.image, color: Colors.white),
//                         ),
//                 ),
//                 title: Text(
//                   item.title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 subtitle: Text(
//                   item.description ?? 'No description',
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => ItemDetailScreen(item: item),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
// import 'package:circlo_app/ui/chat/chat_list_screen.dart';
// import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import 'filter_bottom_sheet.dart';
// import 'offer_item_fab.dart';
// import '../home/feed_tab_nearby.dart';
// import '../home/feed_tab_friends.dart';
// import '../home/feed_tab_trending.dart';
// import '../../providers/items_provider.dart';
// import '../../models/item_model.dart';

// class HomeFeedScreen extends StatefulWidget {
//   const HomeFeedScreen({super.key});

//   @override
//   State<HomeFeedScreen> createState() => _HomeFeedScreenState();
// }

// class _HomeFeedScreenState extends State<HomeFeedScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   void _openFilters(ItemsProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => FilterBottomSheet(
//         initialFilters: provider.appliedFilters,
//         onApply: (filters) {
//           Navigator.pop(context);
//           provider.applyFilters(filters);
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _refreshCurrent(ItemsProvider provider) async {
//     await provider.refreshCurrent(_tabController.index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);
//     final items = provider.nearbyItems; // or provider.trendingItems if needed

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Circlo'),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.filter_alt_rounded),
//               onPressed: () => _openFilters(provider)),
//           IconButton(
//               icon: const Icon(Icons.refresh_rounded),
//               onPressed: () => _refreshCurrent(provider)),
//           IconButton(
//             icon: const Icon(Icons.chat),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ChatListScreen()),
//               );
//             },
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(text: 'Nearby'),
//             Tab(text: 'Friends'),
//             Tab(text: 'Trending')
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildSwipeableList(items, provider),
//           const FeedTabFriends(),
//           const FeedTabTrending(),
//         ],
//       ),
//       floatingActionButton: const OfferItemFAB(),
//     );
//   }

//   /// 🧩 Swipeable list of cards with Edit/Delete for only the current user’s items
//   Widget _buildSwipeableList(List<Item> items, ItemsProvider provider) {
//     final currentUserId = Supabase.instance.client.auth.currentUser?.id;

//     if (items.isEmpty) {
//       return const Center(child: Text('No items found.'));
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final item = items[index];
//         final isMyItem = item.userId == currentUserId;

//         final itemCard = Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 3,
//           child: ListTile(
//             contentPadding:
//                 const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//             leading: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: item.imageUrl != null && item.imageUrl!.isNotEmpty
//                   ? Image.network(
//                       item.imageUrl!,
//                       width: 60,
//                       height: 60,
//                       fit: BoxFit.cover,
//                     )
//                   : Container(
//                       width: 60,
//                       height: 60,
//                       color: Colors.grey[300],
//                       child: const Icon(Icons.image, color: Colors.white),
//                     ),
//             ),
//             title: Text(
//               item.title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             subtitle: Text(
//               item.description ?? 'No description',
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => ItemDetailScreen(item: item),
//                 ),
//               );
//             },
//           ),
//         );

//         // ✅ If this item belongs to the current user, enable edit/delete slide
//         if (isMyItem) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Slidable(
//               key: ValueKey(item.id),
//               endActionPane: ActionPane(
//                 motion: const DrawerMotion(),
//                 extentRatio: 0.50,
//                 children: [
//                   // ✏️ Edit Action
//                   SlidableAction(
//                     onPressed: (context) => provider.editItem(context, item),
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     icon: Icons.edit,
//                     label: 'Edit',
//                   ),

//                   // 🗑️ Delete Action
//                   SlidableAction(
//                     onPressed: (context) async {
//                       final shouldDelete = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text('Confirm Deletion'),
//                           content: const Text(
//                               'Are you sure you want to delete this item?'),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, false),
//                               child: const Text('Cancel'),
//                             ),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                               ),
//                               onPressed: () => Navigator.pop(context, true),
//                               child: const Text('Delete'),
//                             ),
//                           ],
//                         ),
//                       );

//                       if (shouldDelete == true) {
//                         await provider.deleteItem(item.id);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text('Item deleted successfully')),
//                         );
//                       }
//                     },
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     icon: Icons.delete,
//                     label: 'Delete',
//                   ),
//                 ],
//               ),
//               child: itemCard,
//             ),
//           );
//         }

//         // 🟡 Not user's item → normal card
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: itemCard,
//         );
//       },
//     );
//   }
// }
import 'package:circlo_app/ui/chat/chat_list_screen.dart';
import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import 'filter_bottom_sheet.dart';
import 'offer_item_fab.dart';
import '../home/feed_tab_nearby.dart';
import '../home/feed_tab_friends.dart';
import '../home/feed_tab_trending.dart';
import '../../providers/items_provider.dart';
import '../../models/item_model.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ItemsProvider>(context, listen: false);
      provider.loadNearby();
      provider.loadTrending();
      provider.loadFriends();
    });
  }

  void _openFilters(ItemsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterBottomSheet(
        initialFilters: provider.appliedFilters,
        onApply: (filters) {
          Navigator.pop(context);
          provider.applyFilters(filters);
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshCurrent(ItemsProvider provider) async {
    await provider.refreshCurrent(_tabController.index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circlo'),
        backgroundColor: kGreen,
        actions: [
          IconButton(
              icon: const Icon(Icons.filter_alt_rounded),
              onPressed: () => _openFilters(provider)),
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _refreshCurrent(provider)),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Nearby'),
            Tab(text: 'Friends'),
            Tab(text: 'Trending')
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSwipeableList(provider.nearbyItems, provider),
          FeedTabFriendsWrapper(provider: provider),
          FeedTabTrendingWrapper(provider: provider),
        ],
      ),
      floatingActionButton: const OfferItemFAB(),
    );
  }

  /// 🧩 Swipeable list of cards with Edit/Delete for only the current user’s items
  Widget _buildSwipeableList(List<Item> items, ItemsProvider provider) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (items.isEmpty) {
      return const Center(child: Text('No items found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isMyItem = item.userId == currentUserId;

        final itemCard = Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.white),
                    ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              item.description ?? 'No description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailScreen(item: item),
                ),
              );
            },
          ),
        );

        if (isMyItem) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Slidable(
              key: ValueKey(item.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.50,
                children: [
                  SlidableAction(
                    onPressed: (_) async {
                      final result =
                          await provider.editItem(context, item); // waits for edit
                      if (result == true) {
                        // Refresh after edit
                        provider.loadNearby();
                        provider.loadTrending();
                        provider.loadFriends();
                      }
                    },
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (_) async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text(
                              'Are you sure you want to delete this item?'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true) {
                        await provider.deleteItem(item.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Item deleted successfully')),
                          );
                        }
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: itemCard,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: itemCard,
        );
      },
    );
  }
}

/// ⚡ Wrapper for Friends Tab to trigger provider refresh when loaded
class FeedTabFriendsWrapper extends StatelessWidget {
  final ItemsProvider provider;
  const FeedTabFriendsWrapper({required this.provider, super.key});

  @override
  Widget build(BuildContext context) {
    return FeedTabFriends(
      key: ValueKey(provider.friendItems.length),
    );
  }
}

/// ⚡ Wrapper for Trending Tab to trigger provider refresh when loaded
class FeedTabTrendingWrapper extends StatelessWidget {
  final ItemsProvider provider;
  const FeedTabTrendingWrapper({required this.provider, super.key});

  @override
  Widget build(BuildContext context) {
    return FeedTabTrending(
      key: ValueKey(provider.trendingItems.length),
    );
  }
}
