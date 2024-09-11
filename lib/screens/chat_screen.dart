import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/providers/auth_providers.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    return Scaffold(
        appBar: AppBar(
          title: const Text("FlutterChat"),
          actions: [
            IconButton(
              onPressed: () => authNotifier.signOut(),
              icon: const Icon(Icons.exit_to_app),
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
        body: const Column(
          children: [
            Expanded(child: ChatMessages()),
            Divider(),
            NewMessage(),
            SizedBox(height: 16),
          ],
        ));
  }
}
