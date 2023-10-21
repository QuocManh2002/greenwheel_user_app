import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:sizer2/sizer2.dart';

class TagWidget extends StatelessWidget {
  const TagWidget({super.key , required this.tag});
  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4.h,
      width: 10.h,
      decoration: BoxDecoration(
        
        color: tag.mainColor,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: tag.strokeColor ?? tag.mainColor, width: 1.7)
      ),
      child: Container(
        alignment: Alignment.center,
        child: Text(
          tag.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
      ),
    );
  }
}