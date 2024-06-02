import 'package:flutter/material.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/urls.dart';
import '../../view_models/location.dart';
import '../../view_models/order.dart';
import '../../widgets/plan_screen_widget/supplier_order_card.dart';

class ListOrderScreen extends StatelessWidget {
  const ListOrderScreen(
      {super.key,
      required this.orders,
      required this.startDate,
      required this.planId,
      required this.endDate,
      required this.location,
      required this.memberLimit,
      this.availableGcoinAmount,
      required this.tempOrders,
      required this.callback});
  final List<OrderViewModel> orders;
  final List<OrderViewModel> tempOrders;
  final DateTime startDate;
  final int planId;
  final void Function(dynamic) callback;
  final LocationViewModel location;
  final int memberLimit;
  final int? availableGcoinAmount;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Đặt dịch vụ'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Các đơn hàng mẫu',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 1.h,
          ),
          tempOrders.isNotEmpty
              ? SizedBox(
                  height: 75.h,
                  child: ListView.builder(
                      itemCount: tempOrders.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (ctx, index) => SupplierOrderCard(
                            callback: callback,
                            order: tempOrders[index],
                            startDate: startDate,
                            isFromTempOrder: true,
                            isTempOrder: true,
                            memberLimit: memberLimit,
                            endDate: endDate,
                            availableGcoinAmount: availableGcoinAmount,
                            planId: planId,
                            location: location,
                            isConfirm: orders.any((element) =>
                                element.uuid == tempOrders[index].uuid),
                          )),
                )
              : Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15.h,
                      ),
                      Image.asset(
                        emptyPlan,
                        height: 30.h,
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      const Text(
                        'Bạn không có đơn hàng mẫu nào',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ]),
      ),
    ));
  }
}
