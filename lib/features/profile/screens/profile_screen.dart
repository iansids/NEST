import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../../../core/models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/typography/app_text_styles.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../dashboard/widgets/feed_post.dart';

/// Profile screen to display user information and their posts
class ProfileScreen extends StatefulWidget {
  final String? userId; // Optional - if null, shows current user's profile

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _viewingUserId;
  UserModel? _user;
  List<Post> _userPosts = [];
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    _viewingUserId = widget.userId ?? currentUser?.uid ?? '';
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (_viewingUserId.isEmpty) return;

    try {
      // Load user data
      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_users')
          .doc(_viewingUserId)
          .get();

      if (userDoc.exists) {
        _user = UserModel.fromMap(userDoc.data() ?? {});
      }

      // Load user's posts
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('tbl_posts')
          .where('user_id', isEqualTo: _viewingUserId)
          .orderBy('timestamp', descending: true)
          .get();

      _userPosts = postsSnapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id))
          .toList();

      // Check if current user is following this user (if viewing different user)
      if (_isCurrentUser() == false) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final currentUserDoc = await FirebaseFirestore.instance
              .collection('tbl_users')
              .doc(currentUser.uid)
              .get();

          final following = List<String>.from(
            currentUserDoc.data()?['following'] ?? [],
          );
          _isFollowing = following.contains(_viewingUserId);
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isCurrentUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid == _viewingUserId;
  }

  Future<void> _toggleFollow() async {
    if (_user == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final currentUserRef = FirebaseFirestore.instance
          .collection('tbl_users')
          .doc(currentUser.uid);
      final targetUserRef = FirebaseFirestore.instance
          .collection('tbl_users')
          .doc(_viewingUserId);

      if (_isFollowing) {
        // Unfollow
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([_viewingUserId]),
        });
        await targetUserRef.update({
          'followers_count': FieldValue.increment(-1),
        });
      } else {
        // Follow
        await currentUserRef.update({
          'following': FieldValue.arrayUnion([_viewingUserId]),
        });
        await targetUserRef.update({
          'followers_count': FieldValue.increment(1),
        });
      }

      setState(() => _isFollowing = !_isFollowing);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final int fileSizeInMB = await imageFile.length() ~/ (1024 * 1024);

        if (fileSizeInMB > 25) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size must be less than 25 MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        await _cropAndUploadImage(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cropAndUploadImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading profile picture...')),
        );

        // Upload to Cloudinary
        final imageUrl = await CloudinaryService().uploadImage(
          croppedFile.path,
        );

        if (imageUrl != null) {
          // Update Firestore with new profile picture URL
          await FirebaseFirestore.instance
              .collection('tbl_users')
              .doc(_viewingUserId)
              .update({'profile_picture': imageUrl});

          // Update local state
          if (mounted) {
            setState(() {
              if (_user != null) {
                _user = UserModel(
                  userId: _user!.userId,
                  firstName: _user!.firstName,
                  lastName: _user!.lastName,
                  email: _user!.email,
                  username: _user!.username,
                  profilePicture: imageUrl,
                  bio: _user!.bio,
                  dateOfBirth: _user!.dateOfBirth,
                  followersCount: _user!.followersCount,
                  followingCount: _user!.followingCount,
                );
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload profile picture'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), centerTitle: true),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and User Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: _user!.profilePicture == null
                            ? Icon(
                                Icons.person,
                                size: 48,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              )
                            : ClipOval(
                                child: Image.network(
                                  _user!.profilePicture!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_user!.firstName} ${_user!.lastName}',
                              style: AppTextStyles.heading(
                                context,
                                fontSize: 20,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _user!.username,
                              style: AppTextStyles.subheading(
                                context,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_user!.bio != null && _user!.bio!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _user!.bio!,
                                  style: AppTextStyles.body(context),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Followers/Following Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Followers',
                          count: _user!.followersCount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Following',
                          count: _user!.followingCount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Posts',
                          count: _userPosts.length,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action Button (Edit Profile or Follow)
                  SizedBox(
                    width: double.infinity,
                    child: _isCurrentUser()
                        ? TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.12),
                            ),
                            onPressed: _pickAndUploadProfileImage,
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                          )
                        : ElevatedButton(
                            onPressed: _toggleFollow,
                            child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                          ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Posts Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Posts',
                    style: AppTextStyles.heading(context, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  if (_userPosts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          _isCurrentUser()
                              ? 'No posts yet. Start sharing!'
                              : 'No posts from this user',
                          style: AppTextStyles.body(
                            context,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _userPosts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FeedPost(post: _userPosts[index]),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat card widget for displaying follower/following/post counts
class _StatCard extends StatelessWidget {
  final String label;
  final int count;

  const _StatCard({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: AppTextStyles.heading(
              context,
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
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
