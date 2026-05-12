import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String content;
  final String? mediaUrl;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;

  Post({
    required this.postId,
    required this.userId,
    required this.content,
    this.mediaUrl,
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
  });

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;

  factory Post.fromMap(Map<String, dynamic> map, String documentId) {
    return Post(
      postId: documentId,
      userId: map['user_id'] ?? '',
      content: map['content'] ?? '',
      mediaUrl: map['media_url'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'content': content,
      'media_url': mediaUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
    };
  }
}
