import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_title.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<DateTime> listDates = [
    DateTime.parse("2023-12-19"),
    DateTime.parse("2023-12-20"),
    DateTime.parse("2023-12-21"),
    DateTime.parse("2023-12-22"),
    DateTime.parse("2023-12-23"),
    DateTime.parse("2023-12-24"),
    DateTime.parse("2023-12-25"),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  setUpData() {}

  onTap(int index) {
    setState(() {
      _selectedIndex == index;
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
                        _selectedIndex = index;
                      });
                    },
                    child: PlanScheduleTitle(
                      date: listDates[index],
                      isSelected: _selectedIndex == index,
                    )),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
