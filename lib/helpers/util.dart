import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:greenwheel_user_app/core/constants/sessions.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/select_combo_date_screen.dart';
import 'package:greenwheel_user_app/service/config_service.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/service/product_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:sizer2/sizer2.dart';

import '../models/holiday.dart';

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
    return dateTime
        .add(Duration(hours: time.hour))
        .add(Duration(minutes: time.minute))
        .isAfter(DateTime.now()
            .add(const Duration(days: 7))
            .add(const Duration(minutes: 59)));
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

  isEndAtNoon(PlanCreate? plan) {
    final DateTime _arrivedTime = plan == null
        ? DateTime.parse(sharedPreferences.getString('plan_arrivedTime')!)
        : plan.arrivedAt!;
    var dayEqualNight = (plan == null
            ? sharedPreferences.getInt('initNumOfExpPeriod')!
            : plan.numOfExpPeriod)!
        .isEven;
    var arrivedAtNight = _arrivedTime.hour >= 20;
    var arrivedAtEvening = !arrivedAtNight && _arrivedTime.hour >= 16;
    return (arrivedAtEvening && dayEqualNight) ||
        (!arrivedAtEvening && !dayEqualNight);
  }

  handleUpdatePlanDuration(
      void Function() onOk, void Function() onCancel, BuildContext context) {
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            dialogType: DialogType.warning,
            title: 'Thay đổi quan trọng',
            titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSans'),
            desc:
                'Thay đổi này ảnh hưởng đến lịch trình và các thành phần quan trọng của chuyến đi. Đồng ý với thay đổi, chúng tôi sẽ xoá toàn bộ lịch trình và các thành phần liên quan',
            descTextStyle: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'NotoSans',
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            btnOkText: 'Đồng ý',
            btnOkColor: Colors.amber,
            btnOkOnPress: () {
              sharedPreferences.remove('plan_schedule');
              sharedPreferences.remove('plan_surcharge');
              sharedPreferences.remove('plan_temp_order');
              onOk();
            },
            btnCancelColor: Colors.blueAccent,
            btnCancelOnPress: onCancel,
            btnCancelText: 'Huỷ')
        .show();
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
        DateTime.parse(sharedPreferences.getString('plan_start_time')!);
    final startTime =
        DateTime(0, 0, 0, initialDateTime.hour, initialDateTime.minute);
    final arrivedTime = startTime.add(Duration(
        seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
            .ceil()));
    return arrivedTime;
  }

  setUpDataClonePlan(PlanDetail plan, List<bool> options) {
    OrderService _orderService = OrderService();
    sharedPreferences.setInt('planId', plan.id!);
    sharedPreferences.setString('plan_location_name', plan.locationName!);
    sharedPreferences.setInt('plan_location_id', plan.locationId!);
    if (options[0]) {
      sharedPreferences.setInt('initNumOfExpPeriod', plan.numOfExpPeriod!);
      sharedPreferences.setInt(
          'plan_combo_date',
          listComboDate
                  .firstWhere(
                      (element) => element.duration == plan.numOfExpPeriod)
                  .id -
              1);
    }
    if (options[1]) {
      sharedPreferences.setInt('plan_number_of_member', plan.maxMemberCount!);
      sharedPreferences.setInt('plan_max_member_weight', plan.maxMemberWeight!);
    }

    if (options[2]) {
      sharedPreferences.setDouble('plan_start_lat', plan.startLocationLat!);
      sharedPreferences.setDouble('plan_start_lng', plan.startLocationLng!);
      sharedPreferences.setString('plan_start_address', plan.departureAddress!);
    }

    if (options[3]) {
      sharedPreferences.setString('plan_name', plan.name!);
    }

    if (options[4]) {
      sharedPreferences.setStringList('selectedIndex',
          plan.savedContacts!.map((e) => e.providerId.toString()).toList());
    }

    if (options[5]) {
      sharedPreferences.setBool('notAskScheduleAgain', false);
      final availableOrder = plan.orders!
          .where((e) =>
              e.supplier!.isActive! &&
              e.details!.every((element) => element.isAvailable))
          .toList();
      final list = availableOrder.map((e) {
        final orderDetailGroupList =
            e.details!.groupListsBy((e) => e.productId);
        final orderDetailList =
            orderDetailGroupList.entries.map((e) => e.value.first).toList();
        return _orderService.convertToTempOrder(
          e.supplier!,
          e.note ?? "",
          e.type!,
          orderDetailList
              .map((item) => {
                    'productId': item.productId,
                    'productName': item.productName,
                    'quantity': item.quantity,
                    'partySize': item.partySize,
                    'unitPrice': item.unitPrice.toDouble(),
                    'price': item.price.toDouble()
                  })
              .toList(),
          e.period!,
          e.serveDates!.map((date) => date.toString()).toList(),
          e.serveDates!
              .map((date) => DateTime.parse(date.toString())
                  .difference(DateTime(
                      plan.utcStartAt!.toLocal().year,
                      plan.utcStartAt!.toLocal().month,
                      plan.utcStartAt!.toLocal().day,
                      0,
                      0,
                      0))
                  .inDays)
              .toList(),
          e.uuid,
          (orderDetailList.fold(
                  0.0,
                  (previousValue, element) =>
                      previousValue +
                      num.parse(
                              (element.unitPrice * element.quantity).toString())
                          .toInt()) *
              e.serveDates!.length),
        );
      }).toList();
      for (final date in plan.schedule!) {
        for (final item in date) {
          if (item['orderUUID'] != null &&
              !availableOrder
                  .any((element) => element.uuid == item['orderUUID'])) {
            item['orderUUID'] = null;
          }
        }
      }
      sharedPreferences.setString('plan_schedule', json.encode(plan.schedule));
      if (options[6]) {
        sharedPreferences.setString('plan_temp_order', json.encode(list));
      }
    }

    if (options[7]) {
      sharedPreferences.setString(
          'plan_surcharge',
          json.encode(
              plan.surcharges!.map((e) => e.toJsonWithoutImage()).toList()));
    }
    if (options[8]) {
      sharedPreferences.setString('plan_note', plan.note ?? 'null');
    }
  }

  handleAlreadyDraft(BuildContext context, LocationViewModel location,
      String locationName, bool isClone, PlanDetail? plan, List<bool> options) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      dialogType: DialogType.question,
      title:
          'Bạn đang có bản nháp chuyến đi tại ${locationName == location.name ? 'địa điểm này' : locationName}',
      titleTextStyle: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSans'),
      desc: 'Bạn có muốn ghi đè chuyến đi đó không ?',
      descTextStyle: const TextStyle(
          fontSize: 16, color: Colors.grey, fontFamily: 'NotoSans'),
      btnOkOnPress: () async {
        Utils().clearPlanSharePref();
        sharedPreferences.setString('plan_location_name', location.name);
        sharedPreferences.setInt('plan_location_id', location.id);
        if (isClone) {
          setUpDataClonePlan(plan!, options);
        }
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => SelectComboDateScreen(
                  isCreate: true,
                  location: location,
                  isClone: isClone,
                )));
      },
      btnOkColor: Colors.deepOrangeAccent,
      btnOkText: 'Có',
      btnCancelText: 'Không',
      btnCancelColor: Colors.blue,
      btnCancelOnPress: () {
        if (locationName == location.name) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => SelectComboDateScreen(
                    isCreate: true,
                    location: location,
                    isClone: isClone,
                  )));
        }
      },
    ).show();
  }

  showInvalidScheduleAndServiceClone(BuildContext context) {
    AwesomeDialog(
            context: context,
            title:
                'Không thể sao chép đơn dịch vụ nếu không sao chép lịch trình',
            animType: AnimType.leftSlide,
            dialogType: DialogType.warning,
            titleTextStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSans'),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            btnOkColor: Colors.amber,
            btnOkOnPress: () {},
            btnOkText: 'OK')
        .show();
  }

  getHolidayServingDates(List<Holiday> holidays, List<DateTime> servingDates) {
    List<DateTime> normalServingDates = [];
    List<DateTime> holidayServingDates = [];
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

  updateTempOrder(bool isChangeByMember) async {
    final newMaxMemberCount = sharedPreferences.getInt('plan_number_of_member');
    var orderList =
        json.decode(sharedPreferences.getString('plan_temp_order')!);
    if (isChangeByMember) {
      for (final order in orderList) {
        for (final detail in order['details']) {
          detail['quantity'] =
              (newMaxMemberCount! / detail['partySize']).ceil();
        }
        order['total'] = order['details'].fold(
                0,
                (previousValue, element) =>
                    previousValue +
                    num.parse((element['unitPrice'] * element['quantity'])
                            .toString())
                        .toInt()) *
            order['serveDates']!.length /
            GlobalConstant().VND_CONVERT_RATE;
      }
    } else {
      ConfigService _config = ConfigService();
      DateTime startDate =
          DateTime.parse(sharedPreferences.getString('plan_start_date')!);
      final config = await _config.getOrderConfig();
      final holidays = config!.HOLIDAYS;
      var listedPrice = 0.0;
      for (final order in orderList) {
        listedPrice = order['total'] / order['serveDates'].length;
        List<DateTime> _servingDates = [];
        for (final index in order['serveDateIndexes']) {
          _servingDates.add(startDate.add(Duration(days: index)));
        }
        final rs = getHolidayServingDates(holidays!, _servingDates);

        order['serveDates'] = order['serveDateIndexes']
            .map((e) =>
                startDate.add(Duration(days: e)).toString().split(' ')[0])
            .toList();

        if (rs['holidayServingDates'].isNotEmpty) {
          switch (order['type']) {
            case "EAT":
              order['total'] = listedPrice * rs['normalServingDates'].length +
                  listedPrice *
                      rs['holidayServingDates'].length *
                      (1 + config.HOLIDAY_MEAL_UP_PCT! / 100);
              break;
            case "CHECKIN":
              order['total'] = listedPrice * rs['normalServingDates'].length +
                  listedPrice *
                      rs['holidayServingDates'].length *
                      (1 + config.HOLIDAY_LODGING_UP_PCT! / 100);
              break;
            case "VISIT":
              order['total'] = listedPrice * rs['normalServingDates'].length +
                  listedPrice *
                      rs['holidayServingDates'].length *
                      (1 + config.HOLIDAY_RIDING_UP_PCT! / 100);
              break;
          }
        }
      }
    }
    sharedPreferences.setString('plan_temp_order', json.encode(orderList));
  }

  updateScheduleAndOrder(BuildContext context, void Function() onConfirm) {
    int duration = (sharedPreferences.getInt('initNumOfExpPeriod')! / 2).ceil();
    var schedule = json.decode(sharedPreferences.getString('plan_schedule')!);
    var tempOrders =
        json.decode(sharedPreferences.getString('plan_temp_order')!);
    var newSchedule = [];

    for (int i = 0; i < duration; i++) {
      if (i < schedule.length) {
        newSchedule.add(schedule[i]);
      } else {
        newSchedule.add([]);
      }
    }

    var invalidOrder = [];
    for (final order in tempOrders) {
      if (order['serveDateIndexes']
          .any((index) => int.parse(index.toString()) >= duration)) {
        invalidOrder.add(order);
      }
    }
    final arrivedText = sharedPreferences.getString('plan_arrivedTime');
    if (arrivedText != null) {
      final arrivedTime = DateTime.parse(arrivedText);
      final startSession = sessions.firstWhereOrNull((aTime) =>
              aTime.from <= arrivedTime.hour && aTime.to > arrivedTime.hour) ??
          sessions[0];

      for (final item in newSchedule[0]) {
        if (item['orderUUID'] != null) {
          final order =
              tempOrders.firstWhere((e) => e['orderUUID'] == item['orderUUID']);
          final session = sessions
              .firstWhere((element) => element.enumName == order['period']);
          if (session.index < startSession.index &&
              !invalidOrder.any(
                  (element) => element['orderUUID'] == item['orderUUID'])) {
            invalidOrder.add(order);
          }
        }
      }
    }
    if (invalidOrder.isNotEmpty) {
      AwesomeDialog(
              context: context,
              animType: AnimType.leftSlide,
              dialogType: DialogType.infoReverse,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Thay đổi quan trọng',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans'),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Với thay đổi trên các đơn hàng sau đây sẽ không còn khả dụng',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'NotoSans',
                            color: Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    for (int index = 0; index < invalidOrder.length; index++)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: index.isOdd
                                ? primaryColor.withOpacity(0.1)
                                : lightPrimaryTextColor.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: index == 0
                                  ? const Radius.circular(10)
                                  : Radius.zero,
                              topRight: index == 0
                                  ? const Radius.circular(10)
                                  : Radius.zero,
                              bottomLeft: index == invalidOrder.length - 1
                                  ? const Radius.circular(10)
                                  : Radius.zero,
                              bottomRight: index == invalidOrder.length - 1
                                  ? const Radius.circular(10)
                                  : Radius.zero,
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invalidOrder[index]['type'] == 'EAT'
                                  ? 'Dùng bữa tại:'
                                  : invalidOrder[index]['type'] == 'VISIT'
                                      ? 'Thuê phương tiện:'
                                      : 'Nghỉ ngơi tại:',
                              style: const TextStyle(
                                  fontSize: 13, fontFamily: 'NotoSans'),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 30.w,
                                  child: Text(
                                    invalidOrder[index]['providerName'],
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NotoSans'),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 15.w,
                                  child: Text(
                                    NumberFormat.simpleCurrency(
                                            locale: 'vi_VN',
                                            name: '',
                                            decimalDigits: 0)
                                        .format(invalidOrder[index]['total']),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NotoSans'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: SvgPicture.asset(
                                    gcoin_logo,
                                    height: 16,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Đồng ý với các thay đổi này, chúng tôi sẽ xoá danh sách đơn hàng không khả dụng của chuyến đi',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 15, fontFamily: 'NotoSans'),
                        ))
                  ],
                ),
              ),
              btnOkColor: Colors.blueAccent,
              btnOkOnPress: () {
                for (final order in invalidOrder) {
                  tempOrders.remove(tempOrders
                      .firstWhere((e) => e['orderUUID'] == order['orderUUID']));
                  for (final day in newSchedule) {
                    for (final item in day) {
                      if (item['orderUUID'] != null &&
                          order['orderUUID'] == item['orderUUID']) {
                        item['orderUUID'] = null;
                      }
                    }
                  }
                }
                sharedPreferences.setString(
                    'plan_schedule', json.encode(newSchedule));
                sharedPreferences.setString(
                    'plan_temp_order', json.encode(tempOrders));
                onConfirm();
              },
              btnOkText: 'Đồng ý',
              btnCancelColor: Colors.amber,
              btnCancelOnPress: () {},
              btnCancelText: 'Huỷ')
          .show();
    }else{
      onConfirm();
    }
  }

  updateProductPrice() async {
    var orders =
        json.decode(sharedPreferences.getString('plan_temp_order') ?? '[]');
    List<int> ids = [];
    List<double> newPrice = [];

    if (orders.isNotEmpty) {
      for (final order in orders) {
        for (final detail in order['details']) {
          if (!ids.contains(detail['productId'])) {
            ids.add(detail['productId']);
          }
        }
      }
      ids.sort();
      ProductService _productService = ProductService();
      final products = await _productService.getListProduct(ids);
      newPrice = products
          .map((e) => e.price.toDouble() / GlobalConstant().VND_CONVERT_RATE)
          .toList();
      for (final order in orders) {
        for (final detail in order['details']) {
          final index = ids.indexOf(detail['productId']);
          detail['price'] = newPrice[index];
          detail['unitPrice'] = newPrice[index];
        }
        order['total'] = order['details'].fold(
            0,
            (previousValue, element) =>
                previousValue +
                num.parse(
                        (element['unitPrice'] * element['quantity']).toString())
                    .toInt());
      }
    }

    sharedPreferences.setString('plan_temp_order', json.encode(orders));
  }
}
