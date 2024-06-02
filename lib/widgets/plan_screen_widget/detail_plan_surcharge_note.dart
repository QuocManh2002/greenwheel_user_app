import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/plan_statuses.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_total_info.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/surcharge_card.dart';
import 'package:sizer2/sizer2.dart';

class DetailPlanSurchargeNote extends StatefulWidget {
  const DetailPlanSurchargeNote(
      {super.key,
      required this.plan,
      required this.isLeader,
      required this.totalOrder,
      required this.isOffline,
      required this.onRefreshData});
  final PlanDetail plan;
  final bool isLeader;
  final double totalOrder;
  final bool isOffline;
  final void Function() onRefreshData;

  @override
  State<DetailPlanSurchargeNote> createState() =>
      _DetailPlanSurchargeNoteState();
}

class _DetailPlanSurchargeNoteState extends State<DetailPlanSurchargeNote>
    with TickerProviderStateMixin {
  late TabController tabController;
  double _totalSurcharge = 0;
  bool isShowTotal = false;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() {
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    _totalSurcharge = (widget.plan.surcharges ?? []).fold(
      0,
      (previousValue, element) =>
          previousValue +
          (element.imagePath != null ? element.gcoinAmount : 0) *
              widget.plan.memberCount!,
    );
    isShowTotal = widget.plan.status != planStatuses[0].engName &&
        widget.plan.status != planStatuses[1].engName;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phụ thu & ghi chú',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSans',
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          TabBar(
              controller: tabController,
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                ),
                Tab(
                  icon: Icon(Icons.note_alt_outlined),
                ),
              ]),
          SizedBox(
            height: 60.h,
            child: TabBarView(controller: tabController, children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.plan.surcharges != null
                          ? widget.plan.surcharges!.length
                          : 0,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SurchargeCard(
                          maxMemberCount: widget.plan.maxMemberCount!,
                          isEnableToUpdate: (widget.isLeader &&
                                  planStatuses
                                          .firstWhere((element) =>
                                              element.engName ==
                                              widget.plan.status)
                                          .value >
                                      1) ||
                              (!widget.isLeader &&
                                  widget.plan.surcharges![index].imagePath !=
                                      null),
                          isCreate: false,
                          surcharge: widget.plan.surcharges![index],
                          isLeader: widget.isLeader,
                          isOffline: widget.isOffline,
                          callbackSurcharge: (dynamic) {
                            widget.onRefreshData();
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  PlanTotalInfo(
                      plan: widget.plan,
                      isShowTotal: isShowTotal,
                      totalOrder: widget.totalOrder.toInt(),
                      totalSurcharge: _totalSurcharge.toInt())
                ],
              ),
              Container(
                  height: 25.h,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Color(0xFFf2f2f2),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: widget.plan.note == null || widget.plan.note == 'null'
                      ? const Center(
                          child: Text(
                            'Không có ghi chú',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSans'),
                          ),
                        )
                      : HtmlWidget(widget.plan.note!)),
            ]),
          )
        ],
      ),
    );
  }
}
