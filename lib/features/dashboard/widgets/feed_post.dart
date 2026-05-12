import 'package:flutter/material.dart';
import 'package:nest/core/typography/app_text_styles.dart';
import 'package:nest/core/models/post_model.dart';
import 'image_carousel.dart';

/// Feed post card
/// Displays user info, content, images, and action buttons
class FeedPost extends StatelessWidget {
  final Post post;

  const FeedPost({super.key, required this.post});

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${timestamp.month}/${timestamp.day}';
  }

  @override
  Widget build(BuildContext context) {
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
        children: [
          // User header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: post.userAvatar.isNotEmpty
                      ? Image.asset(
                    post.userAvatar,
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
                  )
                      : Icon(
                    Icons.person,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // User name and timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: AppTextStyles.subheading(context, fontSize: 14),
                      ),
                      Text(
                        _formatTimeAgo(post.timestamp),
                        style: AppTextStyles.body(
                          context,
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              post.content,
              style: AppTextStyles.body(context),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          // Images carousel (if exists)
          if (post.hasImages) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // Pass the images list, or wrap the single mediaUrl in a list as a fallback
              child: ImageCarousel(
                  images: post.images.isNotEmpty ? post.images : [post.mediaUrl]
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _ActionButton(
                  icon: Icons.favorite_outline,
                  label: post.likesCount > 0 ? '${post.likesCount}' : 'Like',
                  onPressed: () {},
                ),
                const SizedBox(width: 24),
                _ActionButton(
                  icon: Icons.comment_outlined,
                  label: post.commentsCount > 0 ? '${post.commentsCount}' : 'Comment',
                  onPressed: () {},
                ),
                const SizedBox(width: 24),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: post.sharesCount > 0 ? '${post.sharesCount}' : 'Share',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable action button for post interactions
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.body(
              context,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}