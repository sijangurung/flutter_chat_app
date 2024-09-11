import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chat_app/firebase_initializer.dart';
import 'package:chat_app/model/auth_state.dart';
import 'package:chat_app/providers/auth_providers.dart';
import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  runApp(const ProviderScope(child: AuthChecker()));
}

class AuthChecker extends HookConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authNotifierProvider);
    final authStateUser = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      home: authNotifier is AuthSuccess ||
              authNotifier is AuthLoggedIn ||
              authNotifier is AuthChatsLoaded ||
              authStateUser.value != null
          ? const ChatScreen()
          : const AuthScreen(),
    );
  }
}
