import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentProvider extends ChangeNotifier {
  final List<Comment> _comments = [
    Comment(
      id: '1',
      itemId: '1',
      userId: 'Faiza',
      text: 'Looks great!',
      createdAt: DateTime.now(),
    ),
  ];

  List<Comment> get comments => _comments;

  void addComment(String userId, String itemId, String text) {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: itemId,
      userId: userId,
      text: text,
      createdAt: DateTime.now(),
    );
    _comments.add(newComment);
    notifyListeners();
  }
}
