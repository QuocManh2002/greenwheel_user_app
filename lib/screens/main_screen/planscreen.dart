import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/loading_screen/plan_loading_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/select_combo_date_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/empty_plan.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/tab_icon_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with TickerProviderStateMixin {
  final PlanService _planService = PlanService();
  final LocationService _locationService = LocationService();
  final List<List<PlanCardViewModel>> _totalPlans = [];
  List<PlanCardViewModel> _myPlans = [];
  int _selectedTab = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _setUpData();
  }

  _setUpData() async {
    List<PlanCardViewModel> onGoingPlans = [];
    List<PlanCardViewModel> canceledPlans = [];
    List<PlanCardViewModel> historyPlans = [];
    List<PlanCardViewModel> futurePlans = [];
    List<PlanCardViewModel>? totalPlans =
        await _planService.getPlanCards(false,context);

    if (totalPlans != null) {
      for (final plan in totalPlans) {
        if(plan.status == 'CANCELED'){
          canceledPlans.add(plan);
        }
        else if (plan.utcStartAt.toLocal().isAfter(DateTime.now())) {
          futurePlans.add(plan);
        } else if (plan.utcStartAt.toLocal().isBefore(DateTime.now()) &&
            plan.utcEndAt.toLocal().isAfter(DateTime.now())) {
          onGoingPlans.add(plan);
        } else if (plan.utcEndAt.toLocal().isBefore(DateTime.now())) {
          historyPlans.add(plan);
        }
      }
      setState(() {
        _totalPlans.add(onGoingPlans);
        _totalPlans.add(onGoingPlans);
        _totalPlans.add(historyPlans);
        _totalPlans.add(canceledPlans);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xFFf2f2f2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf2f2f2),
        title: const Text(
          "Kế hoạch",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (sharedPreferences.getInt('plan_location_id') != null)
            ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.white),
                    foregroundColor: MaterialStatePropertyAll(primaryColor),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                        side: BorderSide(color: primaryColor, width: 1.5)))),
                onPressed: () async {
                  LocationViewModel? location =
                      await _locationService.getLocationById(
                          sharedPreferences.getInt('plan_location_id')!);
                  if (location != null) {
                    Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        PageTransition(
                            child: SelectComboDateScreen(
                              isCreate: true,
                              location: location,
                              isClone: false,
                            ),
                            type: PageTransitionType.rightToLeft));
                  }
                },
                child: const Text(
                  'Bản nháp',
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )),
          SizedBox(
            width: 2.w,
          )
        ],
      ),
      body: isLoading
          ? const PlanLoadingScreen()
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            setState(() {
                              _selectedTab = 0;
                            });
                          },
                          child: TabIconButton(
                            iconDefaultUrl: upComingGreen,
                            iconSelectedUrl: upComingWhite,
                            text: 'Sắp đến',
                            isSelected: _selectedTab == 0,
                            index: 0,
                            hasHeight: true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            setState(() {
                              _selectedTab = 1;
                            });
                          },
                          child: TabIconButton(
                            iconDefaultUrl: onGoingGreen,
                            iconSelectedUrl: onGoingWhite,
                            text: 'Đang diễn ra',
                            isSelected: _selectedTab == 1,
                            index: 1,
                            hasHeight: true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            setState(() {
                              _selectedTab = 2;
                            });
                          },
                          child: TabIconButton(
                            iconDefaultUrl: historyGreen,
                            iconSelectedUrl: historyWhite,
                            text: 'Lịch sử',
                            isSelected: _selectedTab == 2,
                            index: 2,
                            hasHeight: true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            setState(() {
                              _selectedTab = 3;
                            });
                          },
                          child: TabIconButton(
                            iconDefaultUrl: cancelGreen,
                            iconSelectedUrl: cancelWhite,
                            text: 'Đã hủy',
                            isSelected: _selectedTab == 3,
                            index: 3,
                            hasHeight: true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                              _selectedTab = 4;
                            });
                            List<PlanCardViewModel>? myplans =
                                await _planService.getPlanCards(true,context);
                            if (myplans != null) {
                              setState(() {
                                isLoading = false;
                                _myPlans = myplans;
                              });
                            }
                          },
                          child: TabIconButton(
                            iconDefaultUrl: draftGreen,
                            iconSelectedUrl: draftWhite,
                            text: 'Chuyến đi của tôi',
                            isSelected: _selectedTab == 4,
                            index: 4,
                            hasHeight: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: _selectedTab != 4
                              ? _totalPlans[_selectedTab].isEmpty
                                  ? const EmptyPlan()
                                  : ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          _totalPlans[_selectedTab].length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: PlanCard(
                                              isOwned: false,
                                              plan: _totalPlans[_selectedTab]
                                                  [index]),
                                        );
                                      },
                                    )
                              : isLoading
                                  ? const PlanLoadingScreen()
                                  : _myPlans.isEmpty
                                      ? const EmptyPlan()
                                      : ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: _myPlans.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              child: PlanCard(
                                                  isOwned: true,
                                                  plan: _myPlans[index]),
                                            );
                                          },
                                        )))
                ],
              ),
            ),
    ));
  }
}
