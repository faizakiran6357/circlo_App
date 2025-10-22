
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/items_provider.dart';
import '../../models/item_model.dart';
import '../../utils/app_theme.dart';
import '../item_detail/item_detail_screen.dart';

class ViewAllScreen extends StatefulWidget {
  final String initialTab; // e.g. "Nearby Items"

  const ViewAllScreen({super.key, required this.initialTab});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = ["Nearby Items", "Friends' Items", "Trending Items"];
  late ScrollController _nearbyScrollController;
  late ScrollController _friendsScrollController;
  late ScrollController _trendingScrollController;

  @override
  void initState() {
    super.initState();
    final initialIndex = tabs.indexOf(widget.initialTab);
    _tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );

    final provider = Provider.of<ItemsProvider>(context, listen: false);
    provider.loadNearby(reset: true);
    provider.loadFriends(reset: true);
    provider.loadTrending(reset: true);

    _nearbyScrollController = ScrollController()..addListener(() => _scrollListener(0));
    _friendsScrollController = ScrollController()..addListener(() => _scrollListener(1));
    _trendingScrollController = ScrollController()..addListener(() => _scrollListener(2));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nearbyScrollController.dispose();
    _friendsScrollController.dispose();
    _trendingScrollController.dispose();
    super.dispose();
  }

  Future<String> _fetchOwnerName(String userId) async {
    final supabase = Supabase.instance.client;
    try {
      final res = await supabase
          .from('users')
          .select('display_name')
          .eq('id', userId)
          .maybeSingle();
      return res?['display_name'] ?? 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  void _scrollListener(int tabIndex) {
    final provider = Provider.of<ItemsProvider>(context, listen: false);
    ScrollController controller;
    bool hasMore;

    switch (tabIndex) {
      case 0:
        controller = _nearbyScrollController;
        hasMore = provider.hasMoreNearby;
        break;
      case 1:
        controller = _friendsScrollController;
        hasMore = provider.hasMoreFriends;
        break;
      case 2:
        controller = _trendingScrollController;
        hasMore = provider.hasMoreTrending;
        break;
      default:
        return;
    }

    if (controller.position.pixels >= controller.position.maxScrollExtent - 200 && hasMore) {
      switch (tabIndex) {
        case 0:
          provider.loadNearby();
          break;
        case 1:
          provider.loadFriends();
          break;
        case 2:
          provider.loadTrending();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Items"),
        backgroundColor: kGreen,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Nearby"),
            Tab(text: "Friends"),
            Tab(text: "Trending"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(provider.nearbyItems, _nearbyScrollController, provider.loadingNearby),
          _buildList(provider.friendItems, _friendsScrollController, provider.loadingFriends),
          _buildList(provider.trendingItems, _trendingScrollController, provider.loadingTrending),
        ],
      ),
    );
  }

  Widget _buildList(List<Item> items, ScrollController controller, bool isLoading) {
    if (items.isEmpty && !isLoading) {
      return const Center(child: Text("No items found."));
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(12),
      itemCount: items.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = items[index];
        return FutureBuilder<String>(
          future: _fetchOwnerName(item.userId),
          builder: (context, snapshot) {
            final ownerName = snapshot.data ?? 'Loading...';
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
              ),
              child: Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                            ? Image.network(
                                item.imageUrl!,
                                height: 90,
                                width: 90,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 90,
                                width: 90,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.white),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description ?? 'No description',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Owner: $ownerName",
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
