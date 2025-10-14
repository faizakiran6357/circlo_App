import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();

  final List<Map<String, String>> _comments = [
    {'user': 'Faiza', 'text': 'Looks great!'},
    {'user': 'Aniqa', 'text': 'Is this still available?'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        for (var comment in _comments)
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(comment['user']!),
            subtitle: Text(comment['text']!),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kGreen),
              onPressed: () {
                if (_commentController.text.trim().isEmpty) return;
                setState(() {
                  _comments.add({'user': 'You', 'text': _commentController.text});
                });
                _commentController.clear();
              },
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
