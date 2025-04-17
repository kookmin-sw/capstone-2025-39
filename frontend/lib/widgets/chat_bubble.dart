import 'dart:async'; // Timer를 위해
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend/widgets/chat_map.dart';

class ChatBubble extends StatefulWidget {
  //Stateful로
  final String message;
  final bool isUser;
  final String? time;
  final double? lat;
  final double? lng;
  final bool isGenerating;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.time,
    this.lat,
    this.lng,
    this.isGenerating = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  late String _dots;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _dots = '.';
    if (widget.isGenerating) {
      _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          if (_dots == '.') {
            _dots = '..';
          } else if (_dots == '..') {
            _dots = '...';
          } else {
            _dots = '.';
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color userBgColor = const Color(0xFF5D815F); // 사용자 말풍선 색
    final Color userTextColor = Colors.white;
    final Color botBgColor = const Color(0xFFF5F5F5); // 챗봇 말풍선 색
    final Color botTextColor = Colors.black;

    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (widget.time != null && widget.time!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                widget.time!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

          // 말풍선 디자인
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: widget.isUser ? userBgColor : botBgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    widget.isUser
                        ? const Radius.circular(16)
                        : const Radius.circular(0),
                bottomRight:
                    widget.isUser
                        ? const Radius.circular(0)
                        : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message,
                  style: TextStyle(
                    color: widget.isUser ? userTextColor : botTextColor,
                    fontSize: 16,
                  ),
                ),
                if (!kIsWeb &&
                    !widget.isUser &&
                    widget.lat != null &&
                    widget.lng != null)
                  Container(
                    height: 150,
                    margin: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ChatMap(lat: widget.lat!, lng: widget.lng!),
                    ),
                  ),
              ],
            ),
          ),

          // 로딩 중 애니메이션
          if (widget.isGenerating && !widget.isUser)
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '메세지 생성중$_dots',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
