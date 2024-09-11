import 'package:chat_app/model/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoggedIn extends AuthState {}

class AuthLoggedOut extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}

class AuthChatsLoaded extends AuthState {
  final List<Chat> chats;

  AuthChatsLoaded({required this.chats});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
