import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/features/home/business/entities/home_province_entity.dart';
import 'package:greenwheel_user_app/features/home/presentation/providers/home_provider.dart';
import 'package:greenwheel_user_app/features/home/presentation/widgets/province_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer2/sizer2.dart';

class Provinces extends StatelessWidget {
  const Provinces({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    provider.getHomeProvinces();
    List<HomeProvinceEntity>? provinces =
        Provider.of<HomeProvider>(context).home_provinces;
    return provinces != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                height: 6,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: SizedBox(
                      height: 25.h,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
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
            ],
          )
        : Container();
  }
}
