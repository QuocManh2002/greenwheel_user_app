import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/models/holiday.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/service/config_service.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SelectOrderDateScreen extends StatefulWidget {
  const SelectOrderDateScreen(
      {super.key,
      required this.supplier,
      required this.list,
      required this.total,
      required this.serviceType,
      this.iniNote = "",
      required this.numberOfMember,
      required this.endDate,
      required this.startDate,
      required this.selectedDate,
      required this.callbackFunction});
  final DateTime startDate;
  final DateTime endDate;
  final SupplierViewModel supplier;
  final List<ItemCart> list;
  final double total;
  final ServiceType serviceType;
  final String iniNote;
  final int numberOfMember;
  final List<DateTime>? selectedDate;
  final void Function(List<DateTime> servingsDates) callbackFunction;

  @override
  State<SelectOrderDateScreen> createState() => _SelectOrderDateScreenState();
}

class _SelectOrderDateScreenState extends State<SelectOrderDateScreen> {
  List<DateTime> servingDates = [];
  List<DateTime> _selectedDays = [];
  ConfigService _configService = ConfigService();
  List<Holiday> holidays = [];
  bool isLoading = true;

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
                  final bool _isHoliday = isHoliday(cellDetails.date);
                  final bool _isSelectedDay = isSelectedDay(cellDetails.date);
                  final bool _isAvaiableDay = isAvaiableDay(cellDetails.date);
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
                  );
                },
                onSubmit: (p0) {
                  widget.callbackFunction(p0 as List<DateTime>);
                  Navigator.of(context).pop();
                },
                selectionMode: DateRangePickerSelectionMode.multiple,
              ),
      ),
    );
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

  isAvaiableDay(DateTime date) {
    return (date.isAfter(widget.startDate) && date.isBefore(widget.endDate)) ||
        date.isAtSameMomentAs(widget.startDate) ||
        date.isAtSameMomentAs(widget.endDate);
  }
}
