import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/screens/loading_screen/plan_loading_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final CarouselController carouselController = CarouselController();
  int currentImageIndex = 0;
  bool isLoading = true;
  List<dynamic> imageUrls = [];
  List<LocationViewModel>? locationModels;
  // LocationService _locationService = LocationService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: isLoading
                ? 
                // SingleChildScrollView(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //     ShimmerWidget.rectangular(width: double.infinity, height: 30.h),
                //     const SizedBox(height: 16,),
                //     Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 16),
                //       child: ShimmerWidget.rectangular(width: 50.w, height: 16),
                //     ),
                //     const SizedBox(height: 16,),
                //     SizedBox(
                //       height: 40.h,
                //       child: ListView.builder(
                //         itemCount: 3,
                //         physics:const BouncingScrollPhysics(),
                //         shrinkWrap:  true,
                //         scrollDirection: Axis.horizontal,
                //         itemBuilder: (context, index) => Padding(
                //           padding: const EdgeInsets.all(16),
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               ShimmerWidget.rectangular(width: 55.w, height: 30.h),
                //               const SizedBox(height: 8,),
                //               ShimmerWidget.rectangular(width: 18.w, height: 16),
                //               const SizedBox(height: 8,),
                //               ShimmerWidget.rectangular(width: 9.w, height: 16),
                //             ],
                //           ),
                //         ),),
                //     ),
                //      Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //       child: ShimmerWidget.rectangular(width: 50.w, height: 16),
                //     ),
                //     SizedBox(
                //       height: 40.h,
                //       child: ListView.builder(
                //         itemCount: 3,
                //         physics:const BouncingScrollPhysics(),
                //         shrinkWrap:  true,
                //         scrollDirection: Axis.horizontal,
                //         itemBuilder: (context, index) => Padding(
                //           padding: const EdgeInsets.all(16),
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               ShimmerWidget.rectangular(width: 55.w, height: 30.h),
                //               const SizedBox(height: 8,),
                //               ShimmerWidget.rectangular(width: 18.w, height: 16),
                //               const SizedBox(height: 8,),
                //               ShimmerWidget.rectangular(width: 9.w, height: 16),
                //             ],
                //           ),
                //         ),),
                //     ),
                //   ]),
                // )
                PlanLoadingScreen()
                : Text("Content")));
  }
}

class Skelton extends StatelessWidget {
  const Skelton({super.key, required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: const BorderRadius.all(Radius.circular(16))),
    );
  }
}
