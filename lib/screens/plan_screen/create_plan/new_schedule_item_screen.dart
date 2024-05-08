import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:greenwheel_user_app/core/constants/meal_text.dart';
import 'package:greenwheel_user_app/core/constants/service_types.dart';
import 'package:greenwheel_user_app/core/constants/sessions.dart';
import 'package:greenwheel_user_app/core/constants/shedule_item_type.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/order_input_model.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_menu_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/create_plan_surcharge.dart';
import 'package:greenwheel_user_app/screens/sub_screen/select_session_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/dialog_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class NewScheduleItemScreen extends StatefulWidget {
  const NewScheduleItemScreen(
      {super.key,
      required this.callback,
      required this.startDate,
      required this.dayIndex,
      required this.sumActivityTime,
      required this.location,
      required this.onDelete,
      this.itemIndex,
      this.isUpper,
      this.plan,
      required this.startActivityTime,
      this.item});
  final void Function(
      {required PlanScheduleItem item,
      required bool isCreate,
      PlanScheduleItem? oldItem,
      bool? isUpper,
      int? itemIndex}) callback;
  final void Function(PlanScheduleItem item, String? orderUUID) onDelete;
  final DateTime startDate;
  final PlanScheduleItem? item;
  final int dayIndex;
  final bool? isUpper;
  final int? itemIndex;
  final Duration sumActivityTime;
  final Duration startActivityTime;
  final LocationViewModel location;
  final PlanCreate? plan;

  @override
  State<NewScheduleItemScreen> createState() => _NewScheduleItemScreenState();
}

