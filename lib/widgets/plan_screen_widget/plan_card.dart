import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_new_screen.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.plan, required this.isOwned});
  final PlanCardViewModel plan;
  final bool isOwned;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => DetailPlanNewScreen(
                  planId: plan.id,
                  isEnableToJoin: false,
                  planType: isOwned ? 'OWNED' : 'JOIN',
                )));
      },
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
          color: Colors.white,
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
                  key: UniqueKey(),
                  fit: BoxFit.cover,
                  height: 15.h,
                  width: 15.h,
                  errorWidget: (context, url, error) =>
                      Image.network(defaultHomeImage),
                  placeholder: (context, url) =>
                      Image.memory(kTransparentImage),
                  imageUrl: '$baseBucketImage${plan.location.imageUrls[0]}',
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(plan.name ?? 'Chuyen di chua dat ten',
                              overflow: TextOverflow.clip,
                              maxLines: 2,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      plan.province.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                        '${DateFormat('dd/MM/yyyy').format(plan.utcStartAt)} - ${DateFormat('dd/MM/yyyy').format(plan.utcEndAt)}')
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
