import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/activities.dart';
import 'package:greenwheel_user_app/constants/locations.dart';
import 'package:greenwheel_user_app/constants/provinces.dart';
import 'package:greenwheel_user_app/screens/main_screen/planscreen.dart';
import 'package:greenwheel_user_app/widgets/activity_card.dart';
import 'package:greenwheel_user_app/widgets/location_card.dart';
import 'package:greenwheel_user_app/widgets/province_card.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  late List<Widget> carouselItems;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setUpData();
  }

  _setUpData() {
    carouselItems = List<Widget>.generate(
        locations.length,
        (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LocationCard(location: locations[index])));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 35.h,
            child: Stack(
              children: [
                Hero(
                    tag: 1,
                    child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      height: 35.h,
                      image: const NetworkImage(
                          'https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0'),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 7.h,
                      ),
                      const Text(
                        'Theo bạn trên mọi cung đường',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                      RichText(
                          text: const TextSpan(
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              children: [
                            TextSpan(
                                text: "GREENWHEELS",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    " - đưa chuyến đi của bạn lên tầm cao mới")
                          ])),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: InkWell(
                          onTap: (){
                            // Navigate to search screen 
                            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PlanScreen()));
                          },
                          child: TextField(
                            enabled: false,
                            controller: searchController,
                            decoration: InputDecoration(
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(width: 2),
                                ),
                                hintText: "Bạn muốn đi đâu?",
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 30,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                  },
                                )),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Địa điểm hot mùa này",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: SizedBox(
                  height: 30.h,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: locations.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: LocationCard(location: locations[index]),
                    ),
                  ),
                ))
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Khám phá mảnh đất Việt Nam",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 12,
          ),

          // diplay list of card depend on province of Viet Nam
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: SizedBox(
                  height: 25.h,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: provinces.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ProvinceCard(province: provinces[index]),
                    ),
                  ),
                ))
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Bạn muốn khám phá điều gì ?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 12,
          ),

          // diplay list of card depend on type of activity
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: SizedBox(
                  height: 30.h,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: provinces.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ActivityCard(activity: activities[index]),
                    ),
                  ),
                ))
              ],
            ),
          ),
        ],
      )),
    ));
  }
}
