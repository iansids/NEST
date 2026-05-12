import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String content;
  final String mediaUrl;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;

  // Additional UI fields that you might fetch from tbl_users or denormalize into tbl_posts
  final String userName;
  final String userAvatar;

  Post({
    required this.postId,
    required this.userId,
    required this.content,
    required this.mediaUrl,
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
    this.userName = 'Unknown User',
    this.userAvatar = '',
  });

  bool get hasImages => mediaUrl.isNotEmpty;

  factory Post.fromMap(Map<String, dynamic> map, String documentId) {
    return Post(
      postId: documentId,
      userId: map['user_id'] ?? '',
      content: map['content'] ?? '',
      mediaUrl: map['media_url'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      // In a production app, you might fetch these from tbl_users using the user_id
      userName: map['username'] ?? '@user',
      userAvatar: map['user_avatar'] ?? '',
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