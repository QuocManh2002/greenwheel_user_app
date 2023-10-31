import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenwheel_user_app/constants/locations.dart';
import 'package:greenwheel_user_app/helpers/direction_handler.dart';
import 'package:greenwheel_user_app/models/location.dart';
import 'package:location/location.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class LocalMapScreen extends StatefulWidget {
  const LocalMapScreen({super.key, required this.location});
  final LocationModel location;

  @override
  State<LocalMapScreen> createState() => _LocalMapScreenState();
}

class _LocalMapScreenState extends State<LocalMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Location _locationController = new Location();
  bool isLoading = true;
  LatLng _currentP = LatLng(0, 0);
  num distance = 0;
  num duration = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationUpdates();
  }

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
      body: isLoading
          ? const Center(
              child: Text("Loading..."),
            )
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                      target: widget.location.locationLatLng, zoom: 15),
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
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 3,
                              color: Colors.black12,
                              offset: Offset(1, 3),
                            )
                          ],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 15.h,
                        width: double.infinity,
                        child: Card(
                          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: Row(
            
            children: [
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(14)),
              child: Hero(
                  tag: widget.location.id,
                  child: FadeInImage(
                    height: 15.h,
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(widget.location.imageUrl),
                    fit: BoxFit.cover,
                    width: 15.h,
                    filterQuality: FilterQuality.high,
                  )),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Text(widget.location.name,
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 8,
                  ),
                  Text("Khoảng cách: ${distance.toStringAsFixed(2)} km"),
                  const SizedBox(
                    height: 8,
                  ),
                  Text("Thời gian di chuyển: ${duration.toStringAsFixed(2)} phút")
                ],
              ),
            )
          ]),
                        ),
                      ),
                    ))
              ],
            ),
    ));
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    }
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
    }

    // _locationController.onLocationChanged
    //     .listen((LocationData currentLocation) async {
    //   if (currentLocation.latitude != null &&
    //       currentLocation.longitude != null) {
    //    setState(() {
    //       _currentP =
    //         LatLng(currentLocation.latitude!, currentLocation.longitude!);
    //         getMapInfo();
    //    });
    //     // _cameraToPosition(_currentP);
    //   }
    // });

    LocationData _locationData = await _locationController.getLocation();
    setState(() {
      _currentP = LatLng(_locationData.latitude!, _locationData.longitude!);
      getMapInfo();
    });
  }

  getMapInfo() async {
    if (_currentP.latitude != 0) {
      var mapInfo = await getDirectionsAPIResponse(
          _currentP, widget.location.locationLatLng);

      if (mapInfo.isNotEmpty) {
        print(mapInfo["duration"]);
        print(mapInfo["distance"]);

        setState(() {
          distance = mapInfo["distance"] / 1000;
          duration = mapInfo["distance"] / 60;

          isLoading = false;
        });
      }
    }
  }
}
