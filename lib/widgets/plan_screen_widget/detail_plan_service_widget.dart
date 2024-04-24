import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:greenwheel_user_app/core/constants/plan_statuses.dart';
import 'package:greenwheel_user_app/core/constants/service_types.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/plan_screen/list_order_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_order_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class DetailPlanServiceWidget extends StatefulWidget {
  const DetailPlanServiceWidget(
      {super.key,
      required this.plan,
      required this.isLeader,
      required this.tempOrders,
      required this.total,
      required this.planType,
      this.orderList,
      required this.onGetOrderList});
  final PlanDetail plan;
  final bool isLeader;
  final void Function() onGetOrderList;
  final List<OrderViewModel>? orderList;
  final List<OrderViewModel> tempOrders;
  final double total;
  final String planType;

  @override
  State<DetailPlanServiceWidget> createState() =>
      _DetailPlanServiceWidgetState();
}

class _DetailPlanServiceWidgetState extends State<DetailPlanServiceWidget>
    with TickerProviderStateMixin {
  late TabController tabController;
  LocationService _locationService = LocationService();
  PlanService _planService = PlanService();
  List<OrderViewModel> _orderList = [];
  List<OrderViewModel> roomOrderList = [];
  List<OrderViewModel> foodOrderList = [];
  List<OrderViewModel> movingOrderList = [];
  bool isShowTotal = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() {
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _orderList = widget.orderList ?? [];
    final orderGroups = _orderList.groupListsBy((element) => element.type);
    roomOrderList = orderGroups[services[1].name] ?? [];
    foodOrderList = orderGroups[services[0].name] ?? [];
    movingOrderList = orderGroups[services[2].name] ?? [];
    isShowTotal =
        widget.plan.status != 'PENDING' && widget.plan.status != 'REGISTERING';
  }

  refreshData() async {
    final rs =
        await _planService.getOrderCreatePlan(widget.plan.id!, widget.planType);
    if (rs != null) {
      setState(() {
        _orderList = rs['orders'];
        final orderGroups = _orderList.groupListsBy((element) => element.type);
        roomOrderList = orderGroups[services[1].name] ?? [];
        foodOrderList = orderGroups[services[0].name] ?? [];
        movingOrderList = orderGroups[services[2].name] ?? [];
      });
    }
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
                            widget.plan.locationId!);
                        if (rs != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ListOrderScreen(
                                    availableGcoinAmount:
                                        widget.plan.actualGcoinBudget,
                                    planId: widget.plan.id!,
                                    orders: widget.tempOrders
                                        .where((element) => !widget.orderList!
                                            .any((e) => e.uuid == element.uuid))
                                        .toList(),
                                    startDate:
                                        widget.plan.utcStartAt!.toLocal(),
                                    callback: (p) {
                                      refreshData();
                                    },
                                    endDate: widget.plan.utcEndAt!.toLocal(),
                                    memberLimit: widget.plan.memberCount!,
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
                  text: '(${roomOrderList.length})',
                ),
                Tab(
                  icon: const Icon(Icons.restaurant),
                  text: '(${foodOrderList.length})',
                ),
                Tab(
                  icon: const Icon(Icons.directions_car),
                  text: '(${movingOrderList.length})',
                )
              ]),
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: roomOrderList.isEmpty &&
                    foodOrderList.isEmpty &&
                    widget.plan.surcharges!.isEmpty
                ? 0.h
                : 35.h,
            child: TabBarView(controller: tabController, children: [
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: roomOrderList.length,
                itemBuilder: (context, index) {
                  return PlanOrderCard(
                      callback: widget.onGetOrderList,
                      isShowQuantity: true,
                      planStatus: widget.plan.status,
                      order: roomOrderList[index],
                      isLeader: widget.isLeader);
                },
              ),
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: foodOrderList.length,
                itemBuilder: (context, index) {
                  return PlanOrderCard(
                      callback: widget.onGetOrderList,
                      isShowQuantity: true,
                      planStatus: widget.plan.status,
                      order: foodOrderList[index],
                      isLeader: widget.isLeader);
                },
              ),
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: movingOrderList.length,
                itemBuilder: (context, index) {
                  return PlanOrderCard(
                      callback: widget.onGetOrderList,
                      isShowQuantity: true,
                      planStatus: widget.plan.status,
                      order: movingOrderList[index],
                      isLeader: widget.isLeader);
                },
              )
            ]),
          ),
          const SizedBox(
            height: 8,
          ),
          if (widget.isLeader)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    color: Colors.grey.withOpacity(0.2)),
                child: Column(
                  children: [
                    buildAmountInfo(
                        'Dự tính:',
                        widget.plan.gcoinBudgetPerCapita! *
                            widget.plan.maxMemberCount!),
                    buildAmountInfo(
                        'Đã thu:',
                        widget.plan.gcoinBudgetPerCapita! *
                            widget.plan.memberCount!),
                    if (isShowTotal)
                      buildAmountInfo(
                          'Hiện tại:', widget.plan.actualGcoinBudget!),
                    if (isShowTotal)
                      buildAmountInfo(
                          'Đã chi:',
                          widget.plan.status == plan_statuses[0].engName ||
                                  widget.plan.status == plan_statuses[1].engName
                              ? 0
                              : widget.total /
                                  GlobalConstant().VND_CONVERT_RATE),
                    if (isShowTotal)
                      buildAmountInfo(
                          'Số tiền đã bù:',
                          widget.plan.maxMemberCount! *
                                  widget.plan.gcoinBudgetPerCapita! -
                              widget.plan.memberCount! *
                                  widget.plan.gcoinBudgetPerCapita!),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  buildAmountInfo(String title, num amount) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            SizedBox(
              width: 30.w,
              child: Text(
                NumberFormat.simpleCurrency(
                        locale: 'vi-VN', decimalDigits: 0, name: "")
                    .format(amount),
                textAlign: TextAlign.end,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: SvgPicture.asset(
                gcoin_logo,
                height: 18,
              ),
            ),
            SizedBox(
              width: 5.w,
            )
          ],
        ),
      );
}
