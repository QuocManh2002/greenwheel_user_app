import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class OrderDetailLoadingScreen extends StatelessWidget {
  const OrderDetailLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          ShimmerWidget.rectangular(width: 100.w, height: 30.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 40.w, height: 2.5.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 45.w, height: 2.5.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 50.w, height: 2.5.h),
                Divider(
                  thickness: 1,
                  height: 4.h,
                  color: Colors.grey.withOpacity(0.2),
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 25.w, height: 3.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 100.w, height: 2.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 100.w, height: 2.h),
                Divider(
                  thickness: 1,
                  height: 4.h,
                  color: Colors.grey.withOpacity(0.2),
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 35.w, height: 3.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 100.w, height: 3.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 100.w, height: 3.h),
                    Divider(
                  thickness: 1,
                  height: 4.h,
                  color: Colors.grey.withOpacity(0.2),
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 100.w, height: 4.h),
                SizedBox(
                  height: 1.h,
                ),
                ShimmerWidget.rectangularWithBorderRadius(
                    width: 100.w, height: 4.h),
              ],
            ),
          )
        ],
      ),
    );
  }
}
