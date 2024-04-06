import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class TransactionDetailLoadingScreen extends StatelessWidget {
  const TransactionDetailLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(
              height: 3.h,
            ),
            ShimmerWidget.rectangularWithBorderRadius(
                width: 100.w, height: 6.h),
            SizedBox(
              height: 3.h,
            ),
            ShimmerWidget.rectangularWithBorderRadius(
                width: 100.w, height: 20.h),
            SizedBox(
              height: 3.h,
            ),
            ShimmerWidget.rectangularWithBorderRadius(
                width: 100.w, height: 30.h),
          ],
        ),
      ),
    );
  }
}
