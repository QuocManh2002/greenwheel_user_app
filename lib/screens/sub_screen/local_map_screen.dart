import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocalMapScreen extends StatefulWidget {
  const LocalMapScreen(
      {super.key,
      this.location,
      this.fromLocation,
      this.toLocation,
      required this.title,
      this.routeData,
      this.toAddress});
  final LocationViewModel? location;
  final PointLatLng? fromLocation;
  final PointLatLng? toLocation;
  final String? toAddress;
  final String title;
  final String? routeData;

  @override
  State<LocalMapScreen> createState() => _LocalMapScreenState();
}

class _LocalMapScreenState extends State<LocalMapScreen> {
  MapboxMap? _mapboxMap;
  bool isLoading = true;
  String? distance;
  String? duration;
  PolylinePoints polylinePoints = PolylinePoints();
  PointLatLng? _defaultCoordinate;
  PointLatLng? fromLocation;
  PointLatLng? toLocation;
  bool isDuplicateFromToLatLng = false;

  _onMapCreated(MapboxMap controller) {
    _mapboxMap = controller;
  }

  getMapInfo() async {
    var jsonResponse = widget.routeData == null
        ? await getRouteInfo(fromLocation!,
            PointLatLng(toLocation!.latitude, toLocation!.longitude))
        : json.decode(widget.routeData!);

    var route = jsonResponse['routes'][0]['overview_polyline']['points'];
    if (jsonResponse['routes'][0]['legs'][0]['duration']['value'] >= 100) {
      setState(() {
        duration = jsonResponse['routes'][0]['legs'][0]['duration']['text'];
        distance = jsonResponse['routes'][0]['legs'][0]['distance']['text'];
      });
      List<PointLatLng> result = polylinePoints.decodePolyline(route);
      List<List<double>> coordinates =
          result.map((point) => [point.longitude, point.latitude]).toList();

      var geojson = '''{
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "properties": {
            "name": "Crema to Council Crest"
          },
          "geometry": {
            "type": "LineString",
            "coordinates": $coordinates
          }
        }
      ]
    }''';

      await _mapboxMap?.style
          .addSource(GeoJsonSource(id: 'line', data: geojson));
      var lineLayerJson = """{
          "type":"line",
          "id":"line_layer",
          "source":"line",
          "paint":{
          "line-join":"round",
          "line-cap":"round",
          "line-color":"rgb(51, 51, 255)",
          "line-width":9.0
          }
        }""";

      await _mapboxMap?.style.addPersistentStyleLayer(lineLayerJson, null);

      await _mapboxMap!.annotations
          .createCircleAnnotationManager()
          .then((value) async {
        value.create(
          CircleAnnotationOptions(
            geometry: Point(
                coordinates:
                    Position(fromLocation!.longitude, fromLocation!.latitude)),
            circleColor: primaryColor.value,
            circleRadius: 12.0,
          ),
        );
      });
    } else {
      setState(() {
        isDuplicateFromToLatLng = true;
      });
    }

    _mapboxMap?.annotations.createCircleAnnotationManager().then((value) async {
      value.create(
        CircleAnnotationOptions(
          geometry: Point(
              coordinates:
                  Position(toLocation!.longitude, toLocation!.latitude)),
          circleColor: redColor.value,
          circleRadius: 12.0,
        ),
      );
    });

    _mapboxMap?.flyTo(
        CameraOptions(
            anchor: ScreenCoordinate(x: 0, y: 0),
            zoom: 13,
            bearing: 0,
            pitch: 0),
        MapAnimationOptions(duration: 2000, startDelay: 0));

    _mapboxMap?.setCamera(CameraOptions(
        center: Point(
            coordinates: Position(toLocation!.longitude, toLocation!.latitude)),
        zoom: 14));
    _mapboxMap?.setBounds(CameraBoundsOptions(
        bounds: CoordinateBounds(
            southwest: Point(
                coordinates:
                    Position(toLocation!.longitude, toLocation!.latitude)),
            northeast: Point(
                coordinates:
                    Position(fromLocation!.longitude, fromLocation!.latitude)),
            infiniteBounds: true),
        maxZoom: 17,
        minZoom: 0,
        maxPitch: 10,
        minPitch: 0));
  }

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() {
    var defaultCoordinate =
        sharedPreferences.getStringList('defaultCoordinate');
    if (defaultCoordinate != null) {
      _defaultCoordinate = PointLatLng(double.parse(defaultCoordinate[0]),
          double.parse(defaultCoordinate[1]));
      if (widget.location != null) {
        fromLocation = _defaultCoordinate;
        toLocation =
            PointLatLng(widget.location!.latitude, widget.location!.longitude);
      } else {
        isDuplicateFromToLatLng = _defaultCoordinate == widget.toLocation;
        toLocation = widget.toLocation;
        fromLocation = widget.fromLocation;
      }
      getMapInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: BackButton(
          style: const ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          MapWidget(
            key: UniqueKey(),
            cameraOptions: CameraOptions(
                center: Point(
                    coordinates: Position(
                        fromLocation!.longitude, fromLocation!.latitude)),
                zoom: 11),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            onMapCreated: _onMapCreated,
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
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.hardEdge,
                    elevation: 2,
                    child: Row(children: [
                      if (widget.location != null)
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14)),
                          child: Hero(
                              tag: widget.location!.id,
                              child: FadeInImage(
                                height: 15.h,
                                placeholder: MemoryImage(kTransparentImage),
                                image: NetworkImage(
                                    '$baseBucketImage${widget.location!.imageUrls[0]}'),
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
                            Text(
                                widget.location != null
                                    ? widget.location!.name
                                    : widget.toAddress!,
                                overflow: TextOverflow.clip,
                                maxLines: 2,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 8,
                            ),
                            if (!isDuplicateFromToLatLng)
                              Text("Khoảng cách: ${distance ?? '...'}"),
                            if (!isDuplicateFromToLatLng)
                              const SizedBox(
                                height: 8,
                              ),
                            if (!isDuplicateFromToLatLng)
                              Text("Thời gian di chuyển: ${duration ?? '...'}"),
                            SizedBox(
                              height: 1.h,
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                ),
              )),
        ],
      ),
    ));
  }
}
