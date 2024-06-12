import 'dart:convert';

import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:phuot_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:sizer2/sizer2.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/plan_statuses.dart';
import '../../core/constants/urls.dart';
import '../../main.dart';
import '../../widgets/plan_screen_widget/base_information.dart';
import '../../widgets/plan_screen_widget/detail_plan_header.dart';
import '../../widgets/plan_screen_widget/detail_plan_service_widget.dart';
import '../../widgets/plan_screen_widget/detail_plan_surcharge_note.dart';
import '../../widgets/plan_screen_widget/plan_schedule.dart';
import '../../widgets/plan_screen_widget/tab_icon_button.dart';

class OfflineDetailScreen extends StatefulWidget {
  const OfflineDetailScreen({super.key, required this.plan});
  final PlanOfflineViewModel plan;

  @override
  State<OfflineDetailScreen> createState() => _OfflineDetailScreenState();
}

class _OfflineDetailScreenState extends State<OfflineDetailScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plan.plan.name!,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
                path:
                    '0${widget.plan.plan.savedContacts![0].phone!.substring(2)}');
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
            Image.memory(base64Decode(widget.plan.plan.imageUrls![0])),
            const SizedBox(
              height: 16,
            ),
            Column(
              children: [
                DetailPlanHeader(isAlreadyJoin: true, plan: widget.plan.plan),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(
                    thickness: 1.8,
                    color: Colors.grey.withOpacity(0.4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            setState(() {
                              _selectedTab = 0;
                            });
                          },
                          child: TabIconButton(
                            iconDefaultUrl: basicInformationGreen,
                            iconSelectedUrl: basicInformationWhite,
                            text: 'Thông tin',
                            isSelected: _selectedTab == 0,
                            index: 0,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            setState(() {
                              _selectedTab = 1;
                            });
                          },
                          child: TabIconButton(
                            iconDefaultUrl: scheduleGreen,
                            iconSelectedUrl: scheduleWhite,
                            text: 'Lịch trình',
                            isSelected: _selectedTab == 1,
                            index: 1,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            setState(() {
                              _selectedTab = 2;
                            });
                          },
                          child: TabIconButton(
                            iconDefaultUrl: serviceGreen,
                            iconSelectedUrl: serviceWhite,
                            text: 'Dịch vụ',
                            isSelected: _selectedTab == 2,
                            index: 2,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            setState(() {
                              _selectedTab = 3;
                            });
                          },
                          child: TabIconButton(
                            iconDefaultUrl: surchargeGreen,
                            iconSelectedUrl: surchargeWhite,
                            text: 'Phụ thu & ghi chú',
                            isSelected: _selectedTab == 3,
                            index: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                if (_selectedTab == 0)
                  BaseInformationWidget(
                    plan: widget.plan.plan,
                    planType: planStatuses[2].engName,
                    isLeader: sharedPreferences.getInt('userId') ==
                        widget.plan.plan.leaderId,
                    refreshData: () {},
                    routeData: widget.plan.routeData,
                    locationLatLng: widget.plan.plan.locationLatLng!,
                  ),
                if (_selectedTab == 1)
                  Column(
                    children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 24),
                          child: const Text(
                            "Lịch trình",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: 80.h,
                        child: PLanScheduleWidget(
                          orders: widget.plan.plan.orders,
                          planId: widget.plan.plan.id!,
                          isLeader: sharedPreferences.getInt('userId') ==
                              widget.plan.plan.leaderId,
                          planType: planStatuses[2].engName,
                          schedule: widget.plan.plan.schedule!,
                          startDate: widget.plan.plan.utcDepartAt!.toLocal(),
                          endDate: widget.plan.plan.utcEndAt!.toLocal(),
                        ),
                      ),
                    ],
                  ),
                if (_selectedTab == 2)
                  DetailPlanServiceWidget(
                      plan: widget.plan.plan,
                      isLeader: true,
                      tempOrders: const [],
                      totalOrder: widget.plan.totalOrder,
                      onGetOrderList: () {}),
                if (_selectedTab == 3)
                  DetailPlanSurchargeNote(
                    plan: widget.plan.plan,
                    isLeader: false,
                    totalOrder: widget.plan.totalOrder,
                    isOffline: true,
                    onRefreshData: () {
                      
                    },
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
