import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/activity.dart';
import 'package:greenwheel_user_app/screens/loading_screen/service_supplier_loading_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/location_card.dart';
import 'package:greenwheel_user_app/view_models/province.dart';
import 'package:greenwheel_user_app/widgets/search_screen_widget/filter_location_card.dart';

class FilterLocationScreen extends StatefulWidget {
  const FilterLocationScreen({super.key, this.province, this.activity});
  final ProvinceViewModel? province;
  final Activity? activity;
  @override
  State<FilterLocationScreen> createState() => _FilterLocationScreenState();
}

class _FilterLocationScreenState extends State<FilterLocationScreen> {
  List<LocationCardViewModel>? locationModels;
  final LocationService _locationService = LocationService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupData();
  }

  _setupData() async {
    locationModels = null;
    if (widget.province != null) {
      locationModels =
          await _locationService.getLocationsByProvinceId(widget.province!.id);
      if (locationModels != null) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      locationModels =
          await _locationService.getLocationsByActivity(widget.activity!);
      if (locationModels != null) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: const ButtonStyle(
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
          ),
          title: Text(
            widget.province != null
                ? widget.province!.name
                : widget.activity!.name,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.bold),
          )),
      body: isLoading
          ? const ServiceSupplierLoadingScreen()
          : SingleChildScrollView(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: locationModels!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: FilterLocationCard(location: locationModels![index]),
                  );
                },
              ),
            ),
    ));
  }
}
