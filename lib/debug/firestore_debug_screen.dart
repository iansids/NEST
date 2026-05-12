import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class FirestoreDebugScreen extends StatefulWidget {
  const FirestoreDebugScreen({Key? key}) : super(key: key);

  @override
  State<FirestoreDebugScreen> createState() => _FirestoreDebugScreenState();
}

class _FirestoreDebugScreenState extends State<FirestoreDebugScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String targetUserId =
      FirebaseAuth.instance.currentUser?.uid ?? 'no-user';
  
  late Future<Map<String, dynamic>> _debugData;

  @override
  void initState() {
    super.initState();
    _debugData = _fetchDebugData();
  }

  Future<Map<String, dynamic>> _fetchDebugData() async {
    final result = <String, dynamic>{};

    try {
      // 1. Check if user exists in tbl_users
      final userDoc = await _db.collection('tbl_users').doc(targetUserId).get();
      result['userExists'] = userDoc.exists;
      result['userData'] = userDoc.data() ?? {};

      // 2. Find all posts by this user
      final userPosts = await _db
          .collection('tbl_posts')
          .where('user_id', isEqualTo: targetUserId)
          .get();
      result['postsCount'] = userPosts.docs.length;
      result['posts'] = userPosts.docs.map((doc) => {
        'id': doc.id,
        'data': doc.data(),
      }).toList();

      // 3. Check collection stats
      final usersCount = await _db.collection('tbl_users').count().get();
      final postsCount = await _db.collection('tbl_posts').count().get();
      result['collectionStats'] = {
        'tbl_users': usersCount.count,
        'tbl_posts': postsCount.count,
      };

      // 4. Sample documents from each collection
      final sampleUsers = await _db.collection('tbl_users').limit(2).get();
      final samplePosts = await _db.collection('tbl_posts').limit(2).get();
      
      result['sampleUsers'] = sampleUsers.docs
          .map((doc) => {'id': doc.id, 'data': doc.data()})
          .toList();
      result['samplePosts'] = samplePosts.docs
          .map((doc) => {'id': doc.id, 'data': doc.data()})
          .toList();

      result['error'] = null;
    } catch (e) {
      result['error'] = e.toString();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Debug Tool'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _debugData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? {};
          final error = data['error'];

          if (error != null) {
            return Center(
              child: Text('Firestore Error: $error'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Info Section
              _buildSection(
                'User: $targetUserId',
                [
                  if (data['userExists'] == true)
                    _buildFieldList(data['userData'] as Map<String, dynamic>)
                  else
                    const Text(
                      '❌ User document NOT found',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Posts Section
              _buildSection(
                'Posts by this user: ${data['postsCount'] ?? 0}',
                [
                  if ((data['posts'] as List?)?.isEmpty ?? true)
                    const Text('❌ No posts found for this user')
                  else
                    Column(
                      children: (data['posts'] as List).map((post) {
                        return ExpansionTile(
                          title: Text('Post: ${post['id']}'),
                          children: [
                            _buildFieldList(post['data'] as Map<String, dynamic>),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Collection Stats
              _buildSection(
                'Collection Statistics',
                [
                  _buildFieldList(data['collectionStats'] as Map<String, dynamic>),
                ],
              ),
              const SizedBox(height: 16),

              // Sample Users
              _buildSection(
                'Sample Users (first 2)',
                [
                  Column(
                    children: (data['sampleUsers'] as List)
                        .asMap()
                        .entries
                        .map((entry) {
                          return ExpansionTile(
                            title: Text('User ${entry.key + 1}: ${entry.value['id']}'),
                            children: [
                              _buildFieldList(entry.value['data'] as Map<String, dynamic>),
                            ],
                          );
                        })
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sample Posts
              _buildSection(
                'Sample Posts (first 2)',
                [
                  Column(
                    children: (data['samplePosts'] as List)
                        .asMap()
                        .entries
                        .map((entry) {
                          return ExpansionTile(
                            title: Text('Post ${entry.key + 1}: ${entry.value['id']}'),
                            children: [
                              _buildFieldList(entry.value['data'] as Map<String, dynamic>),
                            ],
                          );
                        })
                        .toList(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFieldList(Map<String, dynamic> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          final value = entry.value;
          final displayValue = value is Map
              ? jsonEncode(value)
              : value is List
                  ? jsonEncode(value)
                  : value.toString();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SelectableText(
              '${entry.key}: $displayValue',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// To use this debug screen, add it to your navigation:
// 
// Example in dashboard_screen.dart:
// FloatingActionButton(
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const FirestoreDebugScreen()),
//     );
//   },
//   child: const Icon(Icons.bug_report),
// )
