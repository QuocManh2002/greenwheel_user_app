import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenwheel_user_app/models/location.dart';

class LocalMapScreen extends StatefulWidget {
  const LocalMapScreen({super.key, required this.location});
  final Location location;

  @override
  State<LocalMapScreen> createState() => _LocalMapScreenState();
}

class _LocalMapScreenState extends State<LocalMapScreen> {
  final Completer<GoogleMapController> _controller =
        Completer<GoogleMapController>();
  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bản đồ địa phương",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition:
                CameraPosition(target: widget.location.locationLatLng, zoom: 15),
            markers: {
              Marker(
                  markerId: MarkerId(widget.location.id),
                  icon: BitmapDescriptor.defaultMarker,
                  position: widget.location.locationLatLng),
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ],
      ),
    ));
  }
}
