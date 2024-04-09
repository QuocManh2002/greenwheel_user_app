import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/activity.dart';
import 'package:greenwheel_user_app/screens/sub_screen/filter_location_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                child: FilterLocationScreen(
                  activity: activity,
                ),
                type: PageTransitionType.rightToLeft));
      },
      child: SizedBox(
        height: 30.h,
        width: 45.w,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(14)),
                child: CachedNetworkImage(
                  key: UniqueKey(),
                  height: 23.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Image.memory(kTransparentImage),
                  errorWidget: (context, url, error) => Image.network(
                    'https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0',
                    height: 23.h,
                    fit: BoxFit.cover,
                  ),
                  imageUrl: activity.imageUrl,
                )),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                activity.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
