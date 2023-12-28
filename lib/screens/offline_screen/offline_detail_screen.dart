import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule.dart';
import 'package:sizer2/sizer2.dart';

class OfflineDetailScreen extends StatefulWidget {
  const OfflineDetailScreen({super.key, required this.plan});
  final PlanOfflineViewModel plan;

  @override
  State<OfflineDetailScreen> createState() => _OfflineDetailScreenState();
}

class _OfflineDetailScreenState extends State<OfflineDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.memory(base64Decode(widget.plan.imageBase64)),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.plan.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 1.8,
                    color: Colors.grey.withOpacity(0.4),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                            text: "Khởi hành:  ",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            children: [
                              TextSpan(
                                  text:
                                      '${widget.plan.startDate.day}/${widget.plan.startDate.month}/${widget.plan.startDate.year}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal))
                            ])),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                            text: "Kết thúc:     ",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            children: [
                              TextSpan(
                                  text:
                                      '${widget.plan.endDate.day}/${widget.plan.endDate.month}/${widget.plan.endDate.year}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal))
                            ])),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                            text: "Thành viên: ",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            children: [
                              TextSpan(
                                  text: '${widget.plan.memberLimit} người',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal))
                            ])),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 1.8,
                    color: Colors.grey.withOpacity(0.4),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Thành viên đã tham gia: ",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        for (final member in widget.plan.memberList!)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            child: Text(
                              member.isLeading
                                  ? '- ${member.name} - ${member.phone} (Leading) '
                                  : '- ${member.name} - ${member.phone}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 1.8,
                    color: Colors.grey.withOpacity(0.4),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Lịch trình",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    height: 60.h,
                    child: PLanScheduleWidget(
                      schedule: widget.plan.schedule!,
                      startDate: widget.plan.startDate,
                      endDate: widget.plan.endDate,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
