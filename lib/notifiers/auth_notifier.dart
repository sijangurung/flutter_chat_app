import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/repositories/auth_repository.dart';
import 'package:chat_app/model/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthInitial());

  Future<void> signIn({required String email, required String password}) async {
    try {
      state = AuthLoading();
      await _authRepository.signInWithEmailAndPassword(email, password);
      state = AuthLoggedIn();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    required File imageFile,
  }) async {
    try {
      state = AuthLoading();
      User? user = await _authRepository.createUser(email, password);
      if (user != null) {
        final imageUrl = await _authRepository.storeImage(user.uid, imageFile);
        await _authRepository.addUserData(user.uid, {
          'username': username,
          'email': email,
          'image_url': imageUrl,
        });
        state = AuthSuccess(user);
      }
    } catch (e) {
      state = AuthError("Failed to signup: error => ${e.toString()}");
    }
  }

  Future<void> signOut() async {
    stopListeningToChats();
    await _authRepository.signOut();
    // signing out from listeners
    state = AuthLoggedOut();
  }

  Future<void> addUserChat({required String message}) async {
    try {
      await _authRepository.addUserChat(message: message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  StreamSubscription? _chatSubscription;

  void listenToChats() {
    state = AuthLoading();
    try {
      _chatSubscription?.cancel(); // Cancel any existing subscription
      _chatSubscription = _authRepository.getChats().listen(
        (chats) {
          state = AuthChatsLoaded(chats: chats);
        },
        onError: (error) {
          state = AuthError(error.toString());
        },
      );
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  void stopListeningToChats() {
    _chatSubscription?.cancel();
  }
}
