import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/base_information_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan_schedule_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_emergency_service.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_plan_name.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_start_date_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_start_location_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_base_info_dialog.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class CreateNewPlanScreen extends StatefulWidget {
  const CreateNewPlanScreen(
      {super.key, required this.location, required this.isCreate});
  final LocationViewModel location;
  final bool isCreate;

  @override
  State<CreateNewPlanScreen> createState() => _CreateNewPlanScreenState();
}

class _CreateNewPlanScreenState extends State<CreateNewPlanScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final ScrollController _scrollController = ScrollController();
  int _currentStep = 0;
  PlanService _planService = PlanService();

  Future<bool> createDraftPlan(int numOfExpPeriod, DateTime startDate, DateTime endDate,
      int numberOfMember) async {
    return await _planService.createPlanDraft(PlanCreate(
        numOfExpPeriod: numOfExpPeriod,
        locationId: widget.location.id,
        startDate: startDate,
        endDate: endDate,
        latitude: sharedPreferences.getDouble('plan_start_lat')!,
        longitude: sharedPreferences.getDouble('plan_start_lng')!,
        memberLimit: numberOfMember,
        name:
            'Chuyến đi ngày ${startDate.day}/${startDate.month}/${startDate.year}',
        schedule: ''));
  }

  List<Step> getSteps() {
    return [
      Step(
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        title: const Text("Thông tin cơ bản"),
        content: Container(),
      ),
      Step(
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        title: const Text("Lên lịch trình"),
        content: Container(),
      ),
      Step(
        state: _currentStep > 5 ? StepState.complete : StepState.indexed,
        title: const Text("Hoàn tất kế hoạch"),
        content: Container(),
      ),
      // Step(
      //   state: _currentStep > 7 ? StepState.complete : StepState.indexed,
      //   title: const Text("Hoàn tất kế hoạch"),
      //   content: Container(),
      // ),
    ];
  }

  handleQuitScreen() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      body: const Padding(
        padding: EdgeInsets.all(18.0),
        child: Text(
          "Kế hoạch cho chuyến đi này chưa được lưu, bạn có chắc chắn muốn rời khỏi màn hình này không?",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
      btnOkColor: Colors.amber,
      btnOkText: "Rời khỏi",
      btnCancelColor: Colors.red,
      btnCancelText: "Hủy",
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        Utils().clearPlanSharePref();
        Navigator.of(context).pop();
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    late Widget activePage;
    switch (_currentStep) {
      case 0:
        activePage = BaseInformationScreen(
          location: widget.location,
        );
        break;
      case 1:
        activePage = SelectStartLocationScreen(
          location: widget.location,
        );
        break;
      case 2:
        activePage = const SelectStartDateScreen();
        break;
      case 3:
        activePage = CreatePlanScheduleScreen(
          templatePlan: widget.location.templatePlan,
          isCreate: widget.isCreate,
        );
        break;
      case 4:
        activePage = SelectEmergencyService(
            location: widget.location,
            planId: sharedPreferences.getInt('planId')!);
        break;
      case 5:
        activePage = SelectPlanName(
          location: widget.location,
        );
        break;
    }
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Lập kế hoạch"),
        leading: BackButton(
          onPressed: handleQuitScreen,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                      height: 10.h,
                      width: 600,
                      child: Stepper(
                        type: StepperType.horizontal,
                        steps: getSteps(),
                        connectorColor:
                            const MaterialStatePropertyAll(primaryColor),
                        currentStep: 2,
                      )),
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
                if (_currentStep > 0 && _currentStep < 3)
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
                          }
                          getScrollLocation();
                        },
                        child: const Text(
                          "Quay lại",
                          style: TextStyle(fontSize: 22),
                        )),
                  ),
                if (_currentStep > 0 && _currentStep < 3)
                  SizedBox(
                    width: 2.h,
                  ),
                if (_currentStep < 5)
                  Expanded(
                    child: ElevatedButton(
                        style: elevatedButtonStyle,
                        onPressed: () {
                          if (_currentStep == 1 &&
                              sharedPreferences.getDouble('plan_duration') ==
                                  null) {
                            // handleValidationSelectLocationScreen();
                          } else if (_currentStep == 0 &&
                              !checkValidStartDateTime()) {
                            AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    body: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 32),
                                      child: Center(
                                        child: Text(
                                          'Thời gian của chuyến đi phải sau thời điểm hiện tại ít nhất 1 giờ',
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
                          } else if (_currentStep == 2) {
                            ComboDate _selectedComboDate = listComboDate[
                                sharedPreferences.getInt('numOfExpPeriod')!];
                            DateTime startDate = DateTime.parse(
                                sharedPreferences
                                    .getString('plan_start_date')!);
                            DateTime endDate = DateTime.parse(
                                sharedPreferences.getString('plan_end_date')!);
                            int numberOfMember = sharedPreferences
                                .getInt('plan_number_of_member')!;
                            String? timeText =
                                sharedPreferences.getString('plan_start_time');
                            final initialDateTime =
                                DateFormat.Hm().parse(timeText!);
                            final _selectTime =
                                TimeOfDay.fromDateTime(initialDateTime);
                            AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.info,
                                    title: "Xác nhận thông tin",
                                    btnCancelText: 'Chỉnh sửa',
                                    btnCancelColor: Colors.orange,
                                    btnCancelOnPress: () {},
                                    btnOkColor: Colors.blue,
                                    btnOkText: 'Xác nhận',
                                    btnOkOnPress: () async{
                                      if (await createDraftPlan(
                                          _selectedComboDate.numberOfDay +
                                              _selectedComboDate.numberOfNight,
                                          DateTime(
                                              startDate.year,
                                              startDate.month,
                                              startDate.day,
                                              _selectTime.hour,
                                              _selectTime.minute),
                                          endDate,
                                          numberOfMember)) {
                                        setState(() {
                                          _currentStep++;
                                        });
                                        getScrollLocation();
                                      } else {
                                        print('error when create draft plan');
                                      }
                                    },
                                    body: ConfirmBaseInfoDialog(
                                        selectedComboDate: _selectedComboDate,
                                        endDate: endDate,
                                        numberOfMember: numberOfMember,
                                        startDate: DateTime(
                                            startDate.year,
                                            startDate.month,
                                            startDate.day,
                                            _selectTime.hour,
                                            _selectTime.minute)))
                                .show();
                          } else if (_currentStep == 3 &&
                              !checkValidStartActivityTime()) {
                            AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    body: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 32),
                                      child: Center(
                                        child: Text(
                                          'Thời gian của các hoạt động phải sau thời điểm khởi hành của chuyến đi',
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
                            setState(() {
                              _currentStep++;
                            });
                            getScrollLocation();
                          }
                        },
                        child: const Text(
                          "Tiếp tục",
                          style: TextStyle(fontSize: 22),
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
    ));
  }

  getScrollLocation() {
    double targetOffset = 0;
    if (_currentStep < 3) {
      targetOffset = _scrollController.position.minScrollExtent;
    } else if (_currentStep < 4) {
      targetOffset = _scrollController.position.minScrollExtent + 200;
    } else {
      targetOffset = _scrollController.position.maxScrollExtent;
    }
    _scrollController.animateTo(targetOffset,
        duration: const Duration(milliseconds: 300), curve: Curves.bounceInOut);
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
    final first =
        DateFormat.Hms().parse(json.decode(_schedule.first.first['time']));
    final fistTimeActivity = DateTime(0, 0, 0, first.hour, first.minute, 0);
    return _startDateTime.isBefore(fistTimeActivity);
  }
}
