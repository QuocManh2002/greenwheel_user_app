import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/new_schedule_item_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_activity.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_title.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

// ignore: must_be_immutable
class CreatePlanScheduleScreen extends StatefulWidget {
  CreatePlanScheduleScreen(
      {super.key,
      required this.isCreate,
      this.schedule,
      required this.isClone,
      this.planId});
  final bool isCreate;
  final int? planId;
  List<dynamic>? schedule;
  final bool isClone;

  @override
  State<CreatePlanScheduleScreen> createState() =>
      _CreatePlanScheduleScreenState();
}

class _CreatePlanScheduleScreenState extends State<CreatePlanScheduleScreen> {
  double _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  // final ComboDate _selectCombo =
  //     listComboDate[sharedPreferences.getInt('plan_combo_date')!];
  List<PlanSchedule> testList = [];
  final PlanService _planService = PlanService();
  PlanScheduleItem? _selectedItem;
  DateTime? _startDate;
  DateTime? departureDate;
  DateTime startDate =
      DateTime.parse(sharedPreferences.getString('plan_start_date')!);
  String startTime = sharedPreferences.getString('plan_start_time')!;
  final DateTime _endDate =
      DateTime.parse(sharedPreferences.getString('plan_end_date')!);
  final duration = sharedPreferences.getDouble('plan_duration_value');
  final DateTime _departureDate =
      DateTime.parse(sharedPreferences.getString('plan_departureDate')!);

  bool _isNotOverDay = true;

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

  setUpData() async {
    // final initialDateTime = DateFormat.Hm().parse(startTime);
    // final initialDate =
    //     DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    // departureDate =
    //     DateTime(initialDate.year, initialDate.month, initialDate.day)
    //         .add(Duration(hours: initialDateTime.hour))
    //         .add(Duration(minutes: initialDateTime.minute));
    // _startDate =
    //     departureDate!.add(Duration(seconds: (duration! * 3600).ceil()));

    // var checkDate =
    //     DateTime(_startDate!.year, _startDate!.month, _startDate!.day, 6, 0);
    _isNotOverDay = startDate.day == _departureDate.day;
    // if (!_isNotOverDay) {
    //   final _newStartDate =
    //       DateTime.parse(startDate).add(const Duration(days: 1));
    // sharedPreferences.setString('plan_start_date', _newStartDate.toString());
    // }

    if (widget.isCreate) {
      if (!widget.isClone) {
        testList = _planService.generateEmptySchedule(startDate, _endDate);
        var finalList = _planService.convertPlanScheduleToJson(testList);
        sharedPreferences.setString('plan_schedule', json.encode(finalList));
      } else {
        var list = _planService.GetPlanScheduleFromJsonNew(
            widget.schedule!, startDate, _endDate.difference(startDate).inDays);
        // if (!_isNotOverDay) {
        //   final departureDate = DateTime.parse(
        //       sharedPreferences.getString('plan_departureDate')!);
        //   list = [PlanSchedule(date: departureDate, items: []), ...list];
        //   print(list.length);
        // }
        testList = _planService.GetPlanScheduleClone(list);
        var finalList = _planService.convertPlanScheduleToJson(testList);
        sharedPreferences.setString('plan_schedule', json.encode(finalList));
      }
    } else {
      // var scheduleText = sharedPreferences.getString('plan_schedule');
      var list = _planService.GetPlanScheduleFromJsonNew(
          widget.schedule!, startDate, _endDate.difference(startDate).inDays);

      // if (!_isNotOverDay) {
      //   final departureDate =
      //       DateTime.parse(sharedPreferences.getString('plan_departureDate')!);
      //   list = [PlanSchedule(date: departureDate, items: []), ...list];
      // }
      testList = list;
      var finalList = _planService.convertPlanScheduleToJson(testList);
      sharedPreferences.setString('plan_schedule', json.encode(finalList));
    }
  }

  onTap(int index) {
    setState(() {
      _currentPage = index.toDouble();
    });
  }

  callback(PlanScheduleItem item, bool isCreate, PlanScheduleItem? oldItem) {
    if (isCreate) {
      setState(() {
        print(item.date);
        testList
            .firstWhere((element) => element.date == item.date)
            .items
            .add(item);
      });

      var finalList = _planService.convertPlanScheduleToJson(testList);

      sharedPreferences.setString('plan_schedule', json.encode(finalList));
    } else {
      setState(() {
        testList
            .firstWhere((element) => element.date == oldItem!.date)
            .items
            .remove(oldItem);
        testList
            .firstWhere((element) => element.date == item.date)
            .items
            .add(item);
      });

      var finalList = _planService.convertPlanScheduleToJson(testList);

      sharedPreferences.setString('plan_schedule', json.encode(finalList));
      print(finalList);
      Navigator.of(context).pop();
    }
  }

