import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ngày nhận hàng', style: TextStyle(fontFamily: 'NotoSans'),),
        ),
        body: SfDateRangePicker(
          onSelectionChanged: (dateRangePickerSelectionChangedArgs) {},
          confirmText: "XÁC NHẬN",
          backgroundColor: Colors.white,
          headerStyle:const DateRangePickerHeaderStyle(
            backgroundColor: Colors.white
          ),
          selectionColor: primaryColor,
          cancelText: 'HUỶ',
          minDate: widget.startDate,
          maxDate: widget.endDate,
          showActionButtons: true,
          todayHighlightColor: primaryColor,
          initialSelectedDates: widget.selectedDate,
          onCancel: () {
            Navigator.of(context).pop();
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
}
