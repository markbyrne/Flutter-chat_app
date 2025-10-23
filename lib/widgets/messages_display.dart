import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessagesDisplay extends StatelessWidget {
  const MessagesDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (cts, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading messages. Please try again later.'),
          );
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data();
            final nextMessage = index + 1 < messages.length
                ? messages[index + 1]
                : null;

            final currentMessageUID = message['userId'];
            final nextMessageUID = nextMessage != null
                ? nextMessage['userId']
                : null;
            final nextUserSame = currentMessageUID == nextMessageUID;

            final isAuthUser = currentMessageUID == authenticatedUser.uid;

            if (nextUserSame) {
              return MessageBubble.next(
                message: message['text'],
                isMe: isAuthUser,
              );
            } else {
              return MessageBubble.first(
                userImage: message['image_url'],
                username: message['username'],
                message: message['text'],
                isMe: isAuthUser,
              );
            }

            // TODO censor
          },
        );
      },
    );
  }
}
