import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/screens/loading_screen/plan_loading_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:greenwheel_user_app/widgets/plan_card.dart';
import 'package:sizer2/sizer2.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with TickerProviderStateMixin {
  final PlanService _planService = PlanService();
  List<PlanCardViewModel> _officialPlans= [];
  List<PlanCardViewModel> _draftPlans = [];

  bool isLoading = true;
  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setUpData();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  _setUpData() async {
    List<PlanCardViewModel> draftPlans = [];
    List<PlanCardViewModel> officialPlans = [];
    List<PlanCardViewModel>? historyPlan = await _planService.getPlanCards();
    if (historyPlan != null) {
      for(final plan in historyPlan){
        if(plan.status == "DRAFT"){
          draftPlans.add(plan);
        }else{
          officialPlans.add(plan);
        }
      }
      setState(() {
        _draftPlans = draftPlans;
        _officialPlans = officialPlans;
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
          ? const PlanLoadingScreen()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TabBar(
                      controller: tabController,
                      indicatorColor: primaryColor,
                      labelColor: primaryColor,
                      unselectedLabelColor: Colors.grey,
                      labelStyle:const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      tabs:  [
                        Tab(
                          text: "Chính thức",
                          height: 5.h,
                        ),
                        Tab(
                          text: "Bản nháp",
                          height: 5.h,
                        )
                      ]),
                  Expanded(
                    child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            child:
                                TabBarView(controller: tabController, children: [
                              ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _officialPlans.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric( vertical: 4),
                                    child: PlanCard(plan: _officialPlans[index]),
                                  );
                                },
                              ),
                              ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _draftPlans.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric( vertical: 4),
                                    child: PlanCard(plan: _draftPlans[index]),
                                  );
                                },
                              ),
                            ]),
                          ),
                  ),
                ],
              ),
            ),
    ));
  }
}
