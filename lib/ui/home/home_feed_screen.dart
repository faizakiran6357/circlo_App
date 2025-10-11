// import 'package:circlo_app/ui/home/feed_tab_nearby.dart';
// import 'package:circlo_app/ui/home/feed_tab_trending.dart';
// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';
// //import 'feed_tab_nearby.dart';
// import 'feed_tab_friends.dart';
// //import 'feed_tab_trending.dart';
// import 'filter_bottom_sheet.dart';
// import 'offer_item_fab.dart';

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

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _openFilters() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => const FilterBottomSheet(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Circlo"),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_alt_rounded),
//             onPressed: _openFilters,
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(text: "Nearby"),
//             Tab(text: "Friends"),
//             Tab(text: "Trending"),
//           ],
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
// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';
// import 'feed_tab_nearby.dart';
// import 'feed_tab_friends.dart';
// import 'feed_tab_trending.dart';
// import 'filter_bottom_sheet.dart';
// import 'offer_item_fab.dart';
// import '../../services/supabase_item_service.dart';

// class HomeFeedScreen extends StatefulWidget {
//   const HomeFeedScreen({super.key});

//   @override
//   State<HomeFeedScreen> createState() => _HomeFeedScreenState();
// }

// class _HomeFeedScreenState extends State<HomeFeedScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   // Data for tabs
//   List<Map<String, dynamic>> nearbyItems = [];
//   List<Map<String, dynamic>> friendItems = [];
//   List<Map<String, dynamic>> trendingItems = [];

//   bool loadingNearby = true;
//   bool loadingFriends = true;
//   bool loadingTrending = true;

//   // Current applied filter (for nearby)
//   Map<String, dynamic> appliedFilter = {};

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadAll();
//   }

//   Future<void> _loadAll() async {
//     await Future.wait([
//       _loadNearby(),
//       _loadFriends(),
//       _loadTrending(),
//     ]);
//   }

//   Future<void> _loadNearby({double radiusKm = 50}) async {
//     setState(() => loadingNearby = true);
//     try {
//       final items = await SupabaseItemService.fetchNearbyItems(radiusKm);
//       setState(() => nearbyItems = items);
//     } catch (e) {
//       debugPrint('Error loadNearby: $e');
//       setState(() => nearbyItems = []);
//     } finally {
//       setState(() => loadingNearby = false);
//     }
//   }

//   Future<void> _loadFriends() async {
//     setState(() => loadingFriends = true);
//     try {
//       final items = await SupabaseItemService.fetchFriendItems();
//       setState(() => friendItems = items);
//     } catch (e) {
//       debugPrint('Error loadFriends: $e');
//       setState(() => friendItems = []);
//     } finally {
//       setState(() => loadingFriends = false);
//     }
//   }

//   Future<void> _loadTrending() async {
//     setState(() => loadingTrending = true);
//     try {
//       final items = await SupabaseItemService.fetchTrendingItems();
//       setState(() => trendingItems = items);
//     } catch (e) {
//       debugPrint('Error loadTrending: $e');
//       setState(() => trendingItems = []);
//     } finally {
//       setState(() => loadingTrending = false);
//     }
//   }

//   // Apply filters from bottom sheet (affects nearby tab primarily)
//   Future<void> _applyFilters(Map<String, dynamic> filters) async {
//     setState(() {
//       appliedFilter = filters;
//       loadingNearby = true;
//     });
//     try {
//       final items = await SupabaseItemService.fetchFilteredItems(filters);
//       setState(() => nearbyItems = items);
//     } catch (e) {
//       debugPrint('Error applyFilters: $e');
//       setState(() => nearbyItems = []);
//     } finally {
//       setState(() => loadingNearby = false);
//     }
//   }

//   void _openFilters() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true,
//       builder: (_) => FilterBottomSheet(
//         initialFilters: appliedFilter,
//         onApply: (filters) {
//           Navigator.pop(context);
//           _applyFilters(filters);
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _refreshCurrentTab() async {
//     if (_tabController.index == 0) {
//       await _loadNearby();
//     } else if (_tabController.index == 1) {
//       await _loadFriends();
//     } else {
//       await _loadTrending();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Circlo'),
//         backgroundColor: kGreen,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_alt_rounded),
//             onPressed: _openFilters,
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: _refreshCurrentTab,
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(text: 'Nearby'),
//             Tab(text: 'Friends'),
//             Tab(text: 'Trending'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // Nearby
//           FeedTabNearby(
//             items: nearbyItems,
//             isLoading: loadingNearby,
//             onRefresh: () => _loadNearby(),
//           ),

//           // Friends
//           FeedTabFriends(
//             items: friendItems,
//             isLoading: loadingFriends,
//             onRefresh: () => _loadFriends(),
//           ),

//           // Trending
//           FeedTabTrending(
//             items: trendingItems,
//             isLoading: loadingTrending,
//             onRefresh: () => _loadTrending(),
//           ),
//         ],
//       ),
//       floatingActionButton: const OfferItemFAB(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import 'filter_bottom_sheet.dart';
import 'offer_item_fab.dart';
import '../home/feed_tab_nearby.dart';
import '../home/feed_tab_friends.dart';
import '../home/feed_tab_trending.dart';
import '../../providers/items_provider.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _openFilters(ItemsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
          IconButton(icon: const Icon(Icons.filter_alt_rounded), onPressed: () => _openFilters(provider)),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => _refreshCurrent(provider)),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Nearby'), Tab(text: 'Friends'), Tab(text: 'Trending')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FeedTabNearby(),
          FeedTabFriends(),
          FeedTabTrending(),
        ],
      ),
      floatingActionButton: const OfferItemFAB(),
    );
  }
}
