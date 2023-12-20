import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/screens/loading_screen/plan_loading_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/empty_plan.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_card.dart';
import 'package:sizer2/sizer2.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with TickerProviderStateMixin {
  final PlanService _planService = PlanService();
  List<PlanCardViewModel> _onGoingPlans = [];
  List<PlanCardViewModel> _draftPlans = [];
  List<PlanCardViewModel> _canceledPlans = [];
  List<PlanCardViewModel> _futuredPlans = [];
  List<PlanCardViewModel> _historyPlans = [];

  bool isLoading = true;
  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setUpData();
    tabController = TabController(length: 4, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  _setUpData() async {
    List<PlanCardViewModel> draftPlans = [];
    List<PlanCardViewModel> onGoingPlans = [];
    List<PlanCardViewModel> canceledPlans = [];
    List<PlanCardViewModel> historyPlans = [];
    List<PlanCardViewModel> futurePlans = [];
    List<PlanCardViewModel>? totalPlans = await _planService.getPlanCards();

    if (totalPlans != null) {
      for (final plan in totalPlans) {
        switch (plan.status) {
          case "CANCELED":
            canceledPlans.add(plan);
            break;
          case "DRAFT":
            draftPlans.add(plan);
            break;
          case "FUTURE":
            futurePlans.add(plan);
            break;
          case "VERIFIED":
            onGoingPlans.add(plan);
            break;
          case "FINISHED":
            historyPlans.add(plan);
            break;
          case "ONGOING":
            onGoingPlans.add(plan);
            break;
          case "PAST":
            historyPlans.add(plan);
            break;
        }
      }
      setState(() {
        _draftPlans = draftPlans;
        _canceledPlans = canceledPlans;
        _futuredPlans = futurePlans;
        _onGoingPlans = onGoingPlans;
        _historyPlans = historyPlans;
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
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TabBar(
                      controller: tabController,
                      indicatorColor: primaryColor,
                      labelColor: primaryColor,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(
                          text: "Sắp đến",
                          height: 5.h,                         
                        ),
                        Tab(
                          text: "Đang diễn ra",
                          height: 5.h,
                        ),
                        Tab(
                          text: "Lịch sử",
                          height: 5.h,
                        ),
                        Tab(
                          text: "Đã hủy",
                          height: 5.h,
                        )
                      ]),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: TabBarView(controller: tabController, children: [
                        _futuredPlans.isEmpty?
                        const EmptyPlan():
                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _futuredPlans.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: PlanCard(plan: _futuredPlans[index]),
                            );
                          },
                        ),
                        _onGoingPlans.isEmpty?
                        const EmptyPlan():
                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _onGoingPlans.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: PlanCard(plan: _onGoingPlans[index]),
                            );
                          },
                        ),
                        _historyPlans.isEmpty?
                        const EmptyPlan():
                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _historyPlans.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: PlanCard(plan: _historyPlans[index]),
                            );
                          },
                        ),
                        _canceledPlans.isEmpty?
                        const EmptyPlan():
                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _canceledPlans.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: PlanCard(plan: _canceledPlans[index]),
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
