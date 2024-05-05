
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/suggest_plan.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/suggest_plan_card.dart';
import 'package:sizer2/sizer2.dart';

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
  List<SuggestPlanViewModel>? _suggestPlans;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    List<SuggestPlanViewModel>? suggestPlans =
        await _planService.getSuggestPlanByLocation(widget.location.id,context);
    if (suggestPlans.isNotEmpty) {
      setState(() {
        _suggestPlans = suggestPlans;
        isLoading = false;
      });
    } else {
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
        leading: BackButton(
          onPressed: (){Navigator.of(context).pop();},
          style:const ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Colors.white)
          ),
        ),
        title: const Text('Tham khảo kế hoạch', style: TextStyle(color: Colors.white),),
      ),
      body: isLoading
          ? const Center(
              child: Text('Loading...'),
            )
          : _suggestPlans == null
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    )
                  ]),
              )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                        for (final plan in _suggestPlans!)
                          SuggestPlanCard(
                              plan: plan,
                              imageUrl: widget.location.imageUrls[0],
                              location: widget.location,
                              )
                      ],
                    ),
                  ),
                ),
    ));
  }
}
