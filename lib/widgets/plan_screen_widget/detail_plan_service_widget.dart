// ignore_for_file: use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_total_info.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/service_types.dart';
import '../../screens/plan_screen/list_order_screen.dart';
import '../../service/location_service.dart';
import '../../service/plan_service.dart';
import '../../view_models/order.dart';
import '../../view_models/plan_viewmodels/plan_detail.dart';
import 'plan_order_card.dart';

class DetailPlanServiceWidget extends StatefulWidget {
  const DetailPlanServiceWidget(
      {super.key,
      required this.plan,
      required this.isLeader,
      required this.tempOrders,
      required this.totalOrder,
      required this.planType,
      this.orderList,
      required this.onGetOrderList});
  final PlanDetail plan;
  final bool isLeader;
  final void Function() onGetOrderList;
  final List<OrderViewModel>? orderList;
  final List<OrderViewModel> tempOrders;
  final double totalOrder;
  final String planType;

  @override
  State<DetailPlanServiceWidget> createState() =>
      _DetailPlanServiceWidgetState();
}

class _DetailPlanServiceWidgetState extends State<DetailPlanServiceWidget>
    with TickerProviderStateMixin {
  late TabController tabController;
  final LocationService _locationService = LocationService();
  final PlanService _planService = PlanService();
  List<OrderViewModel> _orderList = [];
  List<OrderViewModel> roomOrderList = [];
  List<OrderViewModel> foodOrderList = [];
  List<OrderViewModel> movingOrderList = [];
  bool isShowTotal = false;
  double _totalSurcharge = 0;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() {
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _totalSurcharge = (widget.plan.surcharges ?? []).fold(
      0,
      (previousValue, element) =>
          previousValue +
          (element.imagePath != null ? element.gcoinAmount : 0) *
              widget.plan.memberCount!,
    );
    setState(() {
      _orderList = widget.orderList ?? [];
      final orderGroups = _orderList.groupListsBy((element) => element.type);
      roomOrderList = orderGroups[services[1].name] ?? [];
      foodOrderList = orderGroups[services[0].name] ?? [];
      movingOrderList = orderGroups[services[2].name] ?? [];
    });
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
    setUpData();
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
                        final rs = await _locationService
                            .getLocationById(widget.plan.locationId!);
                        if (rs != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ListOrderScreen(
                                    availableGcoinAmount:
                                        widget.plan.actualGcoinBudget,
                                    planId: widget.plan.id!,
                                    orders: widget.tempOrders
                                        .where((element) => !_orderList
                                            .any((e) => e.uuid == element.uuid))
                                        .toList(),
                                    startDate:
                                        widget.plan.utcStartAt!.toLocal(),
                                    callback: (p) {
                                      widget.onGetOrderList();
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
                      callback: () {
                        widget.onGetOrderList();
                      },
                      isShowQuantity: true,
                      endDate: widget.plan.utcEndAt,
                      planType: widget.planType,
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
                      callback: () {
                        widget.onGetOrderList();
                      },
                      isShowQuantity: true,
                      planType: widget.planType,
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
                      callback: () {
                        widget.onGetOrderList();
                      },
                      isShowQuantity: true,
                      planType: widget.planType,
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
            PlanTotalInfo(
                plan: widget.plan,
                isShowTotal: isShowTotal,
                totalOrder: widget.totalOrder.toInt(),
                totalSurcharge: _totalSurcharge.toInt())
        ],
      ),
    );
  }
}
