

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:greenwheel_user_app/widgets/shimmer_widget.dart';
import 'package:greenwheel_user_app/widgets/test_screen1.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body:
            Center(
              child: ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => TestScreen1()));
                },
                child: Text('click'),
              ),
            )
             )
            );
  }
}

