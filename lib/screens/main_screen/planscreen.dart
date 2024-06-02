import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:phuot_app/core/constants/global_constant.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/plan_statuses.dart';
import '../../core/constants/urls.dart';
import '../../main.dart';
import '../../service/location_service.dart';
import '../../service/plan_service.dart';
import '../../view_models/location.dart';
import '../../view_models/plan_viewmodels/plan_card.dart';
import '../../widgets/plan_screen_widget/empty_plan.dart';
import '../../widgets/plan_screen_widget/plan_card.dart';
import '../../widgets/plan_screen_widget/tab_icon_button.dart';
import '../loading_screen/publish_plan_loading_screen.dart';
import '../plan_screen/create_plan/select_start_location_screen.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with TickerProviderStateMixin {
  final PlanService _planService = PlanService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  final List<List<PlanCardViewModel>> _totalPlans = [];
  List<PlanCardViewModel> _searchPlans = [];
  List<PlanCardViewModel> _myPlans = [];
  int _selectedTab = 0;
  bool isLoading = true;
  bool isSearch = false;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    List<PlanCardViewModel> onGoingPlans = [];
    List<PlanCardViewModel> canceledPlans = [];
    List<PlanCardViewModel> historyPlans = [];
    List<PlanCardViewModel> readyPlans = [];
    List<PlanCardViewModel> joinedPlans = [];
    List<PlanCardViewModel>? totalPlans =
        await _planService.getPlanCards(false);

    if (totalPlans != null) {
      final planGroupList = totalPlans.groupListsBy((plan) => plan.status);
      canceledPlans.addAll(planGroupList[planStatuses[7].engName] ?? []);
      readyPlans.addAll(planGroupList[planStatuses[2].engName] ?? []);
      onGoingPlans.addAll(planGroupList[planStatuses[3].engName] ?? []);
      onGoingPlans.addAll(planGroupList[planStatuses[4].engName] ?? []);
      historyPlans.addAll(planGroupList[planStatuses[5].engName] ?? []);
      historyPlans.addAll(planGroupList[planStatuses[6].engName] ?? []);
      joinedPlans.addAll(planGroupList[planStatuses[1].engName] ?? []);
      setState(() {
        _totalPlans.add(readyPlans);
        _totalPlans.add(onGoingPlans);
        _totalPlans.add(historyPlans);
        _totalPlans.add(canceledPlans);
        _totalPlans.add(joinedPlans);
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  onSearchPlan() async {
    final searchPlans =
        await _planService.searchPLans(_searchController.text, context);
    if (searchPlans != null) {
      setState(() {
        _searchPlans = searchPlans;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
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
                            child: SelectStartLocationScreen(
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: primaryColor, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  shape: BoxShape.rectangle),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      maxLength: GlobalConstant().PLAN_NAME_MAX_LENGTH,
                      maxLines: 1,
                      cursorColor: primaryColor,
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'NotoSans',
                      ),
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 4),
                          counterText: '',
                          border: InputBorder.none,
                          hintText: 'Tên chuyến đi',
                          hintStyle: TextStyle(
                              color: Colors.grey, fontFamily: 'NotoSans')),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        if (isSearch) {
                          setState(() {
                            isSearch = false;
                            _searchController.clear();
                          });
                        } else {
                          onSearchPlan();
                          setState(() {
                            isSearch = true;
                            isLoading = true;
                          });
                        }
                      },
                      icon: Icon(
                        isSearch ? Icons.close : Icons.search,
                        color: primaryColor,
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            if (!isSearch)
              SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 17.w,
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
                    SizedBox(
                      width: 17.w,
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
                    SizedBox(
                      width: 17.w,
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
                    SizedBox(
                      width: 17.w,
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
                    SizedBox(
                      width: 17.w,
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        onTap: () {
                          setState(() {
                            _selectedTab = 4;
                          });
                        },
                        child: TabIconButton(
                          iconDefaultUrl: compassGreen,
                          iconSelectedUrl: compassWhite,
                          text: 'Đã tham gia',
                          isSelected: _selectedTab == 4,
                          index: 4,
                          hasHeight: true,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: 17.w,
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        onTap: () async {
                          setState(() {
                            scrollController.jumpTo(
                                scrollController.position.maxScrollExtent);
                            isLoading = true;
                            _selectedTab = 5;
                          });
                          List<PlanCardViewModel>? myplans =
                              await _planService.getPlanCards(true);
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
                          isSelected: _selectedTab == 5,
                          index: 5,
                          hasHeight: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (isSearch)
              Expanded(
                child: RefreshIndicator(
                    onRefresh: () async {
                      setUpData();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: isLoading
                          ? const PublishPlanLoadingScreen()
                          : _searchPlans.isEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 1,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) => SizedBox(
                                      height: 50.h, child: const EmptyPlan()),
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _searchPlans.length,
                                  itemBuilder: (context, index) {
                                    return PlanCard(
                                      isOwned: false,
                                      plan: _searchPlans[index],
                                      isPublishedPlan: false,
                                    );
                                  },
                                ),
                    )),
              ),
            if (!isSearch)
              isLoading
                  ? const Expanded(child: PublishPlanLoadingScreen())
                  : Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            isLoading = true;
                          });
                          setUpData();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: _selectedTab != 5
                              ? _totalPlans[_selectedTab].isEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: 1,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemBuilder: (context, index) => SizedBox(
                                          height: 50.h,
                                          child: const EmptyPlan()),
                                    )
                                  : ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          _totalPlans[_selectedTab].length,
                                      itemBuilder: (context, index) {
                                        return PlanCard(
                                          isOwned: false,
                                          plan: _totalPlans[_selectedTab]
                                              [index],
                                          isPublishedPlan: false,
                                        );
                                      },
                                    )
                              : isLoading
                                  ? const PublishPlanLoadingScreen()
                                  : _myPlans.isEmpty
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: 1,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemBuilder: (context, index) =>
                                              SizedBox(
                                                  height: 50.h,
                                                  child: const EmptyPlan()),
                                        )
                                      : ListView.builder(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: _myPlans.length,
                                          itemBuilder: (context, index) {
                                            return PlanCard(
                                              isOwned: true,
                                              plan: _myPlans[index],
                                              isPublishedPlan: false,
                                            );
                                          },
                                        ),
                        ),
                      ),
                    )
          ],
        ),
      ),
    ));
  }
}
