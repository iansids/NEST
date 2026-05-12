import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream to listen to posts in real-time
  Stream<List<Post>> streamPosts() {
    return _db
        .collection('tbl_posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Post.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Method to create a new post
  Future<void> createPost(String userId, String content, {String mediaUrl = ''}) async {
    await _db.collection('tbl_posts').add({
      'user_id': userId,
      'content': content,
      'media_url': mediaUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'likes_count': 0,
      'comments_count': 0,
    });
  }
}