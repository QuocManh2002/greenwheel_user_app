import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/screens/offline_screen/offline_detail_screen.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class OfflinePlanCard extends StatelessWidget {
  const OfflinePlanCard({super.key, required this.plan});
  final PlanOfflineViewModel plan;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => OfflineDetailScreen(plan: plan)));
      },
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
            child: Row(children: [
              Container(
                  height: 15.h,
                  width: 15.h,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(14)),
                  child: Image.memory(base64Decode(plan.plan.imageUrls![0]), fit: BoxFit.cover,)),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(plan.plan.name!,
                              overflow: TextOverflow.clip,
                              maxLines: 2,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                            '${DateFormat('dd/MM/yyyy').format(plan.plan.utcDepartAt!.toLocal())} - ${DateFormat('dd/MM/yyyy').format(plan.plan.utcEndAt!.toLocal())}'),
                        const SizedBox(
                          width: 16,
                        ),
                      ],
                    )
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
