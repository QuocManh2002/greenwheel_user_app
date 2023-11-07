import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.plan});
  final PlanCardViewModel plan;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black12,
              offset: Offset(1, 3),
            )
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        height: 15.h,
        width: double.infinity,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              
              children: [
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(14)),
                child: Hero(
                    tag: plan.id,
                    child: FadeInImage(
                      height: 15.h,
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(json.decode(plan.imageUrls)[0]),
                      fit: BoxFit.cover,
                      width: 15.h,
                      filterQuality: FilterQuality.high,
                    )),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Text("Chuyến đi ${plan.locationName}" ,
                    overflow: TextOverflow.clip,
                    maxLines: 2,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(plan.provinceName),
                    const SizedBox(
                      height: 8,
                    ),
                    Text('${plan.startDate.day}/${plan.startDate.month}/${plan.startDate.year} - ${plan.endDate.day}/${plan.endDate.month}/${plan.endDate.year}')
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
