import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/screens/plan_screen/list_order_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_join_service_infor.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/surcharge_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class DetailPlanServiceWidget extends StatefulWidget {
  const DetailPlanServiceWidget(
      {super.key,
      required this.indexService,
      required this.listFood,
      required this.listRoom,
      required this.plan,
      required this.isLeader,
      required this.tempOrders,
      required this.total,
      required this.onGetOrderList});
  final PlanDetail plan;
  final bool isLeader;
  final void Function() onGetOrderList;
  final List<PlanJoinServiceInfor> listRoom;
  final List<PlanJoinServiceInfor> listFood;
  final dynamic indexService;
  final List<OrderViewModel> tempOrders;
  final double total;

  @override
  State<DetailPlanServiceWidget> createState() =>
      _DetailPlanServiceWidgetState();
}

class _DetailPlanServiceWidgetState extends State<DetailPlanServiceWidget>
    with TickerProviderStateMixin {
  late TabController tabController;
  LocationService _locationService = LocationService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Các đơn dịch vụ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )),
              const Spacer(),
              if (widget.isLeader)
                TextButton(
                    onPressed: () async {
                      if (widget.plan.status == 'READY') {
                        final rs = await _locationService.GetLocationById(
                            widget.plan.locationId);
                        if (rs != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ListOrderScreen(
                                    availableGcoinAmount:
                                        widget.plan.currentGcoinBudget,
                                    planId: widget.plan.id,
                                    orders: widget.tempOrders,
                                    startDate: widget.plan.startDate!,
                                    callback: widget.onGetOrderList,
                                    endDate: widget.plan.endDate!,
                                    memberLimit: widget.plan.maxMember,
                                    location: rs,
                                  )));
                        }
                      }
                    },
                    child: Text(
                      'Đi đặt hàng',
                      style: TextStyle(
                        color: widget.plan.status == 'READY'
                            ? primaryColor
                            : Colors.grey,
                      ),
                    ))
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          TabBar(
              controller: tabController,
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                  icon: const Icon(Icons.hotel),
                  text: '(${widget.indexService['roomIndex'].length})',
                ),
                Tab(
                  icon: const Icon(Icons.restaurant),
                  text: '(${widget.indexService['foodIndex'].length})',
                ),
                Tab(
                  icon: const Icon(Icons.account_balance_wallet),
                  text: '(${widget.plan.surcharges!.length})',
                )
              ]),
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: widget.indexService['roomIndex'].isEmpty &&
                    widget.indexService['foodIndex'].isEmpty &&
                    widget.plan.surcharges!.isEmpty
                ? 0.h
                : 35.h,
            child: TabBarView(controller: tabController, children: [
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.indexService['roomIndex'].length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100.w,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.8),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Text(
                                'Ngày ${DateTime.parse(widget.indexService['roomIndex'][index]).difference(widget.plan.startDate!).inDays + 1}',
                                style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              width: 1.h,
                            ),
                            SizedBox(
                              width: 60.w,
                              child: const Text(
                                'Nghỉ tại khách sạn/nhà nghỉ',
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        if (widget.isLeader)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              children: [
                                for (final order
                                    in widget.listRoom[index].orderList)
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                              width: 43.w,
                                              child: Text(order.supplier.name,
                                                  overflow: TextOverflow.clip,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                          SizedBox(
                                            width: 1.h,
                                          ),
                                          Container(
                                            color: Colors.grey,
                                            width: 2,
                                            height: 40,
                                          ),
                                          SizedBox(
                                            width: 1.h,
                                          ),
                                          SizedBox(
                                            width: 30.w,
                                            child: Text(
                                                '${(order.total / 100).toInt()} GCOIN',
                                                overflow: TextOverflow.clip,
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )
                                        ],
                                      ),
                                      if (order !=
                                              widget.listRoom[index].orderList
                                                  .last &&
                                          widget.listRoom[index].orderList
                                                  .last !=
                                              1)
                                        Container(
                                          color: Colors.grey,
                                          height: 2,
                                        )
                                    ],
                                  ),
                              ],
                            ),
                          )
                      ],
                    ),
                  );
                },
              ),
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.indexService['foodIndex'].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: 100.w,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.8),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                child: Text(
                                  'Ngày ${DateTime.parse(widget.indexService['foodIndex'][index]).difference(widget.plan.startDate!).inDays + 1}',
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(
                                width: 1.h,
                              ),
                              SizedBox(
                                width: 60.w,
                                child: Text(
                                  '(${Utils().buildTextFromListString(widget.indexService['foodPeriodList'][index]['periods'].map((e) => e['text']).toList())}) Ăn uống tại nhà hàng',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.clip,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          if (widget.isLeader)
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final detail
                                      in widget.listFood[index].orderList)
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 12.w,
                                              child: Text(
                                                  detail ==
                                                              widget
                                                                  .listFood[
                                                                      index]
                                                                  .orderList
                                                                  .first ||
                                                          detail.period !=
                                                              widget
                                                                  .listFood[
                                                                      index]
                                                                  .orderList[widget
                                                                          .listFood[
                                                                              index]
                                                                          .orderList
                                                                          .indexOf(
                                                                              detail) +
                                                                      -1]
                                                                  .period
                                                      ? Utils().getPeriodString(
                                                          detail.period)['text']
                                                      : '',
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Container(
                                              color: Colors.grey,
                                              width: 2,
                                              height: 40,
                                            ),
                                            SizedBox(
                                              width: 1.h,
                                            ),
                                            SizedBox(
                                              width: 46.w,
                                              child: Text(detail.supplier.name,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Container(
                                              color: Colors.grey,
                                              width: 2,
                                              height: 40,
                                            ),
                                            SizedBox(
                                              width: 1.h,
                                            ),
                                            SizedBox(
                                              width: 14.w,
                                              child: Text(
                                                  '${(detail.total / 100).toInt()}',
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        if (detail !=
                                                widget.listFood[index].orderList
                                                    .last &&
                                            widget.listFood[index].orderList
                                                    .last !=
                                                1)
                                          Container(
                                            color: Colors.grey,
                                            height: 2,
                                          )
                                      ],
                                    )
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.plan.surcharges!.length,
                itemBuilder: (context, index) {
                  return SurchargeCard(
                      amount: widget.plan.surcharges![index].gcoinAmount,
                      note: widget.plan.surcharges![index].note);
                },
              )
            ]),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text(
                  'Ngân sách ban đầu: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  NumberFormat.simpleCurrency(
                          locale: 'vi-VN', decimalDigits: 0, name: "")
                      .format(widget.plan.gcoinBudgetPerCapita! *
                          widget.plan.maxMember),
                  style: const TextStyle(fontSize: 18),
                ),
                SvgPicture.asset(
                  gcoin_logo,
                  height: 25,
                ),
                SizedBox(
                  width: 2.h,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text(
                  'Ngân sách hiện tại: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  NumberFormat.simpleCurrency(
                          locale: 'vi-VN', decimalDigits: 0, name: "")
                      .format(widget.plan.gcoinBudgetPerCapita! *
                          widget.plan.maxMember - widget.total/100),
                  style: const TextStyle(fontSize: 18),
                ),
                SvgPicture.asset(
                  gcoin_logo,
                  height: 25,
                ),
                SizedBox(
                  width: 2.h,
                )
              ],
            ),
          ),
          if (widget.total != 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đã chi: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.simpleCurrency(
                            locale: 'vi-VN', decimalDigits: 0, name: "")
                        .format(widget.total / 100),
                    style: const TextStyle(fontSize: 18),
                  ),
                  SvgPicture.asset(
                    gcoin_logo,
                    height: 25,
                  ),
                  SizedBox(
                    width: 2.h,
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
