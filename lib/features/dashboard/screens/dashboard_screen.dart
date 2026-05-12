import 'package:flutter/material.dart';
import '../../../core/models/post_model.dart';
import '../../../core/typography/app_text_styles.dart';
import '../widgets/feed_post.dart';
import 'create_post_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Main dashboard/feed screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<Post> _posts;
  String? _username;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _initializeMockPosts();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('tbl_users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _username = userDoc.data()?['username'] ?? 'User';
            _fullName = userDoc.data()?['full_name'] ?? _username;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _username = 'User';
          _fullName = 'User';
        });
      }
    }
  }

  void _initializeMockPosts() {
    _posts = [
      Post(
        postId: '1',
        userId: 'user1',
        content:
            'Just launched my new Flutter project! Really excited about the modular architecture we\'ve built. #flutter #development',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 128,
        commentsCount: 24,
      ),
      Post(
        postId: '2',
        userId: 'user2',
        content:
            'Beautiful sunset at the beach today. Nothing beats a good walk by the ocean! 🌅',
        mediaUrl: 'resources/LOGO.png',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        likesCount: 456,
        commentsCount: 89,
      ),
      Post(
        postId: '3',
        userId: 'user3',
        content:
            'Top 5 Flutter best practices for building scalable apps:\n1. Use proper state management\n2. Create reusable widgets\n3. Keep business logic separate\n4. Follow consistent naming conventions\n5. Write tests!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 892,
        commentsCount: 156,
      ),
      Post(
        postId: '4',
        userId: 'user4',
        content: 'Check out my latest photo!',
        mediaUrl: 'resources/ICON.png',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        likesCount: 234,
        commentsCount: 45,
      ),
    ];
  }

  void _handleCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreatePostPage(username: _username ?? 'User'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'resources/LOGO.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'NEST',
              style: AppTextStyles.heading(
                context,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 24,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // User profile header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    radius: 28,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _fullName ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '@${_username ?? 'username'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
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
