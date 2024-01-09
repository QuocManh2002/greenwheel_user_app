import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:sizer2/sizer2.dart';

class BaseInformationWidget extends StatelessWidget {
  const BaseInformationWidget({super.key, required this.plan});
  final PlanDetail plan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              plan.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            height: 1.8,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ngày khởi hành:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Ngày kết thúc:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Số lượng thành viên:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 3.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plan.startDate.day}/${plan.startDate.month}/${plan.startDate.year}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    '${plan.endDate.day}/${plan.endDate.month}/${plan.endDate.year}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    '${plan.memberLimit} người',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            height: 1.8,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}