class _NewScheduleItemScreenState extends State<NewScheduleItemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Duration _selectedTime = const Duration(hours: 1);
  String? _selectedType;
  bool _isModify = false;
  bool _isFoodActivity = false;
  bool _isRoomActivity = false;
  bool _isOrderedActivity = false;
  bool _isVisitActivity = false;
  bool _isStarEvent = false;
  bool? _isEndAtNoon;
  bool _isFirstDay = false;
  bool _isEndDay = false;
  DateTime? arrivedTime;
  Duration? _maxActivityTime;
  DateTime? _startActivityTime;

  int? numberOfMember;
  DateTime? startDate;
  DateTime? endDate;

  dynamic _tempOrder;
  dynamic _surcharge;
  Session? startSession;

  @override
  void initState() {
    super.initState();
    if (widget.plan == null) {
      setUpDataCreate();
    } else {
      setUpDataUpdate();
    }
  }

  setUpDataUpdate() {
    numberOfMember = widget.plan!.maxMemberCount;
    startDate = widget.plan!.startDate;
    endDate = widget.plan!.endDate;

    if (widget.dayIndex == 0) {
      startSession = sessions.firstWhereOrNull((element) =>
          element.from <= widget.plan!.arrivedAt!.hour &&
          element.to > widget.plan!.arrivedAt!.hour);
    } else if (widget.dayIndex >=
        (widget.plan!.numOfExpPeriod! / 2).ceil() - 1) {
      _isEndAtNoon = Utils().isEndAtNoon(widget.plan);
    }
    setUpData();
  }

  setUpDataCreate() {
    numberOfMember = sharedPreferences.getInt('plan_number_of_member')!;
    startDate = DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    endDate = DateTime.parse(sharedPreferences.getString('plan_end_date')!);
    if (widget.dayIndex == 0) {
      final arrivedTime = Utils().getArrivedTimeFromLocal();
      startSession = sessions.firstWhereOrNull((element) =>
          element.from <= arrivedTime.hour && element.to > arrivedTime.hour);
    }
    setUpData();
  }

  setUpData() {
    _isFirstDay = widget.dayIndex == 0;
    _isEndDay = widget.dayIndex >=
        (sharedPreferences.getInt('numOfExpPeriod')! / 2).ceil() - 1;
    if (_isEndDay) {
      _isEndAtNoon = Utils().isEndAtNoon(null);
    }
    _startActivityTime = getStartActivityTime();
    if (widget.item != null) {
      _maxActivityTime = GlobalConstant().MAX_SUM_ACTIVITY_TIME -
          widget.sumActivityTime +
          widget.item!.activityTime!;
      _maxActivityTime =
          GlobalConstant().MAX_SUM_ACTIVITY_TIME - widget.sumActivityTime;
      _selectedTime = widget.item!.activityTime!;
      _selectedDate = widget.item!.date!;
      _descriptionController.text = widget.item!.description!;
      _selectedType = widget.item!.type;
      _shortDescriptionController.text = widget.item!.shortDescription!;
      _isStarEvent = widget.item!.isStarred!;
      _isFoodActivity = widget.item!.type == 'Ăn uống';
      _isRoomActivity = widget.item!.type == 'Check-in';
      _isVisitActivity = widget.item!.type == 'Tham quan';
      final orderList =
          json.decode(sharedPreferences.getString('plan_temp_order') ?? '[]');
      if (orderList.isNotEmpty) {
        final tempOrders =
            orderList.where((e) => e['orderUUID'] == widget.item!.orderUUID);
        if (tempOrders.isNotEmpty) {
          _tempOrder = tempOrders.first;
          _isOrderedActivity = true;
        }
      }
    } else {
      _maxActivityTime = _isFirstDay ? 
          DateTime(0,0,0,22,0).difference(arrivedTime!) - widget.sumActivityTime:
          GlobalConstant().MAX_SUM_ACTIVITY_TIME - widget.sumActivityTime;
      setState(() {
        _selectedDate = widget.startDate.add(Duration(days: widget.dayIndex));
      });
    }
  }

  _appBar(BuildContext ctx) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.of(ctx).pop();
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  foregroundColor: _isModify ? Colors.white : Colors.grey,
                  backgroundColor:
                      _isModify ? primaryColor : Colors.grey.withOpacity(0.5)),
              onPressed: () {
                if (_isModify) {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedType == null) {
                      DialogStyle().basicDialog(
                          context: context,
                          title: 'Hãy chọn dạng hoạt động',
                          type: DialogType.warning);
                    } else {
                      if (_tempOrder != null) {
                        DateTime? endDate;
                        if (widget.plan == null) {
                          endDate = DateTime.parse(
                              sharedPreferences.getString('plan_end_date')!);
                        } else {
                          endDate = widget.plan!.endDate;
                        }
                        if (_selectedType == 'Check-in') {
                          if (widget.item == null) {
                            List<List<DateTime>> splitServeDates = Utils().splitCheckInServeDates(_tempOrder['serveDates']);
                            for(final dateList in splitServeDates){
                              widget.callback(
                                item: PlanScheduleItem(
                                    isStarred: _isStarEvent,
                                    shortDescription:
                                        _shortDescriptionController.text,
                                    description: _descriptionController.text,
                                    date: dateList.first,
                                    orderUUID: _tempOrder['orderUUID'],
                                    activityTime: _selectedTime,
                                    type: _selectedType,
                                    id: widget.item?.id),
                                isCreate: widget.item == null,
                                oldItem: widget.item);
                            widget.callback(
                              item: PlanScheduleItem(
                                  isStarred: _isStarEvent,
                                  shortDescription: 'Check-out',
                                  description: 'Check-out nhà nghỉ/khách sạn',
                                  type: 'Check-out',
                                  date: dateList.last ==
                                          endDate
                                      ? dateList.last
                                      : dateList.last.add(const Duration(days: 1)),
                                  orderUUID: _tempOrder['orderUUID'],
                                  activityTime: _selectedTime,
                                  id: widget.item?.id),
                              isCreate: widget.item == null,
                              oldItem: widget.item,
                            );
                            }
                            
                          } else {
                            final order = json
                                .decode(sharedPreferences
                                        .getString('plan_temp_order') ??
                                    '[]')
                                .where((e) =>
                                    e['orderUUID'] == _tempOrder['orderUUID']);
                            if (order.isNotEmpty) {
                              if (order.first['serveDates'].first !=
                                  _tempOrder['serveDates'].first) {
                                widget.onDelete(
                                    PlanScheduleItem(
                                        orderUUID: null,
                                        date: order.first['serveDates'].first),
                                    _tempOrder['orderUUID']);
                                widget.callback(
                                  item: PlanScheduleItem(
                                      isStarred: _isStarEvent,
                                      shortDescription:
                                          _shortDescriptionController.text,
                                      description: _descriptionController.text,
                                      date: DateTime.parse(
                                          _tempOrder['serveDates']
                                              .first
                                              .toString()),
                                      orderUUID: _tempOrder['orderUUID'],
                                      activityTime: _selectedTime,
                                      type: _selectedType,
                                      id: widget.item?.id),
                                  isCreate: true,
                                  oldItem: widget.item,
                                );
                              }
                              if (order.first['serveDates'].last !=
                                  _tempOrder['serveDates'].last) {
                                widget.onDelete(
                                    PlanScheduleItem(
                                      orderUUID: null,
                                      date: DateTime.parse(order
                                                  .first['serveDates'].last) ==
                                              endDate
                                          ? DateTime.parse(order
                                              .first['serveDates'].last
                                              .toString())
                                          : DateTime.parse(order
                                                  .first['serveDates'].last
                                                  .toString())
                                              .add(const Duration(days: 1)),
                                    ),
                                    _tempOrder['orderUUID']);
                                widget.callback(
                                  item: PlanScheduleItem(
                                      isStarred: _isStarEvent,
                                      shortDescription: 'Check-out',
                                      description:
                                          'Check-out nhà nghỉ/khách sạn',
                                      type: 'Check-out',
                                      date: DateTime.parse(
                                                  _tempOrder['serveDates']
                                                      .last) ==
                                              endDate
                                          ? DateTime.parse(
                                              _tempOrder['serveDates']
                                                  .last
                                                  .toString())
                                          : DateTime.parse(
                                                  _tempOrder['serveDates']
                                                      .last
                                                      .toString())
                                              .add(const Duration(days: 1)),
                                      orderUUID: _tempOrder['orderUUID'],
                                      activityTime: _selectedTime,
                                      id: widget.item?.id),
                                  isCreate: true,
                                  oldItem: widget.item,
                                );
                              }
                            }
                          }
                        } else {
                          if (widget.item == null) {
                            for (final day in _tempOrder['serveDates']) {
                              widget.callback(
                                item: PlanScheduleItem(
                                    isStarred: _isStarEvent,
                                    shortDescription:
                                        _shortDescriptionController.text,
                                    description: _descriptionController.text,
                                    date: DateTime.parse(day.toString()),
                                    orderUUID: _tempOrder['orderUUID'],
                                    activityTime: _selectedTime,
                                    type: _selectedType,
                                    id: widget.item?.id),
                                isCreate: true,
                                oldItem: null,
                              );
                            }
                          } else {
                            final order = json
                                .decode(sharedPreferences
                                        .getString('plan_temp_order') ??
                                    '[]')
                                .where((e) =>
                                    e['orderUUID'] == _tempOrder['orderUUID']);

                            if (order.isEmpty) {
                              for (final day in _tempOrder['serveDates']) {
                                if (widget.item != null) {
                                  widget.item!.date =
                                      DateTime.parse(day.toString());
                                }
                                widget.callback(
                                  item: PlanScheduleItem(
                                      isStarred: _isStarEvent,
                                      shortDescription:
                                          _shortDescriptionController.text,
                                      description: _descriptionController.text,
                                      date: DateTime.parse(day.toString()),
                                      orderUUID: _tempOrder['orderUUID'],
                                      activityTime: _selectedTime,
                                      type: _selectedType,
                                      id: widget.item?.id),
                                  isCreate: widget.item == null,
                                  oldItem: widget.item,
                                );
                              }
                            } else {
                              List<String> invalidOrderDate = [];
                              List<String> validOrderDate = [];
                              List<String> newOrderDate = [];
                              for (final date in order.first['serveDates']) {
                                if (!_tempOrder['serveDates'].contains(date)) {
                                  invalidOrderDate.add(date);
                                } else {
                                  validOrderDate.add(date);
                                }
                              }

                              for (final date in _tempOrder['serveDates']) {
                                if (!validOrderDate.contains(date)) {
                                  newOrderDate.add(date);
                                }
                              }
                              for (final invalidDate in invalidOrderDate) {
                                widget.onDelete(
                                    PlanScheduleItem(
                                        isStarred: _isStarEvent,
                                        shortDescription:
                                            _shortDescriptionController.text,
                                        description:
                                            _descriptionController.text,
                                        date: DateTime.parse(
                                            invalidDate.toString()),
                                        orderUUID: null,
                                        activityTime: _selectedTime,
                                        type: _selectedType,
                                        id: widget.item?.id),
                                    _tempOrder['orderUUID']);
                              }

                              for (final newDay in newOrderDate) {
                                widget.callback(
                                  item: PlanScheduleItem(
                                      isStarred: _isStarEvent,
                                      shortDescription:
                                          _shortDescriptionController.text,
                                      description: _descriptionController.text,
                                      date: DateTime.parse(newDay.toString()),
                                      orderUUID: _tempOrder['orderUUID'],
                                      activityTime: _selectedTime,
                                      type: _selectedType,
                                      id: widget.item?.id),
                                  isCreate: true,
                                  oldItem: widget.item,
                                );
                              }
                            }
                          }
                        }
                        saveTempOrder();
                      } else {
                        widget.callback(
                            item: PlanScheduleItem(
                                isStarred: _isStarEvent,
                                shortDescription:
                                    _shortDescriptionController.text,
                                description: _descriptionController.text,
                                date: _selectedDate,
                                orderUUID: null,
                                activityTime: _selectedTime,
                                type: _selectedType,
                                id: widget.item?.id),
                            isCreate: widget.item == null,
                            oldItem: widget.item,
                            itemIndex: widget.itemIndex,
                            isUpper: widget.isUpper);
                      }
                      Navigator.of(context).pop();
                      // if (widget.item != null) {
                      //   Navigator.of(context).pop();
                      // }
                    }
                  }
                }
              },
              icon: const Icon(
                Icons.done,
                color: Colors.white,
              ),
              label: const Text(
                'Lưu',
                style: TextStyle(color: Colors.white),
              )),
        )
      ],
    );
  }

  bool checkValidStartItem(TimeOfDay time) {
    var startTimeText = sharedPreferences.getString('plan_start_time');
    final startTime = DateFormat.Hm().parse(startTimeText!);
    final startDateTime =
        DateTime(0, 0, 0, startTime.hour, startTime.minute, 0);
    final startActivityDateTime = DateTime(0, 0, 0, time.hour, time.minute);
    return startActivityDateTime.isAfter(startDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item != null ? 'Chỉnh sửa hoạt động' : 'Thêm hoạt động',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 1.h,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 1.h,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 12,
                            ),
                            const Icon(
                              Icons.watch_later_outlined,
                              color: primaryColor,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            SizedBox(
                              width: 35.w,
                              child: const Text(
                                'Thời gian hoạt động',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                var tempValue = _selectedTime;
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          content: SizedBox(
                                            height: 15.h,
                                            width: 100.w,
                                            child: CupertinoTimerPicker(
                                              initialTimerDuration: tempValue,
                                              onTimerDurationChanged: (value) {
                                                tempValue = value;
                                              },
                                              mode: CupertinoTimerPickerMode.hm,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                                style: const ButtonStyle(
                                                  foregroundColor:
                                                      MaterialStatePropertyAll(
                                                          primaryColor),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('HUỶ')),
                                            TextButton(
                                                style: const ButtonStyle(
                                                  foregroundColor:
                                                      MaterialStatePropertyAll(
                                                          primaryColor),
                                                ),
                                                onPressed: () {
                                                  if (tempValue.compareTo(
                                                          _maxActivityTime!) >
                                                      0) {
                                                    DialogStyle().basicDialog(
                                                      context: context,
                                                      title:
                                                          'Đã vượt quá thời gian hoạt động cho một ngày',
                                                      type: DialogType.warning,
                                                      desc:
                                                          'Thời gian tối đa cho hoạt động này là ${_maxActivityTime!.inHours > 0 ? '${_maxActivityTime!.inHours} giờ${_maxActivityTime!.inMinutes.remainder(60) > 0 ? ' ${_maxActivityTime!.inMinutes.remainder(60)} phút' : ''}' : '${_maxActivityTime!.inMinutes.remainder(60)} phút'}',
                                                    );
                                                  } else if (tempValue.compareTo(
                                                          GlobalConstant()
                                                              .MIN_ACTIVITY_TIME) <
                                                      0) {
                                                    DialogStyle().basicDialog(
                                                        title:
                                                            'Thời gian tối thiểu cho hoạt động là 15 phút',
                                                        type:
                                                            DialogType.warning,
                                                        context: context);
                                                  } else {
                                                    setState(() {
                                                      _selectedTime = tempValue;
                                                      _isModify = true;
                                                    });
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                                child: const Text('CHỌN'))
                                          ],
                                        ));
                              },
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 1),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Text(
                                    _selectedTime.inHours > 0
                                        ? '${_selectedTime.inHours} giờ${_selectedTime.inMinutes.remainder(60) > 0 ? ', ${_selectedTime.inMinutes.remainder(60)} phút' : ''}'
                                        : '${_selectedTime.inMinutes.remainder(60)} phút',
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'NotoSans'),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _isStarEvent = !_isStarEvent;
                                });
                              },
                              icon: _isStarEvent
                                  ? const Icon(
                                      Icons.star,
                                      size: 25,
                                      color: Colors.amber,
                                    )
                                  : const Icon(
                                      Icons.star_border_outlined,
                                      size: 25,
                                      color: Colors.grey,
                                    )),
                          const Text(
                            'Hoạt động đặc biệt',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSans'),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                        width: 100.w,
                        height: 7.8.h,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(14))),
                        child: _isOrderedActivity
                            ? Text(
                                _selectedType!,
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 18),
                              )
                            : DropdownButton<String>(
                                hint: const Text(
                                  'Dạng hoạt động',
                                  style: TextStyle(fontSize: 18),
                                ),
                                disabledHint: const Text('aaa'),
                                iconEnabledColor: primaryColor,
                                iconSize: 36,
                                underline: const SizedBox(),
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                icon: const Icon(Icons.arrow_drop_down),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 18),
                                value: _selectedType,
                                onChanged: (value) {
                                  // final startSession = getStartEndSession();
                                  if (value == 'Check-in') {
                                    if (_isEndDay && _isEndAtNoon!) {
                                      DialogStyle().basicDialog(
                                          context: context,
                                          title:
                                              'Thời gian kết thúc chuyến đi không phù hợp với dịch vụ',
                                          type: DialogType.warning);
                                    // } 
                                    // else if (startSession.index == 0) {
                                    //   DialogStyle().basicDialog(
                                    //       context: context,
                                    //       title:
                                    //           'Thời gian bắt đầu hoạt động không phù hợp với dịch vụ',
                                    //       type: DialogType.warning,
                                    //       desc:
                                    //           'Chỉ được check-in nhà nghỉ/khách sạn từ 12:00 (Hiện tại: ${DateFormat.Hm().format(_startActivityTime!)})');
                                    
                                    } else {
                                      setState(() {
                                        if (!_isModify) {
                                          _isModify = true;
                                        }
                                        _selectedType = value;
                                        _isRoomActivity = true;
                                        _isFoodActivity = false;
                                        _isVisitActivity = false;
                                      });
                                    }
                                  } else {
                                    if (!_isModify) {
                                      _isModify = true;
                                    }
                                    setState(() {
                                      _selectedType = value;
                                      _isFoodActivity = value == 'Ăn uống';
                                      _isRoomActivity = value == 'Check-in';
                                      _isVisitActivity = value == 'Tham quan';
                                    });
                                  }
                                },
                                items: scheduleItemTypesVn
                                    .map(
                                      (e) => DropdownMenuItem(
                                          value: e, child: Text(e)),
                                    )
                                    .toList(),
                              ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormFieldWithLength(
                          controller: _shortDescriptionController,
                          inputType: TextInputType.text,
                          maxLength: GlobalConstant()
                              .ACTIVITY_SHORT_DESCRIPTION_MAX_LENGTH,
                          maxline: 2,
                          minline: 2,
                          text: 'Mô tả',
                          onChange: (p0) {
                            if (!_isModify) {
                              setState(() {
                                _isModify = true;
                              });
                            }
                          },
                          onValidate: (value) {
                            if (value!.isEmpty) {
                              return "Mô tả của hoạt động không được để trống";
                            } else if (value.length <
                                    GlobalConstant()
                                        .ACTIVITY_SHORT_DESCRIPTION_MIN_LENGTH ||
                                value.length >
                                    GlobalConstant()
                                        .ACTIVITY_SHORT_DESCRIPTION_MAX_LENGTH) {
                              return "Mô tả của hoạt động phải có độ dài từ ${GlobalConstant().ACTIVITY_SHORT_DESCRIPTION_MIN_LENGTH} đến ${GlobalConstant().ACTIVITY_SHORT_DESCRIPTION_MAX_LENGTH} kí tự";
                            }
                            return null;
                          },
                          hinttext: 'Câu cá, tắm suối...'),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormFieldWithLength(
                          controller: _descriptionController,
                          inputType: TextInputType.text,
                          maxLength:
                              GlobalConstant().ACTIVITY_DESCRIPTION_MAX_LENGTH,
                          maxline: 6,
                          minline: 6,
                          text: 'Mô tả chi tiết',
                          onChange: (p0) {
                            setState(() {
                              _isModify = true;
                            });
                          },
                          onValidate: (value) {
                            if (value!.isEmpty) {
                              return "Mô tả chi tiết của hoạt động không được để trống";
                            } else if (value.length >
                                GlobalConstant()
                                    .ACTIVITY_DESCRIPTION_MAX_LENGTH) {
                              return "Mô tả chi tiết của hoạt động phải có độ dài từ ${GlobalConstant().ACTIVITY_DESCRIPTION_MIN_LENGTH} - ${GlobalConstant().ACTIVITY_DESCRIPTION_MAX_LENGTH} kí tự";
                            }
                            return null;
                          },
                          hinttext: 'Câu cá ở sông Đà...'),
                    ],
                  )),
              SizedBox(
                height: 2.h,
              ),
              if (_isFoodActivity || _isRoomActivity || _isVisitActivity)
                _isOrderedActivity
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chi tiết ${_tempOrder != null ? 'dự trù kinh phí' : 'phụ thu'}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'NotoSans',
                              ),
                            ),
                            SizedBox(
                              height: 0.5.h,
                            ),
                            const Divider(
                              color: Colors.black54,
                              height: 1.5,
                            ),
                            SizedBox(
                              height: 0.5.h,
                            ),
                            if (_tempOrder != null)
                              for (final detail in _tempOrder['details'])
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 70.w,
                                      child: Text(
                                        detail['productName'],
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontFamily: 'NotoSans',
                                        ),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                      child: Text(
                                        'x${detail['quantity']}',
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontFamily: 'NotoSans',
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    )
                                  ],
                                ),
                            if (_surcharge != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    json.decode(_surcharge['note']),
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NotoSans'),
                                  ),
                                  SizedBox(
                                    height: 0.5.h,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        NumberFormat.simpleCurrency(
                                                locale: 'vi_VN',
                                                decimalDigits: 0,
                                                name: '')
                                            .format(_surcharge['gcoinAmount']),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NotoSans'),
                                      ),
                                      SvgPicture.asset(gcoinLogo, height: 18),
                                      if (_surcharge['alreadyDivided'])
                                        const Text(
                                          ' /',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'NotoSans'),
                                        ),
                                      if (_surcharge['alreadyDivided'])
                                        const Icon(
                                          Icons.person,
                                          color: primaryColor,
                                          size: 20,
                                        )
                                    ],
                                  )
                                ],
                              ),
                            SizedBox(
                              height: 0.5.h,
                            ),
                            const Divider(
                              height: 1.5,
                              color: Colors.black54,
                            ),
                            SizedBox(
                              height: 0.5.h,
                            ),
                            if (_tempOrder != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ngày phục vụ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'NotoSans',
                                    ),
                                  ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      for (final day in _tempOrder['serveDates'])
                                        SizedBox(
                                          width: 40.w,
                                          child: Text(
                                            DateFormat('dd/MM')
                                                .format(DateTime.parse(day)),
                                            overflow: TextOverflow.clip,
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'NotoSans'),
                                          ),
                                        )
                                    ],
                                  )
                                ],
                              ),
                            if (_tempOrder != null)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                                child: const Divider(
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tổng cộng',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'NotoSans',
                                  ),
                                ),
                                const Spacer(),
                                if (_tempOrder != null)
                                  SizedBox(
                                    width: 50.w,
                                    child: Text(
                                      NumberFormat.simpleCurrency(
                                              locale: 'vi_VN',
                                              decimalDigits: 0,
                                              name: '')
                                          .format(_tempOrder['total']),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'NotoSans',
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                if (_surcharge != null)
                                  SizedBox(
                                    width: 40.w,
                                    child: Text(
                                      NumberFormat.simpleCurrency(
                                              locale: 'vi_VN',
                                              decimalDigits: 0,
                                              name: '')
                                          .format(_surcharge['alreadyDivided']
                                              ? _surcharge['gcoinAmount'] *
                                                  sharedPreferences.getInt(
                                                      'plan_number_of_member')!
                                              : _surcharge['gcoinAmount']),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'NotoSans',
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                SvgPicture.asset(
                                  gcoinLogo,
                                  height: 18,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                  style: elevatedButtonStyle.copyWith(
                                      maximumSize: MaterialStatePropertyAll(
                                          Size(50.w, 6.h)),
                                      minimumSize: MaterialStatePropertyAll(
                                          Size(50.w, 6.h))),
                                  onPressed: () {
                                    List<DateTime> dates = [];
                                    List<ItemCart> cart = [];
                                    for (final date
                                        in _tempOrder['serveDates']) {
                                      dates.add(DateTime.parse(date));
                                    }
                                    for (final detail in _tempOrder['details']) {
                                      cart.add(ItemCart(
                                          qty: detail['quantity'],
                                          product: ProductViewModel(
                                              id: detail['productId'],
                                              name: detail['productName'],
                                              price: detail['price'])));
                                    }

                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: ServiceMenuScreen(
                                              inputModel: OrderInputModel(
                                                  endDate: endDate,
                                                  startDate: startDate,
                                                  iniNote: _tempOrder['note'],
                                                  isOrder: false,
                                                  period: _tempOrder['period'],
                                                  servingDates: dates,
                                                  supplier: SupplierViewModel(
                                                      id: _tempOrder[
                                                          'providerId'],
                                                      name: _tempOrder[
                                                          'providerName'],
                                                      phone: _tempOrder[
                                                          'providerPhone'],
                                                      thumbnailUrl: _tempOrder[
                                                          'providerImageUrl'],
                                                      address: _tempOrder[
                                                          'providerAddress']),
                                                  orderGuid:
                                                      _tempOrder['orderUUID'],
                                                  numberOfMember:
                                                      numberOfMember,
                                                  session: sessions.firstWhere(
                                                      (element) =>
                                                          element.enumName ==
                                                          _tempOrder['period']),
                                                  serviceType: services
                                                      .firstWhere((element) =>
                                                          element.name ==
                                                          _tempOrder['type']),
                                                  callbackFunction: callback,
                                                  currentCart: cart,
                                                  availableGcoinAmount: 0),
                                            ),
                                            type: PageTransitionType
                                                .rightToLeft));
                                  },
                                  child: const Text(
                                    'Chỉnh sửa dự trù kinh phí',
                                    style: TextStyle(fontSize: 12),
                                  )),
                            )
                          ],
                        ))
                    : Row(
                        children: [
                          Expanded(
                              child: ElevatedButton.icon(
                                  style: elevatedButtonStyle.copyWith(
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.white),
                                      foregroundColor:
                                          const MaterialStatePropertyAll(
                                              primaryColor),
                                      shape: const MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              side: BorderSide(
                                                  color: primaryColor,
                                                  width: 1.5)))),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: CreatePlanSurcharge(
                                              callback: (dynamic surcharge) {
                                                setState(() {
                                                  _isOrderedActivity = true;
                                                  _surcharge = surcharge;
                                                });
                                              },
                                              isCreate: true,
                                            ),
                                            type: PageTransitionType
                                                .rightToLeft));
                                  },
                                  icon: const Icon(Icons.attach_money),
                                  label: const Text(
                                    'Phụ thu',
                                    style: TextStyle(fontSize: 12),
                                  ))),
                          SizedBox(
                            width: 2.w,
                          ),
                          Expanded(
                            child: ElevatedButton.icon(
                                onPressed: () {
                                  if (_isFoodActivity) {
                                    var temp = mealText.firstWhereOrNull(
                                        (element) => element.any((e) =>
                                            _shortDescriptionController.text
                                                .toLowerCase()
                                                .contains(e)));
                                    if (temp == null) {
                                      final startSession =
                                          getStartEndSession();
                                      navigateToServiceSessionScreen(
                                          startSession);
                                    } else {
                                      final startEndSessionIndex = sessions
                                          .indexOf(getStartEndSession());
                                      final mealTextIndex =
                                          mealText.indexOf(temp);
                                      if (_isFirstDay) {
                                        if (mealTextIndex <
                                            startEndSessionIndex) {
                                          handleInvalidActivityBasedOnStartTime(
                                              () {
                                            navigateToServiceSessionScreen(
                                                sessions[
                                                    startEndSessionIndex]);
                                          }, () {});
                                        } else if (mealTextIndex >=
                                            startEndSessionIndex) {
                                          navigateToServiceMainScreen(
                                              sessions[mealTextIndex]);
                                        }
                                      } else if (_isEndDay) {
                                        if (mealTextIndex >
                                            startEndSessionIndex) {
                                          handleInvalidActivityBasedOnEndTime(
                                              () {
                                            navigateToServiceSessionScreen(
                                                null);
                                          }, () {});
                                        } else {
                                          navigateToServiceMainScreen(
                                              sessions[mealTextIndex]);
                                        }
                                      } else {
                                        navigateToServiceMainScreen(
                                            sessions[mealTextIndex]);
                                      }
                                    }
                                  } else if (_isRoomActivity) {
                                    final startEndSessionIndex =
                                        sessions.indexOf(getStartEndSession());
                                    navigateToServiceMainScreen(
                                        sessions[startEndSessionIndex == 0 ? 1 : startEndSessionIndex]);
                                  } else {
                                    final startEndSessionIndex =
                                        sessions.indexOf(getStartEndSession());
                                    navigateToServiceMainScreen(
                                        sessions[startEndSessionIndex]);
                                  }
                                },
                                icon: Icon(_isFoodActivity
                                    ? Icons.restaurant
                                    : _isRoomActivity
                                        ? Icons.hotel
                                        : Icons.directions_car),
                                style: elevatedButtonStyle,
                                label: const Text(
                                  'Dự trù kinh phí',
                                  style: TextStyle(fontSize: 12),
                                )),
                          ),
                        ],
                      ),
              SizedBox(
                height: 50.h,
              )
            ],
          ),
        ),
      ),
    ));
  }

  callback(dynamic tempOrder) {
    setState(() {
      _isOrderedActivity = true;
    });
    _isModify = true;
    _tempOrder = tempOrder;
  }

  saveTempOrder() {
    var tempOrderText = sharedPreferences.getString('plan_temp_order');
    if (tempOrderText == null) {
      final tempEncode = json.encode([_tempOrder]);
      sharedPreferences.setString('plan_temp_order', tempEncode);
    } else {
      final tempOrderDecode = json.decode(tempOrderText);
      final temp = tempOrderDecode
          .where((e) => e['orderUUID'] == _tempOrder['orderUUID'])
          .toList();
      if (temp == null || temp.isEmpty) {
        tempOrderDecode.add(_tempOrder);
      } else {
        tempOrderDecode.remove(temp.first);
        tempOrderDecode.add(_tempOrder);
      }
      sharedPreferences.setString('plan_temp_order', json.encode(tempOrderDecode));
    }
  }

  navigateToServiceMainScreen(Session? initSession) {
    Navigator.push(
        context,
        PageTransition(
            child: ServiceMainScreen(
              isOrder: false,
              serviceType: _isFoodActivity
                  ? services[0]
                  : _isRoomActivity
                      ? services[1]
                      : services[2],
              location: widget.location,
              initSession: initSession,
              numberOfMember: numberOfMember!,
              startDate: _selectedDate,
              endDate: endDate!,
              callbackFunction: callback,
            ),
            type: PageTransitionType.rightToLeft));
  }

  navigateToServiceSessionScreen(Session? startSession) {
    Navigator.push(
        context,
        PageTransition(
            child: SelectSessionScreen(
                serviceType: services[0],
                isOrder: false,
                location: widget.location,
                numberOfMember: numberOfMember!,
                isEndAtNoon: _isEndAtNoon,
                initSession: startSession,
                startDate: _selectedDate,
                endDate: endDate!,
                callbackFunction: callback),
            type: PageTransitionType.rightToLeft));
  }

  handleInvalidActivityBasedOnStartTime(
      void Function() onOk, void Function() onCancel) {
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            dialogType: DialogType.warning,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            title:
                'Mô tả hoạt động không phù hợp với thời gian đến nơi của chuyến đi',
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSans',
            ),
            desc: 'Vẫn giữ mô tả này?',
            descTextStyle: const TextStyle(fontSize: 16, color: Colors.grey),
            btnOkColor: Colors.amber,
            btnOkText: 'Có',
            btnOkOnPress: onOk,
            btnCancelColor: Colors.blueAccent,
            btnCancelOnPress: onCancel,
            btnCancelText: 'Không')
        .show();
  }

  handleInvalidActivityBasedOnEndTime(
      void Function() onOk, void Function() onCancel) {
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            dialogType: DialogType.warning,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            title:
                'Mô tả hoạt động không phù hợp với thời gian kết thúc của chuyến đi',
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSans',
            ),
            desc: 'Vẫn giữ mô tả này?',
            descTextStyle: const TextStyle(fontSize: 16, color: Colors.grey),
            btnOkColor: Colors.amber,
            btnOkText: 'Có',
            btnOkOnPress: onOk,
            btnCancelColor: Colors.blueAccent,
            btnCancelOnPress: onCancel,
            btnCancelText: 'Không')
        .show();
  }

  getStartEndSession() {
    if (_isFirstDay) {
      startSession = sessions.firstWhereOrNull((element) =>
          element.from <= _startActivityTime!.hour &&
          element.to > _startActivityTime!.hour);
      return startSession ?? sessions[0];
    } else if (_isEndDay) {
      if (_isFoodActivity) {
        _isEndAtNoon = Utils().isEndAtNoon(widget.plan);
        if (_isEndAtNoon!) {
          return sessions[1];
        } else {
          return sessions[3];
        }
      } else {
        return sessions[0];
      }
    } else {
      return sessions.firstWhereOrNull((element) =>
              element.from <= _startActivityTime!.hour &&
              element.to > _startActivityTime!.hour) ??
          sessions[0];
    }
  }

  getStartActivityTime() {
    if (_isFirstDay) {
      final initialDateTime =
          DateTime.parse(sharedPreferences.getString('plan_start_time')!);
      final startTime =
          DateTime(0, 0, 0, initialDateTime.hour, initialDateTime.minute);
      arrivedTime = startTime.add(Duration(
          minutes: (sharedPreferences.getDouble('plan_duration_value')! * 60)
              .floor()));
      if (arrivedTime!.hour >= 20) {
        arrivedTime = DateTime(0, 0, 0, 6, 0, 0);
      }
      return arrivedTime!.add(widget.startActivityTime);
    } else {
      return DateTime(0, 0, 0, 6, 0, 0).add(widget.startActivityTime);
    }
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('tempOrder', _tempOrder));
  }
}