  _showBottomSheet(PlanScheduleItem item) {
    setState(() {
      _selectedItem = item;
    });
    print('id: ${item.id}');
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(1.h),
        height: 15.h,
        color: Colors.white,
        width: double.infinity,
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor.withOpacity(0.8),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  minimumSize: Size(70.w, 5.h)),
              onPressed: () {
                _updateItem(item);
              },
              label: const Text(
                'Chỉnh sửa',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.94),
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  minimumSize: Size(70.w, 5.h)),
              onPressed: () {
                _deleteItem(item);
                Navigator.of(context).pop();
              },
              label: const Text(
                'Xóa',
                style: TextStyle(fontSize: 24, color: primaryColor),
              ),
              icon: const Icon(
                Icons.delete,
                color: primaryColor,
              ),
            )
          ],
        ),
      ),
    ).then((value) {
      setState(() {
        _selectedItem = null;
      });
    });
  }

  Widget getPageView(int _index) {
    return Container(
      color: Colors.white.withOpacity(0.1),
      width: 100.w,
      child:
          // !_isNotOverDay ?

          testList[_index].items.isEmpty
              ? Container(
                  color: Colors.white.withOpacity(0.92),
                  child: Column(
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
                          // _isNotOverDay || _currentPage != 0
                          //     ?
                          'Bạn không có lịch trình nào trong ngày này',
                          // : 'Đây là ngày dành cho di chuyển, bạn không thể thêm hoạt động vào ngày này',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: testList[_index].items.length,
                  itemBuilder: (context, index) => PlanScheduleActivity(
                      item: testList[_index].items[index],
                      showBottomSheet: _showBottomSheet,
                      isSelected:
                          _selectedItem == testList[_index].items[index]),
                )),
    );
  }

  _updateItem(PlanScheduleItem item) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => NewScheduleItemScreen(
            callback: callback,
            selectedIndex: _currentPage.toInt(),
            item: item,
            availableTime: 1,
            isNotOverDay: _isNotOverDay,
            startDate: testList.first.date)));
  }

  _deleteItem(PlanScheduleItem item) {
    setState(() {
      testList
          .firstWhere((element) => element.date == item.date)
          .items
          .remove(item);
    });
    var finalList = _planService.convertPlanScheduleToJson(testList);
    sharedPreferences.setString('plan_schedule', json.encode(finalList));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 2.h,
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  showDatePicker(
                      context: context,
                      initialDate: testList.first.date,
                      firstDate: testList.first.date,
                      lastDate: testList.last.date,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData().copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: primaryColor,
                                  onPrimary: Colors.white)),
                          child: DatePickerDialog(
                            initialDate: testList[_currentPage.toInt()].date,
                            firstDate: testList.first.date,
                            lastDate: testList.last.date,
                          ),
                        );
                      }).then((value) {
                    if (value != null) {
                      setState(() {
                        _currentPage = testList
                            .indexOf(testList
                                .firstWhere((element) => element.date == value))
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
              // if (departureDate!
              //     .add(Duration(days: _currentPage.toInt()))
              //     .isAfter(DateTime(startDate.year, startDate.month, startDate.day)))
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:primaryColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        maximumSize: const Size(110, 50)),
                    onPressed: () {
                      var _currentSchedule = testList.firstWhere((element) =>
                          element.date ==
                          testList[0]
                              .date
                              .add(Duration(days: _currentPage.toInt())));
                      int _availableTime = 0;
                      // _currentSchedule.items
                      //     .map((e) => _availableTime += e.activityTime!);
                      for (final item in _currentSchedule.items) {
                        _availableTime += item.activityTime!;
                      }
                      if (_availableTime >= 12) {
                        Utils().ShowFullyActivityTimeDialog(context);
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => NewScheduleItemScreen(
                                  callback: callback,
                                  startDate: testList[0].date,
                                  selectedIndex: _currentPage.toInt(),
                                  availableTime: 12 - _availableTime,
                                  isNotOverDay: _isNotOverDay,
                                )));
                      }
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        Text('Thêm',
                            style: TextStyle(
                              color: Colors.white,
                            ))
                      ],
                    )),
              ),
            ],
          ),
          SizedBox(
            height: 14.h,
            child: ListView.builder(
              itemCount: testList.length,
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
                        // _pageController.jumpToPage(index);
                      });
                    },
                    child: PlanScheduleTitle(
                      date: testList[index].date,
                      isSelected: _currentPage == index.toDouble(),
                    )),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                for (int index = 0; index < testList.length; index++)
                  getPageView(index)
              ],
            ),
          )
        ],
      ),
    );
  }
}
