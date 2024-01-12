import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleActivity extends StatelessWidget {
  const PlanScheduleActivity(
      {super.key,
      required this.item,
      required this.showBottomSheet,
      required this.isSelected});
  final PlanScheduleItem item;
  final void Function(PlanScheduleItem item) showBottomSheet;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
          child: Container(
            width: 100.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                color:
                    isSelected ? primaryColor.withOpacity(0.3) : Colors.white,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.black12,
                    offset: Offset(2, 4),
                  )
                ],
                border: item.orderId != null
                    ? Border.all(color: primaryColor, width: 2)
                    : Border(),
                borderRadius: const BorderRadius.all(Radius.circular(12))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      item.orderId == null
                          ? IconButton(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onPressed: () {
                                showBottomSheet(item);
                              },
                              icon: const Icon(
                                Icons.more_horiz,
                              ))
                          : SizedBox(
                              height: 4.h,
                              child: const Icon(
                                Icons.restaurant,
                                color: primaryColor,
                              ))
                    ],
                  ),
                  Container(
                    color: Colors.black54,
                    height: 2,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.local_activity, size: 22,),
                          SizedBox(
                            height: 1.h,
                          ),
                          const Icon(Icons.calendar_month, size: 22,),
                          SizedBox(
                            height: 1.h,
                          ),
                          const Icon(Icons.watch_later_outlined, size: 22,),
                        ],
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            item.type!,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.clip,
                          ),
                          SizedBox(
                            height: 0.8.h,
                          ),
                          Text(
                            DateFormat.yMMMMEEEEd('vi_VN').format(item.date!),
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 0.8.h,
                          ),
                          Text(
                            DateFormat.Hm().format(DateTime(
                                0, 0, 0, item.time.hour, item.time.minute)),
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
