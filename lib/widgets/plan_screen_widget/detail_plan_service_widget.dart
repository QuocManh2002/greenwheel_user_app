// ignore_for_file: use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phuot_app/core/constants/enums.dart';
import 'package:phuot_app/core/constants/plan_statuses.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/service_types.dart';
import '../../screens/plan_screen/list_order_screen.dart';
import '../../service/location_service.dart';
import '../../view_models/order.dart';
import '../../view_models/plan_viewmodels/plan_detail.dart';
import 'plan_order_card.dart';
import 'plan_total_info.dart';

class DetailPlanServiceWidget extends StatefulWidget {
  const DetailPlanServiceWidget(
      {super.key,
      required this.plan,
      required this.isLeader,
      required this.tempOrders,
      required this.totalOrder,
      required this.onGetOrderList});
  final PlanDetail plan;
  final bool isLeader;
  final void Function() onGetOrderList;
  final List<OrderViewModel> tempOrders;
  final double totalOrder;

  @override
  State<DetailPlanServiceWidget> createState() =>
      _DetailPlanServiceWidgetState();
}

class _DetailPlanServiceWidgetState extends State<DetailPlanServiceWidget>
    with TickerProviderStateMixin {
  late TabController tabController;
  final LocationService _locationService = LocationService();
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
    final orderList = widget.plan.status == planStatuses[0].engName ||
            widget.plan.status == planStatuses[1].engName
        ? widget.tempOrders
        : widget.plan.orders!.where(
            (element) => element.currentStatus != OrderStatus.CANCELLED.name);
    final orderGroups = orderList.groupListsBy((element) => element.type);

    _totalSurcharge = (widget.plan.surcharges ?? []).fold(
      0,
      (previousValue, element) =>
          previousValue +
          (element.imagePath != null ? element.gcoinAmount : 0) *
              widget.plan.memberCount!,
    );
    setState(() {
      roomOrderList = orderGroups[services[1].name] ?? [];
      foodOrderList = orderGroups[services[0].name] ?? [];
      movingOrderList = orderGroups[services[2].name] ?? [];
    });
    final totalList = [roomOrderList, foodOrderList, movingOrderList];
    int index = totalList.indexOf(
        totalList.firstWhereOrNull((element) => element.isNotEmpty) ??
            roomOrderList);
    tabController.animateTo(index, duration: const Duration(milliseconds: 500));
    isShowTotal = widget.plan.status != planStatuses[0].engName &&
        widget.plan.status != planStatuses[1].engName;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
                      if (widget.plan.status == planStatuses[2].engName) {
                        final rs = await _locationService
                            .getLocationById(widget.plan.locationId!);
                        if (rs != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ListOrderScreen(
                                    availableGcoinAmount:
                                        widget.plan.actualGcoinBudget,
                                    planId: widget.plan.id!,
                                    tempOrders: widget.tempOrders,
                                    orders: widget.plan.orders ?? [],
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
                        color: widget.plan.status == planStatuses[2].engName
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
                  icon: const Icon(Icons.motorcycle_sharp),
                  text: '(${movingOrderList.length})',
                )
              ]),
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: roomOrderList.isEmpty &&
                    foodOrderList.isEmpty &&
                    widget.plan.surcharges!.isEmpty
                ? 0.h
                : 55.h,
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
                      planStatus: widget.plan.status,
                      order: roomOrderList[index],
                      isPublish: widget.plan.isPublished ?? false,
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
                      planStatus: widget.plan.status,
                      order: foodOrderList[index],
                      isPublish: widget.plan.isPublished ?? false,
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
                      isPublish: widget.plan.isPublished ?? false,
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
