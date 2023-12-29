import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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
}
