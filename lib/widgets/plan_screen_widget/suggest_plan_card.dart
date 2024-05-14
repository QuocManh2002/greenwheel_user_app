import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_screen.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/suggest_plan.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class SuggestPlanCard extends StatelessWidget {
  const SuggestPlanCard({
    super.key,
    required this.plan,
  });
  final SuggestPlanViewModel plan;

  @override
  Widget build(BuildContext context) {
    final combodate = listComboDate
        .firstWhere((element) => element.duration == plan.periodCount);

    return InkWell(
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                child: DetailPlanNewScreen(
                  isEnableToJoin: false,
                  planId: plan.id,
                  planType: 'PUBLISH',
                  isClone: true,
                ),
                type: PageTransitionType.rightToLeft));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                color: Colors.black12,
                offset: Offset(1, 3),
              )
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 0.1.h,
                ),
                Text(plan.planName,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 0.2.h,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: primaryColor,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      plan.locationName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NotoSans'),
                    )
                  ],
                ),
                SizedBox(
                  height: 0.2.h,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: primaryColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      '${combodate.numberOfDay} ngày, ${combodate.numberOfNight} đêm',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NotoSans'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 0.2.h,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      NumberFormat.simpleCurrency(
                              locale: 'vi_VN', name: '', decimalDigits: 0)
                          .format(plan.gcoinBudgetPerCapita),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NotoSans'),
                    ),
                    SvgPicture.asset(
                      gcoinLogo,
                      height: 18,
                    ),
                    const Text(
                      ' /',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    const Icon(
                      Icons.person,
                      color: primaryColor,
                      size: 22,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
