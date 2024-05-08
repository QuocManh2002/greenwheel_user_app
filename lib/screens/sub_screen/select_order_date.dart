import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/widgets/order_screen_widget/order_total_infor.dart';
import 'package:greenwheel_user_app/widgets/style_widget/dialog_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SelectOrderDateScreen extends StatefulWidget {
  const SelectOrderDateScreen(
      {super.key,
      required this.total,
      required this.serviceType,
      required this.endDate,
      required this.startDate,
      required this.selectedDate,
      required this.isOrder,
      required this.session,
      required this.callbackFunction});
  final DateTime startDate;
  final DateTime endDate;
  final double total;
  final ServiceType serviceType;
  final List<DateTime>? selectedDate;
  final bool isOrder;
  final Session session;
  final void Function(List<DateTime> servingsDates, double total)
      callbackFunction;

  @override
  State<SelectOrderDateScreen> createState() => _SelectOrderDateScreenState();
}

class _SelectOrderDateScreenState extends State<SelectOrderDateScreen> {
  List<DateTime> servingDates = [];
  List<DateTime> _selectedDays = [];
  bool isLoading = false;
  List<DateTime> _selectedHolidays = [];
  int holidayUpPCT = 0;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    holidayUpPCT = Utils().getHolidayUpPct(widget.serviceType.name);
    _selectedDays = widget.selectedDate != null
        ? widget.selectedDate!
        : [
            DateTime(widget.startDate.year, widget.startDate.month,
                widget.startDate.day, 0, 0, 0)
          ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Ngày nhận hàng',
            style: TextStyle(fontFamily: 'NotoSans'),
          ),
        ),
        body: isLoading
            ? Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                    child: ShimmerWidget.rectangularWithBorderRadius(
                        width: 100.w, height: 5.h),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                    child: ShimmerWidget.rectangularWithBorderRadius(
                        width: 100.w, height: 5.h),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                    child: ShimmerWidget.rectangularWithBorderRadius(
                        width: 100.w, height: 5.h),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                    child: ShimmerWidget.rectangularWithBorderRadius(
                        width: 100.w, height: 5.h),
                  )
                ],
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
                minDate: widget.startDate,
                maxDate: widget.endDate,
                showActionButtons: true,
                selectionColor: Colors.white,
                todayHighlightColor: primaryColor,
                initialSelectedDates: widget.selectedDate,
                onCancel: () {
                  Navigator.of(context).pop();
                },
                cellBuilder: (context, cellDetails) {
                  final bool _isHoliday = Utils().isHoliday(cellDetails.date);
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cellDetails.date.day.toString(),
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'NotoSans',
                                color: _isSelectedDay
                                    ? Colors.white
                                    : _isAvaiableDay
                                        ? Colors.black
                                        : Colors.grey),
                          )
                        ],
                      ),
                    ),
                  );
                },
                onSubmit: (dates) {
                  if ((dates as List<DateTime>).isEmpty) {
                    DialogStyle().basicDialog(
                        context: context,
                        title: 'Vui lòng chọn ít nhất 1 ngày phục vụ',
                        type: DialogType.warning);
                  } else {
                    _selectedHolidays = [];
                    for (final date in _selectedDays) {
                      if (Utils().isHoliday(date)) {
                        _selectedHolidays.add(date);
                      }
                    }
                    if (_selectedHolidays.isEmpty) {
                      widget.callbackFunction(
                          dates, widget.total * _selectedDays.length);
                      Navigator.of(context).pop();
                    } else {
                      for (final date in _selectedHolidays) {
                        _selectedDays.remove(date);
                      }
                      AwesomeDialog(
                              context: context,
                              animType: AnimType.leftSlide,
                              dialogType: DialogType.info,
                              body: OrderTotalInformationDialog(
                                  selectedDate: _selectedDays,
                                  holidayUpPCT: holidayUpPCT,
                                  selectedHolidays: _selectedHolidays,
                                  total: widget.total),
                              btnOkColor: Colors.blueAccent,
                              btnOkOnPress: () {
                                widget.callbackFunction(
                                    dates,
                                    widget.total * _selectedDays.length +
                                        widget.total *
                                            _selectedHolidays.length *
                                            (1 + holidayUpPCT / 100));
                                Navigator.of(context).pop();
                              },
                              btnOkText: 'Đồng ý',
                              btnCancelColor: Colors.amber,
                              btnCancelOnPress: () {},
                              btnCancelText: 'Chọn lại')
                          .show();
                    }
                  }
                },
                selectionMode: DateRangePickerSelectionMode.multiple,
              ),
      ),
    );
  }

  isSelectedDay(DateTime date) {
    return _selectedDays.contains(date);
  }

  isAvaiableDay(DateTime date) {
    final startDate = DateTime(widget.startDate.year, widget.startDate.month,
        widget.startDate.day, 0, 0, 0);
    final endDate = DateTime(
        widget.endDate.year, widget.endDate.month, widget.endDate.day, 0, 0, 0);
    if (widget.isOrder) {
    } else {
      bool isValidEndDateService = false;
      final arrivedAt =
          DateTime.parse(sharedPreferences.getString('plan_arrivedTime')!);
      var arrivedAtNight = arrivedAt.hour >= GlobalConstant().HALF_EVENING ||
          arrivedAt.hour < GlobalConstant().MORNING_START;
      var arrivedAtEvening =
          !arrivedAtNight && arrivedAt.hour >= GlobalConstant().HALF_AFTERNOON;
      var dayEqualNight =
          (sharedPreferences.getInt('initNumOfExpPeriod')! / 2).ceil().isEven;
      var isEndAtNoon = (arrivedAtEvening && dayEqualNight) ||
          (!arrivedAtEvening && !dayEqualNight);
      if (widget.serviceType.id == 2) {
        isValidEndDateService = !isEndAtNoon;
      } else {
        isValidEndDateService = !isEndAtNoon || widget.session.index <= 1;
      }
      if (isValidEndDateService) {
        return (date.isAfter(startDate) && date.isBefore(endDate)) ||
            date.isAtSameMomentAs(startDate) ||
            date.isAtSameMomentAs(endDate);
      } else {
        return (date.isAfter(startDate) && date.isBefore(endDate)) ||
            date.isAtSameMomentAs(startDate);
      }
    }
    return (date.isAfter(startDate) && date.isBefore(endDate)) ||
        date.isAtSameMomentAs(startDate) ||
        date.isAtSameMomentAs(endDate);
  }
}
