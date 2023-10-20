import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/location.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location});
  final Location location;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      child: Container(
        height: 30.h,
        width: 60.w,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
              child: Hero(
                  tag: location.id,

                  child: FadeInImage(
                    height: 20.h,
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(location.imageUrl),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    filterQuality: FilterQuality.high,
                    
                  )),
            ),
                Text(location.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
          ]),
        ),
      ),
    );
  }
}
