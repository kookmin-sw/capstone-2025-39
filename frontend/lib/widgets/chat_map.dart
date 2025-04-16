import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatMap extends StatelessWidget {
  //37.610837, 126.996379
  final double lat;
  final double lng;

  const ChatMap({super.key, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    final LatLng myPosition = LatLng(lat, lng);
    final Set<Marker> markers = {
      Marker(markerId: const MarkerId('marker1'), position: myPosition),
    };

    return SizedBox(
      height: 210,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: myPosition, zoom: 15),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      ),
    );
  }
}
