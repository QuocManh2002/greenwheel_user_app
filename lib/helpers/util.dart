import 'dart:convert';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:phuot_app/service/config_service.dart';

import '../core/constants/colors.dart';
import '../core/constants/global_constant.dart';
import '../core/constants/sessions.dart';
import '../main.dart';
import '../models/holiday.dart';
import '../service/traveler_service.dart';
import '../view_models/customer.dart';
import '../view_models/plan_viewmodels/plan_create.dart';
import '../view_models/plan_viewmodels/plan_schedule.dart';
import '../view_models/plan_viewmodels/plan_schedule_item.dart';
import '../view_models/plan_viewmodels/search_start_location_result.dart';
import '../widgets/style_widget/dialog_style.dart';
import 'goong_request.dart';

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
    sharedPreferences.remove("plan_distance_text");
    sharedPreferences.remove("plan_duration_text");
    sharedPreferences.remove("plan_distance_value");
    sharedPreferences.remove("plan_duration_value");
    sharedPreferences.remove('plan_start_date');
    sharedPreferences.remove('plan_end_date');
    sharedPreferences.remove('plan_schedule');
    sharedPreferences.remove('plan_saved_emergency');
    sharedPreferences.remove('numOfExpPeriod');
    sharedPreferences.remove("plan_departureTime");
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
    sharedPreferences.remove('plan_sourceId');
    sharedPreferences.remove('plan_clone_options');
    sharedPreferences.remove('maxCombodateValue');
    sharedPreferences.remove('init_plan_number_of_member');
  }

  Future<String> getImageBase64Encoded(String imageUrl) async {
    Uint8List rsBytes;
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      rsBytes = response.bodyBytes;
      return base64Encode(rsBytes);
    } else {
      throw Exception('Failed to load image: $imageUrl');
    }
  }

  bool checkTimeAfterNow1Hour(TimeOfDay time, DateTime dateTime) {
    return dateTime
        .add(Duration(hours: time.hour))
        .add(Duration(minutes: time.minute))
        .isAfter(DateTime.now()
            .add(const Duration(days: 7))
            .add(const Duration(minutes: 59)));
  }

  Future<bool> checkLoationInSouthSide(
      {required double lon, required double lat}) async {
    String geoString =
        await rootBundle.loadString('assets/geojson/southside.wkt');
    var factory = GeometryFactory.withPrecisionModelSrid(
        PrecisionModel.fromType(PrecisionModel.FLOATING), 4326);
    var reader = WKTReader.withFactory(factory);
    var features = reader.read(geoString);
    var coordinate = Coordinate(lon, lat);
    var point = factory.createPoint(coordinate);
    return features!.contains(point);
  }

  saveDefaultAddressToSharedPref(
      String addressText, PointLatLng addressLatLng) {
    sharedPreferences.setString('defaultAddress', addressText);
    sharedPreferences.setStringList('defaultCoordinate', [
      addressLatLng.latitude.toString(),
      addressLatLng.longitude.toString()
    ]);
  }

  showFullyActivityTimeDialog(BuildContext context) {
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

  bool isValidSentence(String sentence) {
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
        return "Thuê phương tiện";
    }
  }

  getNumOfExpPeriod(DateTime? arrivedTime, int initNumOfExpPeriod,
      DateTime startTime, DateTime? travelDuration, bool isCreate) {
    final startDateTime = DateTime(0, 0, 0, startTime.hour, startTime.minute);
    final arrivedDateTime = arrivedTime ??
        startDateTime
            .add(Duration(hours: travelDuration!.hour))
            .add(Duration(minutes: travelDuration.minute));
    if (arrivedDateTime.isAfter(DateTime(0, 0, 0, 16, 0)) &&
        arrivedDateTime.isBefore(DateTime(0, 0, 1, 6, 0))) {
      if (arrivedDateTime.isBefore(DateTime(0, 0, 0, 20, 0))) {
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

  isEndAtNoon(PlanCreate? plan) {
    final DateTime arrivedTime = plan == null
        ? DateTime.parse(sharedPreferences.getString('plan_arrivedTime')!)
        : plan.arrivedAt!;
    var dayEqualNight = (plan == null
            ? sharedPreferences.getInt('initNumOfExpPeriod')!
            : plan.numOfExpPeriod)!
        .isEven;
    var arrivedAtNight = arrivedTime.hour >= 20;
    var arrivedAtEvening = !arrivedAtNight && arrivedTime.hour >= 16;
    return (arrivedAtEvening && dayEqualNight) ||
        (!arrivedAtEvening && !dayEqualNight);
  }

  isConsecutiveDates(List<DateTime> dates) {
    if (dates.length <= 1) {
      return true;
    }
    dates.sort((a, b) => a.compareTo(b));
    for (int i = 1; i < dates.length; i++) {
      DateTime current = dates[i];
      DateTime previous = dates[i - 1];
      if (current.difference(previous).inDays != 1) {
        return false;
      }
    }
    return true;
  }

  getArrivedTimeFromLocal() {
    final initialDateTime =
        DateTime.parse(sharedPreferences.getString('plan_departureTime')!);
    final startTime =
        DateTime(0, 0, 0, initialDateTime.hour, initialDateTime.minute);
    final arrivedTime = startTime.add(Duration(
        seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
            .ceil()));
    return arrivedTime;
  }

  showInvalidScheduleAndServiceClone(BuildContext context) {
    DialogStyle().basicDialog(
      context: context,
      title: 'Không thể sao chép đơn dịch vụ nếu không sao chép lịch trình',
      type: DialogType.warning,
    );
  }

  getHolidayServingDates(List<DateTime> servingDates) {
    List<DateTime> normalServingDates = [];
    List<DateTime> holidayServingDates = [];
    final holidaysText = sharedPreferences.getStringList('HOLIDAYS');
    final holidays =
        holidaysText!.map((e) => Holiday.fromJson(json.decode(e))).toList();
    for (final date in servingDates) {
      if (holidays.any((element) =>
          element.from.isBefore(date) && element.to.isAfter(date) ||
          date.isAtSameMomentAs(element.from) ||
          date.isAtSameMomentAs(element.to))) {
        holidayServingDates.add(date);
      } else {
        normalServingDates.add(date);
      }
    }
    return {
      'normalServingDates': normalServingDates,
      'holidayServingDates': holidayServingDates
    };
  }

  bool isHoliday(
    DateTime date,
  ) {
    final holidaysText = sharedPreferences.getStringList('HOLIDAYS');
    List<Holiday> holidays =
        holidaysText!.map((e) => Holiday.fromJson(json.decode(e))).toList();
    return holidays.any((element) =>
        element.from.isBefore(date) && element.to.isAfter(date) ||
        date.isAtSameMomentAs(element.from) ||
        date.isAtSameMomentAs(element.to));
  }

  int getHolidayUpPct(String type) {
    switch (type) {
      case 'EAT':
        return sharedPreferences.getInt('HOLIDAY_MEAL_UP_PCT')!;
      case 'CHECKIN':
        return sharedPreferences.getInt('HOLIDAY_LODGING_UP_PCT')!;
      case 'VISIT':
        return sharedPreferences.getInt('HOLIDAY_RIDING_UP_PCT')!;
    }
    return 0;
  }

  splitCheckInServeDates(List<String> serveDates) {
    List<List<DateTime>> result = [];
    List<DateTime> current = [DateTime.parse(serveDates[0])];
    for (int i = 1; i < serveDates.length; i++) {
      DateTime previousDateTime = DateTime.parse(serveDates[i - 1]);
      DateTime currentDateTime = DateTime.parse(serveDates[i]);
      if (currentDateTime.difference(previousDateTime).inDays == 1) {
        current.add(currentDateTime);
      } else {
        result.add(current);
        current = [currentDateTime];
      }
    }
    result.add(current);
    return result;
  }

  bool isValidPeriodOfOrder(
      PlanSchedule schedule, PlanScheduleItem item, bool isFirstDay) {
    if (item.orderUUID == null) {
      return true;
    } else {
      final orderList =
          json.decode(sharedPreferences.getString('plan_temp_order')!);
      final order =
          orderList.firstWhere((order) => order['orderUUID'] == item.orderUUID);
      final itemIndex = schedule.items.indexOf(item);
      Duration sumActivityTime = const Duration();
      DateTime? startActivityTime;
      for (int i = 0; i < itemIndex; i++) {
        sumActivityTime += schedule.items[i].activityTime!;
      }
      if (isFirstDay) {
        final arrivedTime =
            DateTime.parse(sharedPreferences.getString('plan_arrivedTime')!);
        if (arrivedTime.hour >= 20) {
          startActivityTime = DateTime(0, 0, 0, 6, 0, 0).add(sumActivityTime);
        } else {
          startActivityTime = arrivedTime.add(sumActivityTime);
        }
      } else {
        startActivityTime = DateTime(0, 0, 0, 6, 0, 0).add(sumActivityTime);
      }
      final startActivitySession = sessions.firstWhereOrNull((aTime) =>
              aTime.from <= startActivityTime!.hour &&
              aTime.to > startActivityTime.hour) ??
          sessions[0];
      final orderPeriod =
          sessions.firstWhere((session) => session.enumName == order['period']);
      return startActivitySession.index <= orderPeriod.index;
    }
  }

  handleNonDefaultAddress(void Function() onOk, BuildContext context) {
    DialogStyle().basicDialog(
        context: context,
        type: DialogType.warning,
        title: 'Không tìm thấy địa chỉ mặc định',
        desc: 'Bạn phải thêm địa chỉ mặc định để thực hiện thao tác này',
        btnOkText: 'Thêm',
        onOk: onOk,
        btnCancelColor: Colors.blue,
        btnCancelText: 'Huỷ');
  }

  callbackSelectDefaultLocation(SearchStartLocationResult? selectedAddress,
      PointLatLng? selectedLatLng, BuildContext context) async {
    bool isValid = false;
    final CustomerService customerService = CustomerService();
    String defaultAddress = '';
    if (selectedAddress != null) {
      if (selectedAddress.address.length < 3 ||
          selectedAddress.address.length > 120) {
        DialogStyle().basicDialog(
            context: context,
            title: 'Độ dài địa chỉ mặc định phải từ 3 - 120 ký tự',
            type: DialogType.warning);
      } else {
        // setState(() {
        defaultAddress = selectedAddress.address;
        // });
        isValid = true;
      }
    } else {
      var result = await getPlaceDetail(selectedLatLng!);
      if (result != null) {
        if (result['results'][0]['formatted_address'].length < 3 ||
            result['results'][0]['formatted_address'].length > 120) {
          DialogStyle().basicDialog(
              // ignore: use_build_context_synchronously
              context: context,
              title: 'Độ dài địa chỉ mặc định phải từ 3 - 120 ký tự',
              type: DialogType.warning);
        } else {
          defaultAddress = result['results'][0]['formatted_address'];
          isValid = true;
        }
      }
    }
    if (isValid) {
      final rs = await customerService.updateTravelerProfile(TravelerViewModel(
          id: 0,
          name: sharedPreferences.getString('userName')!,
          isMale: sharedPreferences.getBool('userIsMale')!,
          avatarUrl: sharedPreferences.getString('userAvatarUrl'),
          phone: sharedPreferences.getString('userPhone')!,
          balance: 0,
          prestigePoint: 0,
          defaultAddress: defaultAddress,
          defaultCoordinate: selectedAddress != null
              ? PointLatLng(selectedAddress.lat, selectedAddress.lng)
              : selectedLatLng));
      if (rs != null) {
        Utils().saveDefaultAddressToSharedPref(
            defaultAddress,
            selectedAddress == null
                ? selectedLatLng!
                : PointLatLng(selectedAddress.lat, selectedAddress.lng));
      }
    }
  }

  getMaxSumActivity(PlanSchedule schedule, bool isFirstDay, bool isLastDay) {
    if (isFirstDay) {
      final startTime =
          DateTime.parse(sharedPreferences.getString('plan_arrivedTime')!);
      if (startTime.hour >= 20 || startTime.hour < 6) {
        return GlobalConstant().MAX_SUM_ACTIVITY_TIME;
      } else {
        return DateTime(0, 0, 0, 22, 0)
            .difference(DateTime(0, 0, 0, startTime.hour, startTime.minute));
      }
    } else if (isLastDay) {
      if (isEndAtNoon(null)) {
        return const Duration(hours: 8);
      } else {
        return const Duration(hours: 14);
      }
    } else {
      return GlobalConstant().MAX_SUM_ACTIVITY_TIME;
    }
  }

  Future<DateTime> getSystemTime(BuildContext context) async {
    ConfigService configService = ConfigService();
    final timeString = await configService.getAdditionalSpan(context);
    List<String>? parts =
        timeString!.contains('.') ? timeString.split(".") : null;
    List<String> timeParts = (parts == null ? timeString : parts[1]).split(":");
    int days = parts == null ? 0 : int.parse(parts[0].split(".")[0]);
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    int seconds = int.parse(timeParts[2]);
    int microseconds =
        parts == null ? 0 : (double.parse("0.${parts.last}") * 1000000).round();

    Duration duration = Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      microseconds: microseconds,
    );
    return DateTime.now().toLocal().add(duration);
  }
}
