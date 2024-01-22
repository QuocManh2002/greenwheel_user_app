import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sizer2/sizer2.dart';


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
  CircleAnnotationManager? _circleAnnotationManagerEnd;
  PolylinePoints polylinePoints = PolylinePoints();
  PointLatLng? _selectedLocation;
  var distanceText;
  var durationText;

  var distanceValue;
  var durationValue;
  bool _isHasLine = false;
  MapboxMap? _mapboxMap;
  String? address;
  _onMapCreated(MapboxMap controller) {
    _mapboxMap = controller;
    if (_mapboxMap != null) {
      getMapInfo();
    }
  }
  

  getMapInfo() {
    if (_mapboxMap != null) {
      if (_selectedLocation != null) {
        _onSelectLocation(_selectedLocation!);
      }
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
       _mapboxMap?.annotations
          .createCircleAnnotationManager()
          .then((value) async {
        setState(() {
          _circleAnnotationManagerEnd =
              value; // Store the reference to the circle annotation manager
        });
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
    }
  }

  _getRouteInfo() async {
    var jsonResponse = await getRouteInfo(_selectedLocation!,
        PointLatLng(widget.location.latitude, widget.location.longitude));

    var route = jsonResponse['routes'][0]['overview_polyline']['points'];
    setState(() {
      durationText = jsonResponse['routes'][0]['legs'][0]['duration']['text'];
      distanceText = jsonResponse['routes'][0]['legs'][0]['distance']['text'];
      durationValue =
          jsonResponse['routes'][0]['legs'][0]['duration']['value'] / 3600;
      distanceValue =
          jsonResponse['routes'][0]['legs'][0]['distance']['value'] / 1000;
    });

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
                .toJson(),
            northeast: Point(
                    coordinates: Position(_selectedLocation!.longitude,
                        _selectedLocation!.latitude))
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
          "line-color":"rgb(146, 174, 255)",
          "line-width":9.0
          }
        }""";

    await _mapboxMap?.style.addPersistentStyleLayer(lineLayerJson, null);
    setState(() {
      _isHasLine = true;
    });
  }

  _onSelectLocation(PointLatLng selectedLocation) async {
    if (!await Utils().CheckLoationInSouthSide(
        lon: selectedLocation.longitude, lat: selectedLocation.latitude)) {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
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
      if (_isHasLine) {
        await _mapboxMap!.style.removeStyleLayer('line_layer');
        await _mapboxMap!.style.removeStyleSource('line');
      }

      _getRouteInfo();
      _mapboxMap!.setCamera(CameraOptions(
          center: Point(
                  coordinates: Position(
                      selectedLocation.longitude, selectedLocation.latitude))
              .toJson(),
          zoom: 10));
      _mapboxMap?.flyTo(
          CameraOptions(
              anchor: ScreenCoordinate(x: 0, y: 0),
              zoom: 10,
              bearing: 0,
              pitch: 0),
          MapAnimationOptions(duration: 2000, startDelay: 0));
    }
    _mapboxMap?.annotations.createCircleAnnotationManager().then((value) async {
      setState(() {
        _circleAnnotationManagerStart =
            value; // Store the reference to the circle annotation manager
      });
      value.create(
        CircleAnnotationOptions(
          geometry: Point(
                  coordinates: Position(
                      selectedLocation.longitude, selectedLocation.latitude))
              .toJson(),
          circleColor: primaryColor.value,
          circleRadius: 12.0,
        ),
      );
    });
    sharedPreferences.setDouble('plan_start_lat', _selectedLocation!.latitude);
    sharedPreferences.setDouble('plan_start_lng', _selectedLocation!.longitude);
  }
  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   _mapboxMap!.dispose();
  // }

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
      ),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey('mapWidget'),
            resourceOptions: ResourceOptions(
                accessToken:
                    "pk.eyJ1IjoicXVvY21hbmgyMDIiLCJhIjoiY2xuM3AwM2hpMGlzZDJqcGFla2VlejFsOCJ9.gEsXIx57uMGskLDDQYBm4g"),
            cameraOptions: CameraOptions(
                center: Point(
                        coordinates: Position(widget.location.longitude,
                            widget.location.latitude))
                    .toJson(),
                zoom: 10),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            onLongTapListener: (coordinate) async {
              if (_circleAnnotationManagerStart != null) {
                await _circleAnnotationManagerStart!.deleteAll();
              }
              await _onSelectLocation(PointLatLng(coordinate.x, coordinate.y));
            },
            textureView: false,
            onMapCreated: _onMapCreated,
          ),
          if (_isHasLine)
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 3.h),
                  child: ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () {
                        widget.callback(_selectedLocation!);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Chọn địa điểm này')),
                ))
        ],
      ),
    ));
  }
}
