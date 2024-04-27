import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleTitle extends StatelessWidget {
  const PlanScheduleTitle(
      {super.key,
      required this.date,
      required this.isSelected,
      required this.index});
  final DateTime date;
  final bool isSelected;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black12,
              offset: Offset(2, 4),
            )
          ],
          borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        // const Spacer(),
        Text(
          DateFormat.MMMM('vi_VN').format(date),
          style: TextStyle(
              fontSize: 14,
              fontFamily: 'NotoSans',
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500),
        ),
        Text(
          DateFormat.d().format(date),
          style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSans',
              color: isSelected ? Colors.white : Colors.grey),
        ),

        Text(
          DateFormat.EEEE('vi_VN').format(date),
          style: TextStyle(
              fontSize: 14,
              fontFamily: 'NotoSans',
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey),
        ),
      ]),
    );
  }
}
