import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/screens/location_screen/location_screen.dart';
import 'package:phuot_app/view_models/location_viewmodels/location_card.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location});
  final LocationCardViewModel location;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => LocationScreen(locationId: location.id)));
      },
      child: Container(
        color: Colors.white,
        height: 30.h,
        width: 55.w,
        child: Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14)),
                child: CachedNetworkImage(
                  key: UniqueKey(),
                  height: 20.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl:
                      '$baseBucketImage/${55.w.ceil()}x${20.h.ceil()}${location.imagePaths[0]}',
                  placeholder: (context, url) =>
                      Image.memory(kTransparentImage),
                  errorWidget: (context, url, error) =>
                      FadeInImage.assetNetwork(
                    height: 15.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: '',
                    image: defaultHomeImage,
                  ),
                )),
            const Spacer(),
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
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  RatingBar.builder(
                    initialRating: location.rating.toDouble(),
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20,
                    itemBuilder:(context, index) => const Icon(
                         Icons.star,
                        color: Colors.amber,
                      ),
                    onRatingUpdate: (value) {},
                    ignoreGestures: true,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Text(
                    '0 Đánh giá',
                    style: TextStyle(fontWeight: FontWeight.w600),
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
