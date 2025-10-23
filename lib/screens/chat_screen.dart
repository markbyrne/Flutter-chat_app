import 'package:chat_app/widgets/messages_display.dart';
import 'package:chat_app/widgets/new_message_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Chat'), actions: [
        IconButton(onPressed: (){FirebaseAuth.instance.signOut();}, icon: Icon(Icons.logout), color: Theme.of(context).colorScheme.primary,)
      ],),
      body: Column(
        children: const [
          Expanded(child: MessagesDisplay()),
          NewMessageForm()
        ],
      ),
    );
  }
}