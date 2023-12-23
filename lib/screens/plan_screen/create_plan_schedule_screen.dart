import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/screens/plan_screen/new_schedule_item_screen.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_activity.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_title.dart';
import 'package:sizer2/sizer2.dart';

class CreatePlanScheduleScreen extends StatefulWidget {
  const CreatePlanScheduleScreen({super.key, required this.templateSchedule});
  final List<PlanSchedule> templateSchedule;

  @override
  State<CreatePlanScheduleScreen> createState() =>
      _CreatePlanScheduleScreenState();
}

class _CreatePlanScheduleScreenState extends State<CreatePlanScheduleScreen> {
  late AnimationController _animationController;
  double _currentPage = 0;
  PageController _pageController = PageController(initialPage: 0);

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
        widget.templateSchedule
            .firstWhere((element) => element.date == item.date)
            .items
            .add(item);
      });
      // ScaffoldMessenger.of(context).clearSnackBars();
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(const SnackBar(content: Text('Đã thêm hoạt động mới')));
    } else {
      setState(() {
        widget.templateSchedule
            .firstWhere((element) => element.date == oldItem!.date)
            .items
            .remove(oldItem);
        widget.templateSchedule
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
      child: widget.templateSchedule[_index].items.isEmpty
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
              itemCount: widget.templateSchedule[_index].items.length,
              itemBuilder: (context, index) => PlanScheduleActivity(
                  item: widget.templateSchedule[_index].items[index],
                  showBottomSheet: _showBottomSheet),
            )),
    );
  }

  _updateItem(PlanScheduleItem item) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => NewScheduleItemScreen(
            callback: callback,
            item: item,
            startDate: widget.templateSchedule.first.date,
            endDate: widget.templateSchedule.last.date)));
  }

  _deleteItem(PlanScheduleItem item) {
    setState(() {
      widget.templateSchedule
          .firstWhere((element) => element.date == item.date)
          .items
          .remove(item);
    });
    // ScaffoldMessenger.of(context).clearSnackBars();
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(const SnackBar(content: Text('Đã xóa hoạt động')));
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
                    initialDate: widget.templateSchedule.first.date,
                    firstDate: widget.templateSchedule.first.date,
                    lastDate: widget.templateSchedule.last.date,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData().copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: primaryColor,
                                onPrimary: Colors.white)),
                        child: DatePickerDialog(
                          initialDate: widget
                              .templateSchedule[_currentPage.toInt()].date,
                          firstDate: widget.templateSchedule.first.date,
                          lastDate: widget.templateSchedule.last.date,
                        ),
                      );
                    }).then((value) {
                  if (value != null) {
                    setState(() {
                      _currentPage = widget.templateSchedule
                          .indexOf(widget.templateSchedule
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
                              startDate: widget.templateSchedule[0].date,
                              endDate: widget.templateSchedule.last.date,
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
            itemCount: widget.templateSchedule.length,
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
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.bounceIn);
                      // _pageController.jumpToPage(index);
                    });
                  },
                  child: PlanScheduleTitle(
                    date: widget.templateSchedule[index].date,
                    isSelected: _currentPage == index.toDouble(),
                  )),
            ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              for (int index = 0;
                  index < widget.templateSchedule.length;
                  index++)
                getPageView(index)
            ],
          ),
        )
      ],
    );
  }
}
