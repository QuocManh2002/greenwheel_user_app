import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/base_information_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan_schedule_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_emergency_service.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_plan_name.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_service_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_start_location_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
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
        if (rs) {
          Utils().clearPlanSharePref();
          Navigator.of(context).pop();
        }
      },
    ).show();
  }

  late Widget activePage;

  getCurrentPage() {
    setState(() {
      switch (_currentStep) {
        case 0:
          _stepperText = 'Thông tin chuyến đi';
          _stepperNumber = 1;
          activePage = BaseInformationScreen(
            location: widget.location,
          );
          break;
        case 1:
          _stepperText = 'Thông tin chuyến đi';
          _stepperNumber = 2;
          activePage = SelectStartLocationScreen(
            location: widget.location,
          );
          break;
        case 2:
          _stepperText = 'Thông tin chuyến đi';
          _stepperNumber = 3;
          activePage = SelectPlanName(
            location: widget.location,
            isCreate: widget.isCreate,
            isClone: widget.schedule == null ? false : true,
          );
        case 3:
          _stepperText = 'Liên lạc khẩn cấp';
          _stepperNumber = 4;
          activePage = SelectEmergencyService(
            location: widget.location,
          );
          break;
        case 4:
          _stepperText = 'Lên lịch trình';
          _stepperNumber = 5;
          widget.schedule == null
              ? activePage = CreatePlanScheduleScreen(
                  isCreate: widget.isCreate,
                  location: widget.location,
                  isClone: false,
                )
              : activePage = CreatePlanScheduleScreen(
                  isCreate: widget.isCreate,
                  schedule: widget.schedule,
                  location: widget.location,
                  isClone: true,
                );
          break;
        case 5:
          _stepperText = 'Dịch vụ';
          _stepperNumber = 5;
          activePage = SelectServiceScreen(
            isOrder: sharedPreferences.getInt('plan_number_of_member')! == 1,
            location: widget.location,
            isClone: widget.schedule == null ? false : true,
            memberLimit: sharedPreferences.getInt('plan_number_of_member')!,
          );
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
                  if (_currentStep > 0 && _currentStep < 6)
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
                  if (_currentStep > 0 && _currentStep < 6)
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
                            if (_currentStep == 1) {
                              if (sharedPreferences
                                      .getDouble('plan_duration_value') ==
                                  null) {
                                handleValidationSelectLocationScreen();
                              } else {
                                setState(() {
                                  _currentStep++;
                                });
                                getCurrentPage();
                              }
                            } else if (_currentStep == 2) {
                              setState(() {
                                _currentStep++;
                              });
                              getCurrentPage();
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
                                      padding: EdgeInsets.all(12),
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
                                setState(() {
                                  _currentStep += 1;
                                });
                                getCurrentPage();
                              }
                            } else if (_currentStep == 4) {
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
                              } else if (checkValidNumberOfFoodActivity()) {
                                AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    title:
                                        'Có ngày trong chuyến đi chưa đủ hoạt động ăn uống',
                                    titleTextStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    desc: 'Bạn có muốn bổ sung thêm không?',
                                    descTextStyle: const TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    btnOkColor: Colors.orange,
                                    btnOkText: 'Có',
                                    btnOkOnPress: () {},
                                    btnCancelText: 'Không',
                                    btnCancelColor: Colors.blue,
                                    btnCancelOnPress: () {
                                      showConfirmScheduleDialog();
                                    }).show();
                              } else {
                                showConfirmScheduleDialog();
                              }
                            } else {
                              setState(() {
                                _currentStep++;
                              });
                              getCurrentPage();
                            }
                          },
                          child: Text(
                            _currentStep != 5 ? 'Tiếp tục' : 'Hoàn tất',
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
    String _scheduleText = sharedPreferences.getString('plan_schedule')!;
    final List<dynamic> _schedule = json.decode(_scheduleText);
    return _schedule.any((element) => element['events'].length == 0);
  }

  bool checkValidNumberOfFoodActivity() {
    String _scheduleText = sharedPreferences.getString('plan_schedule')!;
    final List<dynamic> _schedule = json.decode(_scheduleText);
    List<dynamic> events = _schedule.map((e) => e['events']).toList();
    return events.any((element) =>
        element.where((e) => e['type'] == 'EAT').toList().length < 3);
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

  showConfirmScheduleDialog() {
    final _duration = (sharedPreferences.getInt('numOfExpPeriod')! / 2).ceil();
    AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        title: 'Xác nhận lịch trình chuyến đi',
        btnOkText: 'Xác nhận',
        btnOkColor: Colors.blue,
        btnOkOnPress: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => SelectServiceScreen(
                    isOrder:
                        sharedPreferences.getInt('plan_number_of_member')! == 1,
                    location: widget.location,
                    isClone: widget.schedule == null ? false : true,
                    memberLimit:
                        sharedPreferences.getInt('plan_number_of_member')!,
                  )));
        },
        btnCancelColor: Colors.orange,
        btnCancelText: 'Chỉnh sửa',
        btnCancelOnPress: () {},
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'Xác nhận lịch trình chuyến đi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              for (int i = 0; i < _duration; i++) buildConfirmScheduleItem(i),
            ],
          ),
        )).show();
  }

  Future<int> completePlan() async {
    var rs = await _planService.completeCreatePlan(
        PlanCreate(
          locationId: widget.location.id,
          name: sharedPreferences.getString('plan_name'),
          latitude: sharedPreferences.getDouble('plan_start_lat')!,
          longitude: sharedPreferences.getDouble('plan_start_lng')!,
          memberLimit: sharedPreferences.getInt('plan_number_of_member') ?? 1,
          savedContacts: json
              .decode(sharedPreferences.getString('plan_saved_emergency')!)
              .toString(),
          startDate:
              DateTime.parse(sharedPreferences.getString('plan_start_date')!),
          departureDate: DateTime.parse(
              sharedPreferences.getString('plan_departureDate')!),
          schedule:
              sharedPreferences.getString('plan_schedule') ?? [].toString(),
          gcoinBudget: sharedPreferences.getInt('plan_budget') ?? 0,
        ),
        sharedPreferences.getInt('planId')!,
        "[]");
    return rs;
  }
}
