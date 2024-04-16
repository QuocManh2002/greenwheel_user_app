import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:greenwheel_user_app/core/constants/meal_text.dart';
import 'package:greenwheel_user_app/core/constants/service_types.dart';
import 'package:greenwheel_user_app/core/constants/sessions.dart';
import 'package:greenwheel_user_app/core/constants/shedule_item_type.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/create_plan_surcharge.dart';
import 'package:greenwheel_user_app/screens/sub_screen/select_session_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class NewScheduleItemScreen extends StatefulWidget {
  const NewScheduleItemScreen(
      {super.key,
      required this.callback,
      required this.startDate,
      required this.selectedIndex,
      required this.maxActivityTime,
      required this.location,
      this.plan,
      this.item});
  final void Function(
      PlanScheduleItem item, bool isCreate, PlanScheduleItem? oldItem) callback;
  final DateTime startDate;
  final PlanScheduleItem? item;
  final int selectedIndex;
  final int maxActivityTime;
  final LocationViewModel location;
  final PlanCreate? plan;

  @override
  State<NewScheduleItemScreen> createState() => _NewScheduleItemScreenState();
}

class _NewScheduleItemScreenState extends State<NewScheduleItemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _activityTimeController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  DateTime _selectedDate = DateTime.now();
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

  int? numberOfMember;
  DateTime? startDate;
  DateTime? endDate;

  dynamic tempOrder;
  dynamic surcharge;
  Session? startSession;

  @override
  void initState() {
    // TODO: implement initState
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

    if (widget.selectedIndex == 0) {
      startSession = sessions.firstWhereOrNull((element) =>
          element.from <= widget.plan!.arrivedAt!.hour &&
          element.to > widget.plan!.arrivedAt!.hour);
    } else if (widget.selectedIndex >=
        (widget.plan!.numOfExpPeriod! / 2).ceil() - 1) {
      _isEndAtNoon = Utils().isEndAtNoon(widget.plan);
    }
    setUpData();
  }

  onChangeQuantity(String type) {
    setState(() {
      _isModify = true;
    });
    if (type == "add") {
      setState(() {
        _activityTimeController.text =
            (int.parse(_activityTimeController.text) + 1).toString();
      });
    } else {
      setState(() {
        _activityTimeController.text =
            (int.parse(_activityTimeController.text) - 1).toString();
      });
    }
  }

  setUpDataCreate() {
    numberOfMember = sharedPreferences.getInt('plan_number_of_member')!;
    startDate = DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    endDate = DateTime.parse(sharedPreferences.getString('plan_end_date')!);
    if (widget.selectedIndex == 0) {
      final arrivedTime = Utils().getArrivedTimeFromLocal();
      startSession = sessions.firstWhereOrNull((element) =>
          element.from <= arrivedTime.hour && element.to > arrivedTime.hour);
    }
    setUpData();
  }

  setUpData() {
    _isFirstDay = widget.selectedIndex == 0;
    _isEndDay = widget.selectedIndex >=
        (sharedPreferences.getInt('numOfExpPeriod')! / 2).ceil() - 1;
    if (widget.item != null) {
      _selectedDate = widget.item!.date!;
      _descriptionController.text = widget.item!.description!;
      _selectedType = widget.item!.type;
      _shortDescriptionController.text = widget.item!.shortDescription!;
      _activityTimeController.text = widget.item!.activityTime!.toString();
      _isStarEvent = widget.item!.isStarred!;
      tempOrder = widget.item!.tempOrder;
    } else {
      setState(() {
        _selectedDate =
            widget.startDate.add(Duration(days: widget.selectedIndex));
        _activityTimeController.text = '1';
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
          if (widget.item != null) {
            Navigator.of(ctx).pop();
          }
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
              onPressed: () async {
                if (_isModify) {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedType == null) {
                      await AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        body: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Hãy chọn dạng hoạt động',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        btnOkColor: Colors.orange,
                        btnOkText: 'Ok',
                        btnOkOnPress: () {},
                      ).show();
                    } else if (_activityTimeController.text.trim() == '' ||
                        int.tryParse(_activityTimeController.text) == null) {
                      Fluttertoast.showToast(
                          msg: "Thời gian hoạt động không hợp lệ",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 18.0);
                    } else if (int.tryParse(_activityTimeController.text)! <
                            0 ||
                        int.tryParse(_activityTimeController.text)! >
                            widget.maxActivityTime) {
                      Fluttertoast.showToast(
                          msg: "Thời gian hoạt động không hợp lệ",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 18.0);
                    } else {
                      if (tempOrder != null) {
                        saveTempOrder();
                        DateTime? endDate;
                        if (widget.plan == null) {
                          endDate = DateTime.parse(
                              sharedPreferences.getString('plan_end_date')!);
                        } else {
                          endDate = widget.plan!.endDate;
                        }
                        if (_selectedType == 'Check-in') {
                          widget.callback(
                              PlanScheduleItem(
                                  isStarred: _isStarEvent,
                                  shortDescription:
                                      _shortDescriptionController.text,
                                  description: _descriptionController.text,
                                  date: DateTime.parse(
                                      tempOrder['serveDates'].first.toString()),
                                  tempOrder: tempOrder,
                                  activityTime:
                                      int.parse(_activityTimeController.text),
                                  type: _selectedType,
                                  id: widget.item?.id),
                              widget.item == null,
                              widget.item);
                          widget.callback(
                              PlanScheduleItem(
                                  isStarred: _isStarEvent,
                                  shortDescription: 'Check-out',
                                  description: 'Check-out nhà nghỉ/khách sạn',
                                  date: DateTime.parse(
                                              tempOrder['serveDates'].last) ==
                                          endDate
                                      ? DateTime.parse(tempOrder['serveDates']
                                          .last
                                          .toString())
                                      : DateTime.parse(tempOrder['serveDates']
                                              .last
                                              .toString())
                                          .add(const Duration(days: 1)),
                                  tempOrder: tempOrder,
                                  activityTime:
                                      int.parse(_activityTimeController.text),
                                  type: 'Check-out',
                                  id: widget.item?.id),
                              widget.item == null,
                              widget.item);
                        } else {
                          for (final day in tempOrder['serveDates']) {
                            widget.callback(
                                PlanScheduleItem(
                                    isStarred: _isStarEvent,
                                    shortDescription:
                                        _shortDescriptionController.text,
                                    description: _descriptionController.text,
                                    date: DateTime.parse(day.toString()),
                                    tempOrder: tempOrder,
                                    activityTime:
                                        int.parse(_activityTimeController.text),
                                    type: _selectedType,
                                    id: widget.item?.id),
                                widget.item == null,
                                widget.item);
                          }
                        }
                      } else {
                        widget.callback(
                            PlanScheduleItem(
                                isStarred: _isStarEvent,
                                shortDescription:
                                    _shortDescriptionController.text,
                                description: _descriptionController.text,
                                date: _selectedDate,
                                tempOrder: tempOrder,
                                activityTime:
                                    int.parse(_activityTimeController.text),
                                type: _selectedType,
                                id: widget.item?.id),
                            widget.item == null,
                            widget.item);
                      }
                      Navigator.of(context).pop();
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
    var startTime = sharedPreferences.getString('plan_start_time');
    final startDateTime = DateFormat.Hm().parse(startTime!);
    final _startDateTime =
        DateTime(0, 0, 0, startDateTime.hour, startDateTime.minute, 0);
    final _startActivityDateTime = DateTime(0, 0, 0, time.hour, time.minute);
    return _startActivityDateTime.isAfter(_startDateTime);
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
                              width: 40.w,
                              child: RichText(
                                  text: TextSpan(
                                      text: 'Thời gian hoạt động',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                      children: [
                                    TextSpan(
                                        text: ' (giờ)',
                                        style: TextStyle(
                                            fontSize: 17,
                                            color:
                                                Colors.grey.withOpacity(0.8)))
                                  ])),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 40.w,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                          color: primaryColor,
                                          iconSize: 24,
                                          onPressed: () {
                                            if (int.parse(
                                                    _activityTimeController
                                                        .text) >
                                                1) {
                                              onChangeQuantity("subtract");
                                            }
                                          },
                                          icon: const Icon(Icons.remove)),
                                      SizedBox(
                                          width: 7.h,
                                          height: 5.h,
                                          child: defaultTextFormField(
                                              onValidate: (value) {
                                                if (value == null ||
                                                    value.isEmpty ||
                                                    int.parse(value) <= 0) {
                                                  return "Thời gian hoạt động không hợp lệ";
                                                }
                                                return null;
                                              },
                                              onChange: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Thời gian hoạt động không được để trống",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          Colors.white,
                                                      textColor: Colors.black,
                                                      fontSize: 18.0);
                                                } else {
                                                  var selectedNumber =
                                                      int.tryParse(
                                                          _activityTimeController
                                                              .text);
                                                  if (selectedNumber == null) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Thời gian hoạt động không hợp lệ",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.white,
                                                        textColor: Colors.black,
                                                        fontSize: 18.0);
                                                  } else {
                                                    if (selectedNumber < 0) {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Thời gian hoạt động không hợp lệ",
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor:
                                                              Colors.white,
                                                          textColor:
                                                              Colors.black,
                                                          fontSize: 18.0);
                                                    } else {}
                                                  }
                                                }
                                              },
                                              borderSize: 2,
                                              textAlign: TextAlign.center,
                                              controller:
                                                  _activityTimeController,
                                              inputType: TextInputType.number)),
                                      IconButton(
                                          color: primaryColor,
                                          iconSize: 24,
                                          onPressed: () {
                                            if (int.parse(
                                                    _activityTimeController
                                                        .text) ==
                                                widget.maxActivityTime) {
                                              Utils()
                                                  .ShowFullyActivityTimeDialog(
                                                      context);
                                            } else {
                                              onChangeQuantity("add");
                                            }
                                          },
                                          icon: const Icon(Icons.add)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 1.h,
                                  ),
                                ],
                              ),
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
                        alignment: Alignment.center,
                        height: 7.8.h,
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(14))),
                        child: DropdownButton<String>(
                          hint: const Text(
                            'Dạng hoạt động',
                            style: TextStyle(fontSize: 18),
                          ),
                          disabledHint: Text('aaa'),
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
                            setState(() {
                              _selectedType = value;
                              _isModify = true;
                            });
                            setState(() {
                              _isFoodActivity = value == 'Ăn uống';
                              _isRoomActivity = value == 'Check-in';
                              _isVisitActivity = value == 'Tham quan';
                            });
                          },
                          items: schedule_item_types_vn
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
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
                            setState(() {
                              _isModify = true;
                            });
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
                              'Chi tiết ${tempOrder != null ? 'dự trù kinh phí' : 'phụ thu'}',
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
                            if (tempOrder != null)
                              for (final detail in tempOrder['details'])
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
                            if (surcharge != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    json.decode(surcharge['note']),
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
                                                name: 'Đ')
                                            .format(surcharge['amount']),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NotoSans'),
                                      ),
                                      if (surcharge['alreadyDivided'])
                                        const Text(
                                          ' /',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'NotoSans'),
                                        ),
                                      if (surcharge['alreadyDivided'])
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
                            if (tempOrder != null &&
                                _selectedType == 'Check-in')
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
                                      for (final day in tempOrder['serveDates'])
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
                            if (tempOrder != null &&
                                _selectedType == 'Check-in')
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
                                if (tempOrder != null)
                                  SizedBox(
                                    width: 50.w,
                                    child: Text(
                                      NumberFormat.simpleCurrency(
                                              locale: 'vi_VN',
                                              decimalDigits: 0,
                                              name: 'Đ')
                                          .format( tempOrder['total']),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'NotoSans',
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                if (surcharge != null) const Spacer(),
                                if (surcharge != null)
                                  SizedBox(
                                    width: 40.w,
                                    child: Text(
                                      NumberFormat.simpleCurrency(
                                              locale: 'vi_VN',
                                              decimalDigits: 0,
                                              name: 'Đ')
                                          .format(surcharge['alreadyDivided']
                                              ? surcharge['amount'] *
                                                  sharedPreferences.getInt(
                                                      'plan_number_of_member')!
                                              : surcharge['amount']),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'NotoSans',
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                              ],
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
                                              callback: (dynamic _surcharge) {
                                                setState(() {
                                                  _isOrderedActivity = true;
                                                  surcharge = _surcharge;
                                                });
                                              },
                                              isCreate: true,
                                            ),
                                            type: PageTransitionType
                                                .rightToLeft));
                                  },
                                  icon: const Icon(Icons.attach_money),
                                  label: const Text('Phụ thu'))),
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
                                      final _startSession =
                                          getStartEndSession();
                                      navigateToServiceSessionScreen(
                                          _startSession);
                                    } else {
                                      final _startEndSessionIndex = sessions
                                          .indexOf(getStartEndSession());
                                      final mealTextIndex =
                                          mealText.indexOf(temp);
                                      if (_isFirstDay) {
                                        if (mealTextIndex <
                                            _startEndSessionIndex) {
                                          handleInvalidActivityBasedOnStartTime(
                                              () {
                                            navigateToServiceSessionScreen(
                                                sessions[
                                                    _startEndSessionIndex]);
                                          }, () {});
                                        } else if (mealTextIndex >=
                                            _startEndSessionIndex) {
                                          navigateToServiceMainScreen(
                                              sessions[mealTextIndex]);
                                        }
                                      } else if (_isEndDay) {
                                        if (mealTextIndex >
                                            _startEndSessionIndex) {
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
                                    final _startEndSessionIndex =
                                        sessions.indexOf(getStartEndSession());
                                    // if (_isFirstDay &&
                                    //     _startEndSessionIndex > 1) {
                                    //   handleInvalidActivityBasedOnStartTime(
                                    //       () {}, () {});
                                    // } else {
                                    navigateToServiceMainScreen(
                                        sessions[_startEndSessionIndex]);
                                    // }
                                  } else {
                                    final _startEndSessionIndex =
                                        sessions.indexOf(getStartEndSession());
                                    navigateToServiceMainScreen(
                                        sessions[_startEndSessionIndex]);
                                  }
                                },
                                icon: Icon(_isFoodActivity
                                    ? Icons.restaurant
                                    : _isRoomActivity
                                        ? Icons.hotel
                                        : Icons.directions_car),
                                style: elevatedButtonStyle,
                                label: const Text('Dự trù kinh phí')),
                          ),
                        ],
                      )
            ],
          ),
        ),
      ),
    ));
  }

  callback(dynamic _tempOrder) {
    setState(() {
      _isOrderedActivity = true;
    });
    tempOrder = _tempOrder;
  }

  saveTempOrder() {
    var temp = sharedPreferences.getString('plan_temp_order');
    if (temp == null) {
      final tempEncode = json.encode([tempOrder]);
      sharedPreferences.setString('plan_temp_order', tempEncode);
    } else {
      final tempDecode = json.decode(temp);
      tempDecode.add(tempOrder);
      sharedPreferences.setString('plan_temp_order', json.encode(tempDecode));
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

  navigateToServiceSessionScreen(Session? _startSession) {
    Navigator.push(
        context,
        PageTransition(
            child: SelectSessionScreen(
                serviceType: services[0],
                isOrder: false,
                location: widget.location,
                numberOfMember: numberOfMember!,
                isEndAtNoon: _isEndAtNoon,
                initSession: _startSession,
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
      final initialDateTime =
          DateTime.parse(sharedPreferences.getString('plan_start_time')!);
      final startTime =
          DateTime(0, 0, 0, initialDateTime.hour, initialDateTime.minute);
      final arrivedTime = startTime.add(Duration(
          seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
              .ceil()));
      startSession = sessions.firstWhereOrNull((element) =>
          element.from <= arrivedTime.hour && element.to > arrivedTime.hour);
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
      return sessions[0];
    }
  }
}
