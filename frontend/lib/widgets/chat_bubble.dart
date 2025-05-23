import 'package:flutter/material.dart';
import '../widgets/chat_map.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? time;
  final double? lat;
  final double? lng;
  final String? placeName;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.time,
    this.lat,
    this.lng,
    this.placeName,
  });

  @override
  Widget build(BuildContext context) {
    const userBg = Color(0xFF5D815F);
    const botBg = Color(0xFFF5F5F5);
    const userTx = Colors.white;
    const botTx = Color(0xFF3F454D);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (time?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                time!,
                style: const TextStyle(
                  color: Color(0xFF3F454D),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // 메시지 말풍선
          if (message.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: isUser ? userBg : botBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: isUser ? userTx : botTx,
                  height: 1.5,
                ),
              ),
            ),

          // 지도 컴포넌트
          if (!isUser && lat != null && lng != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ChatMap(
                lat: lat!,
                lng: lng!,
                placeName: placeName ?? '', // placeName 추가
              ),
            ),
        ],
      ),
    );
  }
}
