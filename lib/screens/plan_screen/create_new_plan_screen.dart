import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/screens/plan_screen/base_information_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_start_location_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:sizer2/sizer2.dart';

class CreateNewPlanScreen extends StatefulWidget {
  const CreateNewPlanScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<CreateNewPlanScreen> createState() => _CreateNewPlanScreenState();
}

class _CreateNewPlanScreenState extends State<CreateNewPlanScreen> {
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
          title: const Text("Thông tin cơ bản"),
          content: Container(),
          isActive: _currentStep >= 1),
      Step(
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          title: const Text("Thông tin cơ bản"),
          content: Container(),
          isActive: _currentStep >= 2),
      Step(
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          title: const Text("Thông tin cơ bản"),
          content: Container(),
          isActive: _currentStep >= 3),
    ];
  }

  

  @override
  Widget build(BuildContext context) {
    late Widget activePage;
    switch (_currentStep) {
      case 0:
        activePage = const BaseInformationScreen();
        break;
      case 1:
        activePage = SelectStartLocationScreen(location: widget.location,);
        break;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Lập kế hoạch"),
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
                activePage
              ],
            ),
          ),
          ElevatedButton(
              style: elevatedButtonStyle,
              onPressed: () {
                double targetOffset = 0;
                if (_currentStep < 3) {
                  setState(() {
                    _currentStep++;
                    getSteps();
                  });
                  targetOffset = _scrollController.position.minScrollExtent +
                      150 * _currentStep;
                } else {
                  targetOffset = _scrollController.position.maxScrollExtent;
                }
                _scrollController.animateTo(targetOffset,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.bounceInOut);
              },
              child: const Text(
                "Tiếp tục",
                style: TextStyle(fontSize: 22),
              )),
          SizedBox(
            height: 2.h,
          )
        ],
      ),
    ));
  }
}
