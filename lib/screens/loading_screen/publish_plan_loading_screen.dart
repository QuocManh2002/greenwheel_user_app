import 'package:flutter/material.dart';
import 'package:phuot_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class PublishPlanLoadingScreen extends StatelessWidget {
  const PublishPlanLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: const BorderRadius.all(Radius.circular(12))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerWidget.rectangularWithBorderRadius(
                  width: 100.w, height: 2.5.h),
              SizedBox(
                height: 1.h,
              ),
              ShimmerWidget.rectangularWithBorderRadius(
                  width: 40.w, height: 2.h),
              SizedBox(
                height: 1.h,
              ),
              ShimmerWidget.rectangularWithBorderRadius(
                  width: 40.w, height: 2.h),
              SizedBox(
                height: 1.h,
              ),
              ShimmerWidget.rectangularWithBorderRadius(
                  width: 40.w, height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
