import 'package:flutter/material.dart';
import '../../../core/models/post_model.dart';
import '../../../core/typography/app_text_styles.dart';
import '../../../core/services/firestore_service.dart';
import '../widgets/feed_post.dart';
import '../widgets/skeleton_feed.dart';
import 'create_post_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../profile/screens/profile_screen.dart';

/// Main dashboard/feed screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _username;
  String? _fullName;
  String? _profilePicture;

  @override
  void initState() {
    super.initState();
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
          final data = userDoc.data();
          final firstName = data?['first_name'] ?? '';
          final lastName = data?['last_name'] ?? '';
          final fullName = '$firstName $lastName'.trim();

          setState(() {
            _username = data?['username'] ?? 'User';
            _fullName = fullName.isNotEmpty ? fullName : 'User';
            _profilePicture = data?['profile_picture'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _username = 'User';
          _fullName = 'User';
          _profilePicture = null;
        });
      }
    }
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    radius: 22,
                    child: _profilePicture != null
                        ? ClipOval(
                            child: Image.network(
                              _profilePicture!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                size: 26,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Icon(Icons.person, size: 26, color: Colors.white),
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
                          '${_username ?? 'username'}',
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
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
          // Post creation bar — skeleton until user data is ready
          if (_username == null)
            const CreatePostSkeleton()
          else
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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: _profilePicture != null
                        ? ClipOval(
                            child: Image.network(
                              _profilePicture!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.person,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                size: 20,
                              ),
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
                  const SizedBox(width: 12),
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
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
          StreamBuilder<List<Post>>(
            stream: FirestoreService().streamPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: List.generate(4, (_) => const FeedPostSkeleton()),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(
                    'Error loading posts',
                    style: AppTextStyles.body(context),
                  ),
                );
              }

              final posts = snapshot.data ?? [];

              if (posts.isEmpty) {
                return Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(
                    'No posts yet. Be the first to share!',
                    style: AppTextStyles.body(context),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return FeedPost(post: posts[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
