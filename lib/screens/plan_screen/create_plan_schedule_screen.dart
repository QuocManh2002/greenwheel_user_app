
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/new_schedule_item_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_activity.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_title.dart';
import 'package:sizer2/sizer2.dart';

class CreatePlanScheduleScreen extends StatefulWidget {
  const CreatePlanScheduleScreen(
      {super.key, required this.templatePlan});
  final List<dynamic> templatePlan;

  @override
  State<CreatePlanScheduleScreen> createState() =>
      _CreatePlanScheduleScreenState();
}

class _CreatePlanScheduleScreenState extends State<CreatePlanScheduleScreen> {
  late AnimationController _animationController;
  double _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final ComboDate _selectCombo =
      listComboDate[sharedPreferences.getInt('plan_combo_date')!];
  List<PlanSchedule> testList = [];
  final PlanService _planService = PlanService();
  final DateTime _startDate =
      DateTime.parse(sharedPreferences.getString('plan_start_date')!);

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
    testList = _planService.GetPlanScheduleFromJson(widget.templatePlan);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pageController.dispose();
    _animationController.dispose();
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
        testList.firstWhere((element) => element.date == item.date).items.sort(
          (a, b) {
            var adate = DateTime(0, 0, 0, a.time.hour, a.time.minute);
            var bdate = DateTime(0, 0, 0, b.time.hour, b.time.minute);
            return adate.compareTo(bdate);
          },
        );
      });

      var finalList = _planService.convertPlanScheduleToJson(testList);

      sharedPreferences.setString('plan_schedule', finalList.toString());
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
      Navigator.of(context).pop();
    }
  }

  _showBottomSheet(PlanScheduleItem item) {
    print('id: ${item.id}');
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(1.h),
        height: 15.h,
        color: Colors.white,
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
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
                style: TextStyle(fontSize: 24),
              ),
              icon: const Icon(Icons.edit),
            ),
            SizedBox(
              height: 1.h,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  shape: const RoundedRectangleBorder(
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
                style: TextStyle(fontSize: 24),
              ),
              icon: const Icon(Icons.delete),
            )
          ],
        ),
      ),
    );
  }

  Widget getPageView(int _index) {
    return SizedBox(
      width: 100.w,
      child: testList[_index].items.isEmpty
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
              itemCount: testList[_index].items.length,
              itemBuilder: (context, index) => PlanScheduleActivity(
                  item: testList[_index].items[index],
                  showBottomSheet: _showBottomSheet),
            )),
    );
  }

  _updateItem(PlanScheduleItem item) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => NewScheduleItemScreen(
            callback: callback,
            item: item,
            startDate: testList.first.date,
            endDate: testList.last.date)));
  }

  _deleteItem(PlanScheduleItem item) {
    setState(() {
      testList
          .firstWhere((element) => element.date == item.date)
          .items
          .remove(item);
    });
    var finalList = _planService.convertPlanScheduleToJson(testList);
    sharedPreferences.setString('plan_schedule', finalList.toString());
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
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      maximumSize: const Size(100, 50)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => NewScheduleItemScreen(
                              callback: callback,
                              startDate: testList[0].date,
                              endDate: testList.last.date,
                            )));
                  },
                  child: const Row(
                    children: [Icon(Icons.add), Text('Thêm')],
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
    );
  }
}
