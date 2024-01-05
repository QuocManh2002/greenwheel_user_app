import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_activity.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_title.dart';
import 'package:sizer2/sizer2.dart';

class PLanScheduleWidget extends StatefulWidget {
  const PLanScheduleWidget(
      {super.key,
      required this.schedule,
      required this.endDate,
      required this.startDate});
  final List<dynamic> schedule;
  final DateTime startDate;
  final DateTime endDate;

  @override
  State<PLanScheduleWidget> createState() => _PLanScheduleWidgetState();
}

class _PLanScheduleWidgetState extends State<PLanScheduleWidget> {
  double _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  PlanService _planService = PlanService();
  List<PlanSchedule> _scheduleList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
    setUpData();
  }

  setUpData() {
    setState(() {
      _scheduleList = _planService.GetPlanScheduleFromJsonNew(
          widget.schedule,
          widget.startDate,
          widget.endDate.difference(widget.startDate).inDays + 1);
    });
  }

  Widget getPageView(int _index) {
    return SizedBox(
      width: 100.w,
      child: _scheduleList[_index].items.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  empty_plan,
                  width: 70.w,
                ),
                const SizedBox(
                  height: 12,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Bạn không có lịch trình nào trong ngày này',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          : SingleChildScrollView(
              child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: _scheduleList[_index].items.length,
              itemBuilder: (context, index) => PlanScheduleActivity(
                item: _scheduleList[_index].items[index],
                showBottomSheet: (item) {},
                isSelected: false,
              ),
            )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                showDatePicker(
                    context: context,
                    initialDate: _scheduleList.first.date,
                    firstDate: _scheduleList.first.date,
                    lastDate: _scheduleList.last.date,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData().copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: primaryColor,
                                onPrimary: Colors.white)),
                        child: DatePickerDialog(
                          initialDate: _scheduleList[_currentPage.toInt()].date,
                          firstDate: _scheduleList.first.date,
                          lastDate: _scheduleList.last.date,
                        ),
                      );
                    }).then((value) {
                  if (value != null) {
                    _scheduleList.map((e) {
                      print(e.date.difference(value).inDays);
                    });
                    setState(() {
                      _currentPage = _scheduleList
                          .indexOf(_scheduleList.firstWhere((element) =>
                              DateTime(value.year, value.month, value.day)
                                  .difference(DateTime(element.date.year,
                                      element.date.month, element.date.day))
                                  .inDays ==
                              0))
                          .toDouble();
                      _pageController.animateToPage(_currentPage.toInt(),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear);
                    });
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3,
                          color: Colors.black12,
                          offset: Offset(2, 4),
                        )
                      ],
                      shape: BoxShape.circle),
                  child: Image.asset(calendar_search, fit: BoxFit.contain),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(
          height: 14.h,
          child: ListView.builder(
            itemCount: _scheduleList.length,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.all(2.w),
              child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  onTap: () {
                    setState(() {
                      _currentPage = index.toDouble();
                      _pageController.animateToPage(index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.bounceIn);
                    });
                  },
                  child: PlanScheduleTitle(
                    date: _scheduleList[index].date,
                    isSelected: _currentPage == index.toDouble(),
                  )),
            ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              for (int index = 0; index < _scheduleList.length; index++)
                getPageView(index)
            ],
          ),
        )
      ],
    );
  }
}
