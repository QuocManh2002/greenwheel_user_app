import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/activity.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      child: Container(
        height: 30.h,
        width: 45.w,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(14)),
              child: Hero(
                  tag: activity.id,
                  child: FadeInImage(
                    height: 23.h,
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(activity.imageUrl),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    filterQuality: FilterQuality.high,
                  )),
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(padding: const EdgeInsets.all(8),
            child: Text(activity.name, style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),)
          ]),
        ),
      ),
    );
  }
}