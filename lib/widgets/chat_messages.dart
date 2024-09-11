import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:chat_app/model/auth_state.dart';
import 'package:chat_app/model/chat.dart';
import 'package:chat_app/providers/auth_providers.dart';
import 'package:chat_app/widgets/message_bubble.dart';

class ChatMessages extends HookConsumerWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AuthState? authState = ref.watch(authNotifierProvider);
    User? currentUser = ref.watch(authStateProvider).value;
    final authNotifier = ref.watch(authNotifierProvider.notifier);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authNotifier.listenToChats();
      });
      return null;
    }, []);

    if (authState != null && authState is AuthChatsLoaded) {
      final List<Chat> loadedMessages = authState.chats;
      return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index];
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1]
                : null;

            final message = chatMessage.text;
            final userImage = chatMessage.userImage;
            final username = chatMessage.username;
            final currentMessageUserId = chatMessage.userId;
            final nextMessageUserId = nextChatMessage?.userId;

            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            final isMe = currentUser?.uid == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(message: message, isMe: isMe);
            }
            return MessageBubble.first(
                userImage: userImage,
                username: username,
                message: message,
                isMe: isMe);
          });
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
