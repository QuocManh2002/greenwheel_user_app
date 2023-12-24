import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/direction_handler.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
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
  TimeOfDay _selectTime = TimeOfDay.now();
  TextEditingController _timeController = TextEditingController();
  Location _locationController = new Location();
  bool isLoading = true;
  LatLng _currentP = LatLng(0, 0);
  num distance = 0;
  num duration = 0;
  TimeOfDay? _initialTime;

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
    // if (_currentP.latitude != 0) {
    var mapInfo = await getDirectionsAPIResponse(selectedLocation,
        LatLng(widget.location.latitude, widget.location.longitude));

    if (mapInfo.isNotEmpty) {
      print(mapInfo["duration"]);
      print(mapInfo["distance"]);

      setState(() {
        distance = mapInfo["distance"] / 1000;
        duration = mapInfo["duration"] / 3600;

        isLoading = false;
      });
      sharedPreferences.setDouble('plan_start_lat', selectedLocation.latitude);
      sharedPreferences.setDouble('plan_start_lng', selectedLocation.longitude);
      sharedPreferences.setDouble('plan_distance', mapInfo["distance"] / 1000);
      sharedPreferences.setDouble('plan_duration', mapInfo["duration"] / 3600);
    }
    // }
  }

  _onStyleLoadedCallback() async {
    await controller.addSymbol(SymbolOptions(
        geometry: _currentP, iconSize: 5, iconImage: current_location));
    await controller.addSymbol(SymbolOptions(
        geometry: LatLng(widget.location.latitude, widget.location.longitude),
        iconSize: 5,
        iconImage: to_location));
    
    final lat = sharedPreferences.getDouble('plan_start_lat');
    final lng = sharedPreferences.getDouble('plan_start_lng');
    if(lat != null){
       await controller.addSymbol(SymbolOptions(
        geometry: LatLng(lat, lng!),
        iconSize: 5,
        iconImage: from_location));
    }
  }

  _onSelectLocaiton(LatLng _selectedLocation) async {
    String? symbolId = sharedPreferences.getString('symbolId');
    if (symbolId != null) {
      controller.removeSymbol(Symbol(symbolId, SymbolOptions.defaultOptions));
    }
    SymbolOptions options = SymbolOptions(
        geometry: _selectedLocation, iconSize: 5, iconImage: from_location);
    Symbol symbol = await controller.addSymbol(options);
    getMapInfo(_selectedLocation);
    sharedPreferences.setString('symbolId', symbol.id);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timeController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationUpdates();
    String? timeText = sharedPreferences.getString('plan_start_time');
    if (timeText != null) {
      final initialDateTime = DateFormat.Hm().parse(timeText);
      setState(() {
        _selectTime = TimeOfDay.fromDateTime(initialDateTime);
        _timeController.text = timeText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                    child: Text(
                  'Thời điểm xuất phát',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
                Expanded(
                  child: defaultTextFormField(
                      readonly: true,
                      controller: _timeController,
                      inputType: TextInputType.datetime,
                      text: 'Giờ',
                      onTap: () {
                        showTimePicker(
                          context: context,
                          initialTime: _selectTime,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData().copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: primaryColor,
                                      onPrimary: Colors.white)),
                              child: TimePickerDialog(
                                initialTime: _selectTime,
                              ),
                            );
                          },
                        ).then((value) {
                          _selectTime = value!;
                          _timeController.text = DateFormat.Hm().format(
                              DateTime(0, 0, 0, _selectTime.hour,
                                  _selectTime.minute));
                          sharedPreferences.setString(
                              'plan_start_time', _timeController.text);
                        });
                      },
                      onValidate: (value) {
                        if (value!.isEmpty) {
                          return "Ngày của hoạt động không được để trống";
                        }
                      },
                      prefixIcon: const Icon(Icons.watch_later_outlined)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          const Text(
            'Chọn địa điểm xuất phát',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 1.h,
          ),
          SizedBox(
            height: 57.h,
            child: Stack(
              children: [
                MapboxMap(
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
                if (duration != 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.all(2.h),
                      child: buildMapInfoWidget(),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMapInfoWidget() {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(blurRadius: 1, offset: Offset(2, 4), color: Colors.black)
          ]),
      child: Column(children: [
        SizedBox(
          height: 1.h,
        ),
        Text(
          'Khoảng cách: ${distance.toStringAsFixed(2)} km',
          style: const TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 1.h,
        ),
        Text(
          'Thời gian di chuyển: ${duration.toStringAsFixed(2)} giờ (dự kiến)',
          style: const TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 1.h,
        ),
      ]),
    );
  }
}
