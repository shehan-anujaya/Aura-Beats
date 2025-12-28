import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/chat_message.dart';
import 'glass_container.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    // Animate new messages
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: isUser
            ? _buildUserBubble(context)
            : _buildAIBubble(context),
      ),
    ).animate().fade().scale();
  }

  Widget _buildUserBubble(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Text(
        message.content,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildAIBubble(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(16),
      ),
      child: Text(
        message.content,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
