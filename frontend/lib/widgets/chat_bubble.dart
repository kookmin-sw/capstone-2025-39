import 'package:flutter/material.dart';
import '../widgets/chat_map.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? time;
  final double? lat;
  final double? lng;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.time,
    this.lat,
    this.lng,
  });

  @override
  Widget build(BuildContext context) {
    final Color userBgColor = const Color(0xFF5D815F);
    final Color userTextColor = Colors.white;

    final Color botBgColor = const Color(0xFFF5F5F5);
    final Color botTextColor = Color(0xFF3F454D);

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
                style: const TextStyle(
                  color: Color(0xFF3F454D),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // 메시지가 있다면 텍스트 말풍선 표시
          if (message.isNotEmpty)
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

          // 지도 표시
          if (lat != null && lng != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ChatMap(lat: lat!, lng: lng!),
            ),
        ],
      ),
    );
  }
}
