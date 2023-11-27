

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/shimmer_widget.dart';
import 'package:sizer2/sizer2.dart';

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
                SingleChildScrollView(
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
                )
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
