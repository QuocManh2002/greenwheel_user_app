import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class ProfileLoadingScreen extends StatelessWidget {
  const ProfileLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h,),
                        ShimmerWidget.circular(width: 15.h, height: 15.h),
                        const SizedBox(height: 32,),
                        ShimmerWidget.rectangular(width: 60.w, height: 32),
                        const SizedBox(height: 32,),
                        ShimmerWidget.rectangular(width: 30.w, height: 20),
                        const SizedBox(height: 32,),
                        ShimmerWidget.rectangular(width: double.infinity.w, height: 15.h),
                        const SizedBox(height: 32,),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: ShimmerWidget.rectangular(width: 30.w, height: 20)),
                        const SizedBox(height: 16,),
                        ShimmerWidget.rectangular(width: double.infinity.w, height: 7.h),
                        const SizedBox(height: 16,),
                        ShimmerWidget.rectangular(width: double.infinity.w, height: 7.h),
                        const SizedBox(height: 16,),
                        ShimmerWidget.rectangular(width: double.infinity.w, height: 7.h),
                      ],
                    ),
                  ),
                );
  }
}