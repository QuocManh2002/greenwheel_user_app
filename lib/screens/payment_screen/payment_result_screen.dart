import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_screen.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen(
      {super.key,
      required this.amount,
      required this.planId,
      required this.isSuccess});
  final int amount;
  final int? planId;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        height: 100.h,
        width: 100.w,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.4),
            primaryColor.withOpacity(0.9)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              decoration: const BoxDecoration(
                  color: lightPrimaryTextColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
              child: Column(
                children: [
                  SizedBox(
                    height: 2.h,
                  ),
                  SvgPicture.asset(
                    appLogo,
                    height: 5.h,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    'Thanh toán${isSuccess ? '' : ' không'} thành công',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans',
                        color: Colors.black87),
                  ),
                  SizedBox(
                    height: 2.h,
                  )
                ],
              ),
            ),
            Container(
              height: 20,
              width: 80.w,
              color: lightPrimaryTextColor,
              child: Row(
                children: [
                  SizedBox(
                      width: 10,
                      height: 20,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10))),
                      )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Flex(
                          direction: Axis.horizontal,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                              (constraints.constrainWidth() / 10).floor(),
                              (index) => SizedBox(
                                    height: 0.8,
                                    width: 5,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade400),
                                    ),
                                  )),
                        );
                      },
                    ),
                  )),
                  SizedBox(
                      width: 10,
                      height: 20,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10))),
                      ))
                ],
              ),
            ),
            Container(
              width: 80.w,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                  color: lightPrimaryTextColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12))),
              child: Column(
                children: [
                  SizedBox(
                    height: 2.h,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text:
                            'Bạn đã ${planId != null ? 'thanh toán' : 'nạp'} ${isSuccess ? '' : 'không '}thành công ',
                        style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 18,
                            color: Colors.black87),
                        children: [
                          TextSpan(
                              text: NumberFormat.simpleCurrency(
                                      locale: 'vi_VN',
                                      decimalDigits: 0,
                                      name: 'GCOIN')
                                  .format(amount),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSuccess
                                      ? primaryColor
                                      : Colors.redAccent)),
                          // TextSpan(
                          //     text:
                          //         ' ${DateFormat('dd/MM/yyyy').format(DateTime.now())} ${DateFormat.Hm().format(DateTime.now())}')
                        ]),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thời gian',
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'NotoSans',
                            color: Colors.grey),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 40.w,
                        child: Text(
                          '${DateFormat('dd/MM/yyyy').format(DateTime.now())} ${DateFormat.Hm().format(DateTime.now())}',
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans'),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          // Navigator.of(context).pushAndRemoveUntil(
                          //     MaterialPageRoute(
                          //         builder: (ctx) =>
                          //             const TabScreen(pageIndex: 0)),
                          //     (route) => false);
                          // Navigator.push(
                          //   context,
                          //   PageTransition(
                          //       child: const TransactionHistoryScreen(),
                          //       type: PageTransitionType.topToBottom),
                          // );
                          Navigator.push(
                            context,
                            PageTransition(
                                child: const TabScreen(
                                  pageIndex: 2,
                                ),
                                type: PageTransitionType.topToBottom),
                          );
                        },
                        child: buildButton('Lịch sử giao dịch', Icons.history),
                      )),
                      SizedBox(
                        width: 3.w,
                      ),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          if (planId != null) {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (ctx) => const TabScreen(
                                          pageIndex: 1,
                                        )),
                                (route) => false);
                            Navigator.push(
                              context,
                              PageTransition(
                                  child: DetailPlanNewScreen(
                                    planId: planId!,
                                    planType: 'JOIN',
                                    isEnableToJoin: false,
                                  ),
                                  type: PageTransitionType.topToBottom),
                            );
                          } else {
                            Navigator.pushAndRemoveUntil(
                                context,
                                PageTransition(
                                    child: const TabScreen(pageIndex: 4),
                                    type: PageTransitionType.rightToLeft), (route) => false,);
                          }
                        },
                        child: buildButton('Quay lại', Icons.keyboard_return),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  buildButton(String title, IconData icon) => Container(
        decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 0.5.h,
            ),
            Icon(
              icon,
              color: primaryColor,
            ),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14, fontFamily: 'NotoSans', color: Colors.black87),
            ),
            SizedBox(
              height: 0.5.h,
            ),
          ],
        ),
      );
}
