import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/service/offline_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline_member.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:sizer2/sizer2.dart';

class SelectEmergencyService extends StatefulWidget {
  const SelectEmergencyService(
      {super.key, required this.location, required this.planId});

  final int planId;

  final LocationViewModel location;

  @override
  State<SelectEmergencyService> createState() => _SelectEmergencyServiceState();
}

class _SelectEmergencyServiceState extends State<SelectEmergencyService>
    with TickerProviderStateMixin {
  late TabController tabController;
  bool isLoading = true;
  PlanDetail? planDetail;
  PlanService _planService = PlanService();
  OfflineService _offlineService = OfflineService();
  List<EmergencyContactViewModel>? emergencyContacts;
  List<EmergencyContactViewModel>? selectedEmergencyContacts = [];
  List<dynamic> rsList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    tabController = TabController(length: 2, vsync: this);
    sharedPreferences.setStringList('selectedIndex', []);
  }

  getData() async {
    sharedPreferences.setStringList('serviceList', []);
    setState(() {
      emergencyContacts = widget.location.emergencyContacts;
    });
    planDetail = await _planService.GetPlanById(widget.planId);
  }

  // callback() {
  //   List<String>? serviceList = sharedPreferences.getStringList('serviceList');
  //   final _selectedList = serviceList!
  //       .map((e) =>
  //           totalList.firstWhere((element) => element.id.toString() == e))
  //       .toList();
  //   setState(() {
  //     listDiLai = _selectedList
  //         .where((element) =>
  //             element.type == "REPAIR_SHOP" ||
  //             element.type == "TAXI" ||
  //             element.type == "VEHICLE_SHOP")
  //         .toList();
  //     listTapHoa =
  //         _selectedList.where((element) => element.type == "GROCERY").toList();
  //   });
  // }

  callback() {
    List<String>? selectedIndex =
        sharedPreferences.getStringList('selectedIndex');

    setState(() {
      selectedEmergencyContacts = [];
      for (final index in selectedIndex!) {
        selectedEmergencyContacts!.add(emergencyContacts![int.parse(index)]);
      }
    });
    rsList = selectedEmergencyContacts!
        .map((e) => EmergencyContactViewModel().toJson(e))
        .toList();
    print(rsList);
    sharedPreferences.setString('plan_saved_emergency', rsList.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        TabBar(
            controller: tabController,
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(
                text: "Danh sách liên lạc",
                icon: Icon(Icons.list),
              ),
              Tab(
                text: "Đã lưu",
                icon: Icon(Icons.saved_search),
              )
            ]),
        SizedBox(
          height:
              emergencyContacts!.isEmpty && selectedEmergencyContacts!.isEmpty
                  ? 50.h
                  : 62.h,
          child: TabBarView(controller: tabController, children: [
            emergencyContacts!.isEmpty
                ? Image.asset(
                    empty_plan,
                    fit: BoxFit.cover,
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: emergencyContacts!.length,
                    itemBuilder: (context, index) {
                      return EmergencyContactCard(
                        emergency: emergencyContacts![index],
                        index: index,
                        callback: callback,
                        isSelected: sharedPreferences
                            .getStringList('selectedIndex')!
                            .any((element) => element == index.toString()),
                      );
                    },
                  ),
            selectedEmergencyContacts!.isEmpty
                ? Image.asset(
                    empty_plan,
                    fit: BoxFit.fitWidth,
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: selectedEmergencyContacts!.length,
                    itemBuilder: (context, index) {
                      return EmergencyContactCard(
                        emergency: selectedEmergencyContacts![index],
                        callback: callback,
                        index: index,
                        isSelected: sharedPreferences
                            .getStringList('selectedIndex')!
                            .any((element) => element == index.toString()),
                      );
                    },
                  ),
          ]),
        ),
        // Spacer(),
        // ElevatedButton(
        //     style: elevatedButtonStyle,
        //     onPressed: () async {
        //       List<int> serviceIds = [];
        //       serviceIds.addAll(sharedPreferences
        //           .getStringList('serviceList')!
        //           .map((e) => int.parse(e))
        //           .toList());
        //       final plan_schedule = planDetail!.schedule;
        //       final plan_schedule_list =
        //           _planService.GetPlanScheduleFromJsonNew(
        //               plan_schedule,
        //               planDetail!.startDate,
        //               planDetail!.endDate
        //                       .difference(planDetail!.startDate)
        //                       .inDays +
        //                   1);
        //       final rs =
        //           _planService.convertPlanScheduleToJson(plan_schedule_list);
        //       print(plan_schedule);
        //       print(plan_schedule_list);
        //       print(rs.toString());
        //       print(serviceIds);
        //       int? planId = await _planService.updateEmergencyService(
        //           PlanCreate(
        //               locationId: planDetail!.id,
        //               startDate: planDetail!.startDate,
        //               endDate: planDetail!.endDate,
        //               latitude: widget.location.latitude,
        //               longitude: widget.location.longitude,
        //               memberLimit: planDetail!.memberLimit,
        //               name: planDetail!.name,
        //               schedule: rs.toString()),
        //           rsList.toString(),
        //           widget.planId);

        //       if (planId != 0) {
        //         print('Thanh cong');
        //         print(planId);
        //         // ignore: use_build_context_synchronously
        //         AwesomeDialog(
        //             context: context,
        //             dialogType: DialogType.success,
        //             body: const Text(
        //               'Thêm dịch vụ thành công',
        //               style:
        //                   TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //             ),
        //             btnOkColor: primaryColor,
        //             btnOkOnPress: () async {
        //               sharedPreferences.setStringList('serviceList', []);
        //               // PlanDetail? plan = await _planService.GetPlanById(
        //               //     sharedPreferences.getInt('planId')!);
        //               // if (plan != null) {
        //               await _offlineService.savePlanToHive(PlanOfflineViewModel(
        //                   id: widget.planId,
        //                   name: planDetail!.name,
        //                   imageBase64: await Utils()
        //                       .getImageBase64Encoded(planDetail!.imageUrls[0]),
        //                   startDate: planDetail!.startDate,
        //                   endDate: planDetail!.endDate,
        //                   memberLimit: planDetail!.memberLimit,
        //                   schedule: planDetail!.schedule,
        //                   memberList: [
        //                     PlanOfflineMember(
        //                         id: int.parse(
        //                             sharedPreferences.getString('userId')!),
        //                         name: "Quoc Manh",
        //                         phone:
        //                             sharedPreferences.getString('userPhone')!,
        //                         isLeading: true)
        //                   ]));
        //               Utils().clearPlanSharePref();
        //               Navigator.of(context).pop();
        //               Navigator.of(context).push(MaterialPageRoute(
        //                   builder: (ctx) => const TabScreen(pageIndex: 1)));
        //             }).show();
        //       }
        //     },
        //     child: const Text('Hoàn tất')),
        // SizedBox(
        //   height: 1.h,
        // )
      ]),
    );
  }
}
