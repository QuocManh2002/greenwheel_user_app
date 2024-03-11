import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:intl/intl.dart';
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
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Địa điểm:",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    "Ngày khởi hành:",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    "Ngày kết thúc:",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    "Số người tối đa:",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  if (plan.memberCount! > 0)
                    const SizedBox(
                      height: 12,
                    ),
                  if (plan.memberCount! > 0)
                    const Text(
                      "Số người đã tham gia:",
                      style: TextStyle(
                        fontSize: 18,
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
                    plan.locationName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(plan.departureDate!),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(plan.endDate!),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    '${plan.memberLimit < 10 ? '0${plan.memberLimit}' : plan.memberLimit} người',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (plan.memberCount! > 0)
                    const SizedBox(
                      height: 12,
                    ),
                  if (plan.memberCount! > 0)
                    Text(
                      '${plan.memberCount! > 0 && plan.memberCount! < 10 ? '0${plan.memberCount}' : plan.memberCount} người',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
