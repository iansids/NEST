/// Data model for social feed posts
class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final List<String> images;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final int shares;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.images,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  /// Check if post has images
  bool get hasImages => images.isNotEmpty;

  /// Get the number of images
  int get imageCount => images.length;
}
