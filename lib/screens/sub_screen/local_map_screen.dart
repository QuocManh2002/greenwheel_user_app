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
  const LocalMapScreen({super.key, required this.location});
  final LocationViewModel location;

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

  _onMapCreated(MapboxMap controller) {
    _mapboxMap = controller;
  }

  getMapInfo() async {
    var jsonResponse = await getRouteInfo(_defaultCoordinate!,
        PointLatLng(widget.location.latitude, widget.location.longitude));

    var route = jsonResponse['routes'][0]['overview_polyline']['points'];
    duration = jsonResponse['routes'][0]['legs'][0]['duration']['text'];
    distance = jsonResponse['routes'][0]['legs'][0]['distance']['text'];

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

    _mapboxMap!.setCamera(CameraOptions(
        center: Point(
                coordinates: Position(
                    widget.location.longitude, widget.location.latitude))
            .toJson(),
        zoom: 10));

    _mapboxMap?.flyTo(
        CameraOptions(
            anchor: ScreenCoordinate(x: 0, y: 0),
            zoom: 8,
            bearing: 0,
            pitch: 0),
        MapAnimationOptions(duration: 2000, startDelay: 0));

    _mapboxMap?.annotations.createCircleAnnotationManager().then((value) async {
      value.create(
        CircleAnnotationOptions(
          geometry: Point(
                  coordinates: Position(_defaultCoordinate!.longitude,
                      _defaultCoordinate!.latitude))
              .toJson(),
          circleColor: primaryColor.value,
          circleRadius: 12.0,
        ),
      );
    });

    _mapboxMap?.annotations.createCircleAnnotationManager().then((value) async {
      value.create(
        CircleAnnotationOptions(
          geometry: Point(
                  coordinates: Position(
                      widget.location.longitude, widget.location.latitude))
              .toJson(),
          circleColor: redColor.value,
          circleRadius: 12.0,
        ),
      );
    });

    _mapboxMap!.setBounds(CameraBoundsOptions(
        bounds: CoordinateBounds(
            southwest: Point(
                    coordinates: Position(
                        widget.location.longitude, widget.location.latitude))
                .toJson(),
            northeast: Point(
                    coordinates: Position(_defaultCoordinate!.longitude,
                        _defaultCoordinate!.latitude))
                .toJson(),
            infiniteBounds: true),
        maxZoom: 17,
        minZoom: 0,
        maxPitch: 10,
        minPitch: 0));

    await _mapboxMap?.style.addSource(GeoJsonSource(id: 'line', data: geojson));
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
        title: const Text(
          "Bản đồ địa phương",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            child: MapWidget(
              key: const ValueKey('mapWidget'),
              cameraOptions: CameraOptions(
                  center: Point(
                          coordinates: Position(widget.location.longitude,
                              widget.location.latitude))
                      .toJson(),
                  zoom: 11),
              styleUri: MapboxStyles.MAPBOX_STREETS,
              textureView: false,
              onMapCreated: _onMapCreated,
            ),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.hardEdge,
                    elevation: 2,
                    child: Row(children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14)),
                        child: Hero(
                            tag: widget.location.id,
                            child: FadeInImage(
                              height: 15.h,
                              placeholder: MemoryImage(kTransparentImage),
                              image: NetworkImage(
                                  '$baseBucketImage${widget.location.imageUrls[0]}'),
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
                            Text("Khoảng cách: $distance"),
                            const SizedBox(
                              height: 8,
                            ),
                            Text("Thời gian di chuyển: $duration")
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
}
