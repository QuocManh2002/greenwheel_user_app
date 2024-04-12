import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class Utils {
  static List<Widget> modelBuilder<M>(
          List<M> models, Widget Function(int index, M model) builder) =>
      models
          .asMap()
          .map<int, Widget>(
              (index, model) => MapEntry(index, builder(index, model)))
          .values
          .toList();

  TimeOfDay convertStringToTime(String timeString) {
    final initialDateTime = DateFormat.Hms().parse(timeString);
    return TimeOfDay.fromDateTime(initialDateTime);
  }

  void clearPlanSharePref() {
    sharedPreferences.setInt("planId", 0);
    sharedPreferences.remove('plan_number_of_member');
    sharedPreferences.remove("plan_combo_date");
    sharedPreferences.remove("plan_start_lat");
    sharedPreferences.remove("plan_start_lng");
    sharedPreferences.remove("plan_start_time");
    sharedPreferences.remove("plan_distance_text");
    sharedPreferences.remove("plan_duration_text");
    sharedPreferences.remove("plan_distance_value");
    sharedPreferences.remove("plan_duration_value");
    sharedPreferences.remove('plan_start_date');
    sharedPreferences.remove('plan_end_date');
    sharedPreferences.remove('plan_schedule');
    sharedPreferences.remove('plan_saved_emergency');
    sharedPreferences.remove('numOfExpPeriod');
    sharedPreferences.remove('plan_departureDate');
    sharedPreferences.remove('plan_closeRegDate');
    sharedPreferences.remove('plan_budget');
    sharedPreferences.remove('plan_name');
    sharedPreferences.remove('plan_start_address');
    sharedPreferences.remove('plan_temp_order');
    sharedPreferences.remove('selectedIndex');
    sharedPreferences.remove('plan_weight');
    sharedPreferences.remove('plan_note');
    sharedPreferences.remove('plan_surcharge');
    sharedPreferences.remove('notAskScheduleAgain');
    sharedPreferences.remove('initNumOfExpPeriod');
    sharedPreferences.remove('plan_max_member_weight');
    sharedPreferences.remove('plan_location_name');
    sharedPreferences.remove('plan_location_id');
    sharedPreferences.remove('plan_arrivedTime');
  }

  Future<String> getImageBase64Encoded(String imageUrl) async {
    var rsBytes;
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      rsBytes = response.bodyBytes;
      return base64Encode(rsBytes);
    } else {
      throw Exception('Failed to load image: $imageUrl');
    }
  }

  bool checkTimeAfterNow1Hour(TimeOfDay time, DateTime dateTime) {
    print(dateTime
        .add(Duration(hours: time.hour))
        .add(Duration(minutes: time.minute)));
    print(DateTime.now().add(const Duration(minutes: 59)));
    print(dateTime
        .add(Duration(hours: time.hour))
        .add(Duration(minutes: time.minute))
        .isAfter(DateTime.now().add(const Duration(minutes: 59))));
    return dateTime
        .add(Duration(hours: time.hour))
        .add(Duration(minutes: time.minute))
        .isAfter(DateTime.now().add(const Duration(minutes: 59)));
  }

  Future<bool> CheckLoationInSouthSide(
      {required double lon, required double lat}) async {
    String geoString =
        await rootBundle.loadString('assets/geojson/southside.wkt');
    var factory = GeometryFactory.withPrecisionModelSrid(
        PrecisionModel.fromType(PrecisionModel.FLOATING), 4326);
    var reader = WKTReader.withFactory(factory);
    var features = reader.read(geoString);
    var coordinate = Coordinate(lon, lat);
    var point = factory.createPoint(coordinate);
    print('Test result: ${features!.contains(point)}');
    return features.contains(point);
  }

  SaveDefaultAddressToSharedPref(
      String addressText, PointLatLng addressLatLng) {
    sharedPreferences.setString('defaultAddress', addressText);
    sharedPreferences.setStringList('defaultCoordinate', [
      addressLatLng.latitude.toString(),
      addressLatLng.longitude.toString()
    ]);
  }

  ShowFullyActivityTimeDialog(BuildContext context) {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        btnOkColor: Colors.orange,
        btnOkText: 'Ok',
        btnOkOnPress: () {},
        body: const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Đã đủ thời gian quy định cho hoạt động của ngày này',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        )).show();
  }

  bool IsValidSentence(String sentence) {
    List<String> words = sentence.split(' ');
    Map<String, int> wordFrequency = {};
    for (String word in words) {
      wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
      if (wordFrequency[word]! >= 3) {
        return false;
      }
    }
    return true;
  }

  bool _isValidSentence(String sentence) {
    List<String> words = sentence.split(' ');
    Map<String, int> wordFrequency = {};

    for (String word in words) {
      wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
      if (wordFrequency[word]! >= 3) {
        return false;
      }
    }

    return true;
  }

  handleServerException(String content, BuildContext context) {
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            dialogType: DialogType.error,
            title: content,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            titleTextStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            btnOkColor: Colors.red,
            btnOkText: 'Ok',
            btnOkOnPress: () {})
        .show();
  }

  getPeriodString(String period) {
    Map rs = {};
    switch (period) {
      case 'MORNING':
        rs = {'text': 'Sáng', 'value': 1};
        break;
      case 'NOON':
        rs = {'text': 'Trưa', 'value': 2};
        break;
      case 'AFTERNOON':
        rs = {'text': 'Chiều', 'value': 3};
        break;
      case 'EVENING':
        rs = {'text': 'Tối', 'value': 4};
        break;
    }
    return rs;
  }

  buildTextFromListString(List<dynamic> list) {
    var rs = '';
    for (final item in list) {
      if (item == list.last || list.length == 1) {
        rs += item!;
      } else {
        rs += '$item, ';
      }
    }
    return rs;
  }

  sortPeriodList(List<dynamic> list) =>
      list.sort((a, b) => a['value'].compareTo(b['value']));

  Widget buildIndicator(int index, int currentIndex) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceInOut,
      height: 0,
      margin: const EdgeInsets.only(left: 16),
      width: currentIndex == index ? 35 : 12,
      decoration: BoxDecoration(
          color: currentIndex == index
              ? primaryColor
              : primaryColor.withOpacity(0.7),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, offset: Offset(2, 3), blurRadius: 3)
          ]),
    );
  }

  getSupplierType(String input) {
    switch (input) {
      case "FOOD_STALL":
        return "quán ăn";
      case "GROCERY_STORE":
        return "tạp hoá";
      case "HOTEL":
        return 'khách sạn';
      case "MOTEL":
        return 'nhà nghỉ';
      case "REPAIR_SHOP":
        return 'tiệm sửa xe';
      case "RESTAURANT":
        return 'nhà hàng';
      case "VEHICLE_RENTAL":
        return "Thuê xe";
    }
  }

  buildServingDatesText(List<dynamic> serveDateIndexes) {
    if (serveDateIndexes.length == 1) {
      return DateFormat('dd/MM').format(DateTime.parse(serveDateIndexes[0]));
    } else {
      return '${DateFormat('dd/MM').format(DateTime.parse(serveDateIndexes[0]))} (+${serveDateIndexes.length - 1} N)';
    }
  }

  getNumOfExpPeriod(DateTime? arrivedTime, int initNumOfExpPeriod,
      DateTime startTime, DateTime? travelDuration, bool isCreate) {
    final _startTime = DateTime(0, 0, 0, startTime.hour, startTime.minute);
    final _arrivedTime = arrivedTime ??
        _startTime
            .add(Duration(hours: travelDuration!.hour))
            .add(Duration(minutes: travelDuration.minute));
    if (_arrivedTime.isAfter(DateTime(0, 0, 0, 16, 0)) &&
        _arrivedTime.isBefore(DateTime(0, 0, 1, 6, 0))) {
      if (_arrivedTime.isBefore(DateTime(0, 0, 0, 20, 0))) {
        return {
          'numOfExpPeriod':
              isCreate ? initNumOfExpPeriod + 1 : initNumOfExpPeriod - 1,
          'isOverDate': false
        };
      } else {
        return {'numOfExpPeriod': initNumOfExpPeriod, 'isOverDate': true};
      }
    } else {
      return {'numOfExpPeriod': initNumOfExpPeriod, 'isOverDate': false};
    }
  }

  isEndAtNoon() {
    final DateTime _arrivedTime =
        DateTime.parse(sharedPreferences.getString('plan_arrivedTime')!);
    var dayEqualNight =
        sharedPreferences.getInt('initNumOfExpPeriod')! % 2 == 0;
    var arrivedAtNight = _arrivedTime.hour >= 20;
    var arrivedAtEvening = !arrivedAtNight && _arrivedTime.hour >= 16;
    return (arrivedAtEvening && dayEqualNight) ||
        (!arrivedAtEvening && !dayEqualNight);
  }
}
