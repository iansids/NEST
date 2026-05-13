import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String content;
  final String? mediaUrl;
  final List<String> mediaUrls;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy;

  Post({
    required this.postId,
    required this.userId,
    required this.content,
    this.mediaUrl,
    this.mediaUrls = const [],
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
    this.likedBy = const [],
  });

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
  List<String> get allMedia {
    if (mediaUrls.isNotEmpty) return mediaUrls;
    if (mediaUrl != null && mediaUrl!.isNotEmpty) return [mediaUrl!];
    return [];
  }

  factory Post.fromMap(Map<String, dynamic> map, String documentId) {
    return Post(
      postId: documentId,
      userId: map['user_id'] ?? '',
      content: map['content'] ?? '',
      mediaUrl: map['media_url'],
      mediaUrls: List<String>.from(map['media_urls'] ?? []),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      likedBy: List<String>.from(map['liked_by'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'content': content,
      'media_url': mediaUrl,
      'media_urls': mediaUrls,
      'timestamp': FieldValue.serverTimestamp(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'liked_by': likedBy,
    };
  }
}
