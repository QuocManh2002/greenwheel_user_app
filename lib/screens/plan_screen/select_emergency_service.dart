import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_card.dart';
import 'package:sizer2/sizer2.dart';

class SelectEmergencyService extends StatefulWidget {
  const SelectEmergencyService(
      {super.key, required this.location});
  final LocationViewModel location;

  @override
  State<SelectEmergencyService> createState() => _SelectEmergencyServiceState();
}

class _SelectEmergencyServiceState extends State<SelectEmergencyService>
    with TickerProviderStateMixin {
  bool isLoading = true;
  List<EmergencyContactViewModel>? emergencyContacts;
  List<EmergencyContactViewModel>? selectedEmergencyContacts = [];
  List<dynamic> rsList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    sharedPreferences.setStringList('selectedIndex', []);
  }

  getData() async {
    sharedPreferences.setStringList('serviceList', []);
    setState(() {
      emergencyContacts = widget.location.emergencyContacts;
    });
  }

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
    sharedPreferences.setString('plan_saved_emergency', json.encode(rsList));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h,),
        SizedBox(height: 5.h,
        child:const Text('Danh sách liên lạc', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        ),
        SizedBox(
          height:
              emergencyContacts!.isEmpty && selectedEmergencyContacts!.isEmpty
                  ? 50.h
                  : 65.h,
          child: emergencyContacts!.isEmpty
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
        ),
      ]),
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
    );
  }
}
