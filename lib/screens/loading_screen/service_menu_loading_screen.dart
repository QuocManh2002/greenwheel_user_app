import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class ServiceMenuLoadingScreen extends StatelessWidget {
  const ServiceMenuLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerWidget.rectangular(width: 50.w, height: 34),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            child: ListView.builder(
              itemCount: 4,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ShimmerWidget.rectangular(width: 30.w, height: 15.h),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      height: 15.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget.rectangular(width: 50.w, height: 30),
                          const SizedBox(
                            height: 8,
                          ),
                          ShimmerWidget.rectangular(width: 30.w, height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      );
}
