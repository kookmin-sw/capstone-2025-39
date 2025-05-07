// 채팅 메세지 모델
class ChatMessage {
  final String text;
  final bool isUser; // 사용자 or 챗봇
  final String time;
  // 위치 정보는 nullable
  //37.610837, 126.996379
  final double? lat;
  final double? lng;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.lat,
    this.lng,
  });
}
