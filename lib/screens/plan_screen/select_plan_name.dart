import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_service_screen.dart';
import 'package:greenwheel_user_app/service/offline_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline_member.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class SelectPlanName extends StatefulWidget {
  const SelectPlanName({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<SelectPlanName> createState() => _SelectPlanNameState();
}

class _SelectPlanNameState extends State<SelectPlanName> {
  TextEditingController _nameController = TextEditingController();
  PlanService _planService = PlanService();
  bool isCreate = false;
  final OfflineService _offlineService = OfflineService();

  createPlan() async {
    int memberLimit = sharedPreferences.getInt('plan_number_of_member')!;
    double lat = sharedPreferences.getDouble('plan_start_lat')!;
    double lng = sharedPreferences.getDouble('plan_start_lng')!;
    String startDate = sharedPreferences.getString('plan_start_date')!;
    String endDate = sharedPreferences.getString('plan_end_date')!;
    String schedule = sharedPreferences.getString('plan_schedule')!;
    String startTime = sharedPreferences.getString('plan_start_time')!;
    int numOfExpPeriod = sharedPreferences.getInt('numOfExpPeriod')!;

    final initialDateTime = DateFormat.Hm().parse(startTime);
    DateTime _startDate = DateTime.parse(startDate)
        .add(Duration(hours: initialDateTime.hour))
        .add(Duration(minutes: initialDateTime.minute));

    // final planSchedule = _planService.GetPlanScheduleFromJsonNew(
    //     json.decode(schedule),
    //     _startDate,
    //     DateTime.parse(endDate).difference(DateTime.parse(startDate)).inDays +
    //         1);

    // print(schedule);
    //  print(json.decode(schedule).toString());
    // print(planSchedule);
    // final _planSchedule = _planService.convertPlanScheduleToJson(planSchedule);
    // print(_planSchedule);

    // DateTime _startDate = DateTime.parse(startDate);
    // if (_startDate.difference(DateTime.now()).inDays == 0) {
    //   _startDate = DateTime.now().add(const Duration(hours: 1));
    // }
    int planId = sharedPreferences.getInt('planId')!;

    int? rs = await _planService.createPlan(PlanCreate(
      numOfExpPeriod: listComboDate[numOfExpPeriod].numberOfDay + listComboDate[numOfExpPeriod].numberOfNight,
        locationId: widget.location.id,
        startDate: _startDate,
        endDate: DateTime.parse(endDate),
        latitude: lat,
        longitude: lng,
        memberLimit: memberLimit,
        name: _nameController.text,
        schedule: json.decode(schedule).toString(),
        savedContacts: sharedPreferences.getString('plan_saved_emergency')
        ),
        planId
        );

    if (rs != 0) {
      setState(() {
        isCreate = true;
      });
      bool isEnableToAddService = DateTime.parse(endDate)
          .isAfter(DateTime.now().add(const Duration(days: 2)));
      if (isEnableToAddService) {
        // ignore: use_build_context_synchronously
        AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Tạo kế hoạch thành công",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 2.h,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Bạn có muốn đặt dịch vụ cho kế hoạch này không ?',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            btnCancelText: 'Không',
            btnCancelColor: Colors.blue,
            btnCancelOnPress: () {
              Utils().clearPlanSharePref();
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const TabScreen(
                        pageIndex: 1,
                      )));
            },
            btnOkText: 'Có',
            btnOkColor: primaryColor,
            btnOkOnPress: () {
              print(sharedPreferences.getString('plan_schedule'));
              print(sharedPreferences.getString('plan_saved_emergency'));
              sharedPreferences.setInt("planId", rs);
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) =>
                      SelectServiceScreen(location: widget.location)));
            }).show();
      } else {
        // ignore: use_build_context_synchronously
        // AwesomeDialog(
        //     context: context,
        //     dialogType: DialogType.success,
        //     body: Column(
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         const Text(
        //           "Tạo kế hoạch thành công",
        //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //         ),
        //         SizedBox(
        //           height: 2.h,
        //         ),
        //         const Padding(
        //           padding: EdgeInsets.symmetric(horizontal: 24),
        //           child: Text(
        //             'Bạn có muốn lưu lại các dịch vụ khẩn cấp cho kế hoạch này không ?',
        //             style: TextStyle(fontSize: 14, color: Colors.grey),
        //             textAlign: TextAlign.center,
        //           ),
        //         )
        //       ],
        //     ),
        //     btnCancelText: 'Không',
        //     btnCancelColor: Colors.blue,
        //     btnCancelOnPress: () async {
              PlanDetail? plan = await _planService.GetPlanById(rs);
              if (plan != null) {
                await _offlineService.savePlanToHive(PlanOfflineViewModel(
                    id: rs,
                    name: _nameController.text,
                    imageBase64:
                        await Utils().getImageBase64Encoded(plan.imageUrls[0]),
                    startDate: plan.startDate,
                    endDate: plan.endDate,
                    memberLimit: memberLimit,
                    schedule: plan.schedule,
                    memberList: [
                      PlanOfflineMember(
                          id: int.parse(sharedPreferences.getString('userId')!),
                          name: "Quoc Manh",
                          phone: sharedPreferences.getString('userPhone')!,
                          isLeading: true)
                    ]));
              }
              Utils().clearPlanSharePref();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const TabScreen(pageIndex: 1)));
            // },
            // btnOkText: 'Có',
            // btnOkColor: primaryColor,
            // btnOkOnPress: () async {
            //   Navigator.of(context).pop();
            //   Navigator.of(context).push(MaterialPageRoute(
            //       builder: (ctx) => SelectEmergencyService(
            //           location: widget.location, planId: rs)));
            // }).show();
      }

      // ignore: use_build_context_synchronously
      // AwesomeDialog(
      //     context: context,
      //     dialogType: DialogType.success,
      //     body: Column(
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         const Text(
      //           "Tạo kế hoạch thành công",
      //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //         ),
      //         SizedBox(
      //           height: 2.h,
      //         ),
      //         const Padding(
      //           padding: EdgeInsets.symmetric(horizontal: 24),
      //           child: Text(
      //             'Bạn có muốn lưu các dịch vụ khẩn cấp cho kế hoạch này không ?',
      //             style: TextStyle(fontSize: 14, color: Colors.grey),
      //             textAlign: TextAlign.center,
      //           ),
      //         )
      //       ],
      //     ),
      //     btnCancelText: 'Không',
      //     btnCancelColor: Colors.blue,
      //     btnCancelOnPress: () async {
      //       bool isEnableToAddService = DateTime.parse(endDate)
      //           .isAfter(DateTime.now().add(const Duration(days: 2)));
      //       if (isEnableToAddService) {
      //         AwesomeDialog(
      //             context: context,
      //             dialogType: DialogType.success,
      //             body: Column(
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 // const Text(
      //                 //   "Tạo kế hoạch thành công",
      //                 //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //                 // ),
      //                 SizedBox(
      //                   height: 2.h,
      //                 ),
      //                 const Padding(
      //                   padding: EdgeInsets.symmetric(horizontal: 24),
      //                   child: Text(
      //                     'Bạn có muốn đặt dịch vụ cho kế hoạch này không ?',
      //                     style: TextStyle(fontSize: 14, color: Colors.grey),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                 )
      //               ],
      //             ),
      //             btnCancelText: 'Không',
      //             btnCancelColor: Colors.blue,
      //             btnCancelOnPress: () async {
      //               PlanDetail? plan = await _planService.GetPlanById(rs);
      //               if (plan != null) {
      //                 await _offlineService.savePlanToHive(PlanOfflineViewModel(
      //                     id: rs,
      //                     name: _nameController.text,
      //                     imageBase64: await Utils()
      //                         .getImageBase64Encoded(plan.imageUrls[0]),
      //                     startDate: plan.startDate,
      //                     endDate: plan.endDate,
      //                     memberLimit: memberLimit,
      //                     schedule: plan.schedule,
      //                     memberList: [
      //                       PlanOfflineMember(
      //                           id: int.parse(
      //                               sharedPreferences.getString('userId')!),
      //                           name: "Quoc Manh",
      //                           phone:
      //                               sharedPreferences.getString('userPhone')!,
      //                           isLeading: true)
      //                     ]));
      //               }
      //               Utils().clearPlanSharePref();
      //               // ignore: use_build_context_synchronously
      //               Navigator.of(context).pop();
      //               // ignore: use_build_context_synchronously
      //               Navigator.of(context).push(MaterialPageRoute(
      //                   builder: (ctx) => const TabScreen(pageIndex: 1)));
      //             },
      //             btnOkText: 'Có',
      //             btnOkColor: primaryColor,
      //             btnOkOnPress: () {
      //               sharedPreferences.setInt("planId", rs);
      //               Navigator.of(context).pop();
      //               Navigator.of(context).push(MaterialPageRoute(
      //                   builder: (ctx) =>
      //                       SelectServiceScreen(location: widget.location)));
      //             }).show();
      //       } else {
      //         PlanDetail? plan = await _planService.GetPlanById(rs);
      //         if (plan != null) {
      //           await _offlineService.savePlanToHive(PlanOfflineViewModel(
      //               id: rs,
      //               name: _nameController.text,
      //               imageBase64:
      //                   await Utils().getImageBase64Encoded(plan.imageUrls[0]),
      //               startDate: plan.startDate,
      //               endDate: plan.endDate,
      //               memberLimit: memberLimit,
      //               schedule: plan.schedule,
      //               memberList: [
      //                 PlanOfflineMember(
      //                     id: int.parse(sharedPreferences.getString('userId')!),
      //                     name: "Quoc Manh",
      //                     phone: sharedPreferences.getString('userPhone')!,
      //                     isLeading: true)
      //               ]));
      //         }
      //         Utils().clearPlanSharePref();
      //         // ignore: use_build_context_synchronously
      //         Navigator.of(context).pop();
      //         // ignore: use_build_context_synchronously
      //         Navigator.of(context).push(MaterialPageRoute(
      //             builder: (ctx) => const TabScreen(pageIndex: 1)));
      //       }
      //     },
      //     btnOkText: 'Có',
      //     btnOkColor: primaryColor,
      //     btnOkOnPress: () {
      //       sharedPreferences.setInt("planId", rs);
      //       Navigator.of(context).pop();
      //       Navigator.of(context).push(MaterialPageRoute(
      //           builder: (ctx) => SelectEmergencyService(
      //                 location: widget.location,
      //                 planId: rs,
      //               )));
      //     }).show();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String endDate = sharedPreferences.getString('plan_end_date')!;
    print(
        DateTime.parse(endDate).isAfter(DateTime.now().add(Duration(days: 2))));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 20.h,
          ),
          const Text(
            'Hãy đặt tên cho chuyến đi của bạn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 2.h,
          ),
          defaultTextFormField(
            controller: _nameController,
            inputType: TextInputType.name,
          ),
          SizedBox(
            height: 3.h,
          ),
          if (!isCreate)
            ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: createPlan,
                child: const Text('Tạo kế hoạch'))
        ],
      ),
    );
  }
}
