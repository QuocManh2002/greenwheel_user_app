import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/urls.dart';
import '../../main.dart';
import '../../service/plan_service.dart';
import '../../service/traveler_service.dart';
import '../../view_models/plan_member.dart';
import '../../view_models/plan_viewmodels/plan_detail.dart';
import '../../widgets/style_widget/button_style.dart';
import '../../widgets/style_widget/dialog_style.dart';
import '../loading_screen/transaction_detail_loading_screen.dart';
import '../payment_screen/payment_result_screen.dart';
import 'create_plan/input_companion_name_screen.dart';

class JoinConfirmPlanScreen extends StatefulWidget {
  const JoinConfirmPlanScreen(
      {super.key,
      required this.plan,
      required this.isPublic,
      this.callback,
      required this.isView,
      this.onPublicizePlan,
      this.member,
      required this.isConfirm});
  final PlanDetail plan;
  final bool isPublic;
  final bool isConfirm;
  final bool isView;
  final PlanMemberViewModel? member;
  final void Function(bool isFromJoinScreen, int? amount, BuildContext context)? onPublicizePlan;
  final void Function()? callback;

  @override
  State<JoinConfirmPlanScreen> createState() => _JoinPlanScreenState();
}

class _JoinPlanScreenState extends State<JoinConfirmPlanScreen> {
  final PlanService _planService = PlanService();
  int weight = 1;
  double? newBalance;
  int? travelerBalance;
  List<String> companionNames = [];
  bool isEnableToAdd = false;
  bool isEnableToSubtract = false;
  final CustomerService _customerService = CustomerService();
  bool isLoading = true;

