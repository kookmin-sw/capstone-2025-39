<br>

# 📱 정릉친구 Flutter App
* 정릉 지역 기반 추천 및 AI 챗봇, 지도 기능, 사용자 관리 기능을 제공하는 모바일 앱


## 주요 기능
- 실시간 채팅 및 채팅 기록 조회
- 위치 기반 챗봇 응답
- 사용자 인증(로그인/회원가입)
- 마이페이지 관리


## 기술 스택
|   Area       |            Technology            |     Description     |
|:---------------------------------:  | :---------------------------------: | :-----------------: |
| Language           |                 Dart                |   Flutter 앱 개발 사용 언어   |
| Framework          |               Flutter               |   크로스 플랫폼  |
| State Management   |               Provider              |       유저 상태 관리       |
| Networking         |                 dio                 | HTTP 통신 |
| Maps               |        google\_maps\_flutter        |  Google Maps 지도 기능  |
| Local Storage      |    flutter\_secure\_storage  |    토큰 저장   |
| Auth               |          Spring Boot (JWT)          |     서버 기반 사용자 인증    |
| Geolocation        |              geolocator             |    사용자 위치 기반 서비스    |
| Speech Recognition |           speech\_to\_text          |       음성 인식 기능      |


## 기본 구조
```
lib/
├── main.dart
├── screens/        # 화면 UI
├── services/       # 서비스(주로 통신)
├── models/         # 데이터 모델
├── providers/      # 상태 관리
├── utils/          # 공통 유틸
└── widgets/        # 커스텀 위젯
```

## 실행 방법
**1. Clone *'frontend'* repository**<br>
**2. Create or update *'gradle.properties'* to add your API key**
```
# gradle.properties.example 참고
GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
android.useAndroidX=true
android.enableJetifier=true
```
**3. `flutter pub get`**<br>
**4. `flutter run`**