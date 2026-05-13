import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return 'Sign-in cancelled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User firebaseUser = userCredential.user!;

      final userDoc = await _firestore
          .collection('tbl_users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        final newUser = UserModel(
          userId: firebaseUser.uid,
          firstName: googleUser.displayName?.split(' ').first ?? 'User',
          lastName: googleUser.displayName?.split(' ').length == 2
              ? googleUser.displayName!.split(' ').last
              : '',
          email: firebaseUser.email ?? '',
          username: '@${googleUser.email?.split('@').first ?? 'user'}',
          profilePicture: googleUser.photoUrl,
          followersCount: 0,
          followingCount: 0,
        );

        await _firestore
            .collection('tbl_users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return 'Firebase error: ${e.message}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('tbl_users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
