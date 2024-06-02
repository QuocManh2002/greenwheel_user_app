import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/global_constant.dart';
import '../../../core/constants/urls.dart';
import '../../../helpers/util.dart';
import '../../../main.dart';
import '../../../service/plan_service.dart';
import '../../../view_models/location.dart';
import '../../../view_models/order.dart';
import '../../../view_models/plan_viewmodels/plan_create.dart';
import '../../../view_models/plan_viewmodels/plan_schedule.dart';
import '../../../view_models/plan_viewmodels/plan_schedule_item.dart';
import '../../../widgets/plan_screen_widget/craete_plan_header.dart';
import '../../../widgets/plan_screen_widget/plan_schedule_activity.dart';
import '../../../widgets/plan_screen_widget/plan_schedule_title.dart';
import '../../../widgets/style_widget/button_style.dart';
import '../../../widgets/style_widget/dialog_style.dart';
import 'create_note_surcharge_screen.dart';
import 'new_schedule_item_screen.dart';

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
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  List<PlanSchedule> scheduleList = [];
  final PlanService _planService = PlanService();
  final OrderService _orderService = OrderService();
  DateTime? departureDate;
  DateTime? startDate;
  int duration = 0;

  getTotal(OrderViewModel order) {
    var total = 0.0;
    for (final detail in order.details!) {
      total += detail.price! * detail.quantity;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.toInt();
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
    var list = _planService.getPlanScheduleFromJsonNew(
        json.decode(widget.plan!.schedule!), widget.plan!.startDate!, duration);
    scheduleList = list;

    var finalList = _planService.convertPlanScheduleToJson(scheduleList);
    widget.plan!.schedule = json.encode(finalList);
  }

  setUpDataCreate() async {
    duration = (sharedPreferences.getInt('numOfExpPeriod')! / 2).ceil();
    String? scheduleText = sharedPreferences.getString('plan_schedule');
    startDate = DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    final DateTime endDate = startDate!.add(Duration(days: duration));
    if (!widget.isClone) {
      if (scheduleText == null) {
        scheduleList = _planService.generateEmptySchedule(startDate!, endDate);
        var finalList = _planService.convertPlanScheduleToJson(scheduleList);
        sharedPreferences.setString('plan_schedule', json.encode(finalList));
      } else {
        scheduleList = _planService.convertPLanJsonToObject(
            duration, startDate!, scheduleText);
        var finalList = _planService.convertPlanScheduleToJson(scheduleList);
        sharedPreferences.setString('plan_schedule', json.encode(finalList));
      }
    } else {
      scheduleList = _planService.getPlanScheduleFromJsonNew(
          json.decode(scheduleText ?? '[]'), startDate!, duration);
      var finalList = _planService.convertPlanScheduleToJson(scheduleList);
      sharedPreferences.setString('plan_schedule', json.encode(finalList));
    }
  }

  callback(
      {required PlanScheduleItem item,
      required bool isCreate,
      PlanScheduleItem? oldItem,
      bool? isUpper,
      int? itemIndex}) {
    if (isCreate) {
      if (isUpper == null) {
        setState(() {
          scheduleList
              .firstWhere((element) => element.date == item.date)
              .items
              .add(item);
        });
      } else {
        setState(() {
          scheduleList
              .firstWhere((element) => element.date == item.date)
              .items
              .insert(isUpper ? itemIndex! : itemIndex! + 1, item);
        });
      }

      var finalList = _planService.convertPlanScheduleToJson(scheduleList);
      if (widget.plan == null) {
        sharedPreferences.setString('plan_schedule', json.encode(finalList));
      } else {
        widget.plan!.schedule = json.encode(finalList);
      }
    } else {
      setState(() {
        var index = 0;
        var itemList = scheduleList
            .firstWhere((element) => element.date == oldItem!.date)
            .items;
        if (oldItem!.orderUUID == null) {
          index = itemList.indexOf(oldItem);
          if (index >= 0) {
            itemList.remove(oldItem);
          }
        } else {
          if (item.type == 'Check-in') {
          } else {
            final tempItem = itemList.firstWhereOrNull(
                (element) => element.orderUUID == oldItem.orderUUID);
            index = itemList.indexOf(tempItem!);
            itemList.remove(tempItem);
          }
        }
        if (index >= 0) {
          scheduleList
              .firstWhere((element) => element.date == item.date)
              .items
              .insert(index, item);
        } else {
          scheduleList
              .firstWhere((element) => element.date == item.date)
              .items
              .add(item);
        }
      });
      var finalList = _planService.convertPlanScheduleToJson(scheduleList);
      sharedPreferences.setString('plan_schedule', json.encode(finalList));
    }
  }

  Widget getPageView(int index) {
    return Container(
      color: Colors.white,
      width: 100.w,
      child: scheduleList[index].items.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  emptyPlan,
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
                        fontSize: 17,),
                  ),
                )
              ],
            )
          : SizedBox(
              height: 50.h,
              child: ReorderableListView(
                children: List.generate(
                  scheduleList[index].items.length,
                  (itemIndex) => PlanScheduleActivity(
                    orderList: json.decode(
                        sharedPreferences.getString('plan_temp_order') ?? '[]'),
                    isCreate: widget.isCreate,
                    key: UniqueKey(),
                    item: scheduleList[index].items[itemIndex],
                    onUpdate: _updateItem,
                    onDetele: _deleteItem,
                    onAdd: _addItem,
                    callback: callback,
                    itemIndex: itemIndex,
                    isValidPeriodOfOrder: Utils().isValidPeriodOfOrder(
                        scheduleList[index],
                        scheduleList[index].items[itemIndex],
                        index == 0),
                  ),
                ),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final PlanScheduleItem item =
                        scheduleList[index].items.removeAt(oldIndex);
                    scheduleList[index].items.insert(newIndex, item);
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
    var currentSchedule = scheduleList.firstWhere((element) =>
        element.date ==
        scheduleList[0].date!.add(Duration(days: _currentPage.toInt())));
    var consumedTime =
        currentSchedule.items.fold(const Duration(), (previousValue, element) {
      return previousValue + element.activityTime!;
    });
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => NewScheduleItemScreen(
            sumActivityTime: consumedTime,
            callback: callback,
            location: widget.location,
            onDelete: _deleteItem,
            dayIndex: _currentPage.toInt(),
            item: item,
            startActivityTime: const Duration(),
            startDate: scheduleList.first.date!)));
  }

  _deleteItem(PlanScheduleItem item, String? orderUUID) async {
    if (item.orderUUID == null) {
      var itemList =
          scheduleList.firstWhere((element) => element.date == item.date).items;
      if (orderUUID == null) {
        setState(() {
          itemList.remove(item);
        });
      } else {
        setState(() {
          itemList.removeWhere(
            (element) => element.orderUUID == orderUUID,
          );
        });
      }
    } else {
      var orderList =
          json.decode(sharedPreferences.getString('plan_temp_order') ?? '[]');
      final order =
          orderList.firstWhere((e) => e['orderUUID'] == item.orderUUID);
      final uuid = item.orderUUID;
      final newDates = order['serveDates']
          .where(
              (date) => DateTime.parse(date).difference(item.date!).inDays != 0)
          .toList();
      bool isDeleteOrder = false;
      await AwesomeDialog(
              context: context,
              animType: AnimType.leftSlide,
              dialogType: DialogType.warning,
              body: StatefulBuilder(
                builder: (context, setState) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Hoạt động có gắn với dự trù kinh phí',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans'),
                        ),
                      ),
                      SizedBox(
                        height: 0.1.h,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.black38,
                      ),
                      SizedBox(
                        height: 0.1.h,
                      ),
                      Text(
                        order['providerName'],
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans'),
                      ),
                      for (final detail in order['details'])
                        RichText(
                            text: TextSpan(
                                text: detail['productName'],
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                    fontFamily: 'NotoSans'),
                                children: [
                              TextSpan(
                                  text: ' x${detail['quantity']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black45))
                            ])),
                      SizedBox(
                        height: 0.1.h,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.black38,
                      ),
                      SizedBox(
                        height: 0.1.h,
                      ),
                      const Text(
                        'Cập nhật ngày phục vụ: ',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans'),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              for (final date in order['serveDates'])
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(DateTime.parse(date)),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54,
                                      fontFamily: 'NotoSans',
                                      fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.keyboard_double_arrow_right,
                            color: Colors.blueAccent,
                            size: 30,
                          ),
                          const Spacer(),
                          newDates.isEmpty
                              ? Text(
                                  'Xoá đơn dịch vụ',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.red.withOpacity(0.7),
                                      fontFamily: 'NotoSans',
                                      fontWeight: FontWeight.w500),
                                )
                              : Column(
                                  children: [
                                    for (final date in newDates)
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(DateTime.parse(date)),
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54,
                                            fontFamily: 'NotoSans',
                                            fontWeight: FontWeight.w500),
                                      ),
                                  ],
                                ),
                        ],
                      ),
                      SizedBox(
                        height: 0.1.h,
                      ),
                      const Divider(
                        color: Colors.black38,
                      ),
                      SizedBox(
                        height: 0.1.h,
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: isDeleteOrder,
                            activeColor: primaryColor,
                            onChanged: (value) {
                              setState(() {
                                isDeleteOrder = !isDeleteOrder;
                              });
                            },
                          ),
                          const Text(
                            'Xoá cả đơn hàng',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'NotoSans',
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 0.1.h,
                      ),
                      const Divider(
                        color: Colors.black38,
                      ),
                      SizedBox(
                        height: 0.1.h,
                      ),
                    ],
                  ),
                ),
              ),
              btnOkColor: Colors.amber,
              btnOkOnPress: () {
                setState(() {
                  scheduleList
                      .firstWhere((element) => element.date == item.date)
                      .items
                      .remove(item);
                });
                if (isDeleteOrder || newDates.isEmpty) {
                  for (final day in scheduleList) {
                    for (final item in day.items) {
                      if (item.orderUUID != null && item.orderUUID == uuid) {
                        item.orderUUID = null;
                      }
                    }
                  }
                  orderList.remove(order);
                } else {
                  order['serveDates'] = newDates;
                  order['serveDateIndexes']
                      .remove(item.date!.difference(startDate!).inDays);
                  order['total'] = _orderService.getTempOrderTotal(order, false);
                }
              },
              btnOkText: 'Xoá',
              btnCancelColor: Colors.blue,
              btnCancelOnPress: () {},
              btnCancelText: 'Huỷ')
          .show();

      sharedPreferences.setString('plan_temp_order', json.encode(orderList));
    }
    var finalList = _planService.convertPlanScheduleToJson(scheduleList);
    sharedPreferences.setString('plan_schedule', json.encode(finalList));
  }

  _addItem(bool? isUpper, int? itemIndex) {
    var currentSchedule = scheduleList.firstWhere((element) =>
        element.date ==
        scheduleList[0].date!.add(Duration(days: _currentPage.toInt())));
    var consumedTime =
        currentSchedule.items.fold(const Duration(), (previousValue, element) {
      return previousValue + element.activityTime!;
    });

    if (consumedTime.compareTo(GlobalConstant().MAX_SUM_ACTIVITY_TIME) == 0) {
      Utils().showFullyActivityTimeDialog(context);
    } else {
      var startActivityTime = isUpper == null
          ? const Duration()
          : currentSchedule.items.length == 1
              ? isUpper
                  ? const Duration()
                  : currentSchedule.items.first.activityTime
              : currentSchedule.items
                  .sublist(0, isUpper ? itemIndex : itemIndex! + 1)
                  .fold(const Duration(), (previousValue, element) {
                  return previousValue + element.activityTime!;
                });
      Navigator.push(
          context,
          PageTransition(
              child: NewScheduleItemScreen(
                  callback: callback,
                  startDate: startDate!,
                  dayIndex: _currentPage,
                  sumActivityTime: consumedTime,
                  location: widget.location,
                  isUpper: isUpper,
                  itemIndex: itemIndex,
                  startActivityTime: startActivityTime!,
                  onDelete: _deleteItem),
              type: PageTransitionType.rightToLeft));
    }
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
                  context, widget.location, widget.isClone, widget.plan);
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
                        _currentPage = scheduleList.indexOf(scheduleList
                            .firstWhere((element) => element.date == value));
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
                    child: Image.asset(calendarSearch, fit: BoxFit.contain),
                  ),
                ),
              ),
              SizedBox(
                width: 2.h,
              ),
              const Spacer(),
              if (scheduleList[_currentPage.toInt()].items.isEmpty)
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
                        _addItem(null, null);
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
            height: 15.h,
            child: ListView.builder(
                itemCount: scheduleList.length,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: false,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final maxSumActivityTime = Utils().getMaxSumActivity(
                      scheduleList[index],
                      index == 0,
                      index == scheduleList.length - 1);
                  return Padding(
                    padding: EdgeInsets.all(1.w),
                    child: InkWell(
                        overlayColor:
                            const MaterialStatePropertyAll(Colors.transparent),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        onTap: () {
                          setState(() {
                            _currentPage = index;
                            _pageController.animateToPage(index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.bounceIn);
                          });
                        },
                        child: PlanScheduleTitle(
                          index: index,
                          date: scheduleList[index].date!,
                          isValidEatActivities: scheduleList[index]
                                  .items
                                  .where((element) => element.type == 'Ăn uống')
                                  .length >=
                              3,
                          isSelected: _currentPage == index.toDouble(),
                          isValidSumOfActivity: scheduleList[index]
                                  .items
                                  .fold(
                                      const Duration(),
                                      (previousValue, element) =>
                                          previousValue + element.activityTime!)
                                  .compareTo(maxSumActivityTime) <
                              0,
                          maxSumActivityTime: maxSumActivityTime,
                          isValidPeriodOfOrder: scheduleList[index].items.every(
                              (item) => Utils().isValidPeriodOfOrder(
                                  scheduleList[index], item, index == 0)),
                        )),
                  );
                }),
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
                } else if (checkValidPeriodOfOrder()) {
                  DialogStyle().basicDialog(
                      context: context,
                      title:
                          'Có hoạt động dịch vụ không phù hợp với lịch trình',
                      desc: 'Hãy điều chỉnh lại hoạt động này',
                      type: DialogType.warning);
                } else if (checkValidMaxSumActivity()) {
                  DialogStyle().basicDialog(
                      context: context,
                      title: 'Có ngày vượt quá thời lượng lịch trình quy định',
                      type: DialogType.warning);
                } else if (checkValidNumberOfFoodActivity()) {
                  bool notAskScheduleAgain =
                      sharedPreferences.getBool('notAskScheduleAgain') ?? false;
                  if (notAskScheduleAgain) {
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
                                      value: notAskScheduleAgain,
                                      onChanged: (value) {
                                        setState(() {
                                          notAskScheduleAgain =
                                              !notAskScheduleAgain;
                                        });
                                        sharedPreferences.setBool(
                                            'notAskScheduleAgain',
                                            notAskScheduleAgain);
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
    String? scheduleText;
    if (widget.isCreate) {
      scheduleText = sharedPreferences.getString('plan_schedule')!;
    } else {
      scheduleText = widget.plan!.schedule;
    }

    final List<dynamic> schedule = json.decode(scheduleText!);
    return schedule.any((element) => element.length == 0);
  }

  bool checkValidNumberOfFoodActivity() {
    String? scheduleText;
    if (widget.isCreate) {
      scheduleText = sharedPreferences.getString('plan_schedule')!;
    } else {
      scheduleText = widget.plan!.schedule;
    }
    final List<dynamic> schedule = json.decode(scheduleText!);
    List<dynamic> events = schedule.map((e) => e).toList();
    return events.any((element) =>
        element.where((e) => e['type'] == 'EAT').toList().length < 3);
  }

  Widget buildConfirmScheduleItem(int index) {
    String? scheduleText;
    if (widget.isCreate) {
      scheduleText = sharedPreferences.getString('plan_schedule')!;
    } else {
      scheduleText = widget.plan!.schedule;
    }

    final List<dynamic> schedule = json.decode(scheduleText!);
    String rsText = '';
    for (final detail in schedule[index]) {
      if (detail != schedule[index].last) {
        rsText +=
            '${detail['shortDescription'].toString().substring(0, 1) == '"' ? json.decode(detail['shortDescription']) : detail['shortDescription'] ?? 'Không có mô tả'} ▷ ';
      } else {
        rsText +=
            '${detail['shortDescription'].toString().substring(0, 1) == '"' ? json.decode(detail['shortDescription']) : detail['shortDescription'] ?? 'Không có mô tả'}';
      }
    }
    return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: index.isOdd
                ? primaryColor.withOpacity(0.1)
                : lightPrimaryTextColor.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              topLeft: index == 0 ? const Radius.circular(10) : Radius.zero,
              topRight: index == 0 ? const Radius.circular(10) : Radius.zero,
              bottomLeft: index == duration - 1
                  ? const Radius.circular(10)
                  : Radius.zero,
              bottomRight: index == duration - 1
                  ? const Radius.circular(10)
                  : Radius.zero,
            )),
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
        body: Container(
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Xác nhận lịch trình chuyến đi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans'),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                for (int i = 0; i < duration; i++) buildConfirmScheduleItem(i),
              ],
            ),
          ),
        )).show();
  }

  checkValidPeriodOfOrder() {
    return scheduleList.any((date) => date.items.any((element) => !Utils()
        .isValidPeriodOfOrder(date, element, date == scheduleList.first)));
  }

  checkValidMaxSumActivity() {
    return scheduleList.any((date) =>
        date.items
            .fold(
                const Duration(),
                (previousValue, element) =>
                    previousValue + element.activityTime!)
            .compareTo(Utils().getMaxSumActivity(
                date, date == scheduleList.first, date == scheduleList.last)) >
        0);
  }
}
