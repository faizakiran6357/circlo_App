
// import 'package:circlo_app/ui/chat/chat_list_screen.dart';
// import 'package:circlo_app/ui/exchange/exchange_requests_screen.dart';
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
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<ItemsProvider>(context, listen: false);
//       provider.loadNearby();
//       provider.loadTrending();
//       provider.loadFriends();
//     });
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
//           IconButton(
//   icon: const Icon(Icons.swap_horiz), // 🔁 exchange icon
//   tooltip: 'My Exchanges',
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const ExchangeRequestsScreen()),
//     );
//   },
// ),

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
//           _buildSwipeableList(provider.nearbyItems, provider),
//           FeedTabFriendsWrapper(provider: provider),
//           FeedTabTrendingWrapper(provider: provider),
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

//         if (isMyItem) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Slidable(
//               key: ValueKey(item.id),
//               endActionPane: ActionPane(
//                 motion: const DrawerMotion(),
//                 extentRatio: 0.50,
//                 children: [
//                   SlidableAction(
//                     onPressed: (_) async {
//                       final result =
//                           await provider.editItem(context, item); // waits for edit
//                       if (result == true) {
//                         // Refresh after edit
//                         provider.loadNearby();
//                         provider.loadTrending();
//                         provider.loadFriends();
//                       }
//                     },
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     icon: Icons.edit,
//                     label: 'Edit',
//                   ),
//                   SlidableAction(
//                     onPressed: (_) async {
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
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Item deleted successfully')),
//                           );
//                         }
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

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: itemCard,
//         );
//       },
//     );
//   }
// }

// /// ⚡ Wrapper for Friends Tab to trigger provider refresh when loaded
// class FeedTabFriendsWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabFriendsWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabFriends(
//       key: ValueKey(provider.friendItems.length),
//     );
//   }
// }

// /// ⚡ Wrapper for Trending Tab to trigger provider refresh when loaded
// class FeedTabTrendingWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabTrendingWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabTrending(
//       key: ValueKey(provider.trendingItems.length),
//     );
//   }
// }
// import 'package:circlo_app/ui/chat/chat_list_screen.dart';
// import 'package:circlo_app/ui/exchange/exchange_requests_screen.dart';
// import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
// import 'package:circlo_app/ui/profile/profile_overview_screen.dart';
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
//   int _selectedIndex = 0; // For BottomNavigationBar

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<ItemsProvider>(context, listen: false);
//       provider.loadNearby();
//       provider.loadTrending();
//       provider.loadFriends();
//     });
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

//   void _onBottomNavTap(int index) {
//     setState(() => _selectedIndex = index);
//     if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const ProfileOverviewScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);

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
//           _buildSwipeableList(provider.nearbyItems, provider),
//           FeedTabFriendsWrapper(provider: provider),
//           FeedTabTrendingWrapper(provider: provider),
//         ],
//       ),
//       floatingActionButton: const OfferItemFAB(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onBottomNavTap,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
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

//         if (isMyItem) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Slidable(
//               key: ValueKey(item.id),
//               endActionPane: ActionPane(
//                 motion: const DrawerMotion(),
//                 extentRatio: 0.50,
//                 children: [
//                   SlidableAction(
//                     onPressed: (_) async {
//                       final result =
//                           await provider.editItem(context, item); // waits for edit
//                       if (result == true) {
//                         provider.loadNearby();
//                         provider.loadTrending();
//                         provider.loadFriends();
//                       }
//                     },
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     icon: Icons.edit,
//                     label: 'Edit',
//                   ),
//                   SlidableAction(
//                     onPressed: (_) async {
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
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Item deleted successfully')),
//                           );
//                         }
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

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: itemCard,
//         );
//       },
//     );
//   }
// }

// /// ⚡ Wrapper for Friends Tab to trigger provider refresh when loaded
// class FeedTabFriendsWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabFriendsWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabFriends(
//       key: ValueKey(provider.friendItems.length),
//     );
//   }
// }

