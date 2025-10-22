
import 'dart:async';
import 'package:circlo_app/ui/auth/login_screen.dart';
import 'package:circlo_app/ui/home/feed_tab_trending.dart';
import 'package:circlo_app/ui/home/offer_item_screen.dart';
import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
import 'package:circlo_app/ui/home/view_all_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import '../../providers/items_provider.dart';
import '../../models/item_model.dart';

// Import your screens for banner navigation
import '../profile/profile_overview_screen.dart';
import '../chat/chat_list_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  Map<String, dynamic>? _currentUser;
  final supabase = Supabase.instance.client;

  bool _hasFriends = true; // 👈 Added flag

  // -------------------------
  // Banner model
  // -------------------------
  final List<BannerModel> banners = [
    BannerModel(
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1675883156911-6496b36c9f4d?ixlib=rb-4.1.0&auto=format&fit=crop&q=80&w=687',
      title: 'List your first item!',
    ),
    BannerModel(
      imageUrl:
          'https://media.istockphoto.com/id/2201622447/photo/wooden-hand-and-yellow-paper-with-motivational-words-people-buy-from-people-they-trust-sales.jpg?s=1024x1024&w=is&k=20&c=8vgJgwylBlKidzjixvNfXfFIUEN_A4sO_msD_TFLABM=',
      title: 'Earn trust points today!',
    ),
    BannerModel(
      imageUrl:
          'https://media.istockphoto.com/id/1601471733/photo/referral-system-receive-bonuses-together-with-friends-cool-discounts-referral-marketing.jpg?s=1024x1024&w=is&k=20&c=hnax6Ll78SfLigwHkPBz_M07IN--F4AReEC6qpMMf74=',
      title: 'Invite friends & get rewards!',
    ),
    BannerModel(
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1756200411527-9d2f5b792d7a?ixlib=rb-4.1.0&auto=format&fit=crop&q=80&w=1972',
      title: 'Check out weekly top items',
    ),
  ];

  late PageController _bannerController;
  int _currentBanner = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCurrentUser();
      final provider = Provider.of<ItemsProvider>(context, listen: false);
      provider.loadNearby();
      provider.loadTrending();
      provider.loadFriends();
      await _checkIfUserHasFriends(); // 👈 check friends after user load
    });

    // Banner auto slide
    _bannerController = PageController(viewportFraction: 0.85);
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentBanner < banners.length - 1) {
        _currentBanner++;
      } else {
        _currentBanner = 0;
      }
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final res = await supabase
          .from('users')
          .select('id, display_name, email, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      setState(() => _currentUser = res);
    }
  }

  // 👇 Check if logged-in user has friends in DB
  Future<void> _checkIfUserHasFriends() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final friends = await supabase
          .from('friends')
          .select()
          .or('user_id.eq.${user.id},friend_id.eq.${user.id}');

      setState(() {
        _hasFriends = friends.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error checking friends: $e');
      setState(() {
        _hasFriends = false;
      });
    }
  }

  Future<String> _fetchOwnerName(String userId) async {
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circlo'),
        backgroundColor: kGreen,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final provider = Provider.of<ItemsProvider>(context, listen: false);
          await provider.refreshAll();
          await _checkIfUserHasFriends(); // refresh also updates this
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------
                // Auto Sliding Banners with onTap
                // ------------------------
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _bannerController,
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return GestureDetector(
                        onTap: () {
                          switch (index) {
                            case 0:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => OfferItemScreen()),
                              );
                              break;
                            case 1:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProfileOverviewScreen()),
                              );
                              break;
                            case 2:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ChatListScreen()),
                              );
                              break;
                            case 3:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ViewAllScreen(
                                        initialTab: 'Trending items')),
                              );
                              break;
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(banner.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: Text(
                              banner.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Nearby Section
                _buildSection(
                  title: 'Nearby Items',
                  items: provider.nearbyItems,
                ),

                const SizedBox(height: 20),

                // Friends Section — only if user has friends 👇
                if (_hasFriends)
                  _buildSection(
                    title: 'Friends\' Items',
                    items: provider.friendItems,
                  ),

                if (_hasFriends) const SizedBox(height: 20),

                // Trending Section
                _buildSection(
                  title: 'Trending Items',
                  items: provider.trendingItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Item> items,
  }) {
    final displayItems = items.length > 4 ? items.take(4).toList() : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (items.length > 4)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewAllScreen(initialTab: title),
                    ),
                  );
                },
                child: const Text(
                  "View All →",
                  style: TextStyle(color: kGreen, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 210,
          child: displayItems.isEmpty
              ? const Center(child: Text('No items found.'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) {
                    final item = displayItems[index];
                    return FutureBuilder<String>(
                      future: _fetchOwnerName(item.userId),
                      builder: (context, snapshot) {
                        final ownerName = snapshot.data ?? 'Loading...';
                        return _buildItemCard(item, ownerName);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Item item, String ownerName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image,
                          color: Colors.white, size: 40),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    item.description ?? 'No description',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Owner: $ownerName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------
// BannerModel class
// ------------------------
class BannerModel {
  final String imageUrl;
  final String title;
  BannerModel({required this.imageUrl, required this.title});
}
