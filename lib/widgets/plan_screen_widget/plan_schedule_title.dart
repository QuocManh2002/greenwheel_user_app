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
          // gradient: isSelected
          //     ? const LinearGradient(
          //         colors: [primaryColor, Color(0xFF82E0AA)],
          //         begin: Alignment.topCenter,
          //         end: Alignment.bottomCenter)
          //     : const LinearGradient(colors: [Colors.white,Colors.white]),
          color: isSelected ? primaryColor : Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black12,
              offset: Offset(2, 4),
            )
          ],
          borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Column(children: [
        const SizedBox(
          height: 18,
        ),
        Text(
          DateFormat.MMMM('vi_VN').format(date),
          style: TextStyle(
              fontSize: 15,
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          DateFormat.d().format(date),
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey),
        ),
        const Spacer(),
        Text(
          DateFormat.EEEE('vi_VN').format(date),
          style: TextStyle(
              fontSize: 15,
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 14,
        ),
      ]),
    );
  }
}
