import 'package:flutter/material.dart';
import 'package:sizer2/sizer2.dart';

class BottomSheetContainerWidget extends StatelessWidget {
  const BottomSheetContainerWidget({super.key, required this.content, required this.title});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100.w,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                color: Colors.black12,
                offset: Offset(1, 3),
              )
            ],
            color: Colors.white.withOpacity(0.97),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              content,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
            )
          ],
        ),
      );
  }
}