import 'package:flutter/material.dart';
import '../../../core/models/post_model.dart';
import '../../../core/typography/app_text_styles.dart';
import '../widgets/post_creation_box.dart';
import '../widgets/feed_post.dart';

/// Main dashboard/feed screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<Post> _posts;

  @override
  void initState() {
    super.initState();
    _initializeMockPosts();
  }

  void _initializeMockPosts() {
    _posts = [
      Post(
        id: '1',
        userId: 'user1',
        userName: 'Alex Chen',
        userAvatar: '',
        content:
            'Just launched my new Flutter project! Really excited about the modular architecture we\'ve built. #flutter #development',
        images: [],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 128,
        comments: 24,
        shares: 15,
      ),
      Post(
        id: '2',
        userId: 'user2',
        userName: 'Sarah Johnson',
        userAvatar: '',
        content:
            'Beautiful sunset at the beach today. Nothing beats a good walk by the ocean! 🌅',
        images: ['resources/ICON.png', 'resources/LOGO.png'],
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        likes: 456,
        comments: 89,
        shares: 42,
      ),
      Post(
        id: '3',
        userId: 'user3',
        userName: 'Dev Community',
        userAvatar: '',
        content:
            'Top 5 Flutter best practices for building scalable apps:\n1. Use proper state management\n2. Create reusable widgets\n3. Keep business logic separate\n4. Follow consistent naming conventions\n5. Write tests!',
        images: [],
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        likes: 892,
        comments: 156,
        shares: 234,
      ),
      Post(
        id: '4',
        userId: 'user4',
        userName: 'Jane Doe',
        userAvatar: '',
        content:
            'Multi-image carousel test post. Using Reddit-style navigation for image browsing.',
        images: [
          'resources/ICON.png',
          'resources/LOGO.png',
          'resources/ICON.png',
          'resources/LOGO.png',
        ],
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        likes: 234,
        comments: 45,
        shares: 18,
      ),
    ];
  }

  void _handleCreatePost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post created! (Coming soon)')),
    );
  }

  void _handleAttachImage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Image picker - Coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NEST',
          style: AppTextStyles.heading(
            context,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Post creation box
          PostCreationBox(
            onCreatePost: _handleCreatePost,
            onAttachImage: _handleAttachImage,
          ),
          const SizedBox(height: 8),
          // Feed posts
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              return FeedPost(post: _posts[index]);
            },
          ),
        ],
      ),
    );
  }
}
