import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/helpers/direction_handler.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class LocalMapScreen extends StatefulWidget {
  const LocalMapScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<LocalMapScreen> createState() => _LocalMapScreenState();
}

class _LocalMapScreenState extends State<LocalMapScreen> {
  late MapboxMapController controller;
  Location _locationController = new Location();
  bool isLoading = true;
  LatLng _currentP = LatLng(0, 0);
  num distance = 0;
  num duration = 0;

  _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

    _onStyleLoadedCallback() async {
    // for (var _kParkingItem in _kParkingList) {
    //   await controller.addSymbol(SymbolOptions(
    //     geometry: _kParkingItem.target,
    //     iconSize: 0.2,
    //     iconImage: "assets/images/delivery.png",
    //   ));
    // }
    await controller.addSymbol(SymbolOptions(
      geometry: _currentP,
      iconSize: 5,
      iconImage: "assets/images/from_icon.png"
    ));
    await controller.addSymbol(SymbolOptions(
      geometry: LatLng(widget.location.latitude, widget.location.longitude),
      iconSize: 5,
      iconImage: "assets/images/to_icon.png"
    ));
  }

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
                // GoogleMap(
                //   mapType: MapType.normal,
                //   initialCameraPosition: CameraPosition(
                //       target: LatLng(widget.location.latitude, widget.location.longitude), zoom: 15),
                //   markers: {
                //     Marker(
                //         markerId: MarkerId(widget.location.id.toString()),
                //         icon: BitmapDescriptor.defaultMarker,
                //         position:LatLng(widget.location.latitude, widget.location.longitude)),
                //   },
                //   onMapCreated: (GoogleMapController controller) {
                //     _controller.complete(controller);
                //   },
                // ),
                MapboxMap(initialCameraPosition: CameraPosition(
                      target: LatLng(widget.location.latitude, widget.location.longitude), zoom: 8),
                      accessToken: mapboxKey,
                      onMapCreated: _onMapCreated,
                      onStyleLoadedCallback: _onStyleLoadedCallback,
                      // myLocationEnabled: true,
                      minMaxZoomPreference: const MinMaxZoomPreference(6, 17),
                      myLocationRenderMode: MyLocationRenderMode.NORMAL,
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
                    image: NetworkImage(widget.location.imageUrls[0]),
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
                  Text("Thời gian di chuyển: ${duration.toStringAsFixed(0)} phút")
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
          _currentP, LatLng(widget.location.latitude, widget.location.longitude));

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
