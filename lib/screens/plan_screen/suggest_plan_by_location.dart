import 'package:flutter/material.dart';
import 'package:phuot_app/models/pagination.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/combo_date_plan.dart';
import '../../core/constants/urls.dart';
import '../../service/plan_service.dart';
import '../../view_models/location.dart';
import '../../view_models/plan_viewmodels/plan_card.dart';
import '../../widgets/plan_screen_widget/filter_published_plan_dialog.dart';
import '../../widgets/plan_screen_widget/plan_card.dart';
import '../loading_screen/publish_plan_loading_screen.dart';

class SuggestPlansByLocationScreen extends StatefulWidget {
  const SuggestPlansByLocationScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<SuggestPlansByLocationScreen> createState() =>
      _SuggestPlanByLocationScreenState();
}

class _SuggestPlanByLocationScreenState
    extends State<SuggestPlansByLocationScreen> {
  final PlanService _planService = PlanService();
  final List<PlanCardViewModel> _suggestPlans = [];
  Pagination<PlanCardViewModel>? page;
  bool isLoading = true;
  String? cursor;

  final controller = ScrollController();
  bool isCalled = false;

  int filterCombodateIndex = 0;
  double filterMinAmount = 0;
  double filterMaxAmount = 1;

  List<PlanCardViewModel>? _filterPlans;

  @override
  void initState() {
    super.initState();
    setUpData();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (!isCalled) {
          setUpData();
          isCalled = true;
        }
      } else {
        if (isCalled) {
          isCalled = false;
        }
      }
    });
  }

  setUpData() async {
    page = null;
    page = await _planService.getSuggestPlanByLocation(
        widget.location.id, cursor, context);
    if (page != null) {
      cursor = page!.cursor;
      setState(() {
        _suggestPlans.addAll(page!.objects!);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: lightPrimaryTextColor,
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.white)),
              ),
              title: const Text(
                'Tham khảo kế hoạch',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: FilterPublishedPlanDialog(
                            comboDateIndex: filterCombodateIndex,
                            maxAmount: filterMaxAmount,
                            minAmount: filterMinAmount,
                            onChangeComboDate: (comboDateIndex) {
                              filterCombodateIndex = comboDateIndex;
                            },
                            onChangeRange: (rangeValues) {
                              filterMaxAmount = rangeValues.end;
                              filterMinAmount = rangeValues.start;
                            },
                          ),
                          actions: [
                            if (_filterPlans != null)
                              TextButton(
                                  style: const ButtonStyle(
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12)),
                                              side: BorderSide(
                                                  color: primaryColor,
                                                  width: 1))),
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.transparent),
                                      foregroundColor: MaterialStatePropertyAll(
                                          primaryColor)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _filterPlans = null;
                                      filterCombodateIndex = 0;
                                      filterMaxAmount = 1;
                                      filterMinAmount = 0;
                                    });
                                  },
                                  child: const Text('Bỏ bộ lọc')),
                            const Spacer(),
                            TextButton(
                                style: const ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Colors.transparent),
                                    foregroundColor:
                                        MaterialStatePropertyAll(primaryColor)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Huỷ')),
                            TextButton(
                                style: const ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12)),
                                            side: BorderSide(
                                                color: primaryColor,
                                                width: 1))),
                                    backgroundColor:
                                        MaterialStatePropertyAll(primaryColor),
                                    foregroundColor:
                                        MaterialStatePropertyAll(Colors.white)),
                                onPressed: onFilterPlans,
                                child: const Text('Áp dụng'))
                          ],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.filter_list_rounded,
                      size: 30,
                    ))
              ],
            ),
            body: isLoading
                ? const PublishPlanLoadingScreen()
                : _filterPlans != null
                    ? _filterPlans!.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    emptyPlan,
                                    height: 30.h,
                                  ),
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                  const Text(
                                    'Không có kế hoạch',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  )
                                ]),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _filterPlans!.length,
                              itemBuilder: (context, index) => PlanCard(
                                  plan: _filterPlans![index],
                                  isOwned: false,
                                  isPublishedPlan: true),
                            ),
                          )
                    : _suggestPlans.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    emptyPlan,
                                    height: 30.h,
                                  ),
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                  const Text(
                                    'Không có kế hoạch nào ở địa điểm này',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  )
                                ]),
                          )
                        : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                              controller: controller,
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _suggestPlans.length,
                              itemBuilder: (context, index) => PlanCard(
                                  plan: _suggestPlans[index],
                                  isOwned: false,
                                  isPublishedPlan: true),
                            ),
                        )));
  }

  onFilterPlans() async {
    Navigator.of(context).pop();
    setState(() {
      isLoading = true;
    });
    final rs = await _planService.filterPublishedPLans(
        (filterMinAmount * 30000).toInt(),
        (filterMaxAmount * 30000).toInt(),
        listComboDate[filterCombodateIndex].duration.toInt(),
        widget.location.id,
        context);
    if (rs.isEmpty) {
      setState(() {
        isLoading = false;
        _filterPlans = [];
      });
    } else {
      setState(() {
        _filterPlans = rs;
        isLoading = false;
      });
    }
  }
}
