import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/search_start_location_result.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sizer2/sizer2.dart';

class SelectStartLocationScreen extends StatefulWidget {
  const SelectStartLocationScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<SelectStartLocationScreen> createState() =>
      _SelectStartLocationScreenState();
}

class _SelectStartLocationScreenState extends State<SelectStartLocationScreen> {
  MapboxMap? _mapboxMap;
  TextEditingController _searchController = TextEditingController();
  var distanceText;
  var durationText;

  var distanceValue;
  var durationValue;

  List<SearchStartLocationResult> _resultList = [];
  bool isShowResult = false;
  TimeOfDay _selectTime = TimeOfDay.now();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  CircleAnnotationManager? _circleAnnotationManagerStart;
  CircleAnnotationManager? _circleAnnotationManagerEnd;
  PolylinePoints polylinePoints = PolylinePoints();
  PointLatLng? _selectedLocation;
  bool _isHasLine = false;

  _onMapCreated(MapboxMap controller) {
    _mapboxMap = controller;
    getMapInfo();
  }

  Future<void> getMapInfo() async {
    if (_mapboxMap != null) {
      if(_selectedLocation != null){
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
      durationValue = jsonResponse['routes'][0]['legs'][0]['duration']['value'] / 3600;
      distanceValue = jsonResponse['routes'][0]['legs'][0]['distance']['value'] / 1000;
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
          "line-color":"rgb(51, 51, 255)",
          "line-width":9.0
          }
        }""";

    await _mapboxMap?.style.addPersistentStyleLayer(lineLayerJson, null);
    _isHasLine = true;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() async {
    double? plan_distance = sharedPreferences.getDouble('plan_distance_value');
    if (plan_distance != null) {
      double? plan_duration = sharedPreferences.getDouble('plan_duration_value');
      setState(() {
        durationValue = plan_duration!;
        distanceValue = plan_distance;
      });
    }

    String? timeText = sharedPreferences.getString('plan_start_time');
    if (timeText != null) {
      final initialDateTime = DateFormat.Hm().parse(timeText);
      setState(() {
        _selectTime = TimeOfDay.fromDateTime(initialDateTime);
        _timeController.text = timeText;
      });
    } else {
      _selectTime =
          TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
      _timeController.text = DateFormat.Hm()
          .format(DateTime(0, 0, 0, _selectTime.hour, _selectTime.minute));
      sharedPreferences.setString('plan_start_time', _timeController.text);
    }

    String? dateText = sharedPreferences.getString('plan_start_date');
    if (dateText != null) {
      setState(() {
        _selectedDate = DateTime.parse(dateText);
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    } else {
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      sharedPreferences.setString(
          'plan_start_date', _selectedDate!.toLocal().toString().split(' ')[0]);
    }

    double? startLat = sharedPreferences.getDouble('plan_start_lat');
    if (startLat != null) {
      double? startLng = sharedPreferences.getDouble('plan_start_lng');
      _selectedLocation = PointLatLng(startLat, startLng!);
      distanceText = sharedPreferences.getString('plan_distance_text');
      distanceValue = sharedPreferences.getDouble('plan_distance_value');
      durationText = sharedPreferences.getString('plan_duration_text');
      durationValue = sharedPreferences.getDouble('plan_duration_value');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'Chọn thời gian và địa điểm xuất phát',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 1.h,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: defaultTextFormField(
                      readonly: true,
                      controller: _dateController,
                      inputType: TextInputType.datetime,
                      text: 'Ngày',
                      onTap: () async {
                        DateTime? newDay = await showDatePicker(
                            context: context,
                            locale: const Locale('vi_VN'),
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2025),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData().copyWith(
                                    colorScheme: const ColorScheme.light(
                                        primary: primaryColor,
                                        onPrimary: Colors.white)),
                                child: DatePickerDialog(
                                  cancelText: 'HỦY',
                                  confirmText: 'LƯU',
                                  initialDate: _selectedDate!,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2025),
                                ),
                              );
                            });
                        if (newDay != null) {
                          _selectedDate = newDay;
                          _dateController.text =
                              DateFormat('dd/MM/yyyy').format(newDay);
                          sharedPreferences.setString(
                              'plan_start_date', newDay.toString());
                        }
                      },
                      prefixIcon: const Icon(Icons.calendar_month),
                      onValidate: (value) {
                        if (value!.isEmpty) {
                          return "Ngày của hoạt động không được để trống";
                        }
                      }),
                ),
                SizedBox(
                  width: 3.w,
                ),
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
                          if (!Utils().checkTimeAfterNow1Hour(
                              value!,
                              DateTime(_selectedDate!.year,
                                  _selectedDate!.month, _selectedDate!.day))) {
                            AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                btnOkColor: Colors.orange,
                                body: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Center(
                                    child: Text(
                                      'Thời gian của chuyến đi phải sau thời điểm hiện tại ít nhất 1 giờ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                btnOkOnPress: () {
                                  _selectTime = TimeOfDay.fromDateTime(
                                      DateTime.now()
                                          .add(const Duration(hours: 1)));
                                  _timeController.text = DateFormat.Hm().format(
                                      DateTime(0, 0, 0, _selectTime.hour,
                                          _selectTime.minute));
                                  sharedPreferences.setString(
                                      'plan_start_time', _timeController.text);
                                }).show();
                          } else {
                            _selectTime = value;
                            _timeController.text = DateFormat.Hm().format(
                                DateTime(0, 0, 0, _selectTime.hour,
                                    _selectTime.minute));
                            sharedPreferences.setString(
                                'plan_start_time', _timeController.text);
                            sharedPreferences.setBool('plan_is_change', false);
                          }
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
            height: 1.h,
          ),
          SizedBox(
            height: 58.h,
            child: Stack(
              children: [
                SizedBox(
                  child: MapWidget(
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
                      await _onSelectLocation(
                          PointLatLng(coordinate.x, coordinate.y));
                    },
                    textureView: false,
                    onMapCreated: _onMapCreated,
                  ),
                ),
                if (distanceText != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.all(2.h),
                      child: buildMapInfoWidget(),
                    ),
                  ),
                Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Padding(
                      padding: EdgeInsets.all(2.h),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(14))),
                        child: TextField(
                          controller: _searchController,
                          keyboardType: TextInputType.streetAddress,
                          cursorColor: primaryColor,
                          maxLines: 1,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: onSearchLocation,
                                  icon: const Icon(
                                    Icons.search,
                                    color: primaryColor,
                                    size: 32,
                                  )),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: primaryColor, width: 2),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(14))),
                              border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 2),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(14)))),
                        ),
                      ),
                    )),
                if (isShowResult)
                  Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.h),
                        child: Container(
                          margin: const EdgeInsets.only(top: 100),
                          child: Column(children: [
                            for (final rs in _resultList)
                              InkWell(
                                onTap: () async {
                                  if (_circleAnnotationManagerStart != null) {
                                    await _circleAnnotationManagerStart!
                                        .deleteAll();
                                  }
                                  await _onSelectLocation(
                                      PointLatLng(rs.lat, rs.lng));

                                  setState(() {
                                    isShowResult = false;
                                  });
                                },
                                child: Container(
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.92),
                                      borderRadius: rs == _resultList.first
                                          ? const BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14))
                                          : rs == _resultList.last
                                              ? const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(14),
                                                  bottomRight:
                                                      Radius.circular(14))
                                              : const BorderRadius.all(
                                                  Radius.zero)),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Spacer(),
                                        const Spacer(),
                                        Text(
                                          rs.name,
                                          style: const TextStyle(fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        const Spacer(),
                                        Text(
                                          rs.address,
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Container(
                                          color: Colors.grey,
                                          height: 1,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                          ]),
                        ),
                      ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  onSearchLocation() async {
    if (_searchController.text.trim().isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Hãy nhập nội dung tìm kiếm',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        btnOkColor: Colors.orange,
        btnOkText: 'Ok',
        btnOkOnPress: () {},
      ).show();
    } else {
      var result = await getSearchResult(_searchController.text);
      if (result == [] || result == null) {
        // ignore: use_build_context_synchronously
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          body: const Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Không tìm thấy địa điểm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Hãy tìm kiếm địa điểm khác',
                  style: TextStyle(fontSize: 18),
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
        List<SearchStartLocationResult> resultList =
            List<SearchStartLocationResult>.from(result["results"]
                .map((e) => SearchStartLocationResult.fromJson(e))).toList();
        setState(() {
          _resultList = resultList;
          isShowResult = true;
        });
      }
    }
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
          'Khoảng cách: $distanceText',
          style: const TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 1.h,
        ),
        Text(
          'Thời gian di chuyển: $durationText (dự kiến)',
          style: const TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 1.h,
        ),
      ]),
    );
  }
}
