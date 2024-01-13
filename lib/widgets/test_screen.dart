
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin {
  MapboxMap? _mapboxMap;
  var duration;
  var distance;
  CircleAnnotationManager? _circleAnnotationManagerStart;
  CircleAnnotationManager? _circleAnnotationManagerEnd;
  PointAnnotationManager? _pointAnnotationManager;

  _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
  }

  PolylinePoints polylinePoints = PolylinePoints();

  getSearchData() {}

  void getZoom() async {
    _mapboxMap?.flyTo(
        CameraOptions(
          zoom: 13.0,
        ),
        MapAnimationOptions(duration: 2000, startDelay: 0));
  }

  getMapInfo() async {
          var jsonResponse = await getRouteInfo(const PointLatLng(10.841877927102306, 106.8098508297925),const PointLatLng(10.585251868508003, 105.0579323957048));

      var route  = jsonResponse['routes'][0]['overview_polyline']['points'];
      duration = jsonResponse['routes'][0]['legs'][0]['duration']['text'];
      distance = jsonResponse['routes'][0]['legs'][0]['distance']['text'];
      print(duration);
      print(distance);

      List<PointLatLng> result = polylinePoints.decodePolyline(route);
      List<List<double>> coordinates = result.map((point) => [point.longitude, point.latitude]).toList();
      var geojson =
      '''{
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
        center:
            Point(coordinates: Position(105.0579323957048, 10.585251868508003))
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
      setState(() {
        _circleAnnotationManagerStart =
            value; // Store the reference to the circle annotation manager
      });
      var pointAnnotationStart = value;
      value.create(
        
        CircleAnnotationOptions(
          geometry: Point(
                  coordinates: Position(105.0579323957048, 10.585251868508003))
              .toJson(),
          circleColor: Colors.red.value,
          circleRadius: 12.0,

        ),
      );
    });

    // _mapboxMap?.annotations.createPointAnnotationManager().then((value) async {
    //   setState(() {
    //     _pointAnnotationManager =
    //         value; // Store the reference to the circle annotation manager
    //   });
    //   var pointAnnotationStart = value;
    //   value.create(
        
    //     PointAnnotationOptions(
    //       geometry: Point(
    //               coordinates: Position(106.8098508297925, 10.841877927102306))
    //           .toJson(),
    //       iconImage: AutofillHints.addressState,
    //       iconSize: 32,
          
    //     ),
    //   );
    // });

    _mapboxMap?.annotations.createCircleAnnotationManager().then((value) async {
      setState(() {
        _circleAnnotationManagerStart =
            value; // Store the reference to the circle annotation manager
      });
      var pointAnnotationStart = value;
      value.create(
        
        CircleAnnotationOptions(
          geometry: Point(
                  coordinates: Position(106.8098508297925,  10.841877927102306))
              .toJson(),
          circleColor: primaryColor.value,
          circleRadius: 12.0,

        ),
      );
    });

    _mapboxMap!.setBounds(CameraBoundsOptions(
        bounds: CoordinateBounds(
            southwest: Point(
                    coordinates:
                        Position(106.8098508297925, 10.841877927102306))
                .toJson(),
            northeast: Point(
                    coordinates:
                        Position(105.0579323957048, 10.585251868508003))
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
    // TODO: implement initState
    super.initState();
    getMapInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white.withOpacity(0.94),
            appBar: AppBar(),
            body: Stack(
              children: [
                SizedBox(
                  child: MapWidget(
                    key: const ValueKey('mapWidget'),
                    
                    resourceOptions: ResourceOptions(
                        accessToken:
                            "pk.eyJ1IjoicXVvY21hbmgyMDIiLCJhIjoiY2xuM3AwM2hpMGlzZDJqcGFla2VlejFsOCJ9.gEsXIx57uMGskLDDQYBm4g"),
                    cameraOptions: CameraOptions(
                      
                        center: Point(
                                coordinates: Position(
                                    105.0579323957048, 10.585251868508003))
                            .toJson(),
                        zoom: 11),
                    styleUri: MapboxStyles.MAPBOX_STREETS,
                    textureView: false,
                    onMapCreated: _onMapCreated,
                    
                  ),
                )
              ],
            )));
  }
}
