import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async {
    final res = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return res.user;
  }

  Future<User?> register(String email, String password) async {
    final res = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user != null) {
      // create minimal user record - admin will fill other details & activate
      final appUser = AppUser(
        uid: user.uid,
        email: email,
        name: '',
        phone: '',
        photoUrl: '',
        role: '',
        isActive: false,
      );
      await _db.collection('users').doc(user.uid).set(appUser.toMap());
    }
    return user;
  }

  Future<void> signOut() async => _auth.signOut();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
