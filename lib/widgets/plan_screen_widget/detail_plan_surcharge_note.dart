import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  });
  final PlanDetail plan;

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
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() {
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _totalSurcharge = widget.plan.surcharges!.fold(0, (previousValue, element) => element.gcoinAmount.toDouble());
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
                      child: Column(children: [
                        for(final sur in widget.plan.surcharges!)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SurchargeCard(amount: sur.gcoinAmount, note: sur.note),
                        )
                      ],),
                    ),
                  ),
                  if (_totalSurcharge != 0)
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
                  SvgPicture.asset(gcoin_logo, height: 20, fit: BoxFit.cover,)
                ],
              ),
            if ( _totalSurcharge != 0)
              Row(
                children: [
                  const Text(
                    'Chi phí bình quân: ',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans'),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.simpleCurrency(
                            locale: 'vi_VN', decimalDigits: 0, name: 'đ')
                        .format(_totalSurcharge /
                            widget.plan.maxMemberCount),
                    style: const TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SvgPicture.asset(
                    gcoin_logo,
                    height: 20,
                    fit: BoxFit.cover,
                  )
                ],
              ),
                ],
              ),
              Container(
                height: 35.h,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Color(0xFFf2f2f2),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: HtmlWidget(widget.plan.note ?? '')),
            ]),
          )
        ],
      ),
    );
  }
}
