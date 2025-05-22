// 채팅 메세지 모델

class ChatMessage {
  final String text;
  final bool isUser; // 사용자 or 챗봇
  final String time;
  final String date;
  // 위치 정보는 nullable
  //37.610837, 126.996379
  final double? lat;
  final double? lng;
  final int roomId; //채팅방 ID int형으로
  final String? placeName;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    required this.date,
    this.lat,
    this.lng,
    required this.roomId,
    this.placeName,
  });
}
