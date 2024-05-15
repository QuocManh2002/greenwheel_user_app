import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleTitle extends StatelessWidget {
  const PlanScheduleTitle(
      {super.key,
      required this.date,
      required this.isSelected,
      this.isValidEatActivities,
      this.isValidPeriodOfOrder,
      this.isValidSumOfActivity,
      this.maxSumActivityTime,
      required this.index});
  final DateTime date;
  final bool isSelected;
  final int index;
  final bool? isValidEatActivities;
  final bool? isValidPeriodOfOrder;
  final bool? isValidSumOfActivity;
  final Duration? maxSumActivityTime;

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
          if (isValidEatActivities != null || isValidPeriodOfOrder != null)
            Positioned(
                right: -0.4.w,
                top: 0,
                child: InkWell(
                    splashColor: Colors.transparent,
                    overlayColor:
                        const MaterialStatePropertyAll(Colors.transparent),
                    onTap: isValidEatActivities! && isValidPeriodOfOrder! && isValidSumOfActivity!
                        ? null
                        : () {
                            AwesomeDialog(
                                    context: context,
                                    animType: AnimType.leftSlide,
                                    dialogType: DialogType.warning,
                                    body: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w, vertical: 1.h),
                                      child: Column(
                                        children: [
                                          if (!isValidEatActivities!)
                                            Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 4),
                                                      child: Icon(
                                                        Icons.info,
                                                        color: Colors.orange,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 2.w,
                                                    ),
                                                    const Expanded(
                                                      child: Text(
                                                        'Ngày chưa đủ hoạt động ăn uống',
                                                        overflow:
                                                            TextOverflow.clip,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black54,
                                                          fontFamily:
                                                              'NotoSans',
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 0.1.h,
                                                ),
                                                const Divider(
                                                  thickness: 1.5,
                                                  color: Colors.black38,
                                                ),
                                              ],
                                            ),
                                          SizedBox(
                                            height: 1.h,
                                          ),
                                          if (!isValidPeriodOfOrder!)
                                            Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 4),
                                                      child: Icon(
                                                        Icons.warning,
                                                        color: Colors.red,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 1.w,
                                                    ),
                                                    const Expanded(
                                                      child: Text(
                                                        'Thời gian phục vụ đơn hàng không phù hợp với lịch trình',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black54,
                                                          fontFamily:
                                                              'NotoSans',
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 0.1.h,
                                                ),
                                                const Divider(
                                                  thickness: 1.5,
                                                  color: Colors.black38,
                                                ),
                                              ],
                                            ),
                                          if (!isValidSumOfActivity!)
                                            Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 4),
                                                      child: Icon(
                                                        Icons.warning,
                                                        color: Colors.red,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 1.w,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'Thời lượng lịch trình trong ngày đã vượt quá ${maxSumActivityTime!.inHours} giờ${maxSumActivityTime!.inMinutes.remainder(60) > 0 ? ' ${maxSumActivityTime!.inMinutes.remainder(60)} phút' : ''}',
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black54,
                                                          fontFamily:
                                                              'NotoSans',
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 0.1.h,
                                                ),
                                                const Divider(
                                                  thickness: 1.5,
                                                  color: Colors.black38,
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    btnOkColor: Colors.amber,
                                    btnOkOnPress: () {},
                                    btnOkText: 'OK')
                                .show();
                          },
                    child: Icon(
                      (!isValidPeriodOfOrder! || !isValidSumOfActivity!)
                          ? Icons.warning
                          : !isValidEatActivities!
                              ? Icons.error
                              : Icons.check_circle,
                      size: 18,
                      color: isValidEatActivities! &&
                              isValidPeriodOfOrder! &&
                              isValidSumOfActivity!
                          ? isSelected
                              ? Colors.white
                              : primaryColor
                          : (!isValidPeriodOfOrder! || !isValidSumOfActivity!)
                              ? Colors.red
                              : Colors.amber,
                    )))
        ],
      ),
    );
  }
}
