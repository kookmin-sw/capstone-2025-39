import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (time != null && time!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                time!,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? Color(0xffEDE9BE) : Color(0xCE90A891),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(message, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
