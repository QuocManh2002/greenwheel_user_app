import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/search_start_location_result.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:location/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sizer2/sizer2.dart';

class SelectDefaultAddress extends StatefulWidget {
  const SelectDefaultAddress({super.key, required this.callback});
  final void Function(SearchStartLocationResult? selectedLocation,
      PointLatLng? selectLatLng) callback;

  @override
  State<SelectDefaultAddress> createState() => _SelectDefaultAddressState();
}

class _SelectDefaultAddressState extends State<SelectDefaultAddress> {
  MapboxMap? _mapboxMap;
  final Location _locationController = Location();
  PointLatLng? _currentLocation;
  CircleAnnotationManager? _circleAnnotationSelected;
  final PointLatLng _defaultLocation = const PointLatLng(10.8406, 106.8117);
  final TextEditingController _searchController = TextEditingController();
  bool _isShowResult = false;
  List<SearchStartLocationResult> _resultList = [];
  bool _isSelected = false;
  SearchStartLocationResult? _selectedSearchResult;
  PointLatLng? _selectedLatLng;

  _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
  }

  Future<void> requirePermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    }
    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
    }

    if (permissionGranted == PermissionStatus.granted) {
      LocationData locationData = await _locationController.getLocation();
      if (locationData.latitude != null) {
        setState(() {
          _currentLocation =
              PointLatLng(locationData.latitude!, locationData.longitude!);
          getMapStyle();
        });
      }
    }
  }

  getMapStyle() {
    _mapboxMap!.setCamera(CameraOptions(
        center: Point(
                coordinates: Position(
                    _currentLocation!.longitude, _currentLocation!.latitude))
            ,
        zoom: 14));

    _mapboxMap?.flyTo(
        CameraOptions(
            anchor: ScreenCoordinate(x: 0, y: 0),
            zoom: 12,
            bearing: 0,
            pitch: 0),
        MapAnimationOptions(duration: 1000, startDelay: 0));

    _mapboxMap?.annotations.createCircleAnnotationManager().then((value) async {
      setState(() {
// Store the reference to the circle annotation manager
      });
      value.create(
        CircleAnnotationOptions(
          geometry: Point(
                  coordinates: Position(
                      _currentLocation!.longitude, _currentLocation!.latitude))
              ,
          circleColor: primaryColor.value,
          circleRadius: 12.0,
        ),
      );
    });
  }

  _onSelectLocation(PointLatLng selectedLocation) async {
    if (!await Utils().checkLoationInSouthSide(
        lon: selectedLocation.longitude, lat: selectedLocation.latitude)) {
      AwesomeDialog(
        // ignore: use_build_context_synchronously
        context: context,
        dialogType: DialogType.warning,
        body: const Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Xin hãy chọn địa điểm trong khu vực miền Nam lãnh thổ Việt Nam',
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
      _mapboxMap!.setCamera(CameraOptions(
          center: Point(
                  coordinates: Position(
                      selectedLocation.longitude, selectedLocation.latitude))
              ,
          zoom: 12));
      _mapboxMap?.flyTo(
          CameraOptions(
              anchor: ScreenCoordinate(x: 0, y: 0),
              zoom: 10,
              bearing: 0,
              pitch: 0),
          MapAnimationOptions(duration: 2000, startDelay: 0));

      _mapboxMap?.annotations
          .createCircleAnnotationManager()
          .then((value) async {
        setState(() {
          _isSelected = true;
          _circleAnnotationSelected =
              value; // Store the reference to the circle annotation manager
        });
        value.create(
          CircleAnnotationOptions(
            geometry: Point(
                    coordinates: Position(
                        selectedLocation.longitude, selectedLocation.latitude))
                ,
            circleColor: Colors.blue.value,
            circleRadius: 12.0,
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    requirePermission();
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
        AwesomeDialog(
          // ignore: use_build_context_synchronously
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
          _isShowResult = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Địa chỉ người dùng',
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: const ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.white)),
        ),
      ),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey('mapWidget'),
            cameraOptions: CameraOptions(
                center: Point(
                        coordinates: Position(_defaultLocation.longitude,
                            _defaultLocation.latitude))
                    ,
                zoom: 11),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            textureView: false,
            onTapListener: (coordinate) async {
              if (_circleAnnotationSelected != null) {
                await _circleAnnotationSelected!.deleteAll();
              }
              _selectedSearchResult = null;
              _selectedLatLng = PointLatLng(coordinate.point.coordinates.lat.toDouble(), coordinate.point.coordinates.lng.toDouble());
              await _onSelectLocation(PointLatLng(coordinate.point.coordinates.lat.toDouble(), coordinate.point.coordinates.lng.toDouble()));
            },
            onMapCreated: _onMapCreated,
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
          if (_isSelected)
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.h),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 50),
                    child: ElevatedButton(
                        style: elevatedButtonStyle,
                        onPressed: () {
                          if (_selectedSearchResult != null) {
                            widget.callback(_selectedSearchResult!, null);
                          } else {
                            widget.callback(null, _selectedLatLng!);
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('Lưu')),
                  ),
                )),
          if (_isShowResult)
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
                            if (_circleAnnotationSelected != null) {
                              await _circleAnnotationSelected!.deleteAll();
                            }
                            await _onSelectLocation(
                                PointLatLng(rs.lat, rs.lng));

                            setState(() {
                              _isShowResult = false;
                              _selectedSearchResult = rs;
                              _selectedLatLng = null;
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
                                            bottomLeft: Radius.circular(14),
                                            bottomRight: Radius.circular(14))
                                        : const BorderRadius.all(Radius.zero)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
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
    ));
  }
}
