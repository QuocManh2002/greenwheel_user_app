
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/bottom_sheet_container_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleActivityView extends StatelessWidget {
  const PlanScheduleActivityView({super.key, required this.item});
  final PlanScheduleItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12,left: 6, right: 6),
      child: InkWell(
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
          // AwesomeDialog(context: context,
          //   animType: AnimType.leftSlide,
          //   dialogType: DialogType.info,
          //   body: Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Column(children: [
          //     const Text('Chi tiết hoạt động', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          //     SizedBox(height: 1.h,),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       children: [
          //         const Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text('Mô tả:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          //             Text('Mô tả chi tiết:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          //           ],
          //         ),
          //         SizedBox(width: 1.h,),
          //         SizedBox(
          //           width: 40.w,
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(item.shortDescription!, style:const TextStyle(fontSize: 16,), overflow: TextOverflow.clip,),
          //               Text(item.description!, style:const TextStyle(fontSize: 16, ), overflow: TextOverflow.clip,)
          //             ],
          //           ),
          //         )
          //       ],
          //     )
          //   ]),
          //   ),
          //   btnOkText: 'Ok',
          //   btnOkColor: Colors.blue,
          //   btnOkOnPress: () {
              
          //   },
          // ).show();
        },
        child: Container(
          width: 100.w,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              color: const Color(0xFFf2f2f2),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.shortDescription ?? 'Không có mô tả',
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.clip,
                ),
                Container(
                  color:item.type == 'Ăn uống' ? primaryColor : Colors.black26,
                  height: 1.5,
                ),
                // Text(
                //   item.description ?? 'Không có mô tả',
                //   style:
                //       const TextStyle(fontSize: 18, color: Colors.black54),
                //   overflow: TextOverflow.clip,
                // ),
                SizedBox(height: 1.h,),
                Row(
                  children: [
                    const Icon(Icons.watch_later_outlined),
                    SizedBox(width: 1.h,),
                    Text('${item.activityTime} giờ', style:const TextStyle(
                      fontSize: 16
                    ),)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
