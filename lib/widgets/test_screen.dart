import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/pdf_handler.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/holiday.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_note_surcharge_screen.dart';
import 'package:greenwheel_user_app/service/config_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/province.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  PrintingInfo? printingInfo;
  PlanService _planService = PlanService();
  PlanDetail? _planDetail;
  ConfigService _configService = ConfigService();
  List<Holiday> holidays = [];
  bool isLoading = true;
  List<DateTime> _selectedDays = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() async {
    final rs = await _configService.getConfig();
    if (rs != null) {
      setState(() {
        holidays = rs;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(
              child: Text('loading'),
            )
          : SfDateRangePicker(
              onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                _selectedDays = dateRangePickerSelectionChangedArgs.value;
              },
              confirmText: "XÁC NHẬN",
              backgroundColor: Colors.white,
              headerStyle: const DateRangePickerHeaderStyle(
                  backgroundColor: Colors.white),
              selectionColor: Colors.white,
              cancelText: 'HUỶ',
              minDate: DateTime(2024),
              maxDate: DateTime(2026),
              showActionButtons: true,
              selectionShape: DateRangePickerSelectionShape.rectangle,
          todayHighlightColor: primaryColor,
              cellBuilder: (context, cellDetails) {
                final bool _isHoliday = isHoliday(cellDetails.date);
                final bool _isSelectedDay = isSelectedDay(cellDetails.date);
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: _isHoliday
                        ? Border.all(
                            color: Colors.redAccent,
                            width: 2,
                          )
                        : const Border(),
                    color:_isSelectedDay
                            ? primaryColor
                            : Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cellDetails.date.day.toString(),
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'NotoSans',
                            color: _isSelectedDay ? Colors.white : Colors.black),
                      )
                    ],
                  ),
                );
              },
              onCancel: () {
                Navigator.of(context).pop();
              },
              selectionMode: DateRangePickerSelectionMode.multiple,
            ),
    ));
  }

  isHoliday(DateTime date) {
    return holidays.any((element) =>
        element.from.isBefore(date) && element.to.isAfter(date) ||
        date.isAtSameMomentAs(element.from) ||
        date.isAtSameMomentAs(element.to));
  }

  isSelectedDay(DateTime date) {
    return _selectedDays.contains(date);
  }
}
