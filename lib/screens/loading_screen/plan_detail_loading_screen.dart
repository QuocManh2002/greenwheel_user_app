import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:phuot_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class PlanDetailLoadingScreen extends StatelessWidget {
  const PlanDetailLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget.rectangular(width: double.infinity, height: 25.h),
          SizedBox(
            height: 2.h,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerWidget.rectangularWithBorderRadius(
                        width: 70.w, height: 10.h),
                    ShimmerWidget.rectangularWithBorderRadius(
                        width: 5.h, height: 5.h)
                  ],
                ),
                SizedBox(
                  height: 1.5.h,
                ),
                const ShimmerWidget.rectangular(
                    width: double.infinity, height: 1),
                SizedBox(
                  height: 1.5.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: 15.w, height: 10.h)),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: 15.w, height: 10.h)),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: 15.w, height: 10.h)),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: 15.w, height: 10.h)),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 70.w, height: 4.h),
                SizedBox(
                  height: 2.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: double.infinity, height: 4.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: double.infinity, height: 4.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: double.infinity, height: 4.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: double.infinity, height: 4.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: double.infinity, height: 4.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: double.infinity, height: 4.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: double.infinity, height: 4.h),
                SizedBox(
                  height: 1.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
