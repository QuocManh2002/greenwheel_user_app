import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:sizer2/sizer2.dart';

class CreateNewPlanScreen extends StatefulWidget {
  const CreateNewPlanScreen({super.key});

  @override
  State<CreateNewPlanScreen> createState() => _CreateNewPlanScreenState();
}

class _CreateNewPlanScreenState extends State<CreateNewPlanScreen> {
  int _selectedCombo = 0;

  List<Step> getSteps() {
    return [
      Step(title: const Text("Thông tin cơ bản"), content: Container()),
      Step(title: const Text("Thông tin cơ bản"), content: Container()),
      Step(title: const Text("Thông tin cơ bản"), content: Container()),
      Step(title: const Text("Thông tin cơ bản"), content: Container()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Lập kế hoạch"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                  height: 10.h,
                  width: 800,
                  child:
                      Stepper(type: StepperType.horizontal, steps: getSteps())),
            ),
            SizedBox(
              height: 300,
              child: CupertinoPicker(
              itemExtent: 64,
              onSelectedItemChanged: (value) {
                setState(() {
                  _selectedCombo = value;
                });
              },
              children: Utils.modelBuilder(
                  listComboDates(),
                  (index, model) => Center(
                        child: Text(model),
                      ))),
            ),
          ],
        ),
      ),
    ));
  }
}
