import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/loading_screen/create_schedule_loading_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/base_information_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan_schedule_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_emergency_service.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_plan_name.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_service_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_start_date_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_start_location_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_base_info_dialog.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

// ignore: must_be_immutable
class CreateNewPlanScreen extends StatefulWidget {
  CreateNewPlanScreen(
      {super.key,
      required this.location,
      required this.isCreate,
      this.schedule});
  final LocationViewModel location;
  final bool isCreate;
  List<dynamic>? schedule;

  @override
  State<CreateNewPlanScreen> createState() => _CreateNewPlanScreenState();
}

class _CreateNewPlanScreenState extends State<CreateNewPlanScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentPage();
  }

  int _currentStep = 0;
  PlanService _planService = PlanService();
  String _stepperText = '';
  int _stepperNumber = 1;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _budgetController = TextEditingController();

  Future<bool> createDraftPlan(int numOfExpPeriod, DateTime departureDate,
      DateTime endDate, int numberOfMember) async {
    var duration = sharedPreferences.getDouble('plan_duration_value');
    var startDate =
        DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    var closeRegDate =
        DateTime.parse(sharedPreferences.getString('plan_closeRegDate')!);
    // departureDate.add(Duration(seconds: (duration! * 3600).ceil()));
    return await _planService.createPlanDraft(PlanCreate(
        numOfExpPeriod: numOfExpPeriod,
        locationId: widget.location.id,
        startDate: startDate,
        closeRegDate: closeRegDate,
        endDate: endDate,
        departureDate: departureDate,
        latitude: sharedPreferences.getDouble('plan_start_lat')!,
        longitude: sharedPreferences.getDouble('plan_start_lng')!,
        memberLimit: numberOfMember,
        name:
            'Chuyến đi ngày ${departureDate.day}/${departureDate.month}/${departureDate.year}',
        schedule: ''));
  }

  handleQuitScreen() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title:
          'Kế hoạch cho chuyến đi này chưa được hoàn tất, bạn có chắc chắn muốn rời khỏi màn hình này không?',
      titleTextStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      padding: EdgeInsets.symmetric(horizontal: 2.h),
      desc: 'Kế hoạch này sẽ được lưu lại trong phần bản nháp',
      descTextStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      btnOkColor: Colors.amber,
      btnOkText: "Rời khỏi",
      btnCancelColor: Colors.red,
      btnCancelText: "Hủy",
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        var rs = true;
        // var rs = await _planService.createPlanDraft(PlanCreate(
        //     locationId: widget.location.id,
        //     latitude: sharedPreferences.getDouble('plan_start_lat')!,
        //     longitude: sharedPreferences.getDouble('plan_start_lng')!,
        //     memberLimit: sharedPreferences.getInt('plan_number_of_member') ?? 1,
        //     schedule:
        //         sharedPreferences.getString('plan_schedule') ?? [].toString(),
        //     savedContacts:
        //         sharedPreferences.getString('plan_saved_emergency') ??
        //             [].toString(),
        //     gcoinBudget: sharedPreferences.getInt('plan_budget') ?? 0,
        //     numOfExpPeriod:
        //         sharedPreferences.getInt('plan_number_of_member')!));
        if (rs) {
          Utils().clearPlanSharePref();
          Navigator.of(context).pop();
        }
        // }else{
        //   log('Something wrong when create draft plan');
        // }
      },
    ).show();
  }

  late Widget activePage;

  getCurrentPage() {
    setState(() {
      switch (_currentStep) {
        case 0:
          _stepperText = 'Thông tin cơ bản';
          _stepperNumber = 1;
          activePage = BaseInformationScreen(
            location: widget.location,
          );
          break;
        case 1:
          _stepperText = 'Thông tin cơ bản';
          _stepperNumber = 1;

          activePage = SelectStartLocationScreen(
            location: widget.location,
          );
          break;
        case 2:
          _stepperText = 'Lên lịch trình';
          _stepperNumber = 2;

          widget.schedule == null
              ? activePage = CreatePlanScheduleScreen(
                  isCreate: widget.isCreate,
                  isClone: false,
                )
              : activePage = CreatePlanScheduleScreen(
                  isCreate: widget.isCreate,
                  schedule: widget.schedule,
                  isClone: true,
                );
          break;
        case 3:
          _stepperText = 'Liên lạc khẩn cấp';
          _stepperNumber = 3;
          activePage = SelectEmergencyService(
              location: widget.location,
              planId: sharedPreferences.getInt('planId')!);
          break;
        case 4:
          _stepperText = 'Hoàn tất kế hoạch';
          _stepperNumber = 4;
          activePage = SelectPlanName(
            location: widget.location,
            isCreate: widget.isCreate,
            isClone: widget.schedule == null ? false : true,
          );
          break;
        case 5:
          _stepperText = 'Tạo khoản thu';
          _stepperNumber = 5;
          activePage =
              SelectServiceScreen(location: widget.location, isClone: false);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Lập kế hoạch",
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(
          onPressed: handleQuitScreen,
          style: const ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.white)),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 7.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: primaryColor, shape: BoxShape.circle),
                          child: Text(
                            '${_stepperNumber.toString()}.',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 1.h,
                        ),
                        Text(
                          _stepperText,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.grey.withOpacity(0.5),
                      height: 1.5,
                    ),
                  ),
                  Expanded(child: activePage)
                ],
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.h),
              child: Row(
                children: [
                  if (_currentStep > 0 && _currentStep < 2)
                    Expanded(
                      child: ElevatedButton(
                          style: elevatedButtonStyle.copyWith(
                              foregroundColor:
                                  const MaterialStatePropertyAll(primaryColor),
                              backgroundColor:
                                  const MaterialStatePropertyAll(Colors.white),
                              shape: const MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                      side: BorderSide(
                                          color: primaryColor, width: 2)))),
                          onPressed: () {
                            if (_currentStep > 0) {
                              setState(() {
                                _currentStep--;
                              });
                              getCurrentPage();
                            }
                          },
                          child: const Text(
                            "Quay lại",
                            style: TextStyle(fontSize: 22),
                          )),
                    ),
                  if (_currentStep > 0 && _currentStep < 2)
                    SizedBox(
                      width: 2.h,
                    ),
                  if (_currentStep < 5)
                    Expanded(
                      child: ElevatedButton(
                          style: elevatedButtonStyle,
                          onPressed: () async {
                            if (_currentStep == 0 &&
                                sharedPreferences
                                        .getInt('plan_number_of_member') ==
                                    0) {
                              AwesomeDialog(
                                      context: context,
                                      animType: AnimType.leftSlide,
                                      dialogType: DialogType.warning,
                                      padding: const EdgeInsets.all(16),
                                      title:
                                          'Hãy chọn số lượng thành viên cho chuyến đi',
                                      titleTextStyle: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      btnOkColor: Colors.orange,
                                      btnOkText: 'Ok',
                                      btnOkOnPress: () {})
                                  .show();
                            }
                            if (_currentStep == 1 &&
                                sharedPreferences
                                        .getDouble('plan_duration_value') ==
                                    null) {
                              handleValidationSelectLocationScreen();
                            }
                            // else if (_currentStep == 1 &&
                            //     !checkValidStartDateTime()) {
                            //   AwesomeDialog(
                            //           context: context,
                            //           dialogType: DialogType.warning,
                            //           body: const Padding(
                            //             padding: EdgeInsets.symmetric(
                            //                 horizontal: 32),
                            //             child: Center(
                            //               child: Text(
                            //                 'Thời gian của chuyến đi phải sau thời điểm hiện tại ít nhất 1 giờ',
                            //                 style: TextStyle(
                            //                     fontSize: 16,
                            //                     fontWeight: FontWeight.bold),
                            //                 textAlign: TextAlign.center,
                            //               ),
                            //             ),
                            //           ),
                            //           btnOkColor: Colors.orange,
                            //           btnOkText: 'OK',
                            //           btnOkOnPress: () {})
                            //       .show();
                            // }
                            // else if (_currentStep == 2) {
                            //   ComboDate _selectedComboDate = listComboDate[
                            //       sharedPreferences.getInt('plan_combo_date')! -
                            //           1];
                            //   DateTime departureDate = DateTime.parse(
                            //       sharedPreferences
                            //           .getString('plan_departureDate')!);
                            //   DateTime endDate = DateTime.parse(
                            //       sharedPreferences
                            //           .getString('plan_end_date')!);
                            //   int numberOfMember = sharedPreferences
                            //       .getInt('plan_number_of_member')!;
                            //   String? timeText = sharedPreferences
                            //       .getString('plan_start_time');
                            //   final initialDateTime =
                            //       DateFormat.Hm().parse(timeText!);
                            //   final _selectTime =
                            //       TimeOfDay.fromDateTime(initialDateTime);
                            //   AwesomeDialog(
                            //           context: context,
                            //           dialogType: DialogType.info,
                            //           title: "Xác nhận thông tin",
                            //           btnCancelText: 'Chỉnh sửa',
                            //           btnCancelColor: Colors.orange,
                            //           btnCancelOnPress: () {},
                            //           btnOkColor: Colors.blue,
                            //           btnOkText: 'Xác nhận',
                            //           btnOkOnPress: () async {
                            //             setState(() {
                            //               activePage =
                            //                   const CreateScheduleLoadingScreen();
                            //             });
                            //             Future.delayed(const Duration(seconds: 1), () {
                            //               setState(() {
                            //                 _currentStep++;
                            //               });
                            //               getCurrentPage();
                            //             },);
                            //             // if (widget.isCreate) {
                            //               // if (await createDraftPlan(
                            //               //     sharedPreferences
                            //               //         .getInt('numOfExpPeriod')!,
                            //               //     DateTime(
                            //               //         departureDate.year,
                            //               //         departureDate.month,
                            //               //         departureDate.day,
                            //               //         _selectTime.hour,
                            //               //         _selectTime.minute),
                            //               //     endDate,
                            //               //     numberOfMember)) {
                            //               //   setState(() {
                            //               //     _currentStep++;
                            //               //     getCurrentPage();
                            //               //   });
                            //               // } else {
                            //               //   print(
                            //               //       'error when create draft plan');
                            //               // }
                            //             // } else {
                            //             //   setState(() {
                            //             //     _currentStep++;
                            //             //   });
                            //             //   getCurrentPage();
                            //             // }
                            //           },
                            //           body: ConfirmBaseInfoDialog(
                            //               selectedComboDate: _selectedComboDate,
                            //               endDate: endDate,
                            //               numberOfMember: numberOfMember,
                            //               startDate: DateTime(
                            //                   departureDate.year,
                            //                   departureDate.month,
                            //                   departureDate.day,
                            //                   _selectTime.hour,
                            //                   _selectTime.minute)))
                            //       .show();
                            // }
                            else if (_currentStep == 2) {
                              if (checkValidNumberOfActivity()) {
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.warning,
                                        body: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 32),
                                          child: Center(
                                            child: Text(
                                              'Tất cả các ngày trong chuyến đi phải có ít nhất một hoạt động',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        btnOkColor: Colors.orange,
                                        btnOkText: 'OK',
                                        btnOkOnPress: () {})
                                    .show();
                              } else {
                                // String? startDateText = sharedPreferences
                                //     .getString('plan_start_date');
                                // final _startDate =
                                //     DateTime.parse(startDateText!);
                                // String? endDateText = sharedPreferences
                                //     .getString('plan_end_date');
                                // final _endDate = DateTime.parse(endDateText!);
                                final _duration = (sharedPreferences
                                            .getInt('numOfExpPeriod')! /
                                        2)
                                    .ceil();
                                AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.info,
                                    title: 'Xác nhận lịch trình chuyến đi',
                                    btnOkText: 'Xác nhận',
                                    btnOkColor: Colors.blue,
                                    btnOkOnPress: () {
                                      setState(() {
                                        _currentStep++;
                                      });
                                      getCurrentPage();
                                    },
                                    btnCancelColor: Colors.orange,
                                    btnCancelText: 'Chỉnh sửa',
                                    btnCancelOnPress: () {},
                                    body: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            child: const Text(
                                              'Xác nhận lịch trình chuyến đi',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          for (int i = 0; i < _duration; i++)
                                            buildConfirmScheduleItem(i),
                                        ],
                                      ),
                                    )).show();
                              }
                            } else if (_currentStep == 3) {
                              List<String>? selectedEmergencyIndexList =
                                  sharedPreferences
                                      .getStringList('selectedIndex');
                              if (selectedEmergencyIndexList == null ||
                                  selectedEmergencyIndexList.isEmpty) {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  body: const Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'Bạn phải chọn ít nhất một liên lạc khẩn cấp cho chuyến đi',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  btnOkColor: Colors.orange,
                                  btnOkText: 'Ok',
                                  btnOkOnPress: () {},
                                ).show();
                              } else {
                                // showBudgetDialog();
                                setState(() {
                                  _currentStep += 1;
                                });
                                getCurrentPage();
                              }
                            } else if (_currentStep == 4) {
                              var memberlimit = sharedPreferences
                                      .getInt('plan_number_of_member') ??
                                  1;
                              var rs = await _planService.createPlanDraft(
                                  PlanCreate(
                                      locationId: widget.location.id,
                                      latitude: sharedPreferences
                                          .getDouble('plan_start_lat')!,
                                      longitude: sharedPreferences
                                          .getDouble('plan_start_lng')!,
                                      memberLimit: memberlimit,
                                      schedule: sharedPreferences
                                              .getString('plan_schedule') ??
                                          [].toString(),
                                      savedContacts:
                                          sharedPreferences.getString(
                                                  'plan_saved_emergency') ??
                                              [].toString(),
                                      gcoinBudget: sharedPreferences
                                              .getInt('plan_budget') ??
                                          0,
                                      numOfExpPeriod: sharedPreferences
                                          .getInt('numOfExpPeriod')!));
                              if (rs) {
                                if (memberlimit == 1) {
                                  final complete = await completePlan();
                                  if (complete != 0) {
// ignore: use_build_context_synchronously
                                    AwesomeDialog(
                                      context: context,
                                      animType: AnimType.bottomSlide,
                                      dialogType: DialogType.question,
                                      padding: const EdgeInsets.all(16),
                                      title:
                                          'Bạn có muốn đặt thêm các dịch vụ cho chuyến đi này không?',
                                      titleTextStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      btnOkColor: Colors.orange,
                                      btnOkText: 'Có',
                                      btnOkOnPress: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    SelectServiceScreen(
                                                      location: widget.location,
                                                      isClone: false,
                                                      isOrder: true,
                                                    )));
                                      },
                                      btnCancelColor: Colors.blue,
                                      btnCancelText: 'Không',
                                      btnCancelOnPress: () {
                                        sharedPreferences.setInt(
                                            'plan_budget', 0);
                                        completePlan();
                                      },
                                    ).show();
                                  }
                                } else {
                                  // ignore: use_build_context_synchronously
                                  AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.question,
                                          title:
                                              'Bạn có muốn tạo các đơn hàng mẫu cho kế hoạch không?',
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          titleTextStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          desc:
                                              'Việc này sẽ giúp bạn ước chừng được khoản chi tiêu cho kế hoạch này',
                                          descTextStyle: const TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                          btnOkColor: Colors.orange,
                                          btnOkText: 'Có',
                                          btnOkOnPress: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (ctx) =>
                                                        SelectServiceScreen(
                                                            location:
                                                                widget.location,
                                                            isClone: false)));
                                          },
                                          btnCancelColor: Colors.blue,
                                          btnCancelOnPress: () {
                                            sharedPreferences.setInt(
                                                'plan_budget', 0);
                                            completePlan();
                                          },
                                          btnCancelText: 'Không')
                                      .show();
                                }
                              }
                            } else {
                              setState(() {
                                _currentStep++;
                              });
                              getCurrentPage();
                            }
                          },
                          child: Text(
                            _currentStep != 4 ? 'Tiếp tục' : 'Hoàn tất',
                            style: const TextStyle(fontSize: 22),
                          )),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 1.h,
            )
          ],
        ),
      ),
    ));
  }

  handleValidationSelectLocationScreen() {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        btnOkColor: Colors.orange,
        btnOkText: 'OK',
        btnOkOnPress: () {},
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Center(
            child: Text(
              'Hãy chọn địa điểm xuất phát cho chuyến đi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        )).show();
  }

  bool checkValidStartDateTime() {
    String? timeText = sharedPreferences.getString('plan_start_time');
    final initialDateTime = DateFormat.Hm().parse(timeText!);
    final _selectTime = TimeOfDay.fromDateTime(initialDateTime);
    String? dateText = sharedPreferences.getString('plan_start_date');
    final _selectedDate = DateTime.parse(dateText!);
    return Utils().checkTimeAfterNow1Hour(_selectTime, _selectedDate);
  }

  bool checkValidStartActivityTime() {
    String? timeText = sharedPreferences.getString('plan_start_time');
    final startDateTime = DateFormat.Hm().parse(timeText!);
    final _startDateTime =
        DateTime(0, 0, 0, startDateTime.hour, startDateTime.minute, 0);
    String _scheduleText = sharedPreferences.getString('plan_schedule')!;
    final List<dynamic> _schedule = json.decode(_scheduleText);
    var firstActivity = _schedule.first.length;
    if (firstActivity == 0) {
      return true;
    }
    final first =
        DateFormat.Hms().parse(json.decode(_schedule.first.first['time']));
    final fistTimeActivity = DateTime(0, 0, 0, first.hour, first.minute, 0);
    return _startDateTime.isBefore(fistTimeActivity);
  }

  bool checkValidNumberOfActivity() {
    // final startDateText = sharedPreferences.getString('plan_start_date');
    // final _startDate = DateTime.parse(startDateText!);
    // final endDateText = sharedPreferences.getString('plan_end_date');
    // final _endDate = DateTime.parse(endDateText!);
    String _scheduleText = sharedPreferences.getString('plan_schedule')!;
    final List<dynamic> _schedule = json.decode(_scheduleText);
    // print(_endDate.difference(DateTime(_startDate.year, _startDate.month, _startDate.day)).inDays +1);
    // if (_schedule.length >
    //     _endDate
    //             .difference(
    //                 DateTime(_startDate.year, _startDate.month, _startDate.day))
    //             .inDays +
    //         1) {
    //   _schedule.remove(_schedule[0]);
    //   sharedPreferences.setString('plan_schedule', json.encode(_schedule));
    // }
    return _schedule.any((element) => element.length == 0);
  }

  Widget buildConfirmScheduleItem(int index) {
    String _scheduleText = sharedPreferences.getString('plan_schedule')!;
    final List<dynamic> _schedule = json.decode(_scheduleText);
    String rsText = '';
    for (final detail in _schedule[index]['events']) {
      if (detail != _schedule[index]['events'].last) {
        rsText +=
            '${json.decode(detail['shortDescription']) ?? 'Không có mô tả'}, ';
      } else {
        rsText +=
            '${json.decode(detail['shortDescription']) ?? 'Không có mô tả'}';
      }
    }

    return Container(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                  text: 'Ngày ${index + 1}: ',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text: rsText,
                        style: const TextStyle(fontWeight: FontWeight.normal))
                  ]),
            ),
            const SizedBox(
              height: 4,
            )
          ],
        ));
  }

  Future showBudgetDialog() => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Nhập khoản thu (GCOIN):',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: _formKey,
            child: defaultTextFormField(
              controller: _budgetController,
              inputType: TextInputType.number,
              onValidate: (value) {
                if (value == null || value.isEmpty) {
                  return "Khoản thu không hợp lệ";
                }
                if (int.parse(value) <= 0) {
                  return "Khoản thu không hợp lệ";
                }
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _currentStep++;
                  });
                  getCurrentPage();
                },
                child: const Text(
                  'Tham khảo',
                  style: TextStyle(color: primaryColor, fontSize: 16),
                )),
            TextButton(
                style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(color: primaryColor, width: 1)))),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    sharedPreferences.setInt(
                        'plan_budget', int.parse(_budgetController.text));
                    setState(() {
                      _currentStep += 2;
                    });
                    getCurrentPage();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                      fontWeight: FontWeight.bold),
                ))
          ],
        ),
      );

  Future<int> completePlan() async {
    var rs = await _planService.createPlan(
        PlanCreate(
            locationId: widget.location.id,
            latitude: sharedPreferences.getDouble('plan_start_lat')!,
            longitude: sharedPreferences.getDouble('plan_start_lng')!,
            memberLimit: sharedPreferences.getInt('plan_number_of_member') ?? 1,
            schedule:
                sharedPreferences.getString('plan_schedule') ?? [].toString(),
            name: sharedPreferences.getString('plan_name'),
            gcoinBudget: sharedPreferences.getInt('plan_budget') ?? 0,
            startDate:
                DateTime.parse(sharedPreferences.getString('plan_start_date')!),
            departureDate: DateTime.parse(
                sharedPreferences.getString('plan_departureDate')!)),
        sharedPreferences.getInt('planId')!);
    return rs;
    // if (rs != 0) {
    //   // ignore: use_build_context_synchronously
    //   AwesomeDialog(
    //     context: context,
    //     animType: AnimType.leftSlide,
    //     dialogType: DialogType.success,
    //     title: 'Tạo kế hoạch thành công',
    //     titleTextStyle:
    //         const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //     btnOkColor: primaryColor,
    //     btnOkText: 'Ok',
    //     btnOkOnPress: () {
    //       Utils().clearPlanSharePref();
    //       Navigator.of(context).pushAndRemoveUntil(
    //           MaterialPageRoute(
    //               builder: (ctx) => const TabScreen(pageIndex: 1)),
    //           (route) => false);
    //     },
    //   ).show();
    // }
  }
}
