import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/direction_handler.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/search_start_location_result.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:flutter/services.dart' show rootBundle;

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
    if (lat != null) {
      Symbol symbol = await controller.addSymbol(SymbolOptions(
          geometry: LatLng(lat, lng!), iconSize: 5, iconImage: from_location));
      sharedPreferences.setString('symbolId', symbol.id);
    }
  }

  _onSelectLocation(LatLng _selectedLocation) async {
    if (!await Utils().test(
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
          geometry: _selectedLocation, iconSize: 5, iconImage: from_location);
      Symbol symbol = await controller.addSymbol(options);
      getMapInfo(_selectedLocation);
      sharedPreferences.setString('symbolId', symbol.id);
    }
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
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 1.h,
          ),
          const Text(
            'Chọn địa điểm xuất phát',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 1.h,
          ),
          SizedBox(
            height: 65.h,
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
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          rs.name,
                                          style: const TextStyle(fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
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

      // List<SearchStartLocationResult> validList = [];

      // for (final rs in resultList) {
      //   if (await checkValidLatLngInVietNam(LatLng(rs.lat, rs.lng))) {
      //     validList.add(rs);
      //   }
      // }
      // if (validList.isEmpty) {
      //   // ignore: use_build_context_synchronously
      //   AwesomeDialog(
      //     context: context,
      //     dialogType: DialogType.warning,
      //     body: const Center(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           Text(
      //             'Xin hãy chọn địa điểm trong lãnh thổ Việt Nam',
      //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //             textAlign: TextAlign.center,
      //           ),
      //           SizedBox(
      //             height: 16,
      //           ),
      //         ],
      //       ),
      //     ),
      //     btnOkOnPress: () {},
      //     btnOkColor: Colors.orange,
      //     btnOkText: 'Ok',
      //   ).show();
      // } else {
        setState(() {
          _resultList = resultList;
          isShowResult = true;
        });
      // }
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

  checkValidLatLngInVietNam(LatLng location) async {
    final geo = GeoJson();
    String geoString = await rootBundle
        .loadString('assets/geojson/vietnam_boundaries.geojson');
    await geo.parse(geoString, verbose: true);
    bool isWithinMultiPolygon = false;
    await geo.processedMultiPolygons.listen((GeoJsonMultiPolygon multiPolygon) {
      List<List<LatLng>> polygonCoordinates = [];
      multiPolygon.polygons.forEach((polygon) {
        List<LatLng> coordinates = [];
        polygon.geoSeries.forEach((geoSerie) {
          geoSerie.geoPoints.forEach((geoPoint) {
            coordinates.add(LatLng(geoPoint.latitude, geoPoint.longitude));
          });
        });
        polygonCoordinates.add(coordinates);
      });
      isWithinMultiPolygon =
          isPointInMultiPolygon(location, polygonCoordinates);
    });
    await geo.parse(geoString);
    print(isWithinMultiPolygon);
    return isWithinMultiPolygon;
  }

  bool isPointInMultiPolygon(
      LatLng point, List<List<LatLng>> polygonCoordinates) {
    for (var polygon in polygonCoordinates) {
      if (isPointInPolygon(point, polygon)) {
        return true;
      }
    }
    return false;
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      LatLng vertex1 = polygon[i];
      LatLng vertex2 = polygon[(i + 1) % polygon.length];
      if (((vertex1.latitude >= point.latitude &&
                  vertex2.latitude < point.latitude) ||
              (vertex1.latitude < point.latitude &&
                  vertex2.latitude >= point.latitude)) &&
          (point.longitude <
              (vertex2.longitude - vertex1.longitude) *
                      (point.latitude - vertex1.latitude) /
                      (vertex2.latitude - vertex1.latitude) +
                  vertex1.longitude)) {
        intersections++;
      }
    }
    return intersections % 2 == 1;
  }
}
