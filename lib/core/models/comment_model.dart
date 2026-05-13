import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentId;
  final String postId;
  final String userId;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> map, String documentId) {
    return Comment(
      commentId: documentId,
      postId: map['post_id'] ?? '',
      userId: map['user_id'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
