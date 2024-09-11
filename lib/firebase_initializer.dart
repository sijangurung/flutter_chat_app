import 'package:firebase_core/firebase_core.dart';

import 'package:chat_app/firebase_options.dart';

class FirebaseInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      name: 'flutter-chat-testapp',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