// /// ⚡ Wrapper for Trending Tab to trigger provider refresh when loaded
// class FeedTabTrendingWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabTrendingWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabTrending(
//       key: ValueKey(provider.trendingItems.length),
//     );
//   }
// }
// import 'package:circlo_app/ui/auth/login_screen.dart';
// import 'package:circlo_app/ui/chat/chat_list_screen.dart';
// import 'package:circlo_app/ui/exchange/exchange_requests_screen.dart';
// import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
// import 'package:circlo_app/ui/profile/profile_overview_screen.dart';
// import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';
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
//   int _selectedIndex = 0;
//   Map<String, dynamic>? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _loadCurrentUser();
//       final provider = Provider.of<ItemsProvider>(context, listen: false);
//       provider.loadNearby();
//       provider.loadTrending();
//       provider.loadFriends();
//     });
//   }

//   Future<void> _loadCurrentUser() async {
//     final supabase = Supabase.instance.client;
//     final user = supabase.auth.currentUser;
//     if (user != null) {
//       final res = await supabase
//           .from('users')
//           .select('display_name, email, avatar_url')
//           .eq('id', user.id)
//           .maybeSingle();
//       setState(() => _currentUser = res);
//     }
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

//   void _onBottomNavTap(int index) {
//     setState(() => _selectedIndex = index);
//     if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const ProfileOverviewScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Circlo'),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.refresh_rounded),
//               onPressed: () => _refreshCurrent(provider)),
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

//       // 🔹 Drawer added here
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             if (_currentUser != null)
//               UserAccountsDrawerHeader(
//                 decoration: const BoxDecoration(color: kGreen),
//                 accountName: Text(_currentUser?['display_name'] ?? 'Unknown User'),
//                 accountEmail: Text(_currentUser?['email'] ?? ''),
//                 currentAccountPicture: CircleAvatar(
//                   backgroundImage: _currentUser?['avatar_url'] != null
//                       ? NetworkImage(_currentUser!['avatar_url'])
//                       : null,
//                   child: _currentUser?['avatar_url'] == null
//                       ? const Icon(Icons.person, size: 40)
//                       : null,
//                 ),
//               )
//             else
//               const DrawerHeader(
//                 decoration: BoxDecoration(color: kGreen),
//                 child: Center(
//                   child: CircularProgressIndicator(color: Colors.white),
//                 ),
//               ),

//             ListTile(
//               leading: const Icon(Icons.filter_alt_rounded, color: kGreen),
//               title: const Text('Filters'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _openFilters(provider);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.chat, color: kGreen),
//               title: const Text('Chats'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ChatListScreen()),
//                 );
//               },
//             ),
//             const Divider(),
//             ListTile(
//   leading: const Icon(Icons.logout, color: Colors.red),
//   title: const Text('Logout'),
//   onTap: () async {
//     final supabase = Supabase.instance.client;

//     // Close the drawer first
//     Navigator.pop(context);

//     try {
//       // Perform logout
//       await supabase.auth.signOut();

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Logged out successfully')),
//         );

//         // Navigate to login screen & clear navigation history
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (_) => const LoginScreen()),
//           (Route<dynamic> route) => false,
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Logout error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to log out')),
//       );
//     }
//   },
// ),
//           ],
//         ),
//       ),

//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildSwipeableList(provider.nearbyItems, provider),
//           FeedTabFriendsWrapper(provider: provider),
//           FeedTabTrendingWrapper(provider: provider),
//         ],
//       ),
     
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

//         if (isMyItem) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Slidable(
//               key: ValueKey(item.id),
//               endActionPane: ActionPane(
//                 motion: const DrawerMotion(),
//                 extentRatio: 0.50,
//                 children: [
//                   SlidableAction(
//                     onPressed: (_) async {
//                       final result =
//                           await provider.editItem(context, item);
//                       if (result == true) {
//                         provider.loadNearby();
//                         provider.loadTrending();
//                         provider.loadFriends();
//                       }
//                     },
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     icon: Icons.edit,
//                     label: 'Edit',
//                   ),
//                   SlidableAction(
//                     onPressed: (_) async {
//                       final shouldDelete = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text('Confirm Deletion'),
//                           content:
//                               const Text('Are you sure you want to delete this item?'),
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
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Item deleted successfully')),
//                           );
//                         }
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

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: itemCard,
//         );
//       },
//     );
//   }
// }

// class FeedTabFriendsWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabFriendsWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabFriends(
//       key: ValueKey(provider.friendItems.length),
//     );
//   }
// }

