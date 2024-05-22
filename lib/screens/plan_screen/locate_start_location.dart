import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class LocateStartLocation extends StatefulWidget {
  const LocateStartLocation(
      {super.key, required this.location, required this.callback});
  final LocationViewModel location;
  final void Function(PointLatLng? point) callback;

  @override
  State<LocateStartLocation> createState() => _LocateStartLocationState();
}

class _LocateStartLocationState extends State<LocateStartLocation> {
  CircleAnnotationManager? _circleAnnotationManagerStart;
  PolylinePoints polylinePoints = PolylinePoints();
  PointLatLng? _selectedLocation;
  String distanceText = '';
  String durationText = '';

  double distanceValue = 0;
  double durationValue = 0;
  bool _isHasLine = false;
  MapboxMap? _mapboxMap;
  String? address;
  _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    if (_mapboxMap != null) {
      getMapInfo();
    }
  }

  getMapInfo() async {
    if (_mapboxMap != null) {
      if (_selectedLocation != null) {
        _onSelectLocation(_selectedLocation!);
      }
      _mapboxMap!.setCamera(CameraOptions(
          center: Point(
                  coordinates: Position(
                      widget.location.longitude, widget.location.latitude))
              ,
          zoom: 10));
      _mapboxMap!.flyTo(
          CameraOptions(
              anchor: ScreenCoordinate(x: 0, y: 0),
              zoom: 8,
              bearing: 0,
              pitch: 0),
          MapAnimationOptions(duration: 2000, startDelay: 0));
      _mapboxMap!.annotations
          .createCircleAnnotationManager()
          .then((value) async {
        value.create(
          CircleAnnotationOptions(
            geometry: Point(
                    coordinates: Position(
                        widget.location.longitude, widget.location.latitude))
                ,
            circleColor: redColor.value,
            circleRadius: 12.0,
          ),
        );
      });
    }
  }

  _getRouteInfo() async {
    var jsonResponse = await getRouteInfo(_selectedLocation!,
        PointLatLng(widget.location.latitude, widget.location.longitude));
    dynamic route;
    if (jsonResponse != null) {
      route = jsonResponse['routes'][0]['overview_polyline']['points'];
      durationText = jsonResponse['routes'][0]['legs'][0]['duration']['text'];
      distanceText = jsonResponse['routes'][0]['legs'][0]['distance']['text'];
      durationValue =
          jsonResponse['routes'][0]['legs'][0]['duration']['value'] / 3600;
      distanceValue =
          jsonResponse['routes'][0]['legs'][0]['distance']['value'] / 1000;
      sharedPreferences.setString('plan_duration_text', durationText);
      sharedPreferences.setString('plan_distance_text', distanceText);
      sharedPreferences.setDouble('plan_duration_value', durationValue);
      sharedPreferences.setDouble('plan_distance_value', distanceValue);
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

      _mapboxMap!.setBounds(CameraBoundsOptions(
          bounds: CoordinateBounds(
              southwest: Point(
                      coordinates: Position(
                          widget.location.longitude, widget.location.latitude))
                  ,
              northeast: Point(
                      coordinates: Position(_selectedLocation!.longitude,
                          _selectedLocation!.latitude))
                  ,
              infiniteBounds: true),
          maxZoom: 17,
          minZoom: 0,
          maxPitch: 10,
          minPitch: 0));
      if (_mapboxMap != null) {
        await _mapboxMap!.style
            .addSource(GeoJsonSource(id: 'line', data: geojson));
        await _mapboxMap!.style.addLayer(LineLayer(
            id: "line_layer",
            sourceId: "line",
            lineJoin: LineJoin.ROUND,
            lineCap: LineCap.ROUND,
            lineOpacity: 0.7,
            lineColor: const Color.fromRGBO(146, 174, 255, 1).value,
            lineWidth: 9.0));
      }
      if (await _mapboxMap!.style.getLayer('line_layer') != null) {
        _isHasLine = true;
      }
    }
    // var lineLayerJson = """{
    //       "type":"line",
    //       "id":"line_layer",
    //       "source":"line",
    //       "paint":{
    //       "line-join":"round",
    //       "line-cap":"round",
    //       "line-color":"rgb(146, 174, 255)",
    //       "line-width":9.0
    //       }
    //     }""";
    // await _mapboxMap?.style.addPersistentStyleLayer(lineLayerJson, null);
  }

  _onSelectLocation(PointLatLng selectedLocation) async {
    if (!await Utils().checkLoationInSouthSide(
        lon: selectedLocation.longitude, lat: selectedLocation.latitude)) {
      AwesomeDialog(
        // ignore: use_build_context_synchronously
        context: context,
        dialogType: DialogType.warning,
        body: const Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Xin hãy chọn địa điểm trong lãnh thổ Việt Nam',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
        btnOkOnPress: () {},
        btnOkColor: Colors.orange,
        btnOkText: 'Ok',
      ).show();
    } else {
      _selectedLocation = selectedLocation;
      if (_mapboxMap != null) {
        if (_isHasLine) {
          await _mapboxMap!.style.removeStyleLayer('line_layer');
          await _mapboxMap!.style.removeStyleSource('line');
        }

        _mapboxMap!.setCamera(CameraOptions(
            center: Point(
                    coordinates: Position(
                        selectedLocation.longitude, selectedLocation.latitude))
                ,
            zoom: 10));
        _mapboxMap?.flyTo(
            CameraOptions(
                anchor: ScreenCoordinate(x: 0, y: 0),
                zoom: 10,
                bearing: 0,
                pitch: 0),
            MapAnimationOptions(duration: 2000, startDelay: 0));
      }
      _mapboxMap?.annotations
          .createCircleAnnotationManager()
          .then((value) async {
        _circleAnnotationManagerStart = value;
        value.create(
          CircleAnnotationOptions(
            geometry: Point(
                    coordinates: Position(
                        selectedLocation.longitude, selectedLocation.latitude))
                ,
            circleColor: primaryColor.value,
            circleRadius: 12.0,
          ),
        );
      });
      _getRouteInfo();
      sharedPreferences.setDouble(
          'plan_start_lat', _selectedLocation!.latitude);
      sharedPreferences.setDouble(
          'plan_start_lng', _selectedLocation!.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Địa điểm xuất phát'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (_selectedLocation == null) {
                  AwesomeDialog(
                          context: context,
                          animType: AnimType.leftSlide,
                          dialogType: DialogType.warning,
                          title: 'Hãy chọn địa điểm xuất phát',
                          titleTextStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans'),
                          btnOkColor: Colors.amber,
                          btnOkOnPress: () {},
                          btnOkText: 'OK')
                      .show();
                } else {
                  widget.callback(_selectedLocation!);
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(
                Icons.check,
                color: Colors.white,
                size: 35,
              ))
        ],
      ),
      body: MapWidget(
        key: UniqueKey(),
        cameraOptions: CameraOptions(
            center: Point(
                    coordinates: Position(
                        widget.location.longitude, widget.location.latitude))
                ,
            zoom: 10),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        onTapListener: (coordinate) async {
          if (_circleAnnotationManagerStart != null) {
            await _circleAnnotationManagerStart!.deleteAll();
          }
          await _onSelectLocation(PointLatLng(coordinate.touchPosition.x, coordinate.touchPosition.y));
        },
        textureView: false,
        onMapCreated: _onMapCreated,
      ),
    ));
  }
}
