import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_activity.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_title.dart';
import 'package:sizer2/sizer2.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _currentPage = 0;
  PageController _pageController = PageController(initialPage: 0);

  List<DateTime> listDates = [
    DateTime.parse("2023-12-19"),
    DateTime.parse("2023-12-20"),
    DateTime.parse("2023-12-21"),
    DateTime.parse("2023-12-22"),
    DateTime.parse("2023-12-23"),
    DateTime.parse("2023-12-24"),
    DateTime.parse("2023-12-25"),
  ];

  List<int> listNumber = [1, 2, 3, 0, 5, 4, 0];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
    _pageController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  setUpData() {}

  onTap(int index) {
    setState(() {
      _currentPage = index.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white.withOpacity(0.94),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 14.h,
            child: ListView.builder(
              itemCount: listDates.length,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.all(2.w),
                child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    onTap: () {
                      setState(() {
                        _currentPage = index.toDouble();
                        _pageController.animateToPage(index,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.bounceIn);
                            // _pageController.jumpToPage(index);
                      });
                      
                    },
                    child: PlanScheduleTitle(
                      date: listDates[index],
                      isSelected: _currentPage == index.toDouble(),
                    )),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                for (int index = 0; index < listDates.length; index++)
                  getPageView(index)
              ],
            ),
          )
        ],
      ),
    ));
  }

  Widget getPageView(int index) {
    return SizedBox(
      width: 100.w,
      child: listNumber[index.toInt()] == 0
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
              itemCount: listNumber[index.toInt()],
              itemBuilder: (context, index) =>
                  PlanScheduleActivity(date: listDates[index.toInt()]),
            )),
    );
  }
}
