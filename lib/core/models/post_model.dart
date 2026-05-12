import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String content;
  final String mediaUrl;
  final List<String> images; // Added to support multi-image carousels
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;
  final int sharesCount; // Added to support share tracking

  // Additional UI fields that you might fetch from tbl_users or denormalize into tbl_posts
  final String userName;
  final String userAvatar;

  Post({
    required this.postId,
    required this.userId,
    required this.content,
    this.mediaUrl = '',
    this.images = const [],
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
    this.sharesCount = 0,
    this.userName = 'Unknown User',
    this.userAvatar = '',
  });

  // Updated to check both mediaUrl and images list
  bool get hasImages => mediaUrl.isNotEmpty || images.isNotEmpty;

  factory Post.fromMap(Map<String, dynamic> map, String documentId) {
    return Post(
      postId: documentId,
      userId: map['user_id'] ?? '',
      content: map['content'] ?? '',
      mediaUrl: map['media_url'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      sharesCount: map['shares_count'] ?? 0,
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
      'images': images,
      'timestamp': FieldValue.serverTimestamp(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
    };
  }
}