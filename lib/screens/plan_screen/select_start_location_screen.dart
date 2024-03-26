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
import 'package:greenwheel_user_app/helpers/util.dart';
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
  var distanceText = '';
  var durationText = '';
  var distanceValue;
  var durationValue;
  List<SearchStartLocationResult> _resultList = [];
  bool isShowResult = false;
  CircleAnnotationManager? _circleAnnotationManagerStart;
  PolylinePoints polylinePoints = PolylinePoints();
  PointLatLng? _selectedLocation;
  bool _isSearching = false;
  String? defaultAddress = '';
  PointLatLng? defaultLatLng;
  PointLatLng? _selectedLatLng;
  bool _isSelectedLocation = false;

  Future<void> getMapInfo() async {
    if (_selectedLocation != null) {
      _onSelectLocation(_selectedLocation!);
    }
  }

  _getRouteInfo() async {
    var jsonResponse = await getRouteInfo(_selectedLocation!,
        PointLatLng(widget.location.latitude, widget.location.longitude));
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
      setState(() {
        _isSelectedLocation = true;
      });
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
    defaultAddress = sharedPreferences.getString('defaultAddress');
    final defaultCoordinate =
        sharedPreferences.getStringList('defaultCoordinate');
    defaultLatLng = PointLatLng(double.parse(defaultCoordinate![0]),
        double.parse(defaultCoordinate[1]));
    double? plan_distance = sharedPreferences.getDouble('plan_distance_value');
    if (plan_distance != null) {
      double? plan_duration =
          sharedPreferences.getDouble('plan_duration_value');
      setState(() {
        durationValue = plan_duration!;
        distanceValue = plan_distance;
      });
    }
    double? startLat = sharedPreferences.getDouble('plan_start_lat');
    if (startLat != null) {
      double? startLng = sharedPreferences.getDouble('plan_start_lng');
      _selectedLocation = PointLatLng(startLat, startLng!);
      distanceText = sharedPreferences.getString('plan_distance_text')!;
      distanceValue = sharedPreferences.getDouble('plan_distance_value');
      durationText = sharedPreferences.getString('plan_duration_text')!;
      durationValue = sharedPreferences.getDouble('plan_duration_value');
      setState(() {
        _searchController.text =
            sharedPreferences.getString('plan_start_address')!;
        _isSelectedLocation = true;
      });
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
                  height: 1.h,
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
                      autofocus: true,
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
                        sharedPreferences.setString(
                            'plan_start_address',
                            defaultAddress == null || defaultAddress!.isEmpty
                                ? 'Không có dữ liệu'
                                : defaultAddress!);
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
                                    fontSize: 13, fontWeight: FontWeight.bold),
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
                // if (_isSearching || isShowResult)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
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
                ),

                if (_isSelectedLocation)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.h, vertical: 0.5.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(children: [
                          const Icon(
                            Icons.directions_car,
                            size: 32,
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          const Text(
                            'Quãng đường di chuyển',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            distanceText == '' || distanceText == 'null'
                                ? ''
                                : distanceText,
                            style: const TextStyle(fontSize: 15),
                          ),
                          SizedBox(
                            width: 1.h,
                          )
                        ]),
                      ),
                    ),
                  ),
                if (_isSelectedLocation)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.h, vertical: 0.5.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(children: [
                          const Icon(
                            Icons.watch_later,
                            size: 32,
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          const Text(
                            'Thời gian di chuyển',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            '$durationText',
                            style: const TextStyle(fontSize: 15),
                          ),
                          SizedBox(
                            width: 1.h,
                          )
                        ]),
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
      _onSelectLocation(point);
      sharedPreferences.setString('plan_start_address', _searchController.text);
    }
  }
}
