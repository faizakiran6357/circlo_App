
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';

// class ReviewsScreen extends StatefulWidget {
//   const ReviewsScreen({super.key});

//   @override
//   State<ReviewsScreen> createState() => _ReviewsScreenState();
// }

// class _ReviewsScreenState extends State<ReviewsScreen>
//     with SingleTickerProviderStateMixin {
//   final supabase = Supabase.instance.client;
//   late TabController _tabController;

//   bool loadingReceived = true;
//   bool loadingGiven = true;

//   List<Map<String, dynamic>> receivedReviews = [];
//   List<Map<String, dynamic>> givenReviews = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadReceivedReviews();
//     _loadGivenReviews();
//   }

//   /// 🟢 Load reviews received by current user
//   Future<void> _loadReceivedReviews() async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     setState(() => loadingReceived = true);

//     try {
//       final res = await supabase
//           .from('reviews')
//           .select('''
//             id,
//             rating,
//             comment,
//             created_at,
//             users:reviewer_id(id, display_name, avatar_url)
//           ''')
//           .eq('reviewee_id', currentUser.id)
//           .order('created_at', ascending: false);

//       setState(() {
//         receivedReviews = List<Map<String, dynamic>>.from(res);
//         loadingReceived = false;
//       });
//     } catch (e) {
//       debugPrint('❌ Error loading received reviews: $e');
//       setState(() => loadingReceived = false);
//     }
//   }

//   /// 🟣 Load reviews given by current user
//   Future<void> _loadGivenReviews() async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     setState(() => loadingGiven = true);

//     try {
//       final res = await supabase
//           .from('reviews')
//           .select('''
//             id,
//             rating,
//             comment,
//             created_at,
//             users:reviewee_id(id, display_name, avatar_url)
//           ''')
//           .eq('reviewer_id', currentUser.id)
//           .order('created_at', ascending: false);

//       setState(() {
//         givenReviews = List<Map<String, dynamic>>.from(res);
//         loadingGiven = false;
//       });
//     } catch (e) {
//       debugPrint('❌ Error loading given reviews: $e');
//       setState(() => loadingGiven = false);
//     }
//   }

//   /// Refresh both tabs
//   Future<void> refreshReviews() async {
//     await Future.wait([_loadReceivedReviews(), _loadGivenReviews()]);
//   }

//   /// 🧩 Build each review card
//   Widget _buildReviewCard(Map<String, dynamic> review) {
//     final user = review['users'] ?? {};

//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: ListTile(
//         leading: user['avatar_url'] != null
//             ? CircleAvatar(backgroundImage: NetworkImage(user['avatar_url']))
//             : const CircleAvatar(child: Icon(Icons.person)),
//         title: Text(
//           user['display_name'] ?? 'Unknown User',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(review['comment'] ?? ''),
//         trailing: Text(
//           '⭐ ${review['rating'].toString()}',
//           style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reviews'),
//         backgroundColor: kGreen,
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [Tab(text: 'Received'), Tab(text: 'Given')],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // ✅ RECEIVED REVIEWS
//           loadingReceived
//               ? const Center(child: CircularProgressIndicator())
//               : receivedReviews.isEmpty
//                   ? const Center(child: Text('No reviews received yet'))
//                   : RefreshIndicator(
//                       onRefresh: _loadReceivedReviews,
//                       child: ListView.builder(
//                         padding: const EdgeInsets.all(12),
//                         itemCount: receivedReviews.length,
//                         itemBuilder: (context, index) =>
//                             _buildReviewCard(receivedReviews[index]),
//                       ),
//                     ),

//           // ✅ GIVEN REVIEWS
//           loadingGiven
//               ? const Center(child: CircularProgressIndicator())
//               : givenReviews.isEmpty
//                   ? const Center(child: Text('No reviews given yet'))
//                   : RefreshIndicator(
//                       onRefresh: _loadGivenReviews,
//                       child: ListView.builder(
//                         padding: const EdgeInsets.all(12),
//                         itemCount: givenReviews.length,
//                         itemBuilder: (context, index) =>
//                             _buildReviewCard(givenReviews[index]),
//                       ),
//                     ),
//         ],
//       ),
//     );
//   }
// }
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

    return Card(
      color: Colors.white, // ✅ White card
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: user['avatar_url'] != null
                  ? NetworkImage(user['avatar_url'])
                  : null,
              child: user['avatar_url'] == null
                  ? const Icon(Icons.person, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['display_name'] ?? 'Unknown User',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review['comment'] ?? '',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        Icon(
                          i <= (review['rating'] ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        review['created_at'] != null
                            ? review['created_at'].toString().split('T')[0]
                            : '',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
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
        title: const Text('Reviews'),
        backgroundColor: kGreen,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Received'), Tab(text: 'Given')],
          indicatorColor: Colors.white,
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
