import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

class PlanLoadingScreen extends StatelessWidget {
  const PlanLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: [
              for(var i = 0; i < 5; i++)
               Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: 
                SizedBox(
                  height: 15.h,
                  child: 
                  Row(children: [
                    ShimmerWidget.rectangular(width: 15.h, height: 15.h),
                    const SizedBox(
                      width: 8,
                    ),
                    const Expanded(
                      child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget.rectangular(
                              width: double.infinity, height: 32),
                          SizedBox(
                            height: 16,
                          ),
                          ShimmerWidget.rectangular(width: 80, height: 16),
                          SizedBox(
                            height: 12,
                          ),
                          ShimmerWidget.rectangular(width: 120, height: 16)
                        ],
                      ),)

                  ]),
                ),
              ),
            ]
          
        ),
      );
}
