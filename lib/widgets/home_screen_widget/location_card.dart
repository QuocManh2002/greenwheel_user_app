import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/screens/sub_screen/location_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/style_widget/rating_bar.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location});
  final LocationViewModel location;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => LocationScreen(location: location)));
      },
      child: Container(
        color: Colors.white,
        height: 30.h,
        width: 55.w,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                decoration:
                    BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14)),
                child: CachedNetworkImage(
                  height: 20.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: location.imageUrls[0],
                  placeholder: (context, url) =>
                      Image.memory(kTransparentImage),
                  errorWidget: (context, url, error) =>
                      FadeInImage.assetNetwork(
                    height: 15.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: 'No Image',
                    image:
                        'https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0',
                  ),
                )),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                location.name,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  RatingBar(
                    rating: 5,
                    ratingCount: 12,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    '${12} Đánh giá',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                location.description,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const Spacer()
          ]),
        ),
      ),
    );
  }
}
