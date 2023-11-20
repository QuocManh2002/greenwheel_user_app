import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key, required this.location});
  final LocationViewModel location;

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
    getData();
  }

  getData() async {
    imageUrls = json.decode(widget.location.imageUrls);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("Test Screen")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              print(currentImageIndex);
            },
            child: CarouselSlider(
                items: imageUrls.map((item) => Hero(
                  tag: widget.location.id,
                  child: FadeInImage(
                    height: 20.h,
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(item.toString()),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    filterQuality: FilterQuality.high,
                  )),).toList(),
                carouselController: carouselController,
                options: CarouselOptions(
                  scrollPhysics: const BouncingScrollPhysics(),
                  autoPlay: false,
                  aspectRatio: 2,
                  autoPlayAnimationDuration: Duration(seconds: 5),
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    currentImageIndex = index;
                  },
                )),
          ),
          // Expanded(
          //   child: SingleChildScrollView(
          //     child: Column(
          //       children: [
          //         for (int i = 0; i < 10; i++)
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Container(
          //               height: 10.h,
          //               color: redColor,
          //             ),
          //           )
          //       ],
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Container(
          //     height: 7.h,
          //     child: ElevatedButton(
          //       onPressed: () {},
          //       child: Text("Button"),
          //       style: elevatedButtonStyle,
          //     ),
          //   ),
          // )
        ],
      ),
    ));
  }
}
