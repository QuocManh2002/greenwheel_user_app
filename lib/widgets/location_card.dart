import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/location.dart';
import 'package:greenwheel_user_app/screens/sub_screen/location_screen.dart';
import 'package:greenwheel_user_app/widgets/rating_bar.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location});
  final Location location;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => LocationScreen(location: location)));
      },
      child: Container(
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
                  BoxDecoration(borderRadius: BorderRadius.circular(14)),
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
                    rating: location.rating,
                    ratingCount: location.numberOfRating,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    '${location.numberOfRating} Đánh giá',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                location.description,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
