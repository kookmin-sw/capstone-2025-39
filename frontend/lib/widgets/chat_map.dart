import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart'; // gestureRecognizers
import 'package:flutter/foundation.dart'; //Factory

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
    final Set<Marker> markers = _buildMarkers();

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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GoogleMap(
                initialCameraPosition: initialCamera,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: true,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
          ),
        ),
        // 좋아요, 전체 보기 아이콘
        SizedBox(
          height: 210, // 지도 높이와 동일하게 맞추는 핵심
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, // 바닥에 붙임
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    liked = !liked;
                  });
                },
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              SizedBox(height: 3),
              IconButton(
                onPressed: () {
                  _showExpandedMap(context);
                },
                icon: Icon(Icons.fullscreen, color: Colors.black, size: 28),
              ),
            ],
          ),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExpandedMapPage(
              lat: widget.lat,
              lng: widget.lng,
              userLat: widget.userLat,
              userLng: widget.userLng,
              liked: liked,
              onLikeToggle: () {
                setState(() {
                  liked = !liked;
                });
              },
            ),
      ),
    );
  }

  Widget _buildCircleIcon({
    IconData? icon,
    String? iconAsset,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child:
              icon != null
                  ? Icon(icon, color: color, size: 28)
                  : Image.asset(iconAsset!, width: 24, height: 24),
        ),
      ),
    );
  }
}

// ExpandedMapPage
class ExpandedMapPage extends StatefulWidget {
  final double lat;
  final double lng;
  final double? userLat;
  final double? userLng;
  final bool liked;
  final VoidCallback onLikeToggle;

  const ExpandedMapPage({
    super.key,
    required this.lat,
    required this.lng,
    this.userLat,
    this.userLng,
    required this.liked,
    required this.onLikeToggle,
  });

  @override
  State<ExpandedMapPage> createState() => _ExpandedMapPageState();
}

class _ExpandedMapPageState extends State<ExpandedMapPage> {
  late bool liked;

  @override
  void initState() {
    super.initState();
    liked = widget.liked;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: screenHeight * 0.95,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 상단 드래그 핸들
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(widget.lat, widget.lng),
                              zoom: 16,
                            ),
                            markers: _buildMarkers(),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: true,
                            mapToolbarEnabled: true,
                            gestureRecognizers:
                                <Factory<OneSequenceGestureRecognizer>>{
                                  Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer(),
                                  ),
                                },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 70), // 하단 아이콘 공간
                  ],
                ),
              ),
            ),
            // 하단 오른쪽 플로팅 버튼
            Positioned(
              bottom: 16 + bottomPadding,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleIcon(
                    icon: liked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    onTap: () {
                      setState(() {
                        liked = !liked;
                      });
                      widget.onLikeToggle();
                    },
                  ),
                  SizedBox(width: 12),
                  _buildCircleIcon(
                    iconAsset: 'assets/icons/exit-fullscreen.png',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildCircleIcon({
    IconData? icon,
    String? iconAsset,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child:
              icon != null
                  ? Icon(icon, color: color, size: 28)
                  : Image.asset(iconAsset!, width: 24, height: 24),
        ),
      ),
    );
  }
}
