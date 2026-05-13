import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:nest/core/typography/app_text_styles.dart';
import 'package:nest/core/models/post_model.dart';
import '../../profile/screens/profile_screen.dart';
import '../screens/comments_page.dart';
import 'image_carousel.dart';

/// Feed post card
/// Displays user info, content, images, and action buttons
class FeedPost extends StatefulWidget {
  final Post post;

  const FeedPost({super.key, required this.post});

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  late Future<Map<String, dynamic>> _userDataFuture;
  bool _isLiked = false;
  bool _isLikeLoading = false;
  int _likesCount = 0;
  int _commentsCount = 0;
  StreamSubscription? _likeStreamSubscription;
  StreamSubscription? _commentStreamSubscription;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
    _likesCount = widget.post.likesCount;
    _commentsCount = widget.post.commentsCount;
    _isLiked = widget.post.likedBy.contains(
      FirebaseAuth.instance.currentUser?.uid,
    );
    _listenToLikes();
    _listenToComments();
  }

  @override
  void dispose() {
    _likeStreamSubscription?.cancel();
    _commentStreamSubscription?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_users')
          .doc(widget.post.userId)
          .get();
      return userDoc.data() ?? {};
    } catch (e) {
      return {};
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${timestamp.month}/${timestamp.day}';
  }

  void _listenToLikes() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Listen to the post document for changes to liked_by array
    _likeStreamSubscription = FirebaseFirestore.instance
        .collection('tbl_posts')
        .doc(widget.post.postId)
        .snapshots()
        .listen((snapshot) {
          if (mounted && !_isLikeLoading) {
            final likedBy = List<String>.from(
              snapshot.data()?['liked_by'] ?? [],
            );
            final likesCount = snapshot.data()?['likes_count'] ?? 0;
            setState(() {
              _isLiked = likedBy.contains(currentUser.uid);
              _likesCount = likesCount;
            });
          }
        });
  }

  void _listenToComments() {
    // Listen to comments count changes
    _commentStreamSubscription = FirebaseFirestore.instance
        .collection('tbl_posts')
        .doc(widget.post.postId)
        .snapshots()
        .listen((snapshot) {
          if (mounted) {
            final commentsCount = snapshot.data()?['comments_count'] ?? 0;
            setState(() {
              _commentsCount = commentsCount;
            });
          }
        });
  }

  Future<void> _toggleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _isLikeLoading) return;

    // Set loading state to prevent listener from interfering
    setState(() => _isLikeLoading = true);

    try {
      final postRef = FirebaseFirestore.instance
          .collection('tbl_posts')
          .doc(widget.post.postId);

      if (_isLiked) {
        // Unlike
        await postRef.update({
          'liked_by': FieldValue.arrayRemove([currentUser.uid]),
          'likes_count': FieldValue.increment(-1),
        });
      } else {
        // Like
        await postRef.update({
          'liked_by': FieldValue.arrayUnion([currentUser.uid]),
          'likes_count': FieldValue.increment(1),
        });
      }

      // Update local state immediately
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
          _isLikeLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLikeLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        final userName = snapshot.data?['username'] ?? 'Unknown User';
        final userAvatar = snapshot.data?['profile_picture'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Avatar
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(userId: widget.post.userId),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: userAvatar.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  userAvatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      size: 20,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                size: 20,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // User name and timestamp
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(userId: widget.post.userId),
                                ),
                              );
                            },
                            child: Text(
                              userName,
                              style: AppTextStyles.subheading(
                                context,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            _formatTimeAgo(widget.post.timestamp),
                            style: AppTextStyles.body(
                              context,
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // More options
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              // Post content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.post.content,
                  style: AppTextStyles.body(context),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              // Image carousel (if exists)
              if (widget.post.allMedia.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ImageCarousel(images: widget.post.allMedia),
                ),
                const SizedBox(height: 12),
              ],
              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Like button with loading state
                    InkWell(
                      onTap: _isLikeLoading ? null : _toggleLike,
                      child: Row(
                        children: [
                          if (_isLikeLoading)
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )
                          else
                            Icon(
                              _isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              size: 18,
                              color: _isLiked
                                  ? Colors.red
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            _likesCount > 0 ? '$_likesCount' : 'Like',
                            style: AppTextStyles.body(
                              context,
                              fontSize: 14,
                              color: _isLiked
                                  ? Colors.red
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Comment button
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CommentsPage(post: widget.post),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _commentsCount > 0 ? '$_commentsCount' : 'Comment',
                            style: AppTextStyles.body(
                              context,
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
