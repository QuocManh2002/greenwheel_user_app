import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';

class DraftPlanScreen extends StatefulWidget {
  const DraftPlanScreen({super.key});

  @override
  State<DraftPlanScreen> createState() => _DraftPlanScreenState();
}

class _DraftPlanScreenState extends State<DraftPlanScreen> {
  PlanService _planService = PlanService();
  List<PlanCardViewModel>? draftPlans;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }
  
  setUpData() async{
    draftPlans = null;
    draftPlans = await _planService.getPlanCardByStatus("DRAFT");
    
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Bản nháp kế hoạch",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    ));
  }
}