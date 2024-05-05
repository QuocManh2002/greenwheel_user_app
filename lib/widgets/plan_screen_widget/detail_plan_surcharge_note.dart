import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/surcharge_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class DetailPlanSurchargeNote extends StatefulWidget {
  const DetailPlanSurchargeNote({
    super.key,
    required this.plan,
    required this.isLeader,
  });
  final PlanDetail plan;
  final bool isLeader;

  @override
  State<DetailPlanSurchargeNote> createState() =>
      _DetailPlanSurchargeNoteState();
}

class _DetailPlanSurchargeNoteState extends State<DetailPlanSurchargeNote>
    with TickerProviderStateMixin {
  late TabController tabController;
  double _totalSurcharge = 0;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() {
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    if (widget.plan.surcharges != null) {
      for (final sur in widget.plan.surcharges!) {
        sur.alreadyDivided ?? true
            ? _totalSurcharge += sur.gcoinAmount * widget.plan.maxMemberCount!
            : _totalSurcharge += sur.gcoinAmount;
      }
    }
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
            height: 40.h,
            child: TabBarView(controller: tabController, children: [
              Column(
                children: [
                  SizedBox(
                    height: 30.h,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          for (final sur in widget.plan.surcharges!)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: SurchargeCard(
                                maxMemberCount: widget.plan.maxMemberCount!,
                                isEnableToUpdate:
                                    widget.plan.status != "REGISTERING" &&
                                        widget.plan.status != 'PENDING',
                                isCreate: false,
                                surcharge: sur,
                                isLeader: widget.isLeader,
                                callbackSurcharge: (dynamic) {},
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  if (_totalSurcharge != 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:  8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightPrimaryTextColor.withOpacity(0.5),
                          borderRadius:const BorderRadius.all(Radius.circular(12))
                        ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Tổng cộng: ',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoSans'),
                              ),
                              const Spacer(),
                              Text(
                                NumberFormat.simpleCurrency(
                                        locale: 'vi_VN', decimalDigits: 0, name: '')
                                    .format(_totalSurcharge),
                                style: const TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SvgPicture.asset(gcoinLogo, height: 18,),
                              SizedBox(
                                width: 5.w,
                              )
                            ],
                          ),
                          SizedBox(height: 0.5.h,),
                          Row(
                          children: [
                            const Text(
                              'Bình quân: ',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NotoSans'),
                            ),
                            const Spacer(),
                            Text(
                              NumberFormat.simpleCurrency(
                                      locale: 'vi_VN', decimalDigits: 0, name: '')
                                  .format(_totalSurcharge /
                                      widget.plan.maxMemberCount!),
                              style: const TextStyle(
                                fontFamily: 'NotoSans',
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SvgPicture.asset(gcoinLogo, height: 18,),
                            SizedBox(
                              width: 5.w,
                            )
                          ],
                        ),
                        ],
                      ),)
                    ),
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
