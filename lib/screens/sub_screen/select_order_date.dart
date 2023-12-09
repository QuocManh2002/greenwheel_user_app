import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/screens/main_screen/cart.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:sizer2/sizer2.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SelectOrderDateScreen extends StatefulWidget {
  const SelectOrderDateScreen({
    super.key,
    required this.location,
    required this.supplier,
    required this.list,
    required this.total,
    required this.serviceType,
    this.iniPickupDate,
    this.iniReturnDate,
    this.iniNote = "",
    required this.numberOfMember
  });
  final LocationViewModel location;
  final SupplierViewModel supplier;
  final List<ItemCart> list;
  final double total;
  final ServiceType serviceType;
  final DateTime? iniPickupDate;
  final DateTime? iniReturnDate;
  final String iniNote;
  final int numberOfMember;

  @override
  State<SelectOrderDateScreen> createState() => _SelectOrderDateScreenState();
}

class _SelectOrderDateScreenState extends State<SelectOrderDateScreen> {
  DateTime? pickupDate;
  DateTime? returnDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pickupDate ??= DateTime.now();
    returnDate ??= DateTime.now().add(const Duration(days: 3));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: (widget.serviceType.id != 100)
              ? SfDateRangePicker(
                  onSelectionChanged: _onSelectionChanged,
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: PickerDateRange(
                      widget.iniPickupDate ?? DateTime.now(),
                      widget.iniReturnDate ??
                          DateTime.now().add(const Duration(days: 3))),
                  minDate: DateTime.now(),
                  maxDate: DateTime.now().add(const Duration(days: 30)),
                )
              : SfDateRangePicker(
                  onSelectionChanged: _onSelectionChanged,
                  selectionMode: DateRangePickerSelectionMode.single,
                  initialSelectedDate: widget.iniPickupDate ?? DateTime.now(),
                  minDate: DateTime.now(),
                  maxDate: DateTime.now().add(const Duration(days: 30)),
                ),
        ),
        bottomNavigationBar: Container(
          height: 9.h,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 90.w,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => CartScreen(
                          startDate: DateTime.now(),
                          endDate: DateTime.now(),
                          numberOfMember: widget.numberOfMember,
                          location: widget.location,
                          supplier: widget.supplier,
                          list: widget.list,
                          total: widget.total,
                          serviceType: widget.serviceType,
                          pickupDate: pickupDate,
                          returnDate: returnDate,
                          note: widget.iniNote,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background color
                  ),
                  child: const Center(
                    child: Text(
                      'Chọn',
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        setState(() {
          pickupDate = args.value.startDate;
          returnDate = args.value.endDate ?? args.value.startDate;
        });
      } else if (args.value is DateTime) {
        setState(() {
          pickupDate = args.value;
          returnDate = args.value;
        });
      }
    });
  }
}
