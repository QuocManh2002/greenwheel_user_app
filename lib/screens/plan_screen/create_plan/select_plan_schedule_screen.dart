import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/service_types.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/create_note_surcharge_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/new_schedule_item_screen.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_service_infor.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/craete_plan_header.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_activity.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule_title.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class SelectPlanScheduleScreen extends StatefulWidget {
  const SelectPlanScheduleScreen(
      {super.key,
      required this.isCreate,
      this.plan,
      required this.location,
      required this.isClone});
  final bool isCreate;
  final PlanCreate? plan;
  final LocationViewModel location;
  final bool isClone;

  @override
  State<SelectPlanScheduleScreen> createState() =>
      _SelectPlanScheduleScreenState();
}

class _SelectPlanScheduleScreenState extends State<SelectPlanScheduleScreen> {
  double _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  List<PlanSchedule> scheduleList = [];
  final PlanService _planService = PlanService();
  PlanScheduleItem? _selectedItem;
  DateTime? departureDate;
  DateTime startDate = DateTime.now();
  int duration = 0;
  OrderService _orderService = OrderService();

  getTotal(OrderViewModel order) {
    var total = 0.0;
    for (final detail in order.details!) {
      total += detail.price! * detail.quantity;
    }
    return total;
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
    if (widget.plan == null) {
      setUpDataCreate();
    } else {
      setUpDataUpdate();
    }
  }

  setUpDataUpdate() async {
    int duration =
        widget.plan!.arrivedAt!.hour > 16 && widget.plan!.arrivedAt!.hour < 20
            ? ((widget.plan!.numOfExpPeriod! + 1) / 2).ceil()
            : (widget.plan!.numOfExpPeriod! / 2).ceil();
    var list = _planService.GetPlanScheduleFromJsonNew(
        json.decode(widget.plan!.schedule!), widget.plan!.startDate!, duration);
    scheduleList = list;

    var finalList = _planService.convertPlanScheduleToJson(scheduleList);
    // if (widget.plan == null) {
    //   sharedPreferences.setString('plan_schedule', json.encode(finalList));
    // } else {
    widget.plan!.schedule = json.encode(finalList);
    // }
  }

