import 'package:chat_app/notifiers/auth_notifier.dart';
import 'package:chat_app/providers/auth_providers.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewMessage extends ConsumerStatefulWidget {
  const NewMessage({super.key});

  @override
  ConsumerState<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends ConsumerState<NewMessage> {
  final _messageController = TextEditingController();

  bool _sendingMessage = false;
  late final AuthNotifier authState;
  @override
  void initState() {
    super.initState();
    authState = ref.read(authNotifierProvider.notifier);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    setState(() => _sendingMessage = true);
    final enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _messageController.clear();
    try {
      authState.addUserChat(message: enteredMessage);
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error : $error')));
    }
    setState(() => _sendingMessage = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(labelText: 'Send a message'),
              ),
            ),
            _sendingMessage
                ? const CircularProgressIndicator()
                : IconButton(
                    color: Theme.of(context).colorScheme.primary,
                    icon: const Icon(Icons.send),
                    onPressed: _submitMessage,
                  )
          ],
        ));
  }
}
