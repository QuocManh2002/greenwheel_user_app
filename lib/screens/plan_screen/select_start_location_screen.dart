import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/direction_handler.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/search_start_location_result.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
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
  TextEditingController _searchController = TextEditingController();
  Location _locationController = new Location();
  bool isLoading = true;
  LatLng _currentP = LatLng(0, 0);
  num distance = 0;
  num duration = 0;
  List<SearchStartLocationResult> _resultList = [];
  bool isShowResult = false;
  TimeOfDay _selectTime = TimeOfDay.now();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();

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
    // if(sharedPreferences.getString('symbolId') != null){
    //   controller.addSymbolLayer(
    //     sharedPreferences.getString('symbolId')!,
    //     sharedPreferences.getString('symbolId')!,
    //     SymbolLayerProperties(iconImage: SvgPicture.asset(to_marker)));
    // }
    await controller.addSymbol(SymbolOptions(
        geometry: _currentP, iconSize: 2, iconImage: current_location));
    await controller.addSymbol(SymbolOptions(
        geometry: LatLng(widget.location.latitude, widget.location.longitude),
        iconSize: 2,
        iconImage: to_location));

    final lat = sharedPreferences.getDouble('plan_start_lat');
    final lng = sharedPreferences.getDouble('plan_start_lng');
    if (lat != null) {
      Symbol symbol = await controller.addSymbol(SymbolOptions(
          geometry: LatLng(lat, lng!), iconSize: 2, iconImage: from_location));
      sharedPreferences.setString('symbolId', symbol.id);
    }
  }

  _onSelectLocation(LatLng _selectedLocation) async {
    if (!await Utils().CheckLoationInSouthSide(
        lon: _selectedLocation.longitude, lat: _selectedLocation.latitude)) {
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
      String? symbolId = sharedPreferences.getString('symbolId');
      if (symbolId != null) {
        controller.removeSymbol(Symbol(symbolId, SymbolOptions.defaultOptions));
      }
      SymbolOptions options = SymbolOptions(
          geometry: _selectedLocation, iconSize: 2, iconImage: from_location);
      Symbol symbol = await controller.addSymbol(options);
      getMapInfo(_selectedLocation);
      sharedPreferences.setString('symbolId', symbol.id);
    }
    sharedPreferences.setBool('plan_is_change', false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationUpdates();
    setUpData();
  }

  setUpData() {
    double? plan_distance = sharedPreferences.getDouble('plan_distance');
    if (plan_distance != null) {
      double? plan_duration = sharedPreferences.getDouble('plan_duration');
      setState(() {
        duration = plan_duration!;
        distance = plan_distance;
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
                          sharedPreferences.setBool('plan_is_change', false);
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
            height: 60.h,
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
                    _onSelectLocation(coordinates);
                  },
                  onStyleLoadedCallback: _onStyleLoadedCallback,
                  minMaxZoomPreference: const MinMaxZoomPreference(2, 17),
                  myLocationRenderMode: MyLocationRenderMode.NORMAL,
                ),
                if (distance != 0)
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
                                onTap: () {
                                  _onSelectLocation(LatLng(rs.lat, rs.lng));
                                  controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: LatLng(rs.lat, rs.lng),
                                              zoom: 15)));
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
                                        ),                                                                              const Spacer(),
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