  setUpDataCreate() async {
    duration = (sharedPreferences.getInt('numOfExpPeriod')! / 2).ceil();
    String? _scheduleText = sharedPreferences.getString('plan_schedule');
    DateTime _startDate =
        DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    final DateTime _endDate = _startDate.add(Duration(days: duration));
    if (!widget.isClone) {
      if (_scheduleText == null) {
        scheduleList = _planService.generateEmptySchedule(_startDate, _endDate);
        var finalList = _planService.convertPlanScheduleToJson(scheduleList);
        sharedPreferences.setString('plan_schedule', json.encode(finalList));
      } else {
        scheduleList = _planService.ConvertPLanJsonToObject(
            duration, _startDate, _scheduleText);
        var finalList = _planService.convertPlanScheduleToJson(scheduleList);
        sharedPreferences.setString('plan_schedule', json.encode(finalList));
      }
    } else {
      var list = _planService.GetPlanScheduleFromJsonNew(
          json.decode(_scheduleText!), _startDate, duration);
      scheduleList = _planService.GetPlanScheduleClone(list);
      var finalList = _planService.convertPlanScheduleToJson(scheduleList);
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
        scheduleList
            .firstWhere((element) => element.date == item.date)
            .items
            .add(item);
      });
      var finalList = _planService.convertPlanScheduleToJson(scheduleList);
      if (widget.plan == null) {
        sharedPreferences.setString('plan_schedule', json.encode(finalList));
      } else {
        widget.plan!.schedule = json.encode(finalList);
      }
    } else {
      setState(() {
        scheduleList
            .firstWhere((element) => element.date == oldItem!.date)
            .items
            .remove(oldItem);
        scheduleList
            .firstWhere((element) => element.date == item.date)
            .items
            .add(item);
      });
      var finalList = _planService.convertPlanScheduleToJson(scheduleList);
      sharedPreferences.setString('plan_schedule', json.encode(finalList));
      Navigator.of(context).pop();
    }
  }

  getDuration() {
    int? numOfExpPeriod = sharedPreferences.getInt('numOfPeriod');
    if (numOfExpPeriod! % 2 == 0) {}
  }

  _showBottomSheet(PlanScheduleItem item) {
    setState(() {
      _selectedItem = item;
    });
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
      color: Colors.white,
      width: 100.w,
      child: scheduleList[_index].items.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  empty_plan,
                  width: 60.w,
                ),
                const SizedBox(
                  height: 12,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Bạn không có lịch trình nào trong ngày này',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          : SizedBox(
              height: 50.h,
              child: ReorderableListView(
                children: List.generate(
                  scheduleList[_index].items.length,
                  (index) => PlanScheduleActivity(
                      isCreate: widget.isCreate,
                      key: UniqueKey(),
                      item: scheduleList[_index].items[index],
                      showBottomSheet: _showBottomSheet,
                      isSelected:
                          _selectedItem == scheduleList[_index].items[index]),
                ),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final PlanScheduleItem item =
                        scheduleList[_index].items.removeAt(oldIndex);
                    scheduleList[_index].items.insert(newIndex, item);
                  });
                  var finalList =
                      _planService.convertPlanScheduleToJson(scheduleList);
                  sharedPreferences.setString(
                      'plan_schedule', json.encode(finalList));
                },
              ),
            ),
    );
  }

  _updateItem(PlanScheduleItem item) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => NewScheduleItemScreen(
            maxActivityTime: 12,
            callback: callback,
            location: widget.location,
            selectedIndex: _currentPage.toInt(),
            item: item,
            startDate: scheduleList.first.date!)));
  }

  _deleteItem(PlanScheduleItem item) {
    setState(() {
      scheduleList
          .firstWhere((element) => element.date == item.date)
          .items
          .remove(item);
    });
    var finalList = _planService.convertPlanScheduleToJson(scheduleList);
    sharedPreferences.setString('plan_schedule', json.encode(finalList));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Lên kế hoạch'),
        leading: BackButton(
          onPressed: () {
            _planService.handleQuitCreatePlanScreen(() {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }, context);
          },
        ),
        actions: [
          InkWell(
            onTap: () {
              _planService.handleShowPlanInformation(
                  context, widget.location, widget.plan);
            },
            overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                backpack,
                fit: BoxFit.fill,
                height: 32,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 3.h),
        child: Column(children: [
          const CreatePlanHeader(stepNumber: 5, stepName: 'Lịch trình'),
          Row(
            children: [
              InkWell(
                onTap: () {
                  showDatePicker(
                      context: context,
                      initialDate: scheduleList.first.date,
                      firstDate: scheduleList.first.date!,
                      lastDate: scheduleList.last.date!,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData().copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: primaryColor,
                                  onPrimary: Colors.white)),
                          child: DatePickerDialog(
                            initialDate:
                                scheduleList[_currentPage.toInt()].date,
                            firstDate: scheduleList.first.date!,
                            lastDate: scheduleList.last.date!,
                          ),
                        );
                      }).then((value) {
                    if (value != null) {
                      setState(() {
                        _currentPage = scheduleList
                            .indexOf(scheduleList
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
              SizedBox(
                width: 2.h,
              ),
              // if (sharedPreferences.getString('plan_temp_order') != null)
              //   IconButton(
              //       style: ButtonStyle(
              //           shape: const MaterialStatePropertyAll(CircleBorder(
              //               side: BorderSide(color: primaryColor, width: 1))),
              //           backgroundColor: MaterialStatePropertyAll(
              //               Colors.white.withOpacity(0.7))),
              //       onPressed: () async {
              //         final orderListJson = json.decode(
              //             sharedPreferences.getString('plan_temp_order')!);
              //         final orderList =
              //             _orderService.getOrderFromJson(orderListJson);
              //         final orderListGroupBy =
              //             orderList.groupListsBy((element) => element.type);
              //         List<OrderViewModel> listMotelOrder =
              //             orderListGroupBy.values.firstWhereOrNull((element) =>
              //                     element.first.type == services[1].name) ??
              //                 [];
              //         List<OrderViewModel> listRestaurantOrder =
              //             orderListGroupBy.values.firstWhereOrNull((element) =>
              //                     element.first.type == services[0].name) ??
              //                 [];
              //         List<OrderViewModel> listVehicleOrder =
              //             orderListGroupBy.values.firstWhereOrNull((element) =>
              //                     element.first.type == services[2].name) ??
              //                 [];
              //         var total = orderList.fold(
              //             0.0,
              //             (previousValue, element) =>
              //                 previousValue + element.total!);
              //         showModalBottomSheet(
              //             context: context,
              //             builder: (ctx) => ConfirmServiceInfor(
              //                   listVehicle: listVehicleOrder,
              //                   listSurcharges: sharedPreferences
              //                               .getString('plan_surcharge') ==
              //                           null
              //                       ? []
              //                       : json.decode(sharedPreferences
              //                           .getString('plan_surcharge')!),
              //                   total: (total / 1000).toDouble(),
              //                   budgetPerCapita: ((total /
              //                               sharedPreferences.getInt(
              //                                   'plan_number_of_member')!) /
              //                           1000)
              //                       .ceil()
              //                       .toDouble(),
              //                   listFood: listRestaurantOrder,
              //                   listRest: listMotelOrder,
              //                 ));
              //       },
              //       icon: const Icon(
              //         Icons.attach_money_rounded,
              //         color: primaryColor,
              //         size: 23,
              //       )),
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
                        maximumSize: const Size(110, 50)),
                    onPressed: () {
                      var _currentSchedule = scheduleList.firstWhere(
                          (element) =>
                              element.date ==
                              scheduleList[0]
                                  .date!
                                  .add(Duration(days: _currentPage.toInt())));
                      var consumedTime = 0;
                      for (final item in _currentSchedule.items) {
                        consumedTime += item.activityTime!;
                      }
                      if (consumedTime == 12) {
                        Utils().ShowFullyActivityTimeDialog(context);
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => NewScheduleItemScreen(
                                  callback: callback,
                                  location: widget.location,
                                  plan: widget.plan,
                                  maxActivityTime: 12 - consumedTime,
                                  startDate: scheduleList[0].date!,
                                  selectedIndex: _currentPage.toInt(),
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
              itemCount: scheduleList.length,
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
                      index: index,
                      date: scheduleList[index].date!,
                      isSelected: _currentPage == index.toDouble(),
                    )),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                for (int index = 0; index < scheduleList.length; index++)
                  getPageView(index)
              ],
            ),
          )
        ]),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 1.h,
        ),
        child: Row(
          children: [
            Expanded(
                child: ElevatedButton(
              style: elevatedButtonStyle.copyWith(
                  backgroundColor: const MaterialStatePropertyAll(Colors.white),
                  foregroundColor: const MaterialStatePropertyAll(primaryColor),
                  shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                      side: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(10))))),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Quay lại'),
            )),
            SizedBox(
              width: 2.w,
            ),
            Expanded(
                child: ElevatedButton(
              style: elevatedButtonStyle,
              onPressed: () {
                if (checkValidNumberOfActivity()) {
                  AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          body: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Center(
                              child: Text(
                                'Tất cả các ngày trong chuyến đi phải có ít nhất một hoạt động',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          btnOkColor: Colors.orange,
                          btnOkText: 'OK',
                          btnOkOnPress: () {})
                      .show();
                } else if (checkValidNumberOfFoodActivity()) {
                  bool _notAskScheduleAgain =
                      sharedPreferences.getBool('notAskScheduleAgain') ?? false;
                  if (_notAskScheduleAgain) {
                    showConfirmScheduleDialog();
                  } else {
                    AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        btnOkColor: Colors.amber,
                        btnOkText: 'Có',
                        btnOkOnPress: () {},
                        body: StatefulBuilder(
                          builder: (context, setState) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                const Text(
                                  'Có ngày trong chuyến đi chưa đủ hoạt động ăn uống',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'NotoSans',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 1.h,
                                ),
                                const Text(
                                  'Bạn có muốn bổ sung không ?',
                                  style: TextStyle(
                                      fontFamily: 'NotoSans',
                                      fontSize: 18,
                                      color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      activeColor: primaryColor,
                                      value: _notAskScheduleAgain,
                                      onChanged: (value) {
                                        setState(() {
                                          _notAskScheduleAgain =
                                              !_notAskScheduleAgain;
                                        });
                                        sharedPreferences.setBool(
                                            'notAskScheduleAgain',
                                            _notAskScheduleAgain);
                                      },
                                    ),
                                    const Text(
                                      'Không hỏi lại',
                                      style: TextStyle(
                                          fontFamily: 'NotoSans',
                                          color: Colors.grey,
                                          fontSize: 16),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        btnCancelText: 'Không',
                        btnCancelColor: Colors.blue,
                        btnCancelOnPress: () {
                          showConfirmScheduleDialog();
                        }).show();
                  }
                } else {
                  showConfirmScheduleDialog();
                }
              },
              child: const Text('Tiếp tục'),
            )),
          ],
        ),
      ),
    ));
  }

  bool checkValidNumberOfActivity() {
    String? _scheduleText;
    if (widget.isCreate) {
      _scheduleText = sharedPreferences.getString('plan_schedule')!;
    } else {
      _scheduleText = widget.plan!.schedule;
    }

    final List<dynamic> _schedule = json.decode(_scheduleText!);
    return _schedule.any((element) => element.length == 0);
  }

  bool checkValidNumberOfFoodActivity() {
    String? _scheduleText;
    if (widget.isCreate) {
      _scheduleText = sharedPreferences.getString('plan_schedule')!;
    } else {
      _scheduleText = widget.plan!.schedule;
    }
    final List<dynamic> _schedule = json.decode(_scheduleText!);
    List<dynamic> events = _schedule.map((e) => e).toList();
    return events.any((element) =>
        element.where((e) => e['type'] == 'EAT').toList().length < 3);
  }

  Widget buildConfirmScheduleItem(int index) {
    String? _scheduleText;
    if (widget.isCreate) {
      _scheduleText = sharedPreferences.getString('plan_schedule')!;
    } else {
      _scheduleText = widget.plan!.schedule;
    }

    final List<dynamic> _schedule = json.decode(_scheduleText!);
    String rsText = '';
    for (final detail in _schedule[index]) {
      if (detail != _schedule[index].last) {
        rsText +=
            '${detail['shortDescription'].toString().substring(0, 1) == '\"' ? json.decode(detail['shortDescription']) : detail['shortDescription'] ?? 'Không có mô tả'}, ';
      } else {
        rsText +=
            '${detail['shortDescription'].toString().substring(0, 1) == '\"' ? json.decode(detail['shortDescription']) : detail['shortDescription'] ?? 'Không có mô tả'}';
      }
    }
    return Container(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                  text: 'Ngày ${index + 1}: ',
                  style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'NotoSans',
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text: rsText,
                        style: const TextStyle(fontWeight: FontWeight.normal))
                  ]),
            ),
            const SizedBox(
              height: 4,
            )
          ],
        ));
  }

  showConfirmScheduleDialog() {
    final _duration = (sharedPreferences.getInt('numOfExpPeriod')! / 2).ceil();
    AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        btnOkText: 'Xác nhận',
        btnOkColor: Colors.blue,
        btnOkOnPress: () {
          Navigator.push(
              context,
              PageTransition(
                  child: CreateNoteSurchargeScreen(
                    location: widget.location,
                    totalService: 0,
                    plan: widget.plan,
                    isCreate: widget.isCreate,
                    isClone: widget.isClone,
                    orderList: json.decode(
                        sharedPreferences.getString('plan_temp_order') ?? '[]'),
                  ),
                  type: PageTransitionType.rightToLeft));
        },
        btnCancelColor: Colors.orange,
        btnCancelText: 'Chỉnh sửa',
        btnCancelOnPress: () {},
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'Xác nhận lịch trình chuyến đi',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSans'),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              for (int i = 0; i < _duration; i++) buildConfirmScheduleItem(i),
            ],
          ),
        )).show();
  }
}
