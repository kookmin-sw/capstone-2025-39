import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/services/like_service.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ChatMap extends StatefulWidget {
  final double lat;
  final double lng;
  final double? userLat;
  final double? userLng;
  final String placeName;

  const ChatMap({
    super.key,
    required this.lat,
    required this.lng,
    required this.placeName,
    this.userLat,
    this.userLng,
  });

  @override
  State<ChatMap> createState() => _ChatMapState();
}

class _ChatMapState extends State<ChatMap> {
  late String token;
  bool liked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    token = 'Bearer ${Provider.of<AuthProvider>(context, listen: false).token}';
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final result = await LikeService.fetchLikeStatus(widget.placeName, token);
    if (mounted) {
      setState(() => liked = result);
    }
  }

  Future<void> _toggleLike() async {
    final toggled = !liked;
    final result = await LikeService.toggleLike(
      placeName: widget.placeName,
      token: token,
      shouldLike: toggled,
    );
    if (mounted && result == toggled) {
      setState(() => liked = toggled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng destination = LatLng(widget.lat, widget.lng);
    final Set<Marker> markers = _buildMarkers();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 280,
          height: 210,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: destination,
                zoom: 15,
              ),
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
        SizedBox(
          height: 210,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _toggleLike,
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 3),
              IconButton(
                onPressed: _showExpandedMap,
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.black,
                  size: 28,
                ),
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

  void _showExpandedMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExpandedMapPage(
              lat: widget.lat,
              lng: widget.lng,
              userLat: widget.userLat,
              userLng: widget.userLng,
              placeName: widget.placeName,
              liked: liked,
              onLikeChanged: (newLiked) {
                setState(() => liked = newLiked);
              },
            ),
      ),
    );
  }
}

// 전체 화면 페이지!
class ExpandedMapPage extends StatefulWidget {
  final double lat;
  final double lng;
  final double? userLat;
  final double? userLng;
  final String placeName;
  final bool liked;
  final ValueChanged<bool> onLikeChanged;

  const ExpandedMapPage({
    super.key,
    required this.lat,
    required this.lng,
    this.userLat,
    this.userLng,
    required this.placeName,
    required this.liked,
    required this.onLikeChanged,
  });

  @override
  State<ExpandedMapPage> createState() => _ExpandedMapPageState();
}

class _ExpandedMapPageState extends State<ExpandedMapPage> {
  late String token;
  late bool liked;

  @override
  void initState() {
    super.initState();
    liked = widget.liked;
    token = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      token =
          'Bearer ${Provider.of<AuthProvider>(context, listen: false).token}';
    });
  }

  Future<void> _toggleLike() async {
    final toggled = !liked;
    print('[Chat_map] 좋아요 토글 확인 placeName : ${widget.placeName}');
    final result = await LikeService.toggleLike(
      placeName: widget.placeName,
      token: token,
      shouldLike: toggled,
    );
    if (mounted && result == toggled) {
      setState(() => liked = toggled);
      widget.onLikeChanged(toggled);
    }
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16 + bottomPadding,
              right: 16,
              child: Row(
                children: [
                  _buildCircleIcon(
                    icon: liked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    onTap: _toggleLike,
                  ),
                  const SizedBox(width: 12),
                  _buildCircleIcon(
                    icon: Icons.fullscreen_exit,
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
    required IconData icon,
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
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: Icon(icon, color: color, size: 28)),
      ),
    );
  }
}
