// 채팅 메세지 모델
import 'package:hive/hive.dart';
part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage {
  @HiveField(0)
  final String text;
  @HiveField(1)
  final bool isUser; // 사용자 or 챗봇
  @HiveField(2)
  final String time;
  @HiveField(3)
  final String date;
  // 위치 정보는 nullable
  //37.610837, 126.996379
  @HiveField(4)
  final double? lat;
  @HiveField(5)
  final double? lng;
  @HiveField(6)
  final int roomId; //채팅방 ID int형으로

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    required this.date,
    this.lat,
    this.lng,
    required this.roomId,
  });
}
