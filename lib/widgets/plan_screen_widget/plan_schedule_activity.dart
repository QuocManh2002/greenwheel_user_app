
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/bottom_sheet_container_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleActivity extends StatelessWidget {
  const PlanScheduleActivity(
      {super.key,
      required this.item,
      required this.showBottomSheet,
      required this.isCreate,
      required this.isSelected});
  final PlanScheduleItem item;
  final void Function(PlanScheduleItem item) showBottomSheet;
  final bool isSelected;
  final bool isCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            showModalBottomSheet(
            context: context, 
            builder: (ctx) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 8),
              
              child: SizedBox(
                width: 100.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 2.h,),
                    Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.6),
                        borderRadius: const BorderRadius.all(Radius.circular(12))
                      ),
                      height: 6,
                      width: 10.h,
                    ),
                    SizedBox(height: 2.h,),
                    BottomSheetContainerWidget(content: item.shortDescription!, title: 'Mô tả'),
                    SizedBox(height: 1.h,),
                    BottomSheetContainerWidget(content: item.description!, title: 'Mô tả chi tiết'),
                    SizedBox(height: 1.h,),
                    BottomSheetContainerWidget(content: DateFormat.yMMMMEEEEd('vi_VN')
                                    .format(item.date!), title: 'Thời gian'),
                                    SizedBox(height: 2.h,)
                  ],
                ),
              ),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
            child: Container(
              width: 100.w,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withOpacity(0.3)
                      : const Color(0xFFf2f2f2),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 3,
                      color: Colors.black12,
                      offset: Offset(2, 4),
                    )
                  ],
                  border: item.type == 'Ăn uống'
                      ? Border.all(color: primaryColor, width: 2)
                      : const Border(),
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
                            item.shortDescription ?? 'Không có mô tả',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        item.type != 'Ăn uống'
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
                      color: item.type == 'Ăn uống' ? primaryColor:Colors.black54,
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
                            const Icon(
                              Icons.local_activity,
                              size: 22,
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            const Icon(
                              Icons.watch_later_outlined,
                              size: 22,
                            ),
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
                              // isCreate ?
                              '${item.activityTime.toString()} giờ',
                              // DateFormat.Hm().format(DateTime(
                              //     0, 0, 0, item.time!.hour, item.time!.minute)),
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
          ),
        )
      ],
    );
  }
}
