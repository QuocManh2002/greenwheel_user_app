import 'dart:convert';

import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/plan_statuses.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/base_information.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/colors.dart';
import '../../widgets/plan_screen_widget/plan_schedule.dart';

class OfflineDetailScreen extends StatefulWidget {
  const OfflineDetailScreen({super.key, required this.plan});
  final dynamic plan;

  @override
  State<OfflineDetailScreen> createState() => _OfflineDetailScreenState();
}

class _OfflineDetailScreenState extends State<OfflineDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết kế hoạch'),
      ),
      floatingActionButton: DraggableFab(
        child: FloatingActionButton(
          backgroundColor: primaryColor.withOpacity(0.9),
          foregroundColor: Colors.white,
          key: UniqueKey(),
          shape: const CircleBorder(),
          onPressed: () async {
            final Uri url = Uri(
                scheme: 'tel',
                path: '0${widget.plan['plan'].savedContacts![0].phone!.substring(2)}');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
          child: const Icon(Icons.phone),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.memory(base64Decode(widget.plan['plan'].imageUrls![0])),
            const SizedBox(
              height: 16,
            ),
            Column(
              children: [
                BaseInformationWidget(
                  plan: widget.plan['plan'],
                  members: widget.plan['plan'].members!,
                  planType: planStatuses[2].engName,
                  isLeader: sharedPreferences.getInt('userId') ==
                      widget.plan['plan'].leaderId,
                  refreshData: () {},
                  routeData: widget.plan['routeData'],
                  locationLatLng: widget.plan['plan'].locationLatLng,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.plan['plan'].name!,
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
                                text: DateFormat('dd/MM/yyyy')
                                    .format(widget.plan['plan'].utcDepartAt!.toLocal()),
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
                                text: DateFormat('dd/MM/yyyy')
                                    .format(widget.plan['plan'].utcEndAt!.toLocal()),
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
                                text: '${widget.plan['plan'].maxMemberCount} người',
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
                      for (final member in widget.plan['plan'].members!)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          child: Text(
                            member.accountId == widget.plan['plan'].leaderId
                                ? '- ${member.name} - 0${member.phone.substring(2)} (Leading) '
                                : '- ${member.name} - 0${member.phone.substring(2)}',
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 80.h,
                  child: PLanScheduleWidget(
                    orders: const [],
                    planId: widget.plan['plan'].id!,
                    isLeader: sharedPreferences.getInt('userId') ==
                        widget.plan['plan'].leaderId,
                    planType: planStatuses[2].engName,
                    schedule: widget.plan['plan'].schedule!,
                    startDate: widget.plan['plan'].utcDepartAt!.toLocal(),
                    endDate: widget.plan['plan'].utcEndAt!.toLocal(),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }
}