// class FeedTabTrendingWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabTrendingWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabTrending(
//       key: ValueKey(provider.trendingItems.length),
//     );
//   }
// }
// import 'package:circlo_app/ui/auth/login_screen.dart';
// import 'package:circlo_app/ui/chat/chat_list_screen.dart';
// import 'package:circlo_app/ui/home/offer_item_screen.dart';
// import 'package:circlo_app/ui/home/search_screen.dart';
// import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
// import 'package:circlo_app/ui/profile/profile_overview_screen.dart';
// import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import 'filter_bottom_sheet.dart';
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
//   int _selectedIndex = 0;
//   Map<String, dynamic>? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _loadCurrentUser();
//       final provider = Provider.of<ItemsProvider>(context, listen: false);
//       provider.loadNearby();
//       provider.loadTrending();
//       provider.loadFriends();
//     });
//   }

//   Future<void> _loadCurrentUser() async {
//     final supabase = Supabase.instance.client;
//     final user = supabase.auth.currentUser;
//     if (user != null) {
//       final res = await supabase
//           .from('users')
//           .select('display_name, email, avatar_url')
//           .eq('id', user.id)
//           .maybeSingle();
//       setState(() => _currentUser = res);
//     }
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

//   void _handleNavTap(int index) {
//     switch (index) {
//       case 0:
//         // Already on Home
//         break;
//       case 1:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const SearchScreen()),
//         );
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ChatListScreen()),
//         );
//         break;
//       case 4:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ProfileOverviewScreen()),
//         );
//         break;
//     }
//   }

//   void _handleFabPressed() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const OfferItemScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Circlo'),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: () => _refreshCurrent(provider),
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

//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             if (_currentUser != null)
//               UserAccountsDrawerHeader(
//                 decoration: const BoxDecoration(color: kGreen),
//                 accountName: Text(_currentUser?['display_name'] ?? 'Unknown User'),
//                 accountEmail: Text(_currentUser?['email'] ?? ''),
//                 currentAccountPicture: CircleAvatar(
//                   backgroundImage: _currentUser?['avatar_url'] != null
//                       ? NetworkImage(_currentUser!['avatar_url'])
//                       : null,
//                   child: _currentUser?['avatar_url'] == null
//                       ? const Icon(Icons.person, size: 40)
//                       : null,
//                 ),
//               )
//             else
//               const DrawerHeader(
//                 decoration: BoxDecoration(color: kGreen),
//                 child: Center(
//                   child: CircularProgressIndicator(color: Colors.white),
//                 ),
//               ),
//             ListTile(
//               leading: const Icon(Icons.filter_alt_rounded, color: kGreen),
//               title: const Text('Filters'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _openFilters(provider);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.chat, color: kGreen),
//               title: const Text('Chats'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ChatListScreen()),
//                 );
//               },
//             ),
//             const Divider(),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text('Logout'),
//               onTap: () async {
//                 final supabase = Supabase.instance.client;
//                 Navigator.pop(context);
//                 try {
//                   await supabase.auth.signOut();
//                   if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Logged out successfully')),
//                     );
//                     Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(builder: (_) => const LoginScreen()),
//                       (Route<dynamic> route) => false,
//                     );
//                   }
//                 } catch (e) {
//                   debugPrint('❌ Logout error: $e');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Failed to log out')),
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),

//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildSwipeableList(provider.nearbyItems, provider),
//           FeedTabFriendsWrapper(provider: provider),
//           FeedTabTrendingWrapper(provider: provider),
//         ],
//       ),

//       // ✅ Fixed BottomNavBar
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 0, // Home screen index
//         onTap: _handleNavTap,
//         onFabPressed: _handleFabPressed,
//       ),
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

//         if (isMyItem) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Slidable(
//               key: ValueKey(item.id),
//               endActionPane: ActionPane(
//                 motion: const DrawerMotion(),
//                 extentRatio: 0.50,
//                 children: [
//                   SlidableAction(
//                     onPressed: (_) async {
//                       final result = await provider.editItem(context, item);
//                       if (result == true) {
//                         provider.loadNearby();
//                         provider.loadTrending();
//                         provider.loadFriends();
//                       }
//                     },
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     icon: Icons.edit,
//                     label: 'Edit',
//                   ),
//                   SlidableAction(
//                     onPressed: (_) async {
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
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Item deleted successfully')),
//                           );
//                         }
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

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: itemCard,
//         );
//       },
//     );
//   }
// }

