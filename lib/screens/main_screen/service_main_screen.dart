import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:phuot_app/core/constants/sessions.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/models/order_input_model.dart';
import 'package:phuot_app/models/service_type.dart';
import 'package:phuot_app/models/session.dart';
import 'package:phuot_app/screens/loading_screen/service_supplier_loading_screen.dart';
import 'package:phuot_app/service/supplier_service.dart';
import 'package:phuot_app/view_models/location.dart';
import 'package:phuot_app/view_models/order.dart';
import 'package:phuot_app/view_models/supplier.dart';
import 'package:phuot_app/widgets/order_screen_widget/supplier_card.dart';
import 'package:sizer2/sizer2.dart';

class ServiceMainScreen extends StatefulWidget {
  const ServiceMainScreen({
    super.key,
    required this.inputModel,
  });

  final OrderInputModel inputModel;

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
    super.initState();
    setUpData();
  }

  setUpData() async {
    List<String> type = [];
    switch (widget.inputModel.serviceType!.name) {
      case 'EAT':
        title = "Dịch vụ ăn uống";
        type.add("FOOD");
        break;
      case 'CHECKIN':
        title = "Dịch vụ lưu trú";
        type.add("ROOM");
        break;
      case 'VISIT':
        title = "Dịch vụ cho thuê xe";
        type.add("VEHICLE");
        break;
    }
    list = await supplierService.getSuppliers(
        PointLatLng(widget.inputModel.location!.latitude,
            widget.inputModel.location!.longitude),
        type,
        widget.inputModel.serviceType!.id == 1
            ? widget.inputModel.session
            : sessions[1]);

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
          preferredSize: Size.fromHeight(12.h),
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
                    if ((widget.inputModel.startDate!
                                .difference(DateTime.now())
                                .inDays +
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
                                SizedBox(
                                  height: 20.h,
                                ),
                                Image.asset(
                                  emptyPlan,
                                  height: 30.h,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
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
                                availableGcoinAmount:
                                    widget.inputModel.availableGcoinAmount,
                                isOrder: widget.inputModel.isOrder,
                                startDate: widget.inputModel.startDate!,
                                endDate: widget.inputModel.endDate!,
                                numberOfMember:
                                    widget.inputModel.numberOfMember!,
                                supplier: list![index],
                                serviceType: widget.inputModel.serviceType!,
                                location: widget.inputModel.location!,
                                initSession: widget.inputModel.session,
                                callbackFunction:
                                    widget.inputModel.callbackFunction!,
                                serveDates: widget.inputModel.servingDates,
                                uuid: widget.inputModel.orderGuid,
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
