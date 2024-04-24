import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_new_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/suggest_plan.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class SuggestPlanCard extends StatelessWidget {
  const SuggestPlanCard(
      {super.key,
      required this.plan,
      required this.imageUrl,
      required this.location});
  final SuggestPlanViewModel plan;
  final String imageUrl;
  final LocationViewModel location;

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
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                color: Colors.black12,
                offset: Offset(1, 3),
              )
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          height: 17.h,
          width: double.infinity,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.hardEdge,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(children: [
                Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(14)),
                    child: CachedNetworkImage(
                        height: 17.h,
                        width: 17.h,
                        fit: BoxFit.cover,
                        imageUrl: '$baseBucketImage/${17.h.ceil()}x${17.h.ceil()}$imageUrl',
                        placeholder: (context, url) =>
                            Image.memory(kTransparentImage),
                        errorWidget: (context, url, error) =>
                            Image.asset(empty_plan))),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 0.1.h,
                      ),
                      SizedBox(
                        width: 45.w,
                        child: Text(plan.planName,
                            overflow: TextOverflow.clip,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 0.2.h,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 20, color: primaryColor,),
                          SizedBox(width: 2.w,),
                          Text(
                            location.province.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'NotoSans'
                            ),
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
                          SvgPicture.asset(gcoin_logo, height: 18,)
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
