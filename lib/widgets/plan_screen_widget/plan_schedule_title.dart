import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleTitle extends StatelessWidget {
  const PlanScheduleTitle(
      {super.key, required this.date, required this.isSelected});
  final DateTime date;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18.w,
      decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black12,
              offset: Offset(3, 5),
            )
          ],
          borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Column(children: [
        const SizedBox(
          height: 18,
        ),
        Text(
          DateFormat.MMMM('vi_VN').format(date),
          style: TextStyle(color: isSelected ? Colors.black : Colors.grey),
        ),
        const Spacer(),
        Text(
          DateFormat.d().format(date),
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey),
        ),
        const Spacer(),
        Text(
          DateFormat.EEEE('vi_VN').format(date),
          style: TextStyle(color: isSelected ? Colors.black : Colors.grey),
        ),
        const SizedBox(
          height: 18,
        ),
      ]),
    );
  }
}
