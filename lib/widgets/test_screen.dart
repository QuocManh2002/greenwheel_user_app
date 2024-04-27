import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/models/configuration.dart';
import 'package:greenwheel_user_app/models/holiday.dart';
import 'package:greenwheel_user_app/service/config_service.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<DateTime> servingDates = [];
  List<DateTime> _selectedDays = [];
  List<DateTime?> _selectedHolidays = [];
  ConfigService _configService = ConfigService();
  ConfigurationModel? config;
  bool isLoading = true;

  double total = 100000;

  final originialList = [
    "2024-04-26",
    "2024-04-28",
    "2024-04-30",
  ];
  final newList = [
    "2024-04-26",
    "2024-04-27",
    "2024-04-29",
  ];

  final invalidList = [];

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    for(final item in originialList){
      if(!newList.contains(item)){
        invalidList.add(item);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
                child: isLoading
                    ? const Center(
                        child: Text('Loading...'),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [for (final item in invalidList) Text(item,)],
                      ))));
  }

  isHoliday(DateTime date) {
    return config!.HOLIDAYS!.any((element) =>
        element.from.isBefore(date) && element.to.isAfter(date) ||
        date.isAtSameMomentAs(element.from) ||
        date.isAtSameMomentAs(element.to));
  }

  isSelectedDay(DateTime date) {
    return _selectedDays.contains(date);
  }

  isAvaiableDay(DateTime date) {
    final startDate = DateTime.now().add(const Duration(days: 5));
    final endDate = DateTime.now().add(const Duration(days: 12));
    return (date.isAfter(startDate) && date.isBefore(endDate)) ||
        date.isAtSameMomentAs(startDate) ||
        date.isAtSameMomentAs(endDate);
  }

  getTotal() {
    final everage = total / _selectedDays.length;
    return everage * (_selectedDays.length - _selectedHolidays.length) +
        everage *
            _selectedHolidays.length *
            (1 + config!.HOLIDAY_LODGING_UP_PCT! / 100);
  }
}
