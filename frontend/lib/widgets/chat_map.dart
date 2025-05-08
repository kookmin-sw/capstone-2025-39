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
          width: 320,
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
              ),
              onPressed: () {
                setState(() {
                  liked = !liked;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.black),
              onPressed: () {
                _showExpandedMap(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  // Map 전체 화면
  void _showExpandedMap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 160),
              child: Container(
                height: screenHeight > 509 ? 509 : screenHeight,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 470,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(widget.lat, widget.lng),
                              zoom: 16,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('destination'),
                                position: LatLng(widget.lat, widget.lng),
                                infoWindow: const InfoWindow(title: '추천 장소'),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed,
                                ),
                              ),
                              if (widget.userLat != null &&
                                  widget.userLng != null)
                                Marker(
                                  markerId: const MarkerId('user'),
                                  position: LatLng(
                                    widget.userLat!,
                                    widget.userLng!,
                                  ),
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
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                liked ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  liked = !liked;
                                });
                                setStateModal(() {}); // 동기화
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
              ),
            );
          },
        );
      },
    );
  }
}
