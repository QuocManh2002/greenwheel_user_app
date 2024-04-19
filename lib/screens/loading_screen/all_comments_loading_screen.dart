import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class AllCommentsLoadingScreen extends StatelessWidget {
  const AllCommentsLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: 5,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ShimmerWidget.rectangularWithBorderRadius(
                width: 100.w, height: 10.h),
          ),
        )
      ],
    );
  }
}
