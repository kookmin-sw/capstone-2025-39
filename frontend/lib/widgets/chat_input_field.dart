import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // LogicalKeyboardKey & KeyEvent 관련
import 'package:speech_to_text/speech_to_text.dart';

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

// 채팅 내의 Input 부분
class _ChatInputFieldState extends State<ChatInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isPressed = false;

  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  String _latestRecognizedWords = '';

  @override
  void dispose() {
    _focusNode.dispose(); //FocusNode를 메모리에서 제거
    _speech.stop(); // 말 그만 듣게
    super.dispose(); // 부모 클래스(State)의 dispose도 함께 실행
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);

    //전송 후 STT 멈추기
    _speech.stop();
    setState(() {
      _isListening = false;
      _latestRecognizedWords = ''; // 전송 후 이전 텍스트 제거
    });

    widget.controller.clear();

    //입력 후 포커스 해제
    FocusScope.of(context).unfocus();
  }

  Future<void> _startListening() async {
    // stt 초기화
    await _speech.cancel();
    widget.controller.clear();
    _latestRecognizedWords = '';
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        print('Speech recognition error: $error'); //에러 출력
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          if (!_isListening) return;
          setState(() {
            _latestRecognizedWords = result.recognizedWords;
            widget.controller.text = _latestRecognizedWords;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller.text.length),
            );
          });
        },
        localeId: 'ko_KR', // 한국어
      );
    } else {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          // 음성녹음 버튼(마이크)
          GestureDetector(
            onTapDown: (_) {
              _startListening();
            },
            onTapUp: (_) {
              _stopListening();
            },
            onTapCancel: () {
              _stopListening(); // 손가락을 바깥으로 떼도 중지
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 73,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(width: 3, color: Colors.transparent),
                gradient:
                    _isListening
                        // 음성 인식 중일때 그라디언트 효과
                        ? SweepGradient(
                          colors: const [
                            Colors.green,
                            Colors.purple,
                            Colors.green,
                          ],
                          startAngle: 0.0,
                          endAngle: 3.14 * 2,
                          tileMode: TileMode.repeated,
                        )
                        : null,
                color: Colors.white,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFDBDBDB), width: 1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SizedBox(
                  width: 18,
                  height: 25,
                  child: Icon(
                    Icons.mic,
                    size: 28,
                    color: _isListening ? Color(0xFF5E8360) : Colors.black87,
                  ),
                ),
              ),
            ),
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
                      _handleSend();
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
                    onTap: () {
                      if (_isListening) {
                        _speech.stop(); //stt 꺼짐
                        setState(() => _isListening = false);
                      }
                    },
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
                          onTap: () => _handleSend(),
                          onTapDown: (_) {
                            setState(() {
                              _isPressed = true;
                            });
                          },
                          onTapCancel: () {
                            setState(() {
                              _isPressed = false;
                            });
                          },
                          onTapUp: (_) {
                            setState(() {
                              _isPressed = false;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color:
                                  _isPressed
                                      ? Color(0xFF456947) //누른 상태 색
                                      : Color(0xFF5D815F), //기본 색
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                              size: 24,
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
