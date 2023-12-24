import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/base_information_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan_schedule_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_start_date_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_start_location_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:sizer2/sizer2.dart';

class CreateNewPlanScreen extends StatefulWidget {
  const CreateNewPlanScreen({super.key, required this.location});
  final LocationViewModel location;

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

  List<Step> getSteps() {
    return [
      Step(
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          title: const Text("Thông tin cơ bản"),
          content: Container(),
          isActive: _currentStep >= 0),
      Step(
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          title: const Text("Lên lịch trình"),
          content: Container(),
          isActive: _currentStep >= 4),
      Step(
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          title: const Text("Chuẩn bị dịch vụ"),
          content: Container(),
          isActive: _currentStep >= 5),
      Step(
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          title: const Text("Hoàn tất kế hoạch"),
          content: Container(),
          isActive: _currentStep >= 6),
    ];
  }

  handleQuitScreen(){
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
                sharedPreferences.setInt("planId", 0);
                sharedPreferences.remove('plan_number_of_member');
                sharedPreferences.remove("plan_combo_date");
                sharedPreferences.remove("plan_start_lat");
                sharedPreferences.remove("plan_start_lng");
                sharedPreferences.remove("plan_start_time");
                // sharedPreferences.remove("plan_start_lng");
                // sharedPreferences.remove("plan_start_lng");
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
          templateSchedule: [
            PlanSchedule(date: DateTime.parse("2023-12-19"), items: [
              PlanScheduleItem(
                  time: TimeOfDay.now(),
                  title: 'An nha hang',
                  date: DateTime.now(),
                  orderId: '123')
            ]),
            PlanSchedule(date: DateTime.parse("2023-12-20"), items: []),
            PlanSchedule(date: DateTime.parse("2023-12-21"), items: []),
            PlanSchedule(date: DateTime.parse("2023-12-22"), items: []),
            PlanSchedule(date: DateTime.parse("2023-12-23"), items: []),
            PlanSchedule(date: DateTime.parse("2023-12-24"), items: []),
            PlanSchedule(date: DateTime.parse("2023-12-25"), items: []),
          ],
        );
        break;
      // case 2:
      //   activePage = const SelectStartTimeScreen();
    }
    return SafeArea(
        child: Scaffold(
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
                      width: 800,
                      child: Stepper(
                        type: StepperType.horizontal,
                        steps: getSteps(),
                        connectorColor:
                            const MaterialStatePropertyAll(primaryColor),
                        currentStep: _currentStep,
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
                if (_currentStep > 0)
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
                          double targetOffset = 0;
                          if (_currentStep < 4) {
                            setState(() {
                              _currentStep--;
                              // getSteps();
                            });
                            targetOffset =
                                _scrollController.position.minScrollExtent +
                                    150 * _currentStep;
                          } else {
                            targetOffset =
                                _scrollController.position.maxScrollExtent;
                          }
                          _scrollController.animateTo(targetOffset,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.bounceInOut);
                        },
                        child: const Text(
                          "Quay lại",
                          style: TextStyle(fontSize: 22),
                        )),
                  ),
                if (_currentStep > 0)
                  SizedBox(
                    width: 2.h,
                  ),
                Expanded(
                  child: ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () {
                        double targetOffset = 0;
                        if (_currentStep < 4) {
                          setState(() {
                            _currentStep++;
                            // getSteps();
                          });
                          targetOffset =
                              _scrollController.position.minScrollExtent +
                                  150 * _currentStep;
                        } else {
                          targetOffset =
                              _scrollController.position.maxScrollExtent;
                        }
                        _scrollController.animateTo(targetOffset,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.bounceInOut);
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
}
