import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleActivityView extends StatelessWidget {
  const PlanScheduleActivityView({super.key, required this.item});
  final PlanScheduleItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12,left: 6, right: 6),
      child: Container(
        width: 100.w,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: const Color(0xFFf2f2f2),
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                color: Colors.black12,
                offset: Offset(2, 4),
              )
            ],
            border: item.orderId != null
                ? Border.all(color: primaryColor, width: 2)
                : const Border(),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.shortDescription ?? 'Không có mô tả',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
              ),
              Container(
                color: Colors.black26,
                height: 1.5,
              ),
              Text(
                item.description ?? 'Không có mô tả',
                style:
                    const TextStyle(fontSize: 18, color: Colors.black54),
                overflow: TextOverflow.clip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