// class FeedTabFriendsWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabFriendsWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabFriends(
//       key: ValueKey(provider.friendItems.length),
//     );
//   }
// }

// class FeedTabTrendingWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabTrendingWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabTrending(
//       key: ValueKey(provider.trendingItems.length),
//     );
//   }
// }
// import 'package:circlo_app/ui/auth/login_screen.dart';
// import 'package:circlo_app/ui/home/offer_item_screen.dart';
// import 'package:circlo_app/ui/home/search_screen.dart';
// import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
// import 'package:circlo_app/ui/profile/profile_overview_screen.dart';
// import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import 'filter_bottom_sheet.dart';
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
//   Map<String, dynamic>? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _loadCurrentUser();
//       final provider = Provider.of<ItemsProvider>(context, listen: false);
//       provider.loadNearby();
//       provider.loadTrending();
//       provider.loadFriends();
//     });
//   }

//   Future<void> _loadCurrentUser() async {
//     final supabase = Supabase.instance.client;
//     final user = supabase.auth.currentUser;
//     if (user != null) {
//       final res = await supabase
//           .from('users')
//           .select('display_name, email, avatar_url')
//           .eq('id', user.id)
//           .maybeSingle();
//       setState(() => _currentUser = res);
//     }
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

//   void _handleNavTap(int index) {
//     switch (index) {
//       case 0:
//         // Already on Home
//         break;
//       case 1:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const SearchScreen()),
//         );
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const LoginScreen()), // could be chat later
//         );
//         break;
//       case 4:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ProfileOverviewScreen()),
//         );
//         break;
//     }
//   }

//   void _handleFabPressed() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const OfferItemScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Circlo'),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: () => _refreshCurrent(provider),
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
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             if (_currentUser != null)
//               UserAccountsDrawerHeader(
//                 decoration: const BoxDecoration(color: kGreen),
//                 accountName: Text(_currentUser?['display_name'] ?? 'Unknown User'),
//                 accountEmail: Text(_currentUser?['email'] ?? ''),
//                 currentAccountPicture: CircleAvatar(
//                   backgroundImage: _currentUser?['avatar_url'] != null
//                       ? NetworkImage(_currentUser!['avatar_url'])
//                       : null,
//                   child: _currentUser?['avatar_url'] == null
//                       ? const Icon(Icons.person, size: 40)
//                       : null,
//                 ),
//               )
//             else
//               const DrawerHeader(
//                 decoration: BoxDecoration(color: kGreen),
//                 child: Center(
//                   child: CircularProgressIndicator(color: Colors.white),
//                 ),
//               ),
//             ListTile(
//               leading: const Icon(Icons.filter_alt_rounded, color: kGreen),
//               title: const Text('Filters'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _openFilters(provider);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.info_outline, color: kGreen),
//               title: const Text('About Circlo'),
//               onTap: () {
//                 Navigator.pop(context);
//                 showAboutDialog(
//                   context: context,
//                   applicationName: 'Circlo',
//                   applicationVersion: '1.0.0',
//                   applicationIcon: const Icon(Icons.group, color: kGreen, size: 40),
//                   children: const [
//                     Text(
//                         'Circlo is a community-driven app for sharing, swapping, '
//                         'and discovering items nearby. Connect with friends, '
//                         'explore trending items, and safely exchange goods in your area.'),
//                     SizedBox(height: 10),
//                     Text('Developed with ❤️ using Flutter & Supabase.'),
//                   ],
//                 );
//               },
//             ),
//             const Divider(),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text('Logout'),
//               onTap: () async {
//                 final supabase = Supabase.instance.client;
//                 Navigator.pop(context);
//                 try {
//                   await supabase.auth.signOut();
//                   if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Logged out successfully')),
//                     );
//                     Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(builder: (_) => const LoginScreen()),
//                       (Route<dynamic> route) => false,
//                     );
//                   }
//                 } catch (e) {
//                   debugPrint('❌ Logout error: $e');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Failed to log out')),
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildSwipeableList(provider.nearbyItems, provider),
//           FeedTabFriendsWrapper(provider: provider),
//           FeedTabTrendingWrapper(provider: provider),
//         ],
//       ),
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 0,
//         onTap: _handleNavTap,
//         onFabPressed: _handleFabPressed,
//       ),
//     );
//   }

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

