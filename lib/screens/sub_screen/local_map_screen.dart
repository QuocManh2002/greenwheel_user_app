import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:location/location.dart';

import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocalMapScreen extends StatefulWidget {
  const LocalMapScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<LocalMapScreen> createState() => _LocalMapScreenState();
}

class _LocalMapScreenState extends State<LocalMapScreen> {
  // late MapboxMapController controller;
  // Location _locationController = Location();
  // bool isLoading = true;
  // LatLng _currentP = LatLng(0, 0);
  // var distance ;
  // var duration ;
  // PolylinePoints polylinePoints = PolylinePoints();

  // _onMapCreated(MapboxMapController controller) {
  //   this.controller = controller;
  // }

    _onStyleLoadedCallback() async {

    // await controller.addSymbol(const SymbolOptions(
    //   geometry: LatLng(10.841877927102306, 106.8098508297925),
    //   iconSize: 5,
    //   iconImage: "assets/images/from_icon.png"
    // ));
    // await controller.addSymbol(SymbolOptions(
    //   geometry: LatLng(widget.location.latitude, widget.location.longitude),
    //   iconSize: 5,
    //   iconImage: "assets/images/to_icon.png"
    // ));

    
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
      body: 
      // isLoading
      //     ? const Center(
      //         child: Text("Loading..."),
      //       )
          // : 
          Stack(
              children: [
                // MapboxMap(initialCameraPosition: CameraPosition(
                //       target: LatLng(widget.location.latitude, widget.location.longitude), zoom: 4),
                //       accessToken: mapboxKey,
                //       onMapCreated: _onMapCreated,
                      
                //       onStyleLoadedCallback: _onStyleLoadedCallback,
                //       // myLocationEnabled: true,
                //       minMaxZoomPreference: const MinMaxZoomPreference(6, 17),
                //       myLocationRenderMode: MyLocationRenderMode.NORMAL,
                //       ),
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
                  // Text("Khoảng cách: ${distance.toStringAsFixed(2)} km"),
                  // const SizedBox(
                  //   height: 8,
                  // ),
                  // Text("Thời gian di chuyển: ${duration.toStringAsFixed(0)} phút")
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
    // PermissionStatus _permissionGranted;
    // _serviceEnabled = await _locationController.serviceEnabled();
    // if (!_serviceEnabled) {
    //   _serviceEnabled = await _locationController.requestService();
    // }
    // _permissionGranted = await _locationController.hasPermission();
    // if (_permissionGranted == PermissionStatus.denied) {
    //   _permissionGranted = await _locationController.requestPermission();
    // }

    // // _locationController.onLocationChanged
    // //     .listen((LocationData currentLocation) async {
    // //   if (currentLocation.latitude != null &&
    // //       currentLocation.longitude != null) {
    // //    setState(() {
    // //       _currentP =
    // //         LatLng(currentLocation.latitude!, currentLocation.longitude!);
    // //         getMapInfo();
    // //    });
    // //     // _cameraToPosition(_currentP);
    // //   }
    // // });

    // LocationData _locationData = await _locationController.getLocation();
    // setState(() {
    //   _currentP = LatLng(_locationData.latitude!, _locationData.longitude!);
    //   getMapInfo();
    // });
  }

  getMapInfo() async {
    // if (_currentP.latitude != 0) {
      // var mapInfo = await getDirectionsAPIResponse(
      //    const LatLng(10.841877927102306, 106.8098508297925), LatLng(widget.location.latitude, widget.location.longitude));

      // if (mapInfo.isNotEmpty) {
      //   print(mapInfo["duration"]);
      //   print(mapInfo["distance"]);

      //   setState(() {
      //     distance = mapInfo["distance"] / 1000;
      //     duration = mapInfo["distance"] / 60;

      //     isLoading = false;
      //   });
      // }


    //   var jsonResponse = await getRouteInfo(const LatLng(10.841877927102306, 106.8098508297925), LatLng(widget.location.latitude, widget.location.longitude));

    //   var route  = jsonResponse['routes'][0]['overview_polyline']['points'];
    //   duration = jsonResponse['routes'][0]['legs'][0]['duration']['text'];
    //   distance = jsonResponse['routes'][0]['legs'][0]['distance']['text'];

    //   List<PointLatLng> result = polylinePoints.decodePolyline(route);
    //   List<List<double>> coordinates = result.map((point) => [point.longitude, point.latitude]).toList();
    //   var geojson =
    //   {
    //   "type": "FeatureCollection",
    //   "features": [
    //     {
    //       "type": "Feature",
    //       "properties": {
    //         "name": "Crema to Council Crest"
    //       },
    //       "geometry": {
    //         "type": "LineString",
    //         "coordinates": coordinates
    //       }
    //     }
    //   ]
    // };

    // await controller.addGeoJsonSource('line', geojson);
    // var lineLayerJson = """{
    //   "type":"line",
    //       "id":"line_layer",
    //       "source":"line",
    //       "paint":{
    //       "line-join":"round",
    //       "line-cap":"round",
    //       "line-color":"rgb(51, 51, 255)",
    //       "line-width":9.0
    //       }
    // }""";

    // }
  }
}
