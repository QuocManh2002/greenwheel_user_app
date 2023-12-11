import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:sizer2/sizer2.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SelectOrderDateScreen extends StatefulWidget {
  const SelectOrderDateScreen(
      {super.key,
      required this.location,
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
  final LocationViewModel location;
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
        // resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text(
                    "Ngày nhận hàng",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
        body: SfDateRangePicker(
          onSelectionChanged: (dateRangePickerSelectionChangedArgs) {},
          confirmText: "XÁC NHẬN",
          selectionColor: primaryColor,
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
        // bottomNavigationBar: Container(
        //   height: 9.h,
        //   width: double.infinity,
        //   color: Colors.white,
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: [
        //       SizedBox(
        //         width: 90.w,
        //         height: 6.h,
        //         child: ElevatedButton(
        //           onPressed: () async {
        //             Navigator.of(context).pop();
        //             Navigator.of(context).push(
        //               MaterialPageRoute(
        //                 builder: (ctx) => CartScreen(
        //                   startDate: widget.startDate,
        //                   endDate: widget.endDate,
        //                   numberOfMember: widget.numberOfMember,
        //                   location: widget.location,
        //                   supplier: widget.supplier,
        //                   list: widget.list,
        //                   total: widget.total,
        //                   serviceType: widget.serviceType,
        //                   note: widget.iniNote,
        //                 ),
        //               ),
        //             );
        //           },
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: Colors.green, // Background color
        //           ),
        //           child: const Center(
        //             child: Text(
        //               'Chọn',
        //               style: TextStyle(
        //                 color: Colors.white, // Text color
        //                 fontSize: 18,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
