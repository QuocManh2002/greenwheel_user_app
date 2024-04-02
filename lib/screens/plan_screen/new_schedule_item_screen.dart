import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/service_types.dart';
import 'package:greenwheel_user_app/core/constants/shedule_item_type.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class NewScheduleItemScreen extends StatefulWidget {
  const NewScheduleItemScreen(
      {super.key,
      required this.callback,
      required this.startDate,
      required this.selectedIndex,
      required this.isNotOverDay,
      required this.maxActivityTime,
      required this.location,
      this.item});
  final void Function(
      PlanScheduleItem item, bool isCreate, PlanScheduleItem? oldItem) callback;
  final DateTime startDate;
  final PlanScheduleItem? item;
  final int selectedIndex;
  final bool isNotOverDay;
  final int maxActivityTime;
  final LocationViewModel location;

  @override
  State<NewScheduleItemScreen> createState() => _NewScheduleItemScreenState();
}

class _NewScheduleItemScreenState extends State<NewScheduleItemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _activityTimeController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedType;
  bool _isModify = false;
  TimeOfDay _startTime = TimeOfDay(hour: 12, minute: 0);
  bool _isFoodActivity = false;
  bool _isRoomActivity = false;
  bool _isOrderedActivity = false;
  bool _isStarEvent = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    setState(() {
      DateTime temp = DateTime(0, 0, 0, 12, 0)
          .add(Duration(hours: int.parse(_activityTimeController.text)));
      _startTime = TimeOfDay(hour: temp.hour, minute: temp.minute);
    });
  }

  setUpData() {
    if (widget.item != null) {
      _selectedDate = widget.item!.date!;
      _descriptionController.text = widget.item!.description!;
      _selectedType = widget.item!.type;
      _shortDescriptionController.text = widget.item!.shortDescription!;
      _activityTimeController.text = widget.item!.activityTime!.toString();
      setState(() {
        _dateController.text =
            DateFormat.yMMMMEEEEd('vi_VN').format(widget.item!.date!);
      });
    } else {
      setState(() {
        _dateController.text = DateFormat.yMMMMEEEEd('vi_VN')
            .format(widget.startDate.add(Duration(days: widget.selectedIndex)));
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
                    if (widget.item == null) {
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
                        widget.callback(
                            PlanScheduleItem(
                                isStarred: _isStarEvent,
                                shortDescription:
                                    _shortDescriptionController.text,
                                description: _descriptionController.text,
                                date: _selectedDate,
                                activityTime:
                                    int.parse(_activityTimeController.text),
                                type: _selectedType),
                            true,
                            null);
                        Navigator.of(context).pop();
                      }
                    } else {
                      widget.callback(
                          PlanScheduleItem(
                              activityTime:
                                  int.parse(_activityTimeController.text),
                              shortDescription:
                                  _shortDescriptionController.text,
                              type: _selectedType,
                              description: _descriptionController.text,
                              date: _selectedDate,
                              id: widget.item!.id),
                          false,
                          widget.item);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item != null ? 'Chỉnh sửa hoạt động' : 'Thêm hoạt động',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                                          color: Colors.grey.withOpacity(0.8)))
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
                                          if (int.parse(_activityTimeController
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
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.white,
                                                        textColor: Colors.black,
                                                        fontSize: 18.0);
                                                  } else {}
                                                }
                                              }
                                            },
                                            borderSize: 2,
                                            textAlign: TextAlign.center,
                                            controller: _activityTimeController,
                                            inputType: TextInputType.number)),
                                    IconButton(
                                        color: primaryColor,
                                        iconSize: 24,
                                        onPressed: () {
                                          if (int.parse(_activityTimeController
                                                  .text) ==
                                              widget.maxActivityTime) {
                                            Utils().ShowFullyActivityTimeDialog(
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
                    SizedBox(height: 2.h,),
                    Row(
                      children: [
                        IconButton(onPressed: (){
                          setState(() {
                            _isStarEvent = !_isStarEvent;
                          });
                        }, icon:
                          _isStarEvent?
                         const Icon(Icons.star, size: 25, color: Colors.amber,):
                         const Icon(Icons.star_border_outlined, size: 25, color: Colors.grey,)),
                         const Text('Hoạt động đặc biệt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSans'),)
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
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                        value: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                            _isModify = true;
                          });
                          if (value == 'Ăn uống') {
                            setState(() {
                              _isFoodActivity = true;
                              _isRoomActivity = false;
                            });
                          } else if (value == 'Check-in') {
                            setState(() {
                              _isRoomActivity = true;
                              _isFoodActivity = false;
                            });
                          } else {
                            setState(() {
                              _isFoodActivity = false;
                              _isRoomActivity = false;
                            });
                          }
                        },
                        items: schedule_item_types_vn
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
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
                        maxLength: 40,
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
                          }
                        },
                        hinttext: 'Câu cá, tắm suối...'),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormFieldWithLength(
                        controller: _descriptionController,
                        inputType: TextInputType.text,
                        maxLength: 300,
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
                          }
                        },
                        hinttext: 'Câu cá ở sông Đà...'),
                  ],
                )),
            SizedBox(
              height: 2.h,
            ),
            if (_isFoodActivity || _isRoomActivity)
              _isOrderedActivity
                  ? Row(
                      children: [
                        const Spacer(),
                        Container(
                          alignment: Alignment.topRight,
                          width: 50.w,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: primaryColor, width: 1.5),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(14))),
                          child: const Text(
                            'Đã dự trù kinh phí',
                            style: TextStyle(
                                fontSize: 17,
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      alignment: Alignment.topRight,
                      child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => ServiceMainScreen(
                                      isOrder: false,
                                      serviceType: _isFoodActivity
                                          ? services[0]
                                          : services[4],
                                      location: widget.location,
                                      numberOfMember: sharedPreferences
                                          .getInt('plan_number_of_member')!,
                                      startDate: DateTime.parse(
                                          sharedPreferences
                                              .getString('plan_start_date')!),
                                      endDate: DateTime.parse(sharedPreferences
                                          .getString('plan_end_date')!),
                                      callbackFunction: callback,
                                    )));
                          },
                          icon: Icon(
                              _isFoodActivity ? Icons.restaurant : Icons.hotel),
                          style: elevatedButtonStyle.copyWith(
                              minimumSize:
                                  MaterialStatePropertyAll(Size(50.w, 5.h))),
                          label: const Text('Dự trù kinh phí')),
                    )
          ],
        ),
      ),
    ));
  }

  callback() {
    setState(() {
      _isOrderedActivity = true;
    });
  }
}
