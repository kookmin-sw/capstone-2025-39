import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // LogicalKeyboardKey & KeyEvent 관련

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onSend;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    //FocusNode를 메모리에서 제거
    _focusNode.dispose(); //FocusNode를 메모리에서 해제
    super.dispose(); //부모 클래스(State)의 dispose도 함께 실행한다.
  }

  void _hanleSend() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    widget.controller.clear();

    //입력 후 포커스 해제 --> placeholder 다시 뜨도록
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          // 음성녹음 버튼(마이크)
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26),
            ),
            child: Icon(Icons.mic, size: 20),
          ),

          // text input box (TextField + 전송 버튼)
          Expanded(
            child: Container(
              height: 73.48, // Figma 기준 높이 반영
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: KeyboardListener(
                  focusNode: _focusNode,
                  onKeyEvent: (event) {
                    final isShiftPressed = HardwareKeyboard
                        .instance
                        .logicalKeysPressed
                        .any(
                          (key) =>
                              key == LogicalKeyboardKey.shiftLeft ||
                              key == LogicalKeyboardKey.shiftRight,
                        );

                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.enter &&
                        !isShiftPressed) {
                      _hanleSend();
                    }
                  },
                  child: TextField(
                    controller: widget.controller, //widget controller
                    maxLines: null, // 줄바꿈 허용
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1, // 줄 간격
                    ),
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 0,
                      ),
                      // 전송 버튼
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 3.0, right: 3.6),
                        child: GestureDetector(
                          onTap: () => widget.onSend(widget.controller.text),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5D815F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
