import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TestScreenDate extends StatefulWidget {
  const TestScreenDate({super.key});

  @override
  State<TestScreenDate> createState() => _TestScreenDateState();
}

class _TestScreenDateState extends State<TestScreenDate> {

  handleSelectionChange(){

  }
  List<DateTime> selectedDates = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('chon ngay'),
      ),
      body: SfDateRangePicker(
        onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
          // selectedDates.add(dateRangePickerSelectionChangedArgs.value);
        },
        confirmText: "Xac nhan",
        selectionColor: primaryColor,
        // showTodayButton: false,
        controller: DateRangePickerController(),
        showActionButtons: true,
        todayHighlightColor: primaryColor,
        onCancel: () {
          Navigator.of(context).pop();
        }, 
        onSubmit: (p0) {
          selectedDates = p0 as List<DateTime>;
          print(selectedDates.length);
        },
        minDate: DateTime.now(),
        maxDate: DateTime(2024),
        selectionMode: DateRangePickerSelectionMode.multiple,
      ),
    ));
  }
}
