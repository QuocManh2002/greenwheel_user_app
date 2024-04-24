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

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    final rs = await _configService.getOrderConfig();
    if (rs != null) {
      setState(() {
        config = rs;
        isLoading = false;
        _selectedDays = [DateTime.now()];
      });
    }
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
          : SfDateRangePicker(
              onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                _selectedDays = dateRangePickerSelectionChangedArgs.value;
              },
              confirmText: "XÁC NHẬN",
              backgroundColor: Colors.white,
              headerStyle: const DateRangePickerHeaderStyle(
                  backgroundColor: Colors.white),
              cancelText: 'HUỶ',
              minDate: DateTime.now().add(const Duration(days: 5)),
              maxDate: DateTime.now().add(const Duration(days: 12)),
              showActionButtons: true,
              selectionColor: Colors.white,
              todayHighlightColor: primaryColor,
              initialSelectedDates: [],
              onCancel: () {
                Navigator.of(context).pop();
              },
              cellBuilder: (context, cellDetails) {
                final bool _isHoliday = isHoliday(cellDetails.date);
                final bool _isSelectedDay = isSelectedDay(cellDetails.date);
                final bool _isAvaiableDay = isAvaiableDay(cellDetails.date);
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: _isHoliday
                          ? Border.all(
                              color: Colors.redAccent,
                              width: 2,
                            )
                          : const Border(),
                      color: _isSelectedDay ? primaryColor : Colors.white,
                    ),
                    child: Text(
                      cellDetails.date.day.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'NotoSans',
                          color: _isSelectedDay
                              ? Colors.white
                              : _isAvaiableDay
                                  ? Colors.black
                                  : Colors.grey),
                    ),
                  ),
                );
              },
              onSubmit: (dates) {
                if ((dates as List<DateTime>).isEmpty) {
                  AwesomeDialog(
                          context: context,
                          animType: AnimType.leftSlide,
                          dialogType: DialogType.warning,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          title: 'Vui lòng chọn ít nhất 1 ngày phục vụ',
                          titleTextStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans'),
                          btnOkColor: Colors.amber,
                          btnOkOnPress: () {},
                          btnOkText: 'Ok')
                      .show();
                } else {
                  _selectedHolidays = [];
                  for (final date in _selectedDays) {
                    if (isHoliday(date)) {
                      _selectedHolidays.add(date);
                    }
                  }
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Ngày chọn: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                for (final date in _selectedDays)
                                  Text(DateFormat('dd/MM/yyyy').format(date)),
                                if (_selectedHolidays.isNotEmpty)
                                  const Text(
                                    'Ngày lễ:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                if (_selectedHolidays.isNotEmpty)
                                  for (final date in _selectedHolidays)
                                    if (date != null)
                                      Text(DateFormat('dd/MM/yyyy')
                                          .format(date)),
                                const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold),),
                                Text(total.toString()),
                                const Text('Tổng cộng gồm lễ:', style: TextStyle(fontWeight: FontWeight.bold),),
                                Text(getTotal().toString(),)
                              ],
                            ),
                          ));
                }
              },
              selectionMode: DateRangePickerSelectionMode.multiple,
            ),
    )));
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
