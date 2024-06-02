import 'package:flutter/material.dart';
import 'package:phuot_app/view_models/plan_viewmodels/search_start_location_result.dart';
import 'package:sizer2/sizer2.dart';

class SearchLocationResultCard extends StatelessWidget {
  const SearchLocationResultCard(
      {super.key, required this.item, required this.list});
  final SearchStartLocationResult item;
  final List<SearchStartLocationResult> list;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: item == list.first
              ? const BorderRadius.only(
                  topLeft: Radius.circular(14), topRight: Radius.circular(14))
              : item == list.last
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14))
                  : const BorderRadius.all(Radius.zero)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Spacer(),
            Text(
              item.name,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const Spacer(),
            Text(
              item.address,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              color: Colors.grey,
              height: 1,
            )
          ],
        ),
      ),
    );
  }
}
