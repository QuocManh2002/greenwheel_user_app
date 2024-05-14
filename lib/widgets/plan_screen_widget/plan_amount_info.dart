import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/urls.dart';

class PlanAmountInfo extends StatelessWidget {
  const PlanAmountInfo({
    super.key,
    required this.title,
    required this.amount,
  });
  final String title;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w300, color: Colors.black87),
        ),
        Expanded(
          child: Text(
            NumberFormat.simpleCurrency(
                    locale: 'vi_VN', decimalDigits: 0, name: "")
                .format(amount),
            textAlign: TextAlign.end,
            overflow: TextOverflow.clip,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: SvgPicture.asset(
            gcoinLogo,
            height: 18,
          ),
        ),
        SizedBox(
          width: 5.w,
        )
      ],
    );
  }
}
