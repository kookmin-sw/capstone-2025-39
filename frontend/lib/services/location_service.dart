import 'package:geolocator/geolocator.dart';

// 현재 사용자의 위치를 가져오는 서비스
// Geolocator 패키지를 사용하여 위치 서비스를 구현
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
  }

  return await Geolocator.getCurrentPosition();
}
