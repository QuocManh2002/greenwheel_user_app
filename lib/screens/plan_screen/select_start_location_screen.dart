import 'package:flutter/cupertino.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/helpers/direction_handler.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:sizer2/sizer2.dart';

class SelectStartLocationScreen extends StatefulWidget {
  const SelectStartLocationScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<SelectStartLocationScreen> createState() =>
      _SelectStartLocationScreenState();
}

class _SelectStartLocationScreenState extends State<SelectStartLocationScreen> {
  late MapboxMapController controller;
  Location _locationController = new Location();
  bool isLoading = true;
  LatLng _currentP = LatLng(0, 0);
  num distance = 0;
  num duration = 0;

  _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
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
      
    });
  }

  getMapInfo(LatLng selectedLocation) async {
    if (_currentP.latitude != 0) {
      var mapInfo = await getDirectionsAPIResponse(
          selectedLocation, LatLng(widget.location.latitude, widget.location.longitude));

      if (mapInfo.isNotEmpty) {
        print(mapInfo["duration"]);
        print(mapInfo["distance"]);

        setState(() {
          distance = mapInfo["distance"] / 1000;
          duration = mapInfo["duration"] / 60;

          isLoading = false;
        });
      }
    }
  }

  _onStyleLoadedCallback() async {
    await controller.addSymbol(SymbolOptions(
        geometry: _currentP,
        iconSize: 5,
        iconImage: "assets/images/from_icon.png"));
    await controller.addSymbol(SymbolOptions(
        geometry: LatLng(widget.location.latitude, widget.location.longitude),
        iconSize: 5,
        iconImage: "assets/images/to_icon.png"));
  }

  _onSelectLocaiton(LatLng _selectedLocation) async{
    String? symbolId = sharedPreferences.getString('symbolId');
    if(symbolId != null){
      controller.removeSymbol(Symbol(symbolId,SymbolOptions.defaultOptions));
    }
    SymbolOptions options = SymbolOptions(
        geometry: _selectedLocation,
        iconSize: 5,
        iconImage: "assets/images/from_icon.png");
    Symbol symbol = await controller.addSymbol(options);
    sharedPreferences.setString('symbolId', symbol.id);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'Chọn địa điểm xuất phát',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 2.h,
          ),
          SizedBox(
            height: 60.h,
            child: MapboxMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      widget.location.latitude, widget.location.longitude),
                  zoom: 8),
              accessToken: mapboxKey,
              onMapCreated: _onMapCreated,
              onMapLongClick: (point, coordinates) {
                _onSelectLocaiton(coordinates);
                
              },
              onStyleLoadedCallback: _onStyleLoadedCallback,
              minMaxZoomPreference: const MinMaxZoomPreference(6, 17),
              myLocationRenderMode: MyLocationRenderMode.NORMAL,
            ),
          ),
        ],
      ),
    );
  }
}
