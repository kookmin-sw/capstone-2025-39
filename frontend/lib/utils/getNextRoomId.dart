// Next Room Id를 구하기 위한 함수

Future<int> getNextRoomId() async {
  return DateTime.now().microsecondsSinceEpoch % 1000000000;
}
