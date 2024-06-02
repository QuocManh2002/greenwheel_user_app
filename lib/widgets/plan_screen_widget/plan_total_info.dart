import 'package:flutter/material.dart';
import 'package:phuot_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:phuot_app/widgets/plan_screen_widget/plan_amount_info.dart';

import '../../core/constants/global_constant.dart';
import '../../core/constants/plan_statuses.dart';

class PlanTotalInfo extends StatelessWidget {
  const PlanTotalInfo(
      {super.key,
      required this.plan,
      required this.isShowTotal,
      required this.totalOrder,
      required this.totalSurcharge});
  final PlanDetail plan;
  final bool isShowTotal;
  final int totalOrder;
  final int totalSurcharge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            color: Colors.grey.withOpacity(0.2)),
        child: Column(
          children: [
            PlanAmountInfo(
                title: 'Dự tính:',
                amount: plan.gcoinBudgetPerCapita! * plan.maxMemberCount!),
            PlanAmountInfo(
                title: 'Đã thu:',
                amount: plan.gcoinBudgetPerCapita! * plan.memberCount!),
            if (isShowTotal)
              Column(
                children: [
                  PlanAmountInfo(
                      title: 'Hiện tại:', amount: plan.actualGcoinBudget!),
                  PlanAmountInfo(
                      title: 'Khoản chi đơn hàng:',
                      amount: plan.status == planStatuses[0].engName ||
                              plan.status == planStatuses[1].engName
                          ? 0
                          : totalOrder ~/ GlobalConstant().VND_CONVERT_RATE),
                  PlanAmountInfo(
                      title: 'Khoản chi bên ngoài:',
                      amount: plan.status == planStatuses[1].engName
                          ? 0
                          : totalSurcharge),
                  PlanAmountInfo(
                      title: 'Số tiền đã bù:',
                      amount:
                          plan.maxMemberCount! * plan.gcoinBudgetPerCapita! -
                              plan.memberCount! * plan.gcoinBudgetPerCapita!),
                ],
              )
          ],
        ),
      ),
    );
  }
}
