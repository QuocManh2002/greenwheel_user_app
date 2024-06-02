import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phuot_app/core/constants/colors.dart';
import 'package:phuot_app/main.dart';
import 'package:phuot_app/widgets/style_widget/dialog_style.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer2/sizer2.dart';

import '../helpers/goong_request.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  MapboxMap? _mapboxMap;
  PolylinePoints polylinePoints = PolylinePoints();
  bool isSnapshot = false;
  GlobalKey _snapshotKey = GlobalKey();
  Image? snapshotImage;
  Snapshotter? _snapshotter;
  List<List<double>> coordinates = [];

  _onMapCreated(MapboxMap controller) async {
    _mapboxMap = controller;
    _snapshotter = await Snapshotter.create(
      options: MapSnapshotOptions(
          size: Size(width: 400, height: 400),
          pixelRatio: MediaQuery.of(context).devicePixelRatio),
    );
    await _snapshotter?.style.setStyleURI(MapboxStyles.OUTDOORS);
  }

  List<String> list = ['Manh', 'Huy', 'Nhat', 'Duy', 'Cong'];

  @override
  void initState() {
    // if (hasConnection) {
    // setUpData();
    // } else {
    //   if (_mapboxMap != null) {
    //     setUpDataOffline();
    //   }
    // }
    super.initState();
  }

  onRefresh()async{
    setState(() {
      list.add('Manhh');
    });
  }

  setUpDataOffline() async {
    // if (_mapboxMap != null) {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/map_data.geojson';
    var data = await rootBundle.loadString(path);
    await _mapboxMap!.style.addSource(GeoJsonSource(id: "line", data: data));
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
    // return;
    // }
  }

  setUpData() async {
    if (hasConnection) {
      var jsonResponse = await getRouteInfo(
          PointLatLng(10.841239294530496, 106.80989662784607),
          PointLatLng(10.95510002044722, 106.66939654015717));

      var route = jsonResponse['routes'][0]['overview_polyline']['points'];
      if (jsonResponse['routes'][0]['legs'][0]['duration']['value'] >= 100) {
        List<PointLatLng> result = polylinePoints.decodePolyline(route);
        coordinates =
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
      }
    } else {
      if (_mapboxMap != null) {
        setUpDataOffline();
      }
    }
  }

  onSnapShot() async {}

  Future<void> saveSource() async {
    if (_mapboxMap == null) return;
    // if (await Permission.storage.request().isGranted) {
    try {
      // Extract geographic data from the map
      // This example assumes you have a GeoJSON source named 'my_geojson_source'
      final geojsonSource =
          await _mapboxMap!.style.getSource('line') as GeoJsonSource?;

      if (geojsonSource != null) {
        // Convert the GeoJSON data to a string
        final geojsonString = geojsonSource.data.toString();

        // Get directory to save the GeoJSON file
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/map_data.geojson';

        // Save the GeoJSON string to a file
        final File file = File(path);
        await file.writeAsString(geojsonString);
        log('GeoJSON saved to $path');

        // Optionally show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GeoJSON saved to $path')),
        );
      } else {
        log('No GeoJSON source found');
      }
    } catch (e) {
      log('Error capturing GeoJSON: $e');
    }
    // } else {
    //   // Handle permission denied
    //   log('Storage permission denied');
    // }
  }

  _onMapIdle(MapIdleEventData data) async {}

  @override
  Widget build(BuildContext context) {
    final MapWidget mapWidget = MapWidget(
      key: ValueKey("mapWidget"),
      onMapCreated: _onMapCreated,
      textureView: true,
      cameraOptions: CameraOptions(
          zoom: 15,
          center: Point(
              coordinates: Position(106.7990999233828, 10.844798637608866))),
      // onMapIdleListener: _onMapIdle,
    );
    return Scaffold(
        appBar: AppBar(
          title: Text('app bar'),
        ),
        body: RefreshIndicator(
          onRefresh: () async{
            onRefresh();
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Container(
                padding: EdgeInsets.symmetric(),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.5),
                ),
                child: Text(
                  list[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ));
  }

  onSave(BuildContext context) async {
    try {
      RenderBox snapshotBox =
          _snapshotKey.currentContext!.findRenderObject() as RenderBox;
      if (snapshotBox.hasSize) {
        _snapshotter?.setSize(Size(
            width: snapshotBox.size.width, height: snapshotBox.size.height));
      }

      final cameraState = await _mapboxMap!.getCameraState();
      _snapshotter?.setCamera(cameraState.toCameraOptions());
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

      if (isSnapshot) {
        _snapshotter?.style.removeStyleSource('line');
        _snapshotter?.style.removeStyleLayer('line_layer');
      }
      // if (await _snapshotter?.style.getLayer('line_layer') != null) {
      // }

      _snapshotter?.style.addSource(GeoJsonSource(id: 'line', data: geojson));
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

      _snapshotter?.style.addPersistentStyleLayer(lineLayerJson, null);

      final snapshot = await _snapshotter?.start();

      if (snapshot != null) {
        setState(() {
          snapshotImage = Image.memory(snapshot);
        });
      }
      setState(() {
        isSnapshot = true;
      });

      RenderRepaintBoundary boundary = _snapshotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3);
      final whietPaint = Paint()..color = Colors.white;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
      canvas.drawRect(
          Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
          whietPaint);
      canvas.drawImage(image, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      // return pngBytes;

      // Uint8List? uint8list = await convertQRToBytes();
      // final byteData =
      //     await snapshotImage!.toByteData(format: ImageByteFormat.png);
      // Uint8List pngBytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(pngBytes);
      if (result['isSuccess']) {
        Fluttertoast.showToast(
          msg: 'Lưu hình ảnh thành công!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1, // Duration in seconds
        );
        // String deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
        // sharedPreferences.setString('deviceToken', deviceToken);
      } else {
        // ignore: use_build_context_synchronously
        DialogStyle().basicDialog(
            context: context,
            title: 'Luu hinh anh that bai',
            type: DialogType.warning);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
