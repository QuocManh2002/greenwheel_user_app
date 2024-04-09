import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class EmergencyListLoadingScreen extends StatelessWidget {
  const EmergencyListLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h,),
            Row(
              children: [
                const SizedBox(
                  width: 24,
                ),
                Expanded(
                    child: ShimmerWidget.rectangularWithBorderRadius(
                        width: 100.w, height: 8.h)),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: ShimmerWidget.rectangularWithBorderRadius(
                        width: 100.w, height: 8.h)),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: ShimmerWidget.rectangularWithBorderRadius(
                        width: 100.w, height: 8.h)),
                const SizedBox(
                  width: 24,
                ),
              ],
            ),
            SizedBox(height: 1.h,),
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: ShimmerWidget.rectangularWithBorderRadius(
                      width: 100.w, height: 15.h),
                ),
              ),
            ),
          ],
        ));
  }
}
