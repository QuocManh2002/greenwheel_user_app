import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    return InkWell(
      onTap: () {
        // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SuggestPlanDetailScreen(planId: plan.id, leaderName: plan.leaderName,location: location,)));
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
          height: 15.h,
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
                      height: 15.h,
                      width: 15.h,
                      fit: BoxFit.cover,
                      imageUrl: '$baseBucketImage$imageUrl',
                      placeholder: (context, url) =>
                          Image.memory(kTransparentImage),
                      errorWidget: (context, url, error) =>
                          FadeInImage.assetNetwork(
                        height: 15.h,
                        width: 15.h,
                        fit: BoxFit.cover,
                        placeholder: 'No Image',
                        image:
                            'https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0',
                      ),
                    )),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 0.2.h,
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
                        height: 0.5.h,
                      ),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(plan.departDate.toLocal())} - ${DateFormat('dd/MM/yyyy').format(plan.endDate.toLocal())}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      SizedBox(
                        width: 50.w,
                        child: RichText(
                          text: TextSpan(
                              text: 'Trưởng đoàn: ',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                              children: [
                                TextSpan(
                                    text: '${plan.leaderName}',
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold))
                              ]),
                          overflow: TextOverflow.ellipsis,
                        ),
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
