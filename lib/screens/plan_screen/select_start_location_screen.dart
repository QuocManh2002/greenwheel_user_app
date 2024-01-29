import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/locate_start_location.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/search_start_location_result.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/search_location_result_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
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
  bool _isSearching = false;
  String? defaultAddress = '';
  PointLatLng? defaultLatLng ;
  PointLatLng? _selectedLatLng;

  Future<void> getMapInfo() async {
    if (_selectedLocation != null) {
      _onSelectLocation(_selectedLocation!);
    }
  }

  _getRouteInfo() async {
    var jsonResponse = await getRouteInfo(_selectedLocation!,
        PointLatLng(widget.location.latitude, widget.location.longitude));

    // var route = jsonResponse['routes'][0]['overview_polyline']['points'];
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
      _getRouteInfo();
    }
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
    int _memberLimit = sharedPreferences.getInt('plan_number_of_member')!;
    defaultAddress = sharedPreferences.getString('defaultAddress');
    final defaultCoordinate = sharedPreferences.getStringList('defaultCoordinate');
    defaultLatLng = PointLatLng(double.parse(defaultCoordinate![0]), double.parse(defaultCoordinate[1]));
    double? plan_distance = sharedPreferences.getDouble('plan_distance_value');
    if (plan_distance != null) {
      double? plan_duration =
          sharedPreferences.getDouble('plan_duration_value');
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
        _timeController.text = DateFormat.Hm().format(initialDateTime);
      });
    } else {
      _selectTime =
          TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 3)));
      _timeController.text = DateFormat.Hm()
          .format(DateTime(0, 0, 0, _selectTime.hour, _selectTime.minute));
      sharedPreferences.setString('plan_start_time', _timeController.text);
    }

    String? dateText = sharedPreferences.getString('plan_departureDate');
    if (dateText != null) {
      setState(() {
        _selectedDate = DateTime.parse(dateText);
        // sharedPreferences.setString('plan_departureDate', dateText);
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    } else {
      if(_memberLimit == 1){
        _selectedDate = DateTime.now().add(const Duration(hours: 2));
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
         sharedPreferences.setString(
          'plan_start_date', _selectedDate!.toLocal().toString().split(' ')[0]);
      final defaultDepartureDate = DateTime(
              _selectedDate!.year, _selectedDate!.month, _selectedDate!.day)
          .add(Duration(hours: _selectTime.hour))
          .add(Duration(minutes: _selectTime.minute));
      sharedPreferences.setString(
          'plan_departureDate', defaultDepartureDate.toString());
      }else{
        final closeRegDate = DateTime.parse(sharedPreferences.getString('plan_closeRegDate')!);
        _selectedDate = closeRegDate.add(const Duration(days: 4));
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
         sharedPreferences.setString(
          'plan_start_date', _selectedDate!.toLocal().toString().split(' ')[0]);
      final defaultDepartureDate = DateTime(
              _selectedDate!.year, _selectedDate!.month, _selectedDate!.day)
          .add(Duration(hours: _selectTime.hour))
          .add(Duration(minutes: _selectTime.minute));
      sharedPreferences.setString(
          'plan_departureDate', defaultDepartureDate.toString());
      }     
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 2.h,
                ),
                const Text(
                  'Thời gian xuất phát',
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
                                  initialDate: _selectedDate,
                                  firstDate: _selectedDate!,
                                  lastDate: _selectedDate!.add(const Duration(days: 830)),
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
                                        firstDate: _selectedDate!,
                                        lastDate:  _selectedDate!.add(const Duration(days: 830)),
                                      ),
                                    );
                                  });
                              if (newDay != null) {
                                _selectedDate = newDay;
                                _dateController.text =
                                    DateFormat('dd/MM/yyyy').format(newDay);
                                sharedPreferences.setString(
                                    'plan_start_date', newDay.toString());
                                sharedPreferences.setString(
                                    'plan_departureDate', newDay.toString());
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
                                    DateTime(
                                        _selectedDate!.year,
                                        _selectedDate!.month,
                                        _selectedDate!.day))) {
                                  AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      btnOkColor: Colors.orange,
                                      body: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
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
                                        _timeController.text = DateFormat.Hm()
                                            .format(DateTime(
                                                0,
                                                0,
                                                0,
                                                _selectTime.hour,
                                                _selectTime.minute));
                                        sharedPreferences.setString(
                                            'plan_start_time',
                                            _timeController.text);
                                      }).show();
                                } else {
                                  _selectTime = value;
                                  _timeController.text = DateFormat.Hm().format(
                                      DateTime(0, 0, 0, _selectTime.hour,
                                          _selectTime.minute));
                                  sharedPreferences.setString(
                                      'plan_start_time', _timeController.text);
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
                  height: 2.h,
                ),
                const Text(
                  'Địa điểm xuất phát',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Padding(
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
                      onTap: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
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
                ),
                if (_isSearching)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.h),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      onTap: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.text =
                              defaultAddress == null || defaultAddress!.isEmpty
                                  ? 'Không có dữ liệu'
                                  : defaultAddress!;
                          _onSelectLocation(defaultLatLng!);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(14),
                          ),
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 1),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 3,
                              color: Colors.black12,
                              offset: Offset(1, 3),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(children: [
                            Icon(Icons.my_location,
                                color: redColor.withOpacity(0.8), size: 32),
                            SizedBox(
                              width: 2.w,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 4,
                                ),
                                const Text(
                                  'Vị trí mặc định',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 75.w,
                                  child: Text(
                                    defaultAddress == null ||
                                            defaultAddress!.isEmpty
                                        ? 'Không có dữ liệu'
                                        : defaultAddress!,
                                    style: const TextStyle(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                )
                              ],
                            )
                          ]),
                        ),
                      ),
                    ),
                  ),
                if (isShowResult)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(14)),
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.5), width: 1),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.black12,
                            offset: Offset(1, 3),
                          )
                        ],
                      ),
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
                                  _searchController.text = rs.address;
                                });
                              },
                              child: SearchLocationResultCard(
                                item: rs,
                                list: _resultList,
                              ))
                      ]),
                    ),
                  ),
                if (_isSearching || isShowResult)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => LocateStartLocation(
                                  location: widget.location,
                                  callback: callback,
                                )));
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(14),
                          ),
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 1),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 3,
                              color: Colors.black12,
                              offset: Offset(1, 3),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(children: [
                            const Icon(
                              Icons.map,
                              size: 32,
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            const Text(
                              'Chọn từ bản đồ',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )
                          ]),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
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
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: primaryColor, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: const [
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

  callback(PointLatLng? point) async {
    var result = await getPlaceDetail(point!);
    if (result != null) {
      setState(() {
        _selectedLatLng = point;
        _searchController.text = result['results'][0]['formatted_address'];
      });
    }
  }
}
