import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class SurchargeCard extends StatelessWidget {
  const SurchargeCard({super.key, required this.amount, required this.note});
  final int amount;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: const BorderRadius.all(Radius.circular(14))),
          child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 55.w,
                  child: Text(
                    note,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Container(
                  color: Colors.grey,
                  width: 2,
                  height: 7.h,
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 23.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        width: 16.w,
                        child: Text(
                          NumberFormat.simpleCurrency(locale: 'vi_VN', name: 'đ',decimalDigits: 0).format(amount),
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      // SvgPicture.asset(gcoin_logo, height: 25,),
                      SizedBox(width: 1.5.w,)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }
}