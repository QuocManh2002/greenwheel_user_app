import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/profie_screen/transaction_detail_screen.dart';
import 'package:greenwheel_user_app/view_models/profile_viewmodels/transaction.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard(
      {super.key, required this.index, required this.transaction});
  final Transaction transaction;
  final int index;
  @override
  Widget build(BuildContext context) {
    bool isNegative = false;
    Icon? icon;
    switch (transaction.type) {
      case 'GIFT':
        icon = const Icon(
          Icons.monetization_on_outlined,
          color: Colors.pinkAccent,
          size: 25,
        );
        isNegative = false;
        break;
      case 'ORDER':
        icon = const Icon(
          Icons.shopping_cart_checkout_outlined,
          color: primaryColor,
          size: 25,
        );
        isNegative = true;
        break;
      case 'ORDER_REFUND':
        icon = const Icon(
          Icons.remove_shopping_cart_outlined,
          color: Colors.orange,
          size: 25,
        );
        isNegative = false;
        break;
      case 'PLAN_FUND':
        icon = const Icon(
          Icons.backpack,
          color: Colors.blueAccent,
          size: 25,
        );
        isNegative = true;
        break;
      case 'PLAN_REFUND':
        icon = const Icon(
          Icons.no_backpack,
          color: Colors.amber,
          size: 25,
        );
        isNegative = false;
        break;
      case 'TOPUP':
        icon = Icon(
          Icons.account_balance,
          color: Colors.redAccent.withOpacity(0.8),
          size: 25,
        );
        isNegative = false;
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                child: TransactionDetailScreen(
                  transaction: transaction,
                  icon: icon!,
                ),
                type: PageTransitionType.rightToLeft));
      },
      child: Container(
        width: 100.w,
        decoration: BoxDecoration(
          color: index.isOdd
              ? Colors.white
              : lightPrimaryTextColor.withOpacity(0.7),
        ),
        padding: EdgeInsets.only(left: 2.h, top: 1.5.h, bottom: 1.5.h),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.5), width: 0.5)),
                child: icon),
            SizedBox(
              width: 1.h,
            ),
            SizedBox(
              width: 78.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 70.w,
                      child: Text(
                        transaction.description ?? 'Không có mô tả',
                        style: const TextStyle(
                            fontSize: 17,
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                        overflow: TextOverflow.clip,
                      )),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        '${DateFormat.Hm().format(transaction.createdAt!)} - ${DateFormat('dd/MM/yyyy').format(transaction.createdAt!)}',
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontFamily: 'NotoSans'),
                      ),
                      const Spacer(),
                      Text(
                        '${isNegative ? '-' : '+'}${NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: '').format(transaction.gcoinAmount)}',
                        style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SvgPicture.asset(
                        gcoin_logo,
                        height: 25,
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
