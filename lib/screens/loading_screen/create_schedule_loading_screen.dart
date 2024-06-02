import 'package:flutter/material.dart';
import 'package:phuot_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class CreateScheduleLoadingScreen extends StatelessWidget {
  const CreateScheduleLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        SizedBox(
          height: 2.h,
        ),
        ShimmerWidget.rectangularWithBorderRadius(width: 40.w, height: 5.h),
        SizedBox(
          height: 3.h,
        ),
        Row(
          children: [
            SizedBox(
              width: 2.h,
            ),
            ShimmerWidget.circular(width: 5.h, height: 5.h),
            const Spacer(),
            ShimmerWidget.rectangularWithBorderRadius(width: 25.w, height: 5.h),
            SizedBox(
              width: 2.h,
            )
          ],
        ),
        SizedBox(
          height: 2.h,
        ),
        Row(
          children: [
            SizedBox(
              width: 2.h,
            ),
            ShimmerWidget.rectangularWithBorderRadius(width: 18.w, height: 12.h),
            SizedBox(
              width: 2.h,
            ),
            ShimmerWidget.rectangularWithBorderRadius(width: 18.w, height: 12.h),
            SizedBox(
              width: 2.h,
            ),
            ShimmerWidget.rectangularWithBorderRadius(width: 18.w, height: 12.h),
            SizedBox(
              width: 2.h,
            ),
            ShimmerWidget.rectangularWithBorderRadius(width: 18.w, height: 12.h),
            SizedBox(
              width: 2.h,
            ),
          ],
        ),
        SizedBox(
          height: 2.h,
        ),
        Column(
          children: [
            ShimmerWidget.rectangularWithBorderRadius(width: 90.w, height: 15.h),
            SizedBox(
              height: 2.h,
            ),
            ShimmerWidget.rectangularWithBorderRadius(width: 90.w, height: 15.h),
            SizedBox(
              height: 2.h,
            ),
            ShimmerWidget.rectangularWithBorderRadius(width: 90.w, height: 15.h),
            SizedBox(
              height: 2.h,
            ),
          ],
        )
      ]),
    );
  }
}