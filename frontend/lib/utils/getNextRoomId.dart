// Next Room Id를 구하기 위한 함수
import 'package:hive/hive.dart';
import 'package:frontend/models/chat_message.dart';

Future<int> getNextRoomId() async {
  return DateTime.now().microsecondsSinceEpoch % 1000000000;
}
