import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/province.dart';
import 'package:greenwheel_user_app/widgets/search_screen_widget/filter_location_card.dart';

class FilterLocationScreen extends StatefulWidget {
  const FilterLocationScreen({super.key, required this.province});
  final ProvinceViewModel province;
  @override
  State<FilterLocationScreen> createState() => _FilterLocationScreenState();
}

class _FilterLocationScreenState extends State<FilterLocationScreen> {
  List<LocationViewModel>? locationModels;
  LocationService _locationService = LocationService();
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupData();
  }

  _setupData() async {
    locationModels = null;
    locationModels =
        await _locationService.getLocationsByProvinceId(widget.province.id);
    if (locationModels != null) {
      print(locationModels);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
          title: Text(
        widget.province.name,
        style: const TextStyle(
            fontFamily: 'NotoSans', fontWeight: FontWeight.bold),
      )),
      body: isLoading
          ? const Center(
              child: Text("Loading..."),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: locationModels!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child:
                          FilterLocationCard(location: locationModels![index]),
                    );
                  },
                ),
              ),
            ),
    ));
  }
}
