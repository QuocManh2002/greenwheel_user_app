import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/comment.dart';
import 'package:greenwheel_user_app/widgets/style_widget/rating_bar.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment});
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.black38, width: 2),
          borderRadius: BorderRadius.circular(12)),
      height: 17.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.hardEdge,
                child: Hero(
                    tag: comment.id,
                    child: FadeInImage(
                      height: 6.h,
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(comment.imgUrl),
                      fit: BoxFit.cover,
                      width: 6.h,
                      filterQuality: FilterQuality.high,
                    )),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.customerName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    RatingBar(rating: comment.rating.toDouble()),
                    Text("  ${comment.date}")
                  ],
                )
              ],
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            comment.content,
            style:const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        )
      ]),
    );
  }
}
