import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class HomeLoadingScreen extends StatelessWidget {
  const HomeLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShimmerWidget.rectangular(width: double.infinity, height: 30.h),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerWidget.rectangular(width: 50.w, height: 16),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              itemCount: 3,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget.rectangular(width: 55.w, height: 30.h),
                    const SizedBox(
                      height: 8,
                    ),
                    ShimmerWidget.rectangular(width: 18.w, height: 16),
                    const SizedBox(
                      height: 8,
                    ),
                    ShimmerWidget.rectangular(width: 9.w, height: 16),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ShimmerWidget.rectangular(width: 50.w, height: 16),
          ),
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              itemCount: 3,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget.rectangular(width: 55.w, height: 30.h),
                    const SizedBox(
                      height: 8,
                    ),
                    ShimmerWidget.rectangular(width: 18.w, height: 16),
                    const SizedBox(
                      height: 8,
                    ),
                    ShimmerWidget.rectangular(width: 9.w, height: 16),
                  ],
                ),
              ),
            ),
          ),
        ]),
      );
}
