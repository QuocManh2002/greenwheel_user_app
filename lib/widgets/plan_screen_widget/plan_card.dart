import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_new_screen.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.plan});
  final PlanCardViewModel plan;

  @override
  Widget build(BuildContext context) {
    Widget buildStatusPoint(PlanCardViewModel plan) {
      Color pointColor = Colors.red;
      print("${plan.startDate} - ${plan.endDate}");
      print(DateTime.now());
      DateTime now = DateTime.now();
      if (now.isBefore(plan.startDate) && now.isAfter(plan.endDate)) {
        pointColor = primaryColor;
      } else if (now.isBefore(plan.endDate)) {
        pointColor = Colors.orange;
      } else if (now.isBefore(plan.startDate)) {
        pointColor = Colors.blue;
      }
      print(now.difference(plan.startDate));

      return Container(
        height: 1.5.h,
        width: 1.5.h,
        decoration: BoxDecoration(shape: BoxShape.circle, color: pointColor),
      );
    }

    return InkWell(
      onTap: () {
        sharedPreferences.setString('selectedDate', plan.startDate.toString());
        sharedPreferences.setInt('selectedDuration',
            plan.endDate.difference(plan.startDate).inDays + 1);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => DetailPlanNewScreen(
                  planId: plan.id,
                  location: plan.location,
                  isEnableToJoin: false,
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
                child: Hero(
                    tag: plan.id,
                    child: FadeInImage(
                      height: 15.h,
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(plan.location.imageUrls[0]),
                      fit: BoxFit.cover,
                      width: 15.h,
                      filterQuality: FilterQuality.high,
                    )),
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
                          child: Text(plan.name,
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
                    Text(plan.province.name),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                            '${plan.startDate.day}/${plan.startDate.month}/${plan.startDate.year} - ${plan.endDate.day}/${plan.endDate.month}/${plan.endDate.year}'),
                        const SizedBox(
                          width: 16,
                        ),
                        // if (plan.status == "OFFICIAL") buildStatusPoint(plan)
                      ],
                    )
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
