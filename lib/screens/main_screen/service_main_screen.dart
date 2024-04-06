import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/screens/loading_screen/service_supplier_loading_screen.dart';
import 'package:greenwheel_user_app/service/supplier_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/order_screen_widget/supplier_card.dart';
import 'package:sizer2/sizer2.dart';

class ServiceMainScreen extends StatefulWidget {
  const ServiceMainScreen(
      {super.key,
      required this.serviceType,
      required this.location,
      required this.numberOfMember,
      required this.startDate,
      required this.endDate,
      this.isOrder,
      this.availableGcoinAmount,
      this.isFromTempOrder,
      this.initSession,
      required this.callbackFunction});
  final int numberOfMember;
  final ServiceType serviceType;
  final LocationViewModel location;
  final DateTime startDate;
  final DateTime endDate;
  final bool? isOrder;
  final int? availableGcoinAmount;
  final bool? isFromTempOrder;
  final void Function() callbackFunction;
  final Session? initSession;

  @override
  State<ServiceMainScreen> createState() => _ServiceMainScreenState();
}

class _ServiceMainScreenState extends State<ServiceMainScreen> {
  SupplierService supplierService = SupplierService();
  List<SupplierViewModel>? list = [];
  String title = "";
  bool isLoading = true;
  List<OrderViewModel>? orderList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() async {
    List<String> type = [];
    switch (widget.serviceType.id) {
      case 1:
        title = "Dịch vụ ăn uống";
        type.add("FOOD");
        break;
      case 5:
        title = "Dịch vụ lưu trú";
        type.add("ROOM");
        break;
      case 6:
        title = "Dịch vụ cho thuê xe";
        type.add("VEHICLE");
        break;
    }
    list = await supplierService.getSuppliers(
        widget.location.longitude, widget.location.latitude, type);

    if (list != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(15.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              onPressed: () {},
                            ),
                            hintText: "Bạn cần tìm dịch vụ nào?",
                            contentPadding: EdgeInsets.all(4.w),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: isLoading
            ? const ServiceSupplierLoadingScreen()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((widget.startDate.difference(DateTime.now()).inDays +
                            1) <=
                        3)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RichText(
                          text: const TextSpan(
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              children: [
                                TextSpan(
                                    text: "Lưu ý: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text:
                                        "Bạn chỉ có thể đặt dịch vụ sau 3 ngày kể từ ngày hôm nay")
                              ]),
                        ),
                      ),
                    list!.isEmpty
                        ? Container(
                          alignment: Alignment.center,
                          child: Column(
                              children: [
                                SizedBox(height: 20.h,),
                                Image.asset(empty_plan, height: 30.h,fit: BoxFit.cover, ),
                                SizedBox(height: 2.h,),
                                const Text(
                                  'Rất tiếc! Hiện dịch vụ không khả dụng',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NotoSans',
                                      fontSize: 17,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                        )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: list!.length,
                            itemBuilder: (context, index) {
                              return SupplierCard(
                                availableGcoinAmount: widget.availableGcoinAmount,
                                isOrder: widget.isOrder,
                                startDate: widget.startDate,
                                endDate: widget.endDate,
                                numberOfMember: widget.numberOfMember,
                                supplier: list![index],
                                serviceType: widget.serviceType,
                                location: widget.location,
                                initSession: widget.initSession,
                                callbackFunction: widget.callbackFunction,
                              );
                            },
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}
