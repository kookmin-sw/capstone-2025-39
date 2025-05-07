import 'dart:convert';
import 'package:http/http.dart' as http;

// 챗봇 응답 처리 서비스
class ChatBotService {
  /* Spring Boot 서버의 주소를 가져온다.
     'http://<your-spring-url>:<port>/chat';
     <your-spring-url> : 서버 ip or domain
     <port> : Spring Boot 서버의 포트 (예 8080)
     /chat : 요청을 보낼 API 경로 

     임시로 서버 로컬에서 돌리므로 http://10.0.2.2:8080/chat 형태
  */

  final String springBootUrl = 'http://223.130.152.181:8080/api/chat';

  Future<Map<String, dynamic>> getReply(
    String input, {
    double? lat,
    double? lng,
  }) async {
    //비동기
    try {
      //요청 바디 구성
      Map<String, dynamic> requestBody = {
        "message": input,
        if (lat != null && lng != null)
          "location": {"lat": lat, "lng": lng}, //위치 정보가 있는 경우
      };

      //POST 요청
      final response = await http.post(
        Uri.parse(springBootUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      //응답 처리
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); //응답 decode해서 data에 저장
        final reply = data['response'];
        final lat = data['lat'];
        final lng = data['lng'];

        if (lat is num && lng is num) {
          //위도, 경도가 우효한 경우 체크
          return {'reply': reply, 'lat': lat, 'lng': lng};
        } else {
          //위도, 경도가 없는 경우 reply만 반환
          return {'reply': reply};
        }
      } else {
        return {'reply': "챗봇 응답 실패 다시 시도해주세요"};
      }
    } catch (e) {
      //임시로 가상 메세지 반환
      return {
        'reply': "요청 실패했습니다 임시 메세지로 국민대학교 반환: $e",
        'lat': 37.610837,
        'lng': 126.996379,
      };

      // return {'reply': "요청 실패했습니다: $e"};
    }
  } //async
}
