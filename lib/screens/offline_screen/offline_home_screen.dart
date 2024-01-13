import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/service/offline_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/offline_screen_widget/offline_plan_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';

class OfflineHomeScreen extends StatefulWidget {
  const OfflineHomeScreen({super.key});

  @override
  State<OfflineHomeScreen> createState() => _OfflineHomeScreenState();
}

class _OfflineHomeScreenState extends State<OfflineHomeScreen> {
  List<PlanOfflineViewModel>? planList;
  OfflineService _offlineService = OfflineService();
  PlanService _planService = PlanService();
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // writeData();
    getData();
  }

  getData() async {
    final list = await _offlineService.getOfflinePlans();
    if (list != null) {
      setState(() {
        planList = list;
        isLoading = false;
      });
    }
  }

  writeData() async {
    List<PlanSchedule> tempSchedule = [
      PlanSchedule(date: DateTime(2023, 10, 10), items: [
        PlanScheduleItem(
            time: TimeOfDay.now(),
            description: 'description',
            date: DateTime(2023, 10, 10)),
      ]),
      PlanSchedule(date: DateTime(2023, 10, 11), items: [
        PlanScheduleItem(
            time: TimeOfDay.now(),
            description: 'description',
            date: DateTime(2023, 10, 11)),
      ]),
      PlanSchedule(date: DateTime(2023, 10, 12), items: [
        PlanScheduleItem(
            time: TimeOfDay.now(),
            description: 'description',
            date: DateTime(2023, 10, 12)),
      ])
    ];

    await _offlineService.savePlanToHive(PlanOfflineViewModel(
        id: 1,
        name: 'Chuyen di test',
        imageBase64: await Utils().getImageBase64Encoded(
            'https://cdn.tgdd.vn/2023/11/content/image--9--800x450.jpg'),
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 3)),
        memberLimit: 3,
        schedule: _planService.convertPlanScheduleToJson(tempSchedule),
        orders: [],
        memberList: [
          PlanOfflineMember(
              id: 1, name: 'Manh', phone: '0383519580', isLeading: true),
          PlanOfflineMember(
              id: 2, name: 'Thinh', phone: '0123456789', isLeading: false)
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white.withOpacity(0.94),
      appBar: AppBar(
        title: const Text('Kế hoạch của bạn'),
      ),
      body: isLoading
          ? const Center(
              child: Text('Loading...'),
            )
          : SingleChildScrollView(
              child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: planList!.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: OfflinePlanCard(plan: planList![index]),
              ),
            )),
    ));
  }
}
