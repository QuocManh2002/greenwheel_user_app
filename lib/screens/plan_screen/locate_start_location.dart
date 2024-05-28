import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../core/constants/colors.dart';
import '../../helpers/goong_request.dart';
import '../../helpers/util.dart';
import '../../main.dart';
import '../../view_models/location.dart';
import '../../view_models/plan_viewmodels/plan_create.dart';
import '../../widgets/style_widget/dialog_style.dart';

class LocateStartLocation extends StatefulWidget {
  const LocateStartLocation(
      {super.key, required this.location, required this.callback, this.plan});
  final LocationViewModel location;
  final PlanCreate? plan;
  final void Function(PointLatLng? point, String? address) callback;

  @override
  State<LocateStartLocation> createState() => _LocateStartLocationState();
}

class _LocateStartLocationState extends State<LocateStartLocation> {
  CircleAnnotationManager? _circleAnnotationManagerStart;
  PolylinePoints polylinePoints = PolylinePoints();
  PointLatLng? _selectedLocation;
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
                  widget.location.longitude, widget.location.latitude)),
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
                    widget.location.longitude, widget.location.latitude)),
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
                      widget.location.longitude, widget.location.latitude)),
              northeast: Point(
                  coordinates: Position(_selectedLocation!.longitude,
                      _selectedLocation!.latitude)),
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
  }

  _onSelectLocation(PointLatLng selectedLocation) async {
    if (!await Utils().checkLoationInSouthSide(
        lon: selectedLocation.longitude, lat: selectedLocation.latitude)) {
      DialogStyle().basicDialog(
          // ignore: use_build_context_synchronously
          context: context,
          title: 'Xin hãy chọn địa điểm trong lãnh thổ Việt Nam',
          type: DialogType.warning);
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
                    selectedLocation.longitude, selectedLocation.latitude)),
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
                    selectedLocation.longitude, selectedLocation.latitude)),
            circleColor: primaryColor.value,
            circleRadius: 12.0,
          ),
        );
      });
      _getRouteInfo();
      if (widget.plan == null) {
        sharedPreferences.setDouble(
            'plan_start_lat', _selectedLocation!.latitude);
        sharedPreferences.setDouble(
            'plan_start_lng', _selectedLocation!.longitude);
      } else {
        widget.plan?.departCoordinate = _selectedLocation;
      }
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
                  DialogStyle().basicDialog(
                      context: context,
                      title: 'Vui lòng chọn địa điểm xuất phát',
                      type: DialogType.warning);
                } else {
                  widget.callback(_selectedLocation!, address);
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
      body: Stack(
        children: [
          MapWidget(
            key: UniqueKey(),
            cameraOptions: CameraOptions(
                center: Point(
                    coordinates: Position(
                        widget.location.longitude, widget.location.latitude)),
                zoom: 10),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            onTapListener: (coordinate) async {
              final tempAddress = await _getPlaceDetail(PointLatLng(
                  coordinate.point.coordinates.lat.toDouble(),
                  coordinate.point.coordinates.lng.toDouble()));
              if (tempAddress == null || tempAddress.toString().isEmpty) {
                DialogStyle().basicDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    title: 'Không xác định được địa chỉ cụ thể',
                    desc: 'Vui lòng chọn lại một địa điểm khác',
                    type: DialogType.warning);
              } else if (tempAddress.toString().length >
                      GlobalConstant().ADDRESS_MAX_LENGTH ||
                  tempAddress.toString().length <
                      GlobalConstant().ADDRESS_MIN_LENGTH) {
                DialogStyle().basicDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    title:
                        'Độ dài của địa điểm xuất phát phải từ ${GlobalConstant().ADDRESS_MIN_LENGTH} - ${GlobalConstant().ADDRESS_MAX_LENGTH} ký tự',
                    desc:
                        'Địa điểm đã chọn: $tempAddress, vui lòng chọn lại địa điểm khác',
                    type: DialogType.warning);
              } else {
                // DialogStyle().ba
                AwesomeDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        animType: AnimType.leftSlide,
                        dialogType: DialogType.warning,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        body: Center(
                          child: RichText(
                            text: TextSpan(
                                text: 'Chọn ',
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey,
                                  fontFamily: 'NotoSans',
                                ),
                                children: [
                                  TextSpan(
                                      text: tempAddress,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  const TextSpan(
                                      text: ' làm địa điểm xuất phát.')
                                ]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        btnOkOnPress: () async {
                          if (_circleAnnotationManagerStart != null) {
                            await _circleAnnotationManagerStart!.deleteAll();
                          }
                          await _onSelectLocation(PointLatLng(
                              coordinate.point.coordinates.lat.toDouble(),
                              coordinate.point.coordinates.lng.toDouble()));
                          address = tempAddress;
                        },
                        btnOkColor: Colors.amber,
                        btnOkText: 'Chọn',
                        btnCancelColor: Colors.blueAccent,
                        btnCancelOnPress: () {},
                        btnCancelText: 'Huỷ')
                    .show();
              }
            },
            textureView: false,
            onMapCreated: _onMapCreated,
          ),
        ],
      ),
    ));
  }

  _getPlaceDetail(PointLatLng point) async {
    var result = await getPlaceDetail(point);
    if (result != null) {
      return result['results'][0]['formatted_address'];
    }
    return null;
  }
}