//         if (isMyItem) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Slidable(
//               key: ValueKey(item.id),
//               endActionPane: ActionPane(
//                 motion: const DrawerMotion(),
//                 extentRatio: 0.50,
//                 children: [
//                   SlidableAction(
//                     onPressed: (_) async {
//                       final result = await provider.editItem(context, item);
//                       if (result == true) {
//                         provider.loadNearby();
//                         provider.loadTrending();
//                         provider.loadFriends();
//                       }
//                     },
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     icon: Icons.edit,
//                     label: 'Edit',
//                   ),
//                   SlidableAction(
//                     onPressed: (_) async {
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
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Item deleted successfully')),
//                           );
//                         }
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

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: itemCard,
//         );
//       },
//     );
//   }
// }

// class FeedTabFriendsWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabFriendsWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabFriends(
//       key: ValueKey(provider.friendItems.length),
//     );
//   }
// }

// class FeedTabTrendingWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabTrendingWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabTrending(
//       key: ValueKey(provider.trendingItems.length),
//     );
//   }
// }
// import 'package:circlo_app/ui/auth/login_screen.dart';
// import 'package:circlo_app/ui/chat/chat_list_screen.dart';
// import 'package:circlo_app/ui/home/offer_item_screen.dart';
// import 'package:circlo_app/ui/home/search_screen.dart';
// import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
// import 'package:circlo_app/ui/profile/profile_overview_screen.dart';
// import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import 'filter_bottom_sheet.dart';
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
//   Map<String, dynamic>? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _loadCurrentUser();
//       final provider = Provider.of<ItemsProvider>(context, listen: false);
//       provider.loadNearby();
//       provider.loadTrending();
//       provider.loadFriends();
//     });
//   }

//   Future<void> _loadCurrentUser() async {
//     final supabase = Supabase.instance.client;
//     final user = supabase.auth.currentUser;
//     if (user != null) {
//       final res = await supabase
//           .from('users')
//           .select('display_name, email, avatar_url')
//           .eq('id', user.id)
//           .maybeSingle();
//       setState(() => _currentUser = res);
//     }
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

//   void _handleNavTap(int index) {
//     switch (index) {
//       case 0:
//         break;
//       case 1:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const SearchScreen()),
//         );
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ChatListScreen()),
//         );
//         break;
//       case 4:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ProfileOverviewScreen()),
//         );
//         break;
//     }
//   }

//   void _handleFabPressed() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const OfferItemScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context);

//     return Scaffold(
// appBar: AppBar(
//   title: const Text('Circlo'),
//   backgroundColor: kGreen,
//   actions: [
//     PopupMenuButton<String>(
//       icon: const Icon(Icons.more_vert, color: Colors.white),
//       onSelected: (value) {
//         if (value == 'refresh') {
//           _refreshCurrent(provider);
//         } else if (value == 'filters') {
//           _openFilters(provider);
//         }
//       },
//       itemBuilder: (context) => [
//         const PopupMenuItem(
//           value: 'refresh',
//           child: Row(
//             children: [
//               Icon(Icons.refresh_rounded, color: kGreen),
//               SizedBox(width: 8),
//               Text('Refresh'),
//             ],
//           ),
//         ),
//         const PopupMenuItem(
//           value: 'filters',
//           child: Row(
//             children: [
//               Icon(Icons.filter_alt_rounded, color: kGreen),
//               SizedBox(width: 8),
//               Text('Filters'),
//             ],
//           ),
//         ),
//       ],
//     ),
//   ],
//   bottom: TabBar(
//     controller: _tabController,
//     indicatorColor: Colors.white,
//     tabs: const [
//       Tab(text: 'Nearby'),
//       Tab(text: 'Friends'),
//       Tab(text: 'Trending')
//     ],
//   ),
// ),

