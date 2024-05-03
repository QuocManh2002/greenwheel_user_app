import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/widgets/style_widget/dialog_style.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleTitle extends StatelessWidget {
  const PlanScheduleTitle(
      {super.key,
      required this.date,
      required this.isSelected,
      this.isValidEatActivities,
      required this.index});
  final DateTime date;
  final bool isSelected;
  final int index;
  final bool? isValidEatActivities;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 21.w,
      child: Stack(
        children: [
          Container(
            width: 20.w,
            decoration: BoxDecoration(
                color: isSelected ? primaryColor : lightPrimaryTextColor,
                borderRadius: const BorderRadius.all(Radius.circular(12))),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
          ),
          if (isValidEatActivities != null)
            Positioned(
                right: - 0.4.w,
                top: 0,
                child: InkWell(
                    splashColor: Colors.transparent,
                    overlayColor: const MaterialStatePropertyAll(Colors.transparent),
                    onTap: isValidEatActivities!
                        ? null
                        : () {
                            DialogStyle().basicDialog(
                                context: context,
                                title: 'Ngày chưa đủ hoạt động ăn uống',
                                desc: 'Hãy bổ sung cho chuyến đi thật đầy đủ nhé',
                                type: DialogType.warning);
                          },
                    child: Icon(
                      isValidEatActivities!
                          ? Icons.check_circle
                          : Icons.error,
                      size: 18,
                      color: isValidEatActivities!
                          ? isSelected
                              ? Colors.white
                              : primaryColor
                          : Colors.redAccent.withOpacity(0.8),
                    )))
        ],
      ),
    );
  }
}
