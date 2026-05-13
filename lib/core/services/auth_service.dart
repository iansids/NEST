import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with Google
  /// Returns null if sign-in is successful (user is now authenticated)
  /// Returns error message if sign-in fails
  Future<String?> signInWithGoogle() async {
    try {
      // Sign out first to allow user to select account
      await _googleSignIn.signOut();

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return 'Sign-in cancelled';
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User firebaseUser = userCredential.user!;

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('tbl_users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        // New user - create UserModel with Google data
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

        // Save to Firestore
        await _firestore
            .collection('tbl_users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());
      }

      return null; // Success - no error
    } on FirebaseAuthException catch (e) {
      return 'Firebase error: ${e.message}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Sign out from Google and Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  /// Get user data from Firestore
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