// drawer: Drawer(
//   child: ListView(
//     padding: EdgeInsets.zero,
//     children: [
//       if (_currentUser != null)
//         UserAccountsDrawerHeader(
//           decoration: const BoxDecoration(color: kGreen),
//           accountName: Text(_currentUser?['display_name'] ?? 'Unknown User'),
//           accountEmail: Text(_currentUser?['email'] ?? ''),
//           currentAccountPicture: CircleAvatar(
//             backgroundImage: _currentUser?['avatar_url'] != null
//                 ? NetworkImage(_currentUser!['avatar_url'])
//                 : null,
//             child: _currentUser?['avatar_url'] == null
//                 ? const Icon(Icons.person, size: 40)
//                 : null,
//           ),
//         )
//       else
//         const DrawerHeader(
//           decoration: BoxDecoration(color: kGreen),
//           child: Center(
//             child: CircularProgressIndicator(color: Colors.white),
//           ),
//         ),
//       ListTile(
//         leading: const Icon(Icons.info_outline, color: kGreen),
//         title: const Text('About Circlo'),
//         onTap: () {
//           Navigator.pop(context);
//           showAboutDialog(
//             context: context,
//             applicationName: 'Circlo',
//             applicationVersion: '1.0.0',
//             applicationIcon: const Icon(Icons.group, color: kGreen, size: 40),
//             children: const [
//               Text(
//                   'Circlo is a community-driven app for sharing, swapping, '
//                   'and discovering items nearby. Connect with friends, '
//                   'explore trending items, and safely exchange goods in your area.'),
//               SizedBox(height: 10),
//               Text('Developed with ❤️ using Flutter & Supabase.'),
//             ],
//           );
//         },
//       ),
//       const Divider(),
//       ListTile(
//         leading: const Icon(Icons.logout, color: Colors.red),
//         title: const Text('Logout'),
//         onTap: () async {
//           final supabase = Supabase.instance.client;
//           Navigator.pop(context);
//           try {
//             await supabase.auth.signOut();
//             if (context.mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Logged out successfully')),
//               );
//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (_) => const LoginScreen()),
//                 (Route<dynamic> route) => false,
//               );
//             }
//           } catch (e) {
//             debugPrint('❌ Logout error: $e');
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Failed to log out')),
//             );
//           }
//         },
//       ),
//     ],
//   ),
// ),

//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildSwipeableList(provider.nearbyItems, provider),
//           FeedTabFriendsWrapper(provider: provider),
//           FeedTabTrendingWrapper(provider: provider),
//         ],
//       ),
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 0,
//         onTap: _handleNavTap,
//         onFabPressed: _handleFabPressed,
//       ),
//     );
//   }

//   /// 🔹 Sleek, compact modern card design
//   Widget _buildSwipeableList(List<Item> items, ItemsProvider provider) {
//     final currentUserId = Supabase.instance.client.auth.currentUser?.id;

//     if (items.isEmpty) return const Center(child: Text('No items found.'));

//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final item = items[index];
//         final isMyItem = item.userId == currentUserId;

//         final itemCard = GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
//             );
//           },
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 6),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: item.imageUrl != null && item.imageUrl!.isNotEmpty
//                       ? Image.network(
//                           item.imageUrl!,
//                           height: 80,
//                           width: 80,
//                           fit: BoxFit.cover,
//                         )
//                       : Container(
//                           height: 80,
//                           width: 80,
//                           color: Colors.grey[300],
//                           child: const Icon(Icons.image, color: Colors.white, size: 40),
//                         ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(item.title,
//                           style: const TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 4),
//                       Text(item.description ?? 'No description',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontSize: 14, color: Colors.black87)),
//                       const SizedBox(height: 6),
//                       if (item.tags.isNotEmpty)
//                         Wrap(
//                           spacing: 6,
//                           children: item.tags
//                               .map((tag) => Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 6, vertical: 2),
//                                     decoration: BoxDecoration(
//                                       color: kGreen.withOpacity(0.2),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Text(tag,
//                                         style: const TextStyle(
//                                             fontSize: 11, color: kGreen)),
//                                   ))
//                               .toList(),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );

