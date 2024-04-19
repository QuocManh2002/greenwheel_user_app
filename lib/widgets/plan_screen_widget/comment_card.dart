import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/comment.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment, required this.isViewAll});
  final CommentViewModel comment;
  final bool isViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.black38, width: 1),
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
              child: CachedNetworkImage(
                  key: UniqueKey(),
                  height: 5.h,
                  width: 5.h,
                  placeholder: (context, url) => Image.memory(kTransparentImage),
                  errorWidget: (context, url, error) => Image.asset(no_image),
                  fit: BoxFit.cover,
                  imageUrl: '$baseBucketImage${comment.imgUrl}',
                  ),
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
              SizedBox(
                width: 70.w,
                child: Text(
                  comment.content,
                  style: const TextStyle(
                      fontSize: 15),
                  overflow: isViewAll ? TextOverflow.clip : TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 1.h,)
            ],
          )
        ],
      ),
    );
  }
}
