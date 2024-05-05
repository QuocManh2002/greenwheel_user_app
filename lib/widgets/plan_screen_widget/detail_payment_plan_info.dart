
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class DetailPaymentPlanInfo extends StatelessWidget {
  const DetailPaymentPlanInfo(
      {super.key, required this.plan, required this.isView});
  final PlanDetail plan;
  final bool isView;

  @override
  Widget build(BuildContext context) {
    buildTextWidget(String text) => Text(
          text,
          textAlign: TextAlign.end,
          overflow: TextOverflow.clip,
          style: const TextStyle(fontFamily: 'NotoSans',
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        );
    return Column(
      children: [
        Container(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Thông tin chuyến đi',
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            )),
        SizedBox(
          height: 0.7.h,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              border:
                  Border.all(color: primaryColor.withOpacity(0.7), width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(12))),
          child: Column(children: [
            SizedBox(
              height: 0.5.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chuyến đi',
                  style: TextStyle(fontFamily: 'NotoSans', fontSize: 15, color: Colors.grey),
                ),
                const Spacer(),
                SizedBox(
                  width: 60.w,
                  child: buildTextWidget(plan.name!),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Divider(
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Địa điểm',
                  style: TextStyle(fontFamily: 'NotoSans', fontSize: 15, color: Colors.grey),
                ),
                const Spacer(),
                SizedBox(
                  width: 60.w,
                  child: buildTextWidget(plan.locationName!),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Divider(
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thời gian',
                  style: TextStyle(fontFamily: 'NotoSans', fontSize: 15, color: Colors.grey),
                ),
                const Spacer(),
                SizedBox(
                    width: 60.w,
                    child: buildTextWidget(
                        '${DateFormat('dd/MM/yyyy').format(plan.utcDepartAt!)} - ${DateFormat('dd/MM/yyyy').format(plan.utcEndAt!)}'))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Divider(
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Số người tối đa',
                  style: TextStyle(fontFamily: 'NotoSans', fontSize: 15, color: Colors.grey),
                ),
                const Spacer(),
                SizedBox(
                  width: 30.w,
                  child: buildTextWidget(plan.maxMemberCount! < 10
                      ? '0${plan.maxMemberCount}'
                      : plan.maxMemberCount.toString()),
                )
              ],
            ),
            if (!isView)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Divider(
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
            if (!isView)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số người đi cùng tối đa',
                    style: TextStyle(fontFamily: 'NotoSans', fontSize: 15, color: Colors.grey),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 30.w,
                    child: buildTextWidget(
                        plan.maxMemberWeight! < 11 && plan.maxMemberWeight! > 1
                            ? '0${plan.maxMemberWeight! - 1}'
                            : '${plan.maxMemberWeight! - 1}'),
                  )
                ],
              ),
            SizedBox(
              height: 0.5.h,
            )
          ]),
        ),
      ],
    );
  }
}
