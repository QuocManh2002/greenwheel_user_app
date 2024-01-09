import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jts/dart_jts.dart';
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

  List<PlanScheduleItem> sortByTime(List<PlanScheduleItem> list) {
    list.sort(
      (a, b) {
        var adate = DateTime(0, 0, 0, a.time.hour, a.time.minute);
        var bdate = DateTime(0, 0, 0, b.time.hour, b.time.minute);
        return adate.compareTo(bdate);
      },
    );
    return list;
  }

  void clearPlanSharePref() {
    sharedPreferences.setInt("planId", 0);
    sharedPreferences.remove('plan_number_of_member');
    sharedPreferences.remove("plan_combo_date");
    sharedPreferences.remove("plan_start_lat");
    sharedPreferences.remove("plan_start_lng");
    sharedPreferences.remove("plan_start_time");
    sharedPreferences.remove("plan_distance");
    sharedPreferences.remove("plan_duration");
    sharedPreferences.remove('plan_start_date');
    sharedPreferences.remove('plan_is_change');
    sharedPreferences.remove('plan_end_date');
    sharedPreferences.remove('plan_schedule');
    sharedPreferences.remove('plan_saved_emergency');
    sharedPreferences.remove('numOfExpPeriod');
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

  Future<bool> test({required double lon, required double lat}) async {
  // var file = File('./geojson/vnmgeojson.wkt');
  String geoString = await rootBundle
        .loadString('assets/geojson/vnmgeojson.wkt');
  // var text = await file.readAsString();
  var factory = GeometryFactory.withPrecisionModelSrid(PrecisionModel.fromType(PrecisionModel.FLOATING), 4326);
  var reader = WKTReader.withFactory(factory);
  var features = reader.read(geoString);
  var coordinate = Coordinate(lon, lat);
  var point = factory.createPoint(coordinate);
  print('Test result: ${features!.contains(point)}');
  return features.contains(point);
}
}