  onChangeWeight(bool isAdd) {
    if (isAdd && isEnableToAdd) {
      setState(() {
        weight += 1;
      });
      if (!isEnableToSubtract) {
        setState(() {
          isEnableToSubtract = true;
        });
      }
      if (widget.member == null
          ? (weight == widget.plan.maxMemberWeight ||
              weight == widget.plan.maxMemberCount! - widget.plan.memberCount!)
          : (weight == widget.plan.maxMemberWeight! - widget.member!.weight ||
              weight ==
                  widget.plan.maxMemberCount! - widget.plan.memberCount!)) {
        setState(() {
          isEnableToAdd = false;
        });
      }
    } else if (!isAdd && weight > 1) {
      setState(() {
        weight -= 1;
      });
      if (weight == 1) {
        setState(() {
          isEnableToSubtract = false;
          companionNames.clear();
        });
      }
      if (!isEnableToAdd) {
        setState(() {
          isEnableToAdd = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    if (widget.isConfirm) {
      weight = widget.plan.maxMemberCount! - widget.plan.memberCount!;
    }
    isEnableToAdd = widget.member == null
        ? (weight < widget.plan.maxMemberWeight! &&
            weight < widget.plan.maxMemberCount! - widget.plan.memberCount!)
        : (weight < widget.plan.maxMemberWeight! - widget.member!.weight &&
            weight < widget.plan.maxMemberCount! - widget.plan.memberCount!);

    isEnableToSubtract = weight > 1;
    travelerBalance = await _customerService
        .getTravelerBalance(sharedPreferences.getInt('userId')!);
    if (travelerBalance != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title:
            Text(widget.isConfirm ? 'Xác nhận bù tiền' : 'Xác nhận tham gia'),
      ),
      body: isLoading
          ? const TransactionDetailLoadingScreen()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: primaryColor.withOpacity(0.7), width: 2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
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
                                      locale: 'vi_VN',
                                      decimalDigits: 0,
                                      name: "")
                                  .format(travelerBalance),
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: primaryColor.withOpacity(0.7), width: 2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        child: Column(children: [
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Chuyến đi',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
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
                                      fontWeight: FontWeight.bold,
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
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
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
                                      fontWeight: FontWeight.bold,
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
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 60.w,
                                child: Text(
                                  '${DateFormat('dd/MM').format(widget.plan.utcDepartAt!)} - ${DateFormat('dd/MM').format(widget.plan.utcEndAt!)}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
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
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
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
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              )
                            ],
                          ),
                          if (widget.plan.maxMemberWeight! > 1) buildDivider(),
                          if (widget.plan.maxMemberWeight! > 1)
                            Row(
                              children: [
                                SizedBox(
                                  width: 60.w,
                                  child: const Text(
                                    'Thành viên tối đa của 1 nhóm',
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  widget.plan.maxMemberWeight! < 10
                                      ? '0${widget.plan.maxMemberWeight!}'
                                      : '${widget.plan.maxMemberWeight!}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                )
                              ],
                            ),
                          if (widget.isConfirm) buildDivider(),
                          if (widget.isConfirm)
                            Row(
                              children: [
                                SizedBox(
                                  width: 60.w,
                                  child: const Text(
                                    'Đã tham gia',
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  widget.plan.memberCount! < 10
                                      ? '0${widget.plan.memberCount!}'
                                      : '${widget.plan.memberCount!}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: primaryColor.withOpacity(0.7), width: 2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 1.h,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Chi phí tham gia',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 35.w,
                                  child: Text(
                                    NumberFormat.simpleCurrency(
                                            locale: 'vi-VN',
                                            decimalDigits: 0,
                                            name: "")
                                        .format(
                                            widget.plan.gcoinBudgetPerCapita),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                SvgPicture.asset(
                                  gcoinLogo,
                                  height: 25,
                                )
                              ],
                            ),
                            buildDivider(),
                            Row(
                              children: [
                                const Text(
                                  'Người đại diện',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
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
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            buildDivider(),
                            Row(
                              children: [
                                Text(
                                  widget.isConfirm
                                      ? 'Số thành viên phải bù'
                                      : 'Số người của nhóm',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                const Spacer(),
                                if (!widget.isConfirm &&
                                    widget.plan.maxMemberWeight != 1 &&
                                    isEnableToSubtract)
                                  InkWell(
                                    overlayColor:
                                        const MaterialStatePropertyAll(
                                            Colors.transparent),
                                    onTap: () {
                                      onChangeWeight(false);
                                    },
                                    child: Icon(
                                      Icons.remove,
                                      color: isEnableToSubtract
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                SizedBox(
                                  width: 0.5.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: widget.isConfirm ||
                                              (!isEnableToAdd &&
                                                  !isEnableToSubtract)
                                          ? const Border()
                                          : Border.all(
                                              color: Colors.grey, width: 1.5),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8))),
                                  alignment:
                                      (!isEnableToAdd && !isEnableToSubtract) ||
                                              widget.isConfirm
                                          ? Alignment.centerRight
                                          : Alignment.center,
                                  width: 6.h,
                                  child: Text(
                                    weight.toString(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: 0.5.h,
                                ),
                                if (!widget.isConfirm &&
                                    widget.plan.maxMemberWeight != 1 &&
                                    isEnableToAdd)
                                  InkWell(
                                    overlayColor:
                                        const MaterialStatePropertyAll(
                                            Colors.transparent),
                                    onTap: () {
                                      onChangeWeight(true);
                                    },
                                    child: Icon(
                                      Icons.add,
                                      color: isEnableToAdd
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            buildDivider(),
                            Row(
                              children: [
                                const Text(
                                  'Tạm tính',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                const Spacer(),
                                Text(
                                  NumberFormat.simpleCurrency(
                                          locale: 'vi-VN',
                                          decimalDigits: 0,
                                          name: "")
                                      .format(weight *
                                          widget.plan.gcoinBudgetPerCapita!),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                SizedBox(
                                  width: 1.h,
                                ),
                                SvgPicture.asset(
                                  gcoinLogo,
                                  height: 25,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  widget.isConfirm ? 'Tổng cộng tiền bù' : 'Tổng cộng',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  NumberFormat.simpleCurrency(
                          locale: 'vi-VN', decimalDigits: 0, name: "")
                      .format(weight * widget.plan.gcoinBudgetPerCapita!),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                if (!widget.isConfirm) {
                  if (weight != 1 || widget.member != null) {
                    handleInputInformation();
                  } else {
                    handleJoin();
                  }
                } else {
                  handleConfirm();
                }
              },
              style: elevatedButtonStyle.copyWith(
                  minimumSize: MaterialStatePropertyAll(Size(100.w, 50))),
              child: Text(
                widget.isConfirm || (widget.member == null && weight == 1)
                    ? 'Thanh toán'
                    : 'Nhập thông tin',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 1.h,
            )
          ],
        ),
      ),
    ));
  }

  handleInputInformation() {
    if (companionNames.isNotEmpty) {
      if (weight - 1 < companionNames.length) {
        companionNames = companionNames
            .splitAfterIndexed((index, element) => index == weight - 2)
            .first;
      }
    }
    Navigator.push(
        context,
        PageTransition(
            child: InputCompanionNameScreen(
              initNames: companionNames,
              weight: widget.member == null ? weight - 1 : weight,
              callback: callback,
              onJoin: handleJoin,
            ),
            type: PageTransitionType.rightToLeft));
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

  handleJoin() {
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            dialogType: DialogType.question,
            title:
                'Thanh toán ${NumberFormat.simpleCurrency(locale: 'vi-VN', decimalDigits: 0, name: "").format(widget.plan.gcoinBudgetPerCapita)}${weight != 1 ? 'x $weight = ${NumberFormat.simpleCurrency(locale: 'vi-VN', decimalDigits: 0, name: "").format(widget.plan.gcoinBudgetPerCapita! * weight)}' : ''}GCOIN',
            titleTextStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            btnOkColor: Colors.deepOrangeAccent,
            btnOkText: 'Đồng ý',
            btnOkOnPress: () async {
              final rs = await _planService.joinPlan(
                  widget.plan.id!, companionNames, context);
              if (rs != null) {
                handleJoinSuccess();
              }
            },
            btnCancelColor: Colors.blueAccent,
            btnCancelOnPress: () {},
            btnCancelText: 'Huỷ')
        .show();
  }

  handleConfirm() {
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            dialogType: DialogType.question,
            title:
                'Thanh toán ${NumberFormat.simpleCurrency(locale: 'vi-VN', decimalDigits: 0, name: "").format(widget.plan.gcoinBudgetPerCapita)}${widget.plan.maxMemberCount! - widget.plan.memberCount! > 1 ? ' x ${widget.plan.maxMemberCount! - widget.plan.memberCount!} = ${NumberFormat.simpleCurrency(locale: 'vi-VN', decimalDigits: 0, name: "").format(widget.plan.gcoinBudgetPerCapita! * (widget.plan.maxMemberCount! - widget.plan.memberCount!))}' : ''} GCOIN',
            titleTextStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            btnOkColor: Colors.blue,
            btnOkText: 'Chơi',
            btnOkOnPress: () async {
              final rs =
                  await _planService.confirmMember(widget.plan.id!, context);
              if (rs != 0) {
                DialogStyle().successDialog(
                    // ignore: use_build_context_synchronously
                    context,
                    "Đã chốt số lượng thành viên");
                Future.delayed(const Duration(milliseconds: 1500), () {
                  widget.callback!();
                  Navigator.of(context).pop();
                });
              }
            },
            btnCancelColor: Colors.deepOrangeAccent,
            btnCancelOnPress: () {},
            btnCancelText: 'Huỷ')
        .show();
  }

  callback(List<String> names) {
    companionNames = names;
  }

  handleJoinSuccess() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (ctx) => PaymentResultScreen(
                  planId: widget.plan.id!,
                  isSuccess: true,
                  isPublicPlan: widget.isPublic,
                  onPublic: widget.isPublic ? widget.onPublicizePlan : null,
                  amount: widget.plan.gcoinBudgetPerCapita! * weight,
                )),
        (route) => false);
  }
}
