import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser; // true = 사용자 입력, false = 챗봇 응답
  final String? time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final Color userBgColor = const Color(0xFF5D815F); // 사용자: 초록
    final Color userTextColor = Colors.white;

    final Color botBgColor = const Color(0xFFF5F5F5); // 챗봇: F5F5F5
    final Color botTextColor = Colors.black; // 챗봇 텍스트는 black

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
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isUser ? userBgColor : botBgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    isUser
                        ? const Radius.circular(16)
                        : const Radius.circular(0),
                bottomRight:
                    isUser
                        ? const Radius.circular(0)
                        : const Radius.circular(16),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isUser ? userTextColor : botTextColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
