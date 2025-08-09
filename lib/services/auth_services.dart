import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInAdmin(String email, String password) async {
    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-fields',
          message: 'Email and password cannot be empty',
        );
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;


      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (!adminDoc.exists) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'not-admin',
          message: 'You are not authorized to access this app.',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
