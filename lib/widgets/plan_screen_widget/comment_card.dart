import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/comment.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment});
  final CommentViewModel comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.black38, width: 2),
          borderRadius: BorderRadius.circular(12)),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6, right: 12),
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.hardEdge,
              child: Hero(
                  tag: UniqueKey(),
                  child: FadeInImage(
                    height: 5.h,
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(comment.imgUrl),
                    fit: BoxFit.cover,
                    width: 5.h,
                    filterQuality: FilterQuality.high,
                  )),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.customerName,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(comment.date),
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                comment.content,
                style: const TextStyle(
                    fontSize: 15),
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 1.h,)
            ],
          )
        ],
      ),
    );
  }
}
