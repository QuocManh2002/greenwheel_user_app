import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/plans.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:greenwheel_user_app/widgets/plan_card.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  PlanService _planService = PlanService();
  List<PlanCardViewModel>? historyPlan;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setUpData();
  }

  _setUpData() async {
    historyPlan = null;
    historyPlan = await _planService.getPlanCardByStatus("OFFICIAL");
    if (historyPlan != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Kế hoạch",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(
              child: Text("Loading..."),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            
                            backgroundColor: primaryColor.withOpacity(0.3),
                            shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: () {},
                        child: const Text(
                          'Bản nháp',
                          style: TextStyle(color: primaryColor, fontSize: 17),
                        )),
                  ),
                  SingleChildScrollView(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: historyPlan!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PlanCard(plan: historyPlan![index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    ));
  }
}
