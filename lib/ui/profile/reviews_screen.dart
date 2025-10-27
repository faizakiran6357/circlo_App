
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;

  bool loadingReceived = true;
  bool loadingGiven = true;

  List<Map<String, dynamic>> receivedReviews = [];
  List<Map<String, dynamic>> givenReviews = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReceivedReviews();
    _loadGivenReviews();
  }

  Future<void> _loadReceivedReviews() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    setState(() => loadingReceived = true);

    try {
      final res = await supabase
          .from('reviews')
          .select('''
            id,
            rating,
            comment,
            created_at,
            users:reviewer_id(id, display_name, avatar_url)
          ''')
          .eq('reviewee_id', currentUser.id)
          .order('created_at', ascending: false);

      setState(() {
        receivedReviews = List<Map<String, dynamic>>.from(res);
        loadingReceived = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading received reviews: $e');
      setState(() => loadingReceived = false);
    }
  }

  Future<void> _loadGivenReviews() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    setState(() => loadingGiven = true);

    try {
      final res = await supabase
          .from('reviews')
          .select('''
            id,
            rating,
            comment,
            created_at,
            users:reviewee_id(id, display_name, avatar_url)
          ''')
          .eq('reviewer_id', currentUser.id)
          .order('created_at', ascending: false);

      setState(() {
        givenReviews = List<Map<String, dynamic>>.from(res);
        loadingGiven = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading given reviews: $e');
      setState(() => loadingGiven = false);
    }
  }

  Future<void> refreshReviews() async {
    await Future.wait([_loadReceivedReviews(), _loadGivenReviews()]);
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final user = review['users'] ?? {};

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black12.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: kBg,
              backgroundImage: user['avatar_url'] != null
                  ? NetworkImage(user['avatar_url'])
                  : null,
              child: user['avatar_url'] == null
                  ? const Icon(Icons.person, size: 24, color: kTextDark)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          user['display_name'] ?? 'Unknown User',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: kTextDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kAmber.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: kAmber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              (review['rating'] ?? 0).toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: kTextDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        Icon(
                          i <= (review['rating'] ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: kAmber,
                          size: 16,
                        ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        review['created_at'] != null
                            ? review['created_at'].toString().split('T')[0]
                            : '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      review['comment'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen,
        centerTitle: true,
        foregroundColor: Colors.white, // makes back arrow white
        title: const Text(
          'Reviews',
          style: TextStyle(
            color: Colors.white, // title text white
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Given'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          indicator: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          loadingReceived
              ? const Center(child: CircularProgressIndicator())
              : receivedReviews.isEmpty
                  ? const Center(child: Text('No reviews received yet'))
                  : RefreshIndicator(
                      color: kGreen,
                      backgroundColor: Colors.white,
                      onRefresh: _loadReceivedReviews,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: receivedReviews.length,
                        itemBuilder: (context, index) =>
                            _buildReviewCard(receivedReviews[index]),
                      ),
                    ),
          loadingGiven
              ? const Center(child: CircularProgressIndicator())
              : givenReviews.isEmpty
                  ? const Center(child: Text('No reviews given yet'))
                  : RefreshIndicator(
                      color: kGreen,
                      backgroundColor: Colors.white,
                      onRefresh: _loadGivenReviews,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: givenReviews.length,
                        itemBuilder: (context, index) =>
                            _buildReviewCard(givenReviews[index]),
                      ),
                    ),
        ],
      ),
    );
  }
}
