import 'package:flutter/material.dart';
import '../../../core/models/post_model.dart';
import '../../../core/typography/app_text_styles.dart';
import '../widgets/feed_post.dart';
import 'create_post_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        postId: '1',
        userId: 'user1',
        userName: 'Alex Chen',
        userAvatar: '',
        content:
        'Just launched my new Flutter project! Really excited about the modular architecture we\'ve built. #flutter #development',
        images: [],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 128,
        commentsCount: 24,
        sharesCount: 15,
      ),
      Post(
        postId: '2',
        userId: 'user2',
        userName: 'Sarah Johnson',
        userAvatar: '',
        content:
        'Beautiful sunset at the beach today. Nothing beats a good walk by the ocean! 🌅',
        images: ['resources/ICON.png', 'resources/LOGO.png'],
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        likesCount: 456,
        commentsCount: 89,
        sharesCount: 42,
      ),
      Post(
        postId: '3',
        userId: 'user3',
        userName: 'Dev Community',
        userAvatar: '',
        content:
        'Top 5 Flutter best practices for building scalable apps:\n1. Use proper state management\n2. Create reusable widgets\n3. Keep business logic separate\n4. Follow consistent naming conventions\n5. Write tests!',
        images: [],
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 892,
        commentsCount: 156,
        sharesCount: 234,
      ),
      Post(
        postId: '4',
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
        likesCount: 234,
        commentsCount: 45,
        sharesCount: 18,
      ),
    ];
  }

  void _handleCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreatePostPage(),
      ),
    );
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
        // ADD THE ACTIONS ARRAY HERE
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Post creation button (looks like text box)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // User avatar placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Text input button
                Expanded(
                  child: GestureDetector(
                    onTap: _handleCreatePost,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Text(
                        "What's on your mind?",
                        style: AppTextStyles.body(
                          context,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
