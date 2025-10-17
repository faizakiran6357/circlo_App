import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';

class AddReviewScreen extends StatefulWidget {
  final String targetUserId; // User receiving the review
  final String exchangeId;   // (kept for navigation consistency, not used in DB)

  const AddReviewScreen({
    super.key,
    required this.targetUserId,
    required this.exchangeId,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final supabase = Supabase.instance.client;

  int rating = 0;
  final TextEditingController commentController = TextEditingController();
  bool loading = false;

  Future<void> submitReview() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // ✅ FIXED COLUMN NAME (comment)
      await supabase.from('reviews').insert({
        'reviewer_id': currentUser.id,
        'reviewee_id': widget.targetUserId,
        'rating': rating,
        'comment': commentController.text.trim(), // ✅ singular
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Review submitted successfully!')),
      );

      if (context.mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('❌ Exception submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
        backgroundColor: kGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Rate your exchange', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () => setState(() => rating = starIndex),
                  icon: Icon(
                    rating >= starIndex ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your review here...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}