import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String text;
  final String userImage;
  final String username;
  final String userId;

  Chat({
    required this.text,
    required this.userImage,
    required this.username,
    required this.userId,
  });

  factory Chat.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      text: data['text'] ?? '',
      userImage: data['userImage'] ?? '',
      username: data['username'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}
