import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class LocationLoadingScreen extends StatelessWidget {
  const LocationLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ShimmerWidget.rectangular(width: double.infinity, height: 25.h),
          SizedBox(
            height: 2.h,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 50.w, height: 4.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 45.w, height: 4.h),
                SizedBox(
                  height: 1.h,
                ),
                const ShimmerWidget.rectangular(
                    width: double.infinity, height: 1.5),
                SizedBox(
                  height: 1.h,
                ),
                Row(
                  children: [
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: double.infinity, height: 4.h)),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: double.infinity, height: 4.h)),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: double.infinity, height: 4.h)),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: double.infinity, height: 4.h)),
                  ],
                ),
                SizedBox(
                  height: 1.h,
                ),
                Row(
                  children: [
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: double.infinity, height: 4.h)),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: double.infinity, height: 4.h)),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: double.infinity, height: 4.h)),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ShimmerWidget.rectangularWithBorderRadius(
                            width: double.infinity, height: 4.h)),
                  ],
                ),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: double.infinity, height: 10.h),
                SizedBox(
                  height: 1.h,
                ),
                const ShimmerWidget.rectangular(
                    width: double.infinity, height: 1.5),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 40.w, height: 3.h),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                  alignment: Alignment.center,
                  child: ShimmerWidget.rectangularWithBorderRadius(
                      width: 70.w, height: 5.h),
                ),
                SizedBox(
                  height: 1.h,
                ),
                const ShimmerWidget.rectangular(
                    width: double.infinity, height: 1.5),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 40.w, height: 3.h),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                  alignment: Alignment.center,
                  child: ShimmerWidget.rectangularWithBorderRadius(
                      width: 70.w, height: 5.h),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
