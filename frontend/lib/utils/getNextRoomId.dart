// Next Room Id를 구하기 위한 함수
import 'package:hive/hive.dart';
import '../models/chat_message.dart';

Future<int> getNextRoomId() async {
  final box = Hive.box<ChatMessage>('chatBox');
  final roomIds = box.values.map((msg) => msg.roomId).toSet();
  if (roomIds.isEmpty) return 1;
  return roomIds.reduce((a, b) => a > b ? a : b) + 1;
}
