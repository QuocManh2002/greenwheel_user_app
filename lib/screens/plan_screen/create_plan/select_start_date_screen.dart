import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/urls.dart';
import '../../../helpers/util.dart';
import '../../../main.dart';
import '../../../service/plan_service.dart';
import '../../../view_models/location.dart';
import '../../../view_models/plan_viewmodels/plan_create.dart';
import '../../../widgets/plan_screen_widget/craete_plan_header.dart';
import '../../../widgets/style_widget/button_style.dart';
import '../../../widgets/style_widget/dialog_style.dart';
import '../../../widgets/style_widget/text_form_field_widget.dart';
import 'select_combo_date_screen.dart';

class SelectStartDateScreen extends StatefulWidget {
  const SelectStartDateScreen(
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
  State<SelectStartDateScreen> createState() => _SelectStartDateState();
}

class _SelectStartDateState extends State<SelectStartDateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool? _isCloneName;
  bool? _isCloneTime;
  bool isAvailableToOrder = false;

  TimeOfDay _selectTime =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));

  DateTime? _selectedDate = DateTime.now();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final PlanService _planService = PlanService();

  @override
  void initState() {
    super.initState();
    if (widget.isCreate) {
      setUpDataCreate();
    } else {
      setUpDataUpdate();
    }
  }

  setUpDataUpdate() {
    _nameController.text = widget.plan!.name!;
    _timeController.text =
        DateFormat.Hm().format(widget.plan!.departAt!.toLocal());
    _dateController.text =
        DateFormat('dd/MM/yyyy').format(widget.plan!.departAt!.toLocal());
  }

  setUpDataCreate() {
    if (widget.isClone) {
      final cloneOptions =
          json.decode(sharedPreferences.getString('plan_clone_options')!);
      _isCloneName = cloneOptions[1];
      _isCloneTime = cloneOptions[2];
    }
    final name = sharedPreferences.getString('plan_name');
    if (name != null) {
      _nameController.text = name;
    }
    final departDateText = sharedPreferences.getString('plan_departureDate');
    final departTimeText = sharedPreferences.getString('plan_departureTime');
    if (departTimeText != null) {
      final departTime = DateTime.parse(departTimeText);
      _selectTime = TimeOfDay.fromDateTime(departTime);
      _timeController.text = DateFormat.Hm().format(departTime);
    } else {
      _timeController.text =
          DateFormat.Hm().format(DateTime.now().add(const Duration(hours: 1)));

      final startTime =
          DateTime(0, 0, 0, DateTime.now().hour + 1, DateTime.now().minute);
      sharedPreferences.setString('plan_departureTime', startTime.toString());
    }
    if (departDateText != null) {
      final departDate = DateTime.parse(departDateText);
      _selectedDate = departDate;
      _dateController.text = DateFormat('dd/MM/yyyy').format(departDate);
    } else {
      var initDate = DateTime.now().add(const Duration(days: 7));
      if (DateTime(0, 0, 0, _selectTime.hour, _selectTime.minute).isBefore(
          DateTime(0, 0, 0, DateTime.now().hour, DateTime.now().minute))) {
        initDate = initDate.add(const Duration(days: 1));
      }
      _selectedDate = initDate;
      _dateController.text = DateFormat('dd/MM/yyyy').format(initDate);
      sharedPreferences.setString('plan_departureDate', initDate.toString());
      sharedPreferences.setString(
          'plan_start_date', initDate.toString().split(' ')[0]);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _timeController.dispose();
    _dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Lên kế hoạch'),
        leading: BackButton(
          onPressed: () {
            _planService.handleQuitCreatePlanScreen(() {
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
        padding: EdgeInsets.only(left: 2.w, bottom: 3.h, right: 2.w),
        child: Column(
          children: [
            const CreatePlanHeader(
                stepNumber: 2, stepName: 'Tên & thời gian xuất phát'),
            const Text(
              'Hãy đặt tên cho chuyến đi của bạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 2.h,
            ),
            Form(
              key: formKey,
              child: defaultTextFormField(
                autofocus: true,
                padding: const EdgeInsets.only(left: 12),
                controller: _nameController,
                inputType: TextInputType.name,
                readonly: widget.isClone && _isCloneName!,
                maxLength: 30,
                onChange: (value) {
                  if (widget.plan == null) {
                    sharedPreferences.setString('plan_name', value!);
                  } else {
                    widget.plan!.name = value;
                  }
                },
                onValidate: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tên của chuyến đi không được để trống";
                  } else if (value.length < 3 || value.length > 30) {
                    return "Tên của chuyến đi phải có độ dài từ 3 - 30 kí tự";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            const Text(
              'Thời gian xuất phát',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 1.h,
            ),
            Row(
              children: [
                Expanded(
                  child: defaultTextFormField(
                    readonly: true,
                    controller: _dateController,
                    inputType: TextInputType.datetime,
                    text: 'Ngày',
                    onTap: () async {
                      DateTime? newDay = await showDatePicker(
                          context: context,
                          locale: const Locale('vi', 'VN'),
                          initialDate: DateFormat('dd/MM/yyyy')
                              .parse(_dateController.text),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 30)),
                          cancelText: 'HỦY',
                          confirmText: 'CHỌN',
                          builder: (
                            context,
                            child,
                          ) {
                            return Theme(
                                data: ThemeData().copyWith(
                                    colorScheme: const ColorScheme.light(
                                        primary: primaryColor,
                                        onPrimary: Colors.white)),
                                child: child!);
                          });
                      if (newDay != null) {
                        if (DateTime(newDay.year, newDay.month, newDay.day,
                                _selectTime.hour, _selectTime.minute)
                            .isBefore(
                                DateTime.now().add(const Duration(days: 7)))) {
                          isAvailableToOrder = false;
                          DateTime availableTime =
                              DateTime.now().add(const Duration(days: 7));
                          DialogStyle().basicDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              title: 'Cảnh báo',
                              desc:
                                  'Với thời gian khởi hành trước ${DateFormat.Hm().format(availableTime)} ${DateFormat('dd/MM/yyyy').format(availableTime)}, kế hoạch sẽ được lưu dưới dạng bản nháp và không thể ước chừng chi phí dịch vụ',
                              type: DialogType.warning);
                        } else {
                          isAvailableToOrder = true;
                        }
                        _dateController.text =
                            DateFormat('dd/MM/yyyy').format(newDay);
                        if (widget.isCreate) {
                          _selectedDate = newDay;
                          sharedPreferences.setString(
                              'plan_start_date', newDay.toString());
                          sharedPreferences.setString(
                              'plan_departureDate', newDay.toString());
                        } else {
                          final startTime =
                              DateFormat.Hm().parse(_timeController.text);
                          widget.plan!.departAt = newDay
                              .add(Duration(hours: startTime.hour))
                              .add(Duration(minutes: startTime.minute));
                        }
                      }
                    },
                    prefixIcon: const Icon(Icons.calendar_month),
                  ),
                ),
                SizedBox(
                  width: 3.w,
                ),
                Expanded(
                  child: defaultTextFormField(
                      readonly: true,
                      controller: _timeController,
                      inputType: TextInputType.datetime,
                      text: 'Giờ',
                      onTap: widget.isClone && _isCloneTime!
                          ? null
                          : () async {
                              Duration newTime = Duration(
                                  hours: _selectTime.hour,
                                  minutes: _selectTime.minute);
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        content: SizedBox(
                                            width: 100.w,
                                            height: 25.h,
                                            child: CupertinoTimerPicker(
                                              mode: CupertinoTimerPickerMode.hm,
                                              initialTimerDuration: Duration(
                                                  hours: _selectTime.hour,
                                                  minutes: _selectTime.minute),
                                              onTimerDurationChanged: (value) {
                                                newTime = value;
                                              },
                                            )),
                                        actions: [
                                          TextButton(
                                              style: const ButtonStyle(
                                                  foregroundColor:
                                                      MaterialStatePropertyAll(
                                                          primaryColor)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('HUỶ')),
                                          TextButton(
                                              style: const ButtonStyle(
                                                  foregroundColor:
                                                      MaterialStatePropertyAll(
                                                          primaryColor)),
                                              onPressed: () {
                                                if (DateTime(
                                                        _selectedDate!.year,
                                                        _selectedDate!.month,
                                                        _selectedDate!.day,
                                                        newTime.inHours,
                                                        newTime.inMinutes
                                                            .remainder(60))
                                                    .isBefore(DateTime.now()
                                                        .add(const Duration(
                                                            days: 7)))) {
                                                  isAvailableToOrder = false;
                                                  DateTime availableTime =
                                                      DateTime.now().add(
                                                          const Duration(
                                                              days: 7));
                                                  DialogStyle().basicDialog(
                                                      // ignore: use_build_context_synchronously
                                                      context: context,
                                                      title: 'Cảnh báo',
                                                      desc:
                                                          'Với thời gian khởi hành trước ${DateFormat.Hm().format(availableTime)} ${DateFormat('dd/MM/yyyy').format(availableTime)}, kế hoạch sẽ được lưu dưới dạng bản nháp và không thể ước chừng chi phí dịch vụ',
                                                      type: DialogType.warning);
                                                } else {
                                                  isAvailableToOrder = true;
                                                }

                                                _timeController.text =
                                                    DateFormat.Hm().format(
                                                        DateTime(
                                                            0,
                                                            0,
                                                            0,
                                                            newTime.inHours,
                                                            newTime.inMinutes
                                                                .remainder(
                                                                    60)));
                                                if (widget.isCreate) {
                                                  sharedPreferences.setString(
                                                      'plan_departureTime',
                                                      DateTime(
                                                              0,
                                                              0,
                                                              0,
                                                              newTime.inHours,
                                                              newTime.inMinutes
                                                                  .remainder(
                                                                      60))
                                                          .toString());
                                                } else {
                                                  setState(() {
                                                    final departTime =
                                                        DateFormat.Hm().parse(
                                                            _timeController
                                                                .text);
                                                    final departDate =
                                                        DateFormat('dd/MM/yyyy')
                                                            .parse(
                                                                _dateController
                                                                    .text);
                                                    widget.plan!.departAt =
                                                        DateTime(
                                                            departDate.year,
                                                            departDate.month,
                                                            departDate.day,
                                                            departTime.hour,
                                                            departTime.minute);
                                                  });
                                                }
                                                setState(() {
                                                  _selectTime = TimeOfDay(
                                                      hour: newTime.inHours,
                                                      minute: newTime.inMinutes
                                                          .remainder(60));
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('CHỌN')),
                                        ],
                                      ));
                            },
                      prefixIcon: const Icon(Icons.watch_later_outlined)),
                ),
              ],
            ),
          ],
        ),
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
              style: outlinedButtonStyle,
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectTime.hour,
                          _selectTime.minute)
                      .isBefore(DateTime.now().add(const Duration(days: 7)))) {
                    var schedule = json.decode(
                        sharedPreferences.getString('plan_schedule') ?? '[]');
                    for (final day in schedule) {
                      for (final item in day) {
                        if (item['orderUUID'] != null) {
                          item['orderUUID'] = null;
                        }
                      }
                    }
                    sharedPreferences.remove('plan_temp_order');
                    sharedPreferences.setString(
                        'plan_schedule', json.encode(schedule));
                  }
                  if (widget.isClone) {
                    Utils().updateTempOrder(false, null);
                  }
                  Navigator.push(
                      context,
                      PageTransition(
                          child: SelectComboDateScreen(
                            location: widget.location,
                            isCreate: widget.isCreate,
                            plan: widget.plan,
                            isClone: widget.isClone,
                          ),
                          type: PageTransitionType.rightToLeft));
                }
              },
              child: const Text('Tiếp tục'),
            )),
          ],
        ),
      ),
    ));
  }
}
