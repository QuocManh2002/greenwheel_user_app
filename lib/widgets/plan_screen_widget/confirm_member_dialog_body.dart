import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:intl/intl.dart';

class ConfirmMemberDialogBody extends StatelessWidget {
  const ConfirmMemberDialogBody({super.key, required this.plan});
  final PlanDetail plan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Text(
            'Chuyến đi chưa đủ thành viên',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text(
                'Số lượng thành viên',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '${plan.memberCount! < 10 ? '0${plan.memberCount}' : plan.memberCount}/${plan.maxMemberCount! < 10 ? '0${plan.maxMemberCount}' : plan.maxMemberCount}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          Row(
            children: [
              const Text(
                'Thời gian',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '${DateFormat('dd/MM/yyyy').format(plan.utcDepartAt!)} - ${DateFormat('dd/MM/yyyy').format(plan.utcEndAt!)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          Row(
            children: [
              const Text(
                'Chi phí tham gia',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                NumberFormat.simpleCurrency(
                        locale: 'vi_VN', decimalDigits: 0, name: 'GCOIN')
                    .format(plan.gcoinBudgetPerCapita),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Thanh toán thêm ${NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: '').format(plan.gcoinBudgetPerCapita)}${plan.maxMemberCount! - plan.memberCount! > 1 ? ' x ${plan.maxMemberCount! - plan.memberCount!} = ${NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: '').format(plan.gcoinBudgetPerCapita! * (plan.maxMemberCount! - plan.memberCount!))}' : ''}GCOIN để chốt số lượng thành viên cho chuyến đi',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
