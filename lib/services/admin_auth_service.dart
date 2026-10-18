import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Only Firebase users whose Firestore doc has role == 'admin' may use this
/// app. Promote a shopper to admin from the Firebase console:
///   Firestore > users > {uid} > set field  role = "admin"
class AdminAuthService {
  AdminAuthService._();

  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  /// Returns null on success, or an error message.
  static Future<String?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      final role = doc.data()?['role'];
      if (role != 'admin') {
        await _auth.signOut();
        return 'This account is not authorized for the Seller Portal.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'That email address looks invalid.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        case 'network-request-failed':
          return 'No internet connection.';
      }
      return e.message ?? 'Sign in failed.';
    }
  }

  static Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  static Future<void> signOut() => _auth.signOut();
}
