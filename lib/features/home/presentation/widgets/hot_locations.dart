import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/features/home/presentation/providers/home_provider.dart';
import 'package:greenwheel_user_app/features/home/presentation/widgets/location_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer2/sizer2.dart';

class HotLocations extends StatefulWidget {
  const HotLocations({super.key});

  @override
  State<HotLocations> createState() => _HotLocationsState();
}

class _HotLocationsState extends State<HotLocations> {
  final controller = ScrollController();
  bool isCalled = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setUpData();
  }

  setUpData() {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    provider.getHotLocations();
    controller.addListener(() {
      if(controller.position.pixels == controller.position.maxScrollExtent){
        if(!isCalled){
          provider.getHotLocations();
          print('call');
          isCalled = true;
        }
      }else{
        if(isCalled){
          isCalled = false;
          print('dont call');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 6,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Địa điểm hot mùa này",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Consumer<HomeProvider>(
            builder: (context, value, child) {
              return Row(
                children: <Widget>[
                  Expanded(
                      child: SizedBox(
                    height: 30.h,
                    child: ListView.builder(
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: value.hot_locations == null
                          ? 0
                          : value.hot_locations!.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child:
                            LocationCard(location: value.hot_locations![index]),
                      ),
                    ),
                  ))
                ],
              );
              // child: Row(
              //   children: <Widget>[
              //     Expanded(
              //         child: SizedBox(
              //       height: 30.h,
              //       child: ListView.builder(
              //         controller: controller,
              //         physics: const BouncingScrollPhysics(),
              //         itemCount: hot_locations.length,
              //         shrinkWrap: true,
              //         scrollDirection: Axis.horizontal,
              //         itemBuilder: (context, index) => Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 8),
              //           child: LocationCard(location: hot_locations[index]),
              //         ),
              //       ),
              //     ))
              //   ],
              // ),
            },
          ),
        ),
      ],
    );
    // : Container();
  }
}
