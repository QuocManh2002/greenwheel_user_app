import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/transaction_history_screen.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class SuccessPaymentScreen extends StatelessWidget {
  const SuccessPaymentScreen({super.key, required this.amount});
  final int amount;

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
                  Image.asset(
                    app_logo,
                    height: 5.h,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  const Text(
                    'Thanh toán thành công',
                    style: TextStyle(
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
                    text:  TextSpan(
                        text: 'Bạn đã thanh toán thành công số tiền ',
                        style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 18,
                            color: Colors.black87),
                        children: [
                          TextSpan(
                              text: NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: 'GCOIN').format(amount),
                              style:const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                          TextSpan(text: ' ${DateFormat('dd/MM/yyyy').format(DateTime.now())} ${DateFormat.Hm().format(DateTime.now())}')
                        ]),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (ctx) =>
                                      const TabScreen(pageIndex: 0)),
                              (route) => false);
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: const TransactionHistoryScreen(),
                                  type: PageTransitionType.topToBottom),);
                        },
                        child: buildButton('Lịch sử giao dịch', Icons.history),
                      )),
                      SizedBox(
                        width: 3.w,
                      ),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              PageTransition(
                                  child: const TabScreen(pageIndex: 0),
                                  type: PageTransitionType.topToBottom),
                              (route) => false);
                        },
                        child: buildButton('Trang chủ', Icons.home),
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
