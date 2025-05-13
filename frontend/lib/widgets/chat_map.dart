import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatMap extends StatefulWidget {
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
  State<ChatMap> createState() => _ChatMapState();
}

class _ChatMapState extends State<ChatMap> {
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    final LatLng destination = LatLng(widget.lat, widget.lng);
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: const InfoWindow(title: '추천 장소'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    if (widget.userLat != null && widget.userLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(widget.userLat!, widget.userLng!),
          infoWindow: const InfoWindow(title: '내 위치'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    final CameraPosition initialCamera = CameraPosition(
      target: destination,
      zoom: 15,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 280,
          height: 210,
          child: GoogleMap(
            initialCameraPosition: initialCamera,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
          ),
        ),
        Column(
          children: [
            IconButton(
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  liked = !liked;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.fullscreen, color: Colors.black, size: 24),
              onPressed: () {
                _showExpandedMap(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.lat, widget.lng),
        infoWindow: const InfoWindow(title: '추천 장소'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    if (widget.userLat != null && widget.userLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(widget.userLat!, widget.userLng!),
          infoWindow: const InfoWindow(title: '내 위치'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    return markers;
  }

  // Map 전체 화면
  void _showExpandedMap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final bottomPadding = MediaQuery.of(context).padding.bottom;

        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              height: screenHeight,
              width: screenWidth,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
              ),
              child: SafeArea(
                top: false, // 상단은 구글 맵으로 채우므로 제외
                child: Stack(
                  children: [
                    // 지도 전체 영역
                    Positioned.fill(
                      child: Column(
                        children: [
                          Expanded(
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(widget.lat, widget.lng),
                                zoom: 16,
                              ),
                              markers: _buildMarkers(),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              zoomControlsEnabled: true,
                            ),
                          ),
                          const SizedBox(height: 60), // 아이콘 영역 확보
                        ],
                      ),
                    ),

                    // 하단 오른쪽 아이콘 영역 (SafeArea 고려)
                    Positioned(
                      bottom: 16 + bottomPadding,
                      right: 16,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              liked ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                liked = !liked;
                              });
                              setStateModal(() {}); // 모달 setState도 동기화
                            },
                          ),
                          IconButton(
                            icon: Image.asset(
                              'assets/icons/exit-fullscreen.png',
                              color: Colors.black,
                              width: 28,
                              height: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
