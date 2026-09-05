import 'package:flutter/material.dart';
import '../core/chat_scope.dart';
import 'chat_world_page.dart';

class Chatbox extends StatelessWidget {
  final ChatContext contextData;

  const Chatbox({super.key, required this.contextData});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'darkest-world-chatbox',
      onPressed: () => _open(context),
      icon: const Icon(Icons.chat_bubble_outline),
      label: const Text('Chatbox'),
    );
  }

  void _open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatWorldPage(context: contextData),
      ),
    );
  }
}
