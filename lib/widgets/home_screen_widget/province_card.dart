import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/screens/sub_screen/filter_location_screen.dart';
import 'package:greenwheel_user_app/view_models/province.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class ProvinceCard extends StatelessWidget {
  const ProvinceCard({super.key, required this.province});
  final ProvinceViewModel province;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => FilterLocationScreen(
                  province: province,
                )));
      },
      child: Container(
        height: 25.h,
        width: 25.h,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: Stack(children: [
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(14)),
              child: 
              CachedNetworkImage(
                key: UniqueKey(),
                height: 25.h,
                fit: BoxFit.cover,placeholder: (context, url) =>
                      Image.memory(kTransparentImage),
                  errorWidget: (context, url, error) =>
                  Image.network('https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0', height: 25.h, fit: BoxFit.cover,),
                imageUrl:'https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0',)
            ),
            Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    province.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ))
          ]),
        ),
      ),
    );
  }
}
