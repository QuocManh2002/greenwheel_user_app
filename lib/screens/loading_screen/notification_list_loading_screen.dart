
import 'package:flutter/material.dart';
import 'package:phuot_app/core/constants/colors.dart';
import 'package:phuot_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class NotificationListLoadingScreen extends StatelessWidget {
  const NotificationListLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          for (int i = 0; i < 10; i++)
            Container(
              height: 9.h,
              decoration: BoxDecoration(
                  color: i.isEven ? Colors.white : lightPrimaryTextColor),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  ShimmerWidget.circular(width: 5.h, height: 5.h),
                  SizedBox(
                    width: 2.h,
                  ),
                  Expanded(
                      child: ShimmerWidget.rectangularWithBorderRadius(
                          width: double.infinity, height: 5.h))
                ],
              ),
            )
        ],
      ),
    );
  }
}
