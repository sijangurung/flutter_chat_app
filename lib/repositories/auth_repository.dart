import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:chat_app/model/chat.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebasestorage;

  AuthRepository(
    this._firebaseAuth,
    this._firestore,
    this._firebasestorage,
  );

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // #region Authentication
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<User?> createUser(String email, String password) async {
    final userCredentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return userCredentials.user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  // #endregion

// #region Firestore
  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<void> addUserChat({required String message}) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final userData = await getUserData(user.uid);
      await _firestore.collection('chats').add({
        'text': message,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData['username'],
        'userImage': userData['image_url'],
      });
    }
  }

  Stream<List<Chat>> getChats() {
    return _firestore
        .collection('chats')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Chat.fromDocument(doc)).toList());
  }
// #endregion

// #region Firestorage
  Future<String> storeImage(String uid, File imageFile) async {
    final storageRef =
        _firebasestorage.ref().child('user_images').child('$uid.jpg');

    await storageRef.putFile(imageFile);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }
// #endregion
}
