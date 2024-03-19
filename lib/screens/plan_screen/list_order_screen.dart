import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:sizer2/sizer2.dart';

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
      required this.callback});
  final List<OrderViewModel> orders;
  final DateTime startDate;
  final int planId;
  final void Function() callback;
  final LocationViewModel location;
  final int memberLimit;
  final double? availableGcoinAmount;
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
          orders.isNotEmpty
              ? SizedBox(
                  height: 75.h,
                  child: ListView.builder(
                      itemCount: orders.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (ctx, index) => SupplierOrderCard(
                            callback: callback,
                            order: orders[index],
                            startDate: startDate,
                            isFromTempOrder: true,
                            isTempOrder: true,
                            memberLimit: memberLimit,
                            endDate: endDate,
                            availableGcoinAmount: availableGcoinAmount,
                            planId: planId,
                          )),
                )
              : Center(
                child: Column(
                    children: [
                      SizedBox(height: 15.h,),
                      Image.asset(
                        empty_plan,
                        height: 30.h,
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      const Text(
                        'Bạn không có đơn hàng mẫu nào',
                        style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
              ),
          const Spacer(),
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white.withOpacity(0.94),
                      builder: (ctx) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 23, vertical: 15),
                            child: Row(
                              children: [
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (ctx) => ServiceMainScreen(
                                                serviceType: services[4],
                                                location: location,
                                                isOrder: true,
                                                availableGcoinAmount: availableGcoinAmount,
                                                numberOfMember: memberLimit,
                                                startDate: startDate,
                                                isFromTempOrder: false,
                                                endDate: endDate,
                                                callbackFunction:callback)));
                                  },
                                  child: Container(
                                    height: 12.h,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 0.5.h,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue
                                                      .withOpacity(0.7)),
                                              padding: const EdgeInsets.all(10),
                                              child: const Icon(
                                                Icons.hotel,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Text(
                                              'Lưu trú',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: 2.h, top: 2.h),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.grey,
                                            size: 30,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                                SizedBox(
                                  width: 2.h,
                                ),
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (ctx) => ServiceMainScreen(
                                                serviceType: services[0],
                                                isFromTempOrder: false,
                                                availableGcoinAmount: availableGcoinAmount,
                                                location: location,
                                                isOrder: true,
                                                numberOfMember: memberLimit,
                                                startDate: startDate,
                                                endDate: endDate,
                                                callbackFunction:callback)));
                                  },
                                  child: Container(
                                    height: 12.h,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 0.5.h,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.orange
                                                      .withOpacity(0.7)),
                                              padding: const EdgeInsets.all(10),
                                              child: const Icon(
                                                Icons.restaurant,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Text(
                                              'Ăn uống',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: 2.h, top: 2.h),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.grey,
                                            size: 30,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ));
                },
                style: elevatedButtonStyle,
                child: const Text('Đặt đơn hàng mới')),
          ),
          SizedBox(
            height: 2.h,
          )
        ]),
      ),
    ));
  }
}
