import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/base_information_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan_schedule_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_plan_name.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_service_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_start_date_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_start_location_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
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
          isCreate: true,
        );
        break;
      case 4:
        activePage = SelectPlanName(
          location: widget.location,
        );
        break;
      case 5:
        activePage = SelectServiceScreen(location: widget.location);
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
                 if(_currentStep < 4) 
                Expanded(
                  child: ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () {
                        if (_currentStep == 2) {
                          ComboDate _selectedComboDate = listComboDate[
                              sharedPreferences.getInt('plan_combo_date')!];
                          DateTime startDate = DateTime.parse(
                              sharedPreferences.getString('plan_start_date')!);
                          DateTime endDate = DateTime.parse(
                              sharedPreferences.getString('plan_end_date')!);
                          int numberOfMember = sharedPreferences.getInt('plan_number_of_member')!;    
                          AwesomeDialog(
                              context: context,
                              dialogType: DialogType.info,
                              title: "Xác nhận thông tin",
                              btnCancelText: 'Chỉnh sửa',
                              btnCancelColor: Colors.orange,
                              btnCancelOnPress: () {
                                
                              },
                              btnOkColor: Colors.blue,
                              btnOkText: 'Lưu',
                              btnOkOnPress: () {
                                setState(() {
                                  _currentStep++;
                                });
                                getScrollLocation();
                              },
                              body: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Xác nhận thông tin',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    const Text(
                                      '(Bạn sẽ không thể chỉnh sửa những thông tin này trong các bước tiếp theo)',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                            text: "Tổng thời gian chuyến đi:  ",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${_selectedComboDate.numberOfDay} ngày, ${_selectedComboDate.numberOfNight} đêm',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal))
                                            ])),
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                            text: "Ngày khởi hành:  ",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${startDate.day}/${startDate.month}/${startDate.year}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal))
                                            ])),
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                            text: "Ngày kết thúc:  ",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${endDate.day}/${endDate.month}/${endDate.year}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal))
                                            ])),
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                            text: "Số lượng thành viên:  ",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '$numberOfMember',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal))
                                            ])),        
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                  ],
                                ),
                              )).show();
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
    // } 
    // else if (_currentStep < 6) {
    //   targetOffset = _scrollController.position.minScrollExtent + 300;
    } else {
      targetOffset = _scrollController.position.maxScrollExtent;
    }
    _scrollController.animateTo(targetOffset,
        duration: const Duration(milliseconds: 300), curve: Curves.bounceInOut);
  }
}
