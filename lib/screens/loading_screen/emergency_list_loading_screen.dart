import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class EmergencyListLoadingScreen extends StatelessWidget {
  const EmergencyListLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 80.h,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: ShimmerWidget.rectangularWithBorderRadius(
                  width: 100.w, height: 15.h),
            ),
          ),
        ));
  }
}
