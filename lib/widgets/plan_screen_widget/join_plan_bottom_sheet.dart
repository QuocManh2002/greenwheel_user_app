import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class JoinPlanBottomSheet extends StatefulWidget {
  const JoinPlanBottomSheet({super.key, required this.plan});
  final PlanDetail plan;

  @override
  State<JoinPlanBottomSheet> createState() => _JoinPlanBottomSheetState();
}

class _JoinPlanBottomSheetState extends State<JoinPlanBottomSheet> {
  int weight = 1;

  onChangeWeight(bool isAdd) {
    if (isAdd && weight < widget.plan.maxMemberCount! - widget.plan.memberCount!) {
      setState(() {
        weight += 1;
      });
    } else if (!isAdd && weight > 1) {
      setState(() {
        weight -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.center,
              height: 6,
              width: 10.h,
              decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
            ),
            SizedBox(
              height: 2.h,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: primaryColor.withOpacity(0.7), width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
              child: Row(
                children: [
                  const Text(
                    'Số dư của bạn',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.simpleCurrency(
                            locale: 'en-US', decimalDigits: 0, name: "")
                        .format(sharedPreferences.getDouble('userBalance')),
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  SvgPicture.asset(
                    gcoinLogo,
                    height: 28,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 1.5.h,
            ),
            Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Thông tin chuyến đi',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                )),
            SizedBox(
              height: 0.7.h,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: primaryColor.withOpacity(0.7), width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
              child: Column(children: [
                SizedBox(
                  height: 1.h,
                ),
                Row(
                  children: [
                    const Text(
                      'Chuyến đi',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        widget.plan.name!,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    )
                  ],
                ),
                buildDivider(),
                Row(
                  children: [
                    const Text(
                      'Địa điểm',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        widget.plan.locationName!,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    )
                  ],
                ),
                buildDivider(),
                Row(
                  children: [
                    const Text(
                      'Thời gian',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        '${DateFormat('dd/MM/yyyy').format(widget.plan.utcDepartAt!)} - ${DateFormat('dd/MM/yyyy').format(widget.plan.utcEndAt!)}',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    )
                  ],
                ),
                buildDivider(),
                Row(
                  children: [
                    const Text(
                      'Số người tối đa',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 30.w,
                      child: Text(
                        widget.plan.maxMemberCount! < 10
                            ? '0${widget.plan.maxMemberCount}'
                            : widget.plan.maxMemberCount.toString(),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 1.h,
                )
              ]),
            ),
            SizedBox(
              height: 1.5.h,
            ),
            Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Chi tiết thanh toán',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                )),
            SizedBox(
              height: 0.7.h,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: primaryColor.withOpacity(0.7), width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
              child: Column(
                children: [
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Chi phí tham gia',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 40.w,
                        child: Text(
                          NumberFormat.simpleCurrency(
                                  locale: 'en-US', decimalDigits: 0, name: "")
                              .format(widget.plan.gcoinBudgetPerCapita),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        width: 1.h,
                      ),
                      SvgPicture.asset(
                        gcoinLogo,
                        height: 30,
                      )
                    ],
                  ),
                  buildDivider(),
                  Row(
                    children: [
                      const Text(
                        'Người đại diện',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 40.w,
                        child: Text(
                          sharedPreferences.getString('userName')!,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  buildDivider(),
                  Row(
                    children: [
                      const Text(
                        'Số người của nhóm bạn',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Spacer(),
                      InkWell(
                        overlayColor:
                            const MaterialStatePropertyAll(Colors.transparent),
                        onTap: () {
                          onChangeWeight(false);
                        },
                        child: const Icon(Icons.remove),
                      ),
                      SizedBox(
                        width: 0.5.h,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8))),
                        alignment: Alignment.center,
                        width: 6.h,
                        child: Text(
                          weight.toString(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 0.5.h,
                      ),
                      InkWell(
                        overlayColor:
                            const MaterialStatePropertyAll(Colors.transparent),
                        onTap: () {
                          onChangeWeight(true);
                        },
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  buildDivider(),
                  Row(
                    children: [
                      const Text(
                        'Tạm tính',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        NumberFormat.simpleCurrency(
                                locale: 'en-US', decimalDigits: 0, name: "")
                            .format(weight * widget.plan.gcoinBudgetPerCapita!),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      SizedBox(
                        width: 1.h,
                      ),
                      SvgPicture.asset(
                        gcoinLogo,
                        height: 30,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Spacer(),
                    Text(
                      NumberFormat.simpleCurrency(
                              locale: 'en-US', decimalDigits: 0, name: "")
                          .format(weight * widget.plan.gcoinBudgetPerCapita!),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    SizedBox(
                      width: 1.h,
                    ),
                    SvgPicture.asset(
                      gcoinLogo,
                      height: 30,
                    )
                  ],
                ),
                SizedBox(
                  height: 1.h,
                ),
                ElevatedButton(
                  onPressed: () {
                    AwesomeDialog(
                            context: context,
                            animType: AnimType.leftSlide,
                            dialogType: DialogType.question,
                            title:
                                'Thanh toán ${widget.plan.gcoinBudgetPerCapita} ${weight != 1 ? 'x $weight = ${widget.plan.gcoinBudgetPerCapita! * weight}' : ''} GCOIN',
                            titleTextStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            btnOkColor: Colors.blue,
                            btnOkText: 'Chơi',
                            btnOkOnPress: () {},
                            btnCancelColor: Colors.deepOrangeAccent,
                            btnCancelOnPress: () {},
                            btnCancelText: 'Huỷ')
                        .show();
                  },
                  style: elevatedButtonStyle.copyWith(
                      minimumSize: MaterialStatePropertyAll(Size(100.w, 50))),
                  child: const Text(
                    'Thanh toán',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                )
              ],
            )
          ]),
    );
  }

  buildDivider() => Column(
        children: [
          SizedBox(
            height: 0.7.h,
          ),
          Container(
            color: Colors.grey.withOpacity(0.5),
            height: 1.2,
          ),
          SizedBox(
            height: 0.7.h,
          ),
        ],
      );
}
