import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/activities.dart';
import 'package:greenwheel_user_app/screens/loading_screen/home_loading_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/search_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_new_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/province.dart';
import 'package:greenwheel_user_app/widgets/home_screen_widget/activity_card.dart';
import 'package:greenwheel_user_app/widgets/home_screen_widget/location_card.dart';
import 'package:greenwheel_user_app/widgets/home_screen_widget/province_card.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  List<LocationViewModel>? locationModels;
  List<ProvinceViewModel>? provinceModels;
  LocationService _locationService = LocationService();
  bool isLoading = true;
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

  _setUpData() async {
    locationModels = null;
    provinceModels = null;
    locationModels = await _locationService.getLocations();
    provinceModels = await _locationService.getProvinces();
    if (locationModels != null && provinceModels != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: isLoading
          ? const HomeLoadingScreen()
          : SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FloatingActionButton(onPressed: (){
                //   Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => 
                //   const DetailPlanNewScreen(planId: 24, isEnableToJoin: true,
                  
                //   )
                //   ));
                // },
                  
                // ),
                SizedBox(
                  height: 35.h,
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        height: 35.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl:
                            "https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0",
                        placeholder: (context, url) =>
                            Image.memory(kTransparentImage),
                        errorWidget: (context, url, error) =>
                            FadeInImage.assetNetwork(
                          height: 35.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: 'No Image',
                          image:
                              'https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0',
                        ),
                      ),
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                    children: [
                                  TextSpan(
                                      text: "GREENWHEELS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
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
                                onTap: () {
                                  // Navigate to search screen
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (ctx) => const SearchScreen(
                                            searchState: false,
                                          )));
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
                          itemCount: locationModels!.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child:
                                LocationCard(location: locationModels![index]),
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
                          itemCount: provinceModels!.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child:
                                ProvinceCard(province: provinceModels![index]),
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
                          itemCount: activities.length,
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
                const SizedBox(
                  height: 12,
                ),
              ],
            )),
    ));
  }
}