//         if (isMyItem) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4),
//             child: Slidable(
//               key: ValueKey(item.id),
//               endActionPane: ActionPane(
//                 motion: const DrawerMotion(),
//                 extentRatio: 0.5,
//                 children: [
//                   SlidableAction(
//                     onPressed: (_) async {
//                       final result = await provider.editItem(context, item);
//                       if (result == true) {
//                         provider.loadNearby();
//                         provider.loadTrending();
//                         provider.loadFriends();
//                       }
//                     },
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     icon: Icons.edit,
//                     label: 'Edit',
//                   ),
//                   SlidableAction(
//                     onPressed: (_) async {
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
//                                 onPressed: () => Navigator.pop(context, false),
//                                 child: const Text('Cancel')),
//                             ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red),
//                                 onPressed: () => Navigator.pop(context, true),
//                                 child: const Text('Delete')),
//                           ],
//                         ),
//                       );
//                       if (shouldDelete == true) {
//                         await provider.deleteItem(item.id);
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                               content: Text('Item deleted successfully')));
//                         }
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

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4),
//           child: itemCard,
//         );
//       },
//     );
//   }
// }

// class FeedTabFriendsWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabFriendsWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabFriends(
//       key: ValueKey(provider.friendItems.length),
//     );
//   }
// }

// class FeedTabTrendingWrapper extends StatelessWidget {
//   final ItemsProvider provider;
//   const FeedTabTrendingWrapper({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FeedTabTrending(
//       key: ValueKey(provider.trendingItems.length),
//     );
//   }
// }
import 'package:circlo_app/ui/auth/login_screen.dart';
import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import 'filter_bottom_sheet.dart';
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
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCurrentUser();
      final provider = Provider.of<ItemsProvider>(context, listen: false);
      provider.loadNearby();
      provider.loadTrending();
      provider.loadFriends();
    });
  }

  Future<void> _loadCurrentUser() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      final res = await supabase
          .from('users')
          .select('display_name, email, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      setState(() => _currentUser = res);
    }
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'refresh') {
                _refreshCurrent(provider);
              } else if (value == 'filters') {
                _openFilters(provider);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, color: kGreen),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'filters',
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_rounded, color: kGreen),
                    SizedBox(width: 8),
                    Text('Filters'),
                  ],
                ),
              ),
            ],
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

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (_currentUser != null)
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: kGreen),
                accountName:
                    Text(_currentUser?['display_name'] ?? 'Unknown User'),
                accountEmail: Text(_currentUser?['email'] ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: _currentUser?['avatar_url'] != null
                      ? NetworkImage(_currentUser!['avatar_url'])
                      : null,
                  child: _currentUser?['avatar_url'] == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              )
            else
              const DrawerHeader(
                decoration: BoxDecoration(color: kGreen),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: kGreen),
              title: const Text('About Circlo'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Circlo',
                  applicationVersion: '1.0.0',
                  applicationIcon:
                      const Icon(Icons.group, color: kGreen, size: 40),
                  children: const [
                    Text(
                        'Circlo is a community-driven app for sharing, swapping, '
                        'and discovering items nearby. Connect with friends, '
                        'explore trending items, and safely exchange goods in your area.'),
                    SizedBox(height: 10),
                    Text('Developed with ❤️ using Flutter & Supabase.'),
                  ],
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                final supabase = Supabase.instance.client;
                Navigator.pop(context);
                try {
                  await supabase.auth.signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully')),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                } catch (e) {
                  debugPrint('❌ Logout error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to log out')),
                  );
                }
              },
            ),
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
    );
  }

  /// 🔹 Sleek, compact modern card design
  Widget _buildSwipeableList(List<Item> items, ItemsProvider provider) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (items.isEmpty) return const Center(child: Text('No items found.'));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isMyItem = item.userId == currentUserId;

        final itemCard = GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailScreen(item: item),
              ),
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
                          color: Colors.grey[300],
                          child: const Icon(Icons.image,
                              color: Colors.white, size: 40),
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
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 6),
                      if (item.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children: item.tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(tag,
                                      style: const TextStyle(
                                          fontSize: 11, color: kGreen)),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (isMyItem) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Slidable(
              key: ValueKey(item.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.5,
                children: [
                  SlidableAction(
                    onPressed: (_) async {
                      final result = await provider.editItem(context, item);
                      if (result == true) {
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
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () =>
                                  Navigator.pop(context, true),
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
                                content:
                                    Text('Item deleted successfully')),
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
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: itemCard,
        );
      },
    );
  }
}

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
