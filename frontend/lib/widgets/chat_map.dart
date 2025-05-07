import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatMap extends StatelessWidget {
  //37.610837, 126.996379
  final double lat;
  final double lng;
  final double? userLat;
  final double? userLng;

  const ChatMap({
    super.key,
    required this.lat,
    required this.lng,
    this.userLat,
    this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng destination = LatLng(lat, lng);
    // 마커 목록
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: const InfoWindow(title: '추천 장소'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    if (userLat != null && userLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(userLat!, userLng!),
          infoWindow: const InfoWindow(title: '내 위치'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    // 기본 카메라 위치 (목적지 기준)
    final CameraPosition initialCamera = CameraPosition(
      target: destination,
      zoom: 15,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 320,
          height: 210,
          child: GoogleMap(
            initialCameraPosition: initialCamera,

            markers: markers,
            myLocationEnabled: true, // 현재 위치 버튼 활성화
            myLocationButtonEnabled: true, // 오른쪽 현재위치 버튼
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
          ),
        ),

        // 아이콘 버튼들 위치
        Column(
          children: [
            IconButton(
              icon: Icon(Icons.favorite_border, color: Colors.red),
              onPressed: () {
                // 좋아요 버튼 클릭시 동작
              },
            ),
            IconButton(
              icon: Icon(Icons.fullscreen, color: Colors.black),
              onPressed: () {
                // 전체 화면 버튼 클릭시 동작
                _showExpandedMap(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  // 지도 전체 화면으로 보기
  void _showExpandedMap(BuildContext context) {
    bool liked = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: screenHeight > 645 ? 645 : screenHeight,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 6),
                      // 지도 영역
                      Padding(
                        padding: const EdgeInsets.only(left: 9),
                        child: SizedBox(
                          width: 393,
                          height: 450,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(lat, lng),
                              zoom: 16,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('destination'),
                                position: LatLng(lat, lng),
                                infoWindow: const InfoWindow(title: '추천 장소'),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed,
                                ),
                              ),
                              if (userLat != null && userLng != null)
                                Marker(
                                  markerId: const MarkerId('user'),
                                  position: LatLng(userLat!, userLng!),
                                  infoWindow: const InfoWindow(title: '내 위치'),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueAzure,
                                  ),
                                ),
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: true,
                          ),
                        ),
                      ),

                      // 장소 정보
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 이미지 카드
                            Container(
                              width: 153,
                              height: 153,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                'assets/images/basic_place_img.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 장소 정보 카드
                            Container(
                              width: 155,
                              height: 153,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '정릉천',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '서울시 000',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 오른쪽 하트 , 축소 아이콘
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              liked ? Icons.favorite : Icons.favorite_border,
                              color: liked ? Colors.red : Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                liked = !liked;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.close_fullscreen,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
