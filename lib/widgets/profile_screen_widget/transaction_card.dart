import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/view_models/profile_viewmodels/transaction.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard(
      {super.key, required this.index, required this.transaction});
  final Transaction transaction;
  final int index;
  @override
  Widget build(BuildContext context) {
    bool isNegative = false;
    if(transaction.receiverId != null){
      isNegative = false;
    }else{
      isNegative = true;
    }
    return Container(
      width: 100.w,
      decoration: BoxDecoration(
        color: index.isOdd ? Colors.white : lightPrimaryTextColor.withOpacity(0.7),
      ),
      padding:
          EdgeInsets.only(left: 2.h, top: 1.5.h, bottom: 1.5.h),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.grey.withOpacity(0.5), width: 0.5)),
            child:
            isNegative ? 
             Icon(
              Icons.account_balance,
              color: Colors.red.withOpacity(0.7),
              size: 25,
            ):
            const Icon(
              Icons.paid_sharp,
              color: Colors.blueAccent,
              size: 28,
            )
            ,
          ),
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
                      style:const TextStyle(
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
                      '${isNegative ? '-':'+'}${NumberFormat.simpleCurrency(
                              locale: 'vi_VN', decimalDigits: 0, name: '')
                          .format(transaction.gcoinAmount)}',
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
    );
  }
}
