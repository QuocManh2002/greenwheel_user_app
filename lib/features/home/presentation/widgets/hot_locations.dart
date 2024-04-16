import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/features/home/business/entities/home_location_entity.dart';
import 'package:greenwheel_user_app/features/home/presentation/providers/home_provider.dart';
import 'package:greenwheel_user_app/features/home/presentation/widgets/location_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer2/sizer2.dart';

class HotLocations extends StatelessWidget {
  const HotLocations({super.key});

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<HomeProvider>(context);
    provider.getHotLocations();
    List<HomeLocationEntity>? hot_locations = Provider.of<HomeProvider>(context).hot_locations;
    return
    hot_locations != null && hot_locations.isNotEmpty ?
     Column(
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
          child: Row(
            children: <Widget>[
              Expanded(
                  child: SizedBox(
                height: 30.h,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: hot_locations.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: LocationCard(location: hot_locations[index]),
                  ),
                ),
              ))
            ],
          ),
        ),
      ],
    ):Container();
  }
}
