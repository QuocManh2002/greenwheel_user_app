import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/select_emergency_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/craete_plan_header.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class SelectStartDateScreen extends StatefulWidget {
  const SelectStartDateScreen(
      {super.key, required this.isCreate, this.plan, required this.location});
  final bool isCreate;
  final PlanDetail? plan;
  final LocationViewModel location;

  @override
  State<SelectStartDateScreen> createState() => _SelectStartDateState();
}

class _SelectStartDateState extends State<SelectStartDateScreen> {
  TextEditingController _nameController = TextEditingController();
  // final OfflineService _offlineService = OfflineService();
  DateTime? _endDate;
  late ComboDate _initComboDate;
  TimeOfDay _selectTime = TimeOfDay.now();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  bool isOverDate = false;
  int numberOfDay = 0;
  int numberOfNight = 0;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final PlanService _planService = PlanService();

  handleChangeComboDate() {
    dynamic rs;
    final departureDate = widget.isCreate
        ? DateTime.parse(sharedPreferences.getString('plan_departureDate')!)
        : widget.plan!.utcDepartAt;
    if (widget.isCreate) {
      final initialDateTime =
          DateTime.parse(sharedPreferences.getString('plan_start_time')!);
      final startTime =
          DateTime(0, 0, 0, initialDateTime.hour, initialDateTime.minute);
      final arrivedTime = startTime.add(Duration(
          seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
              .ceil()));
      sharedPreferences.setString('plan_arrivedTime', arrivedTime.toString());
      rs = Utils().getNumOfExpPeriod(
          arrivedTime, _initComboDate.duration.toInt(), startTime, null, true);
    } else {
      rs = Utils().getNumOfExpPeriod(
          null,
          widget.plan!.numOfExpPeriod!,
          widget.plan!.utcDepartAt!,
          DateFormat.Hms().parse(widget.plan!.travelDuration!),
          true);
    }

    isOverDate = rs['isOverDate'];
    if (rs['isOverDate'] ||
        rs['numOfExpPeriod'] != _initComboDate.duration.toInt()) {
      if (rs['isOverDate']) {
        if (widget.isCreate) {
          sharedPreferences.setString(
              'plan_start_date',
              departureDate!
                  .add(const Duration(days: 1))
                  .toLocal()
                  .toString()
                  .split(' ')[0]);
        } else {
          setState(() {
            widget.plan!.startDate =
                departureDate!.add(const Duration(days: 1));
          });
        }
      }
      setState(() {
        numberOfNight = _initComboDate.numberOfNight + 1;
        _endDate =
            departureDate!.add(Duration(days: _initComboDate.numberOfDay));
      });
      if (widget.isCreate) {
        sharedPreferences.setString(
            'plan_end_date', _endDate.toString().split(' ')[0]);
      } else {
        setState(() {
          widget.plan!.endDate = _endDate;
        });
      }
    } else {
      setState(() {
        numberOfNight = _initComboDate.numberOfNight;
        _endDate =
            departureDate!.add(Duration(days: _initComboDate.numberOfDay - 1));
      });
      if (widget.isCreate) {
        sharedPreferences.setString(
            'plan_end_date', _endDate.toString().split(' ')[0]);
      } else {
        widget.plan!.endDate = _endDate;
      }
    }
    if (rs['numOfExpPeriod'] != _initComboDate.duration.toInt()) {
      if (widget.isCreate) {
        sharedPreferences.setInt('numOfExpPeriod', numberOfDay + numberOfNight);
      } else {
        setState(() {
          widget.plan!.actualGcoinBudget = numberOfDay + numberOfNight;
        });
      }
    } else {
      sharedPreferences.setInt(
          'numOfExpPeriod', _initComboDate.duration.toInt());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isCreate) {
      setUpDataCreate();
    } else {
      setUpDataUpdate();
    }
  }

  setUpDataUpdate() {
    _initComboDate = listComboDate.firstWhere(
        (element) => element.duration == widget.plan!.numOfExpPeriod);
    _nameController.text = widget.plan!.name!;
    _timeController.text = DateFormat.Hm().format(widget.plan!.utcDepartAt!);
    _dateController.text =
        DateFormat('dd/MM/yyyy').format(widget.plan!.utcDepartAt!);
    numberOfDay = _initComboDate.numberOfDay;
    numberOfNight = _initComboDate.numberOfNight;
    handleChangeComboDate();
  }

  handleChangeDateUpdate() {}

  setUpDataCreate() {
    final name = sharedPreferences.getString('plan_name');
    if (name != null) {
      _nameController.text = name;
    }
    var _numOfExpPeriod = sharedPreferences.getInt('initNumOfExpPeriod');
    _initComboDate = listComboDate.firstWhere((element) =>
        element.numberOfDay + element.numberOfNight == _numOfExpPeriod);
    numberOfDay = _initComboDate.numberOfDay;
    numberOfNight = _initComboDate.numberOfNight;
    final _duration = (_numOfExpPeriod! / 2).ceil();
    final _departDateText = sharedPreferences.getString('plan_departureDate');
    final _departTimeText = sharedPreferences.getString('plan_start_time');
    if (_departDateText != null) {
      final departDate = DateTime.parse(_departDateText);
      _selectedDate = departDate;
      _dateController.text = DateFormat('dd/MM/yyyy').format(departDate);
      _endDate = departDate.add(Duration(days: _duration - 1));
    } else {
      final initDate = DateTime.now().add(const Duration(days: 7));
      _selectedDate = initDate;
      _dateController.text = DateFormat('dd/MM/yyyy').format(initDate);
      _endDate = initDate.add(Duration(days: _duration - 1));
      sharedPreferences.setString('plan_departureDate', initDate.toString());
      sharedPreferences.setString(
          'plan_start_date', initDate.toString().split(' ')[0]);
      sharedPreferences.setString('plan_end_date',
          initDate.add(Duration(days: _duration - 1)).toString());
    }

    if (_departTimeText != null) {
      final departTime = DateTime.parse(_departTimeText);
      _selectTime = TimeOfDay.fromDateTime(departTime);
      _timeController.text = DateFormat.Hm().format(departTime);
    } else {
      _timeController.text =
          DateFormat.Hm().format(DateTime.now().add(const Duration(hours: 1)));

      final _startTime =
          DateTime(0, 0, 0, DateTime.now().hour + 1, DateTime.now().minute);
      sharedPreferences.setString('plan_start_time', _startTime.toString());
    }
    handleChangeComboDate();
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
              Navigator.of(context).pop();
            }, context);
          },
        ),
        actions: [
          InkWell(
            onTap: () {
              _planService.handleShowPlanInformation(context, widget.location);
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
                stepNumber: 3, stepName: 'Tên & thời gian xuất phát'),
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
                maxLength: 30,
                onChange: (p0) {
                  sharedPreferences.setString('plan_name', p0!);
                },
                onValidate: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tên của chuyến đi không được để trống";
                  } else if (value.length < 3 || value.length > 30) {
                    return "Tên của chuyến đi phải có độ dài từ 3 - 30 kí tự";
                  }
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
                            firstDate:
                                DateTime.now().add(const Duration(days: 7)),
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
                          _dateController.text =
                              DateFormat('dd/MM/yyyy').format(newDay);
                          if (widget.isCreate) {
                            _selectedDate = newDay;
                            sharedPreferences.setString(
                                'plan_start_date', newDay.toString());
                            sharedPreferences.setString(
                                'plan_departureDate', newDay.toString());
                            final duration =
                                (sharedPreferences.getInt('numOfExpPeriod')! /
                                        2)
                                    .ceil();
                            setState(() {
                              _endDate = _selectedDate!
                                  .add(Duration(days: duration - 1));
                            });
                          } else {
                            widget.plan!.utcDepartAt = newDay;
                          }

                          handleChangeComboDate();
                        }
                      },
                      prefixIcon: const Icon(Icons.calendar_month),
                      onValidate: (value) {
                        if (value!.isEmpty) {
                          return "Ngày của hoạt động không được để trống";
                        }
                      }),
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
                      onTap: () async {
                        TimeOfDay? newTime = await showTimePicker(
                          context: context,
                          initialTime: _selectTime,
                          confirmText: 'CHỌN',
                          cancelText: 'HUỶ',
                          initialEntryMode: TimePickerEntryMode.dial,
                          builder: (context, child) {
                            return Theme(
                                data: ThemeData().copyWith(
                                    colorScheme: const ColorScheme.light(
                                        primary: primaryColor,
                                        onPrimary: Colors.white)),
                                child: MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: false),
                                  child: Localizations.override(
                                    context: context,
                                    locale: const Locale('vi', ''),
                                    child: child!,
                                  ),
                                ));
                          },
                        ).then((value) {
                          if (!Utils().checkTimeAfterNow1Hour(
                              value!,
                              DateTime(_selectedDate!.year,
                                  _selectedDate!.month, _selectedDate!.day))) {
                            AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                btnOkColor: Colors.orange,
                                body: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Center(
                                    child: Text(
                                      'Thời gian của chuyến đi phải sau thời điểm hiện tại ít nhất 1 giờ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                btnOkOnPress: () {
                                  _selectTime = TimeOfDay.fromDateTime(
                                      DateTime.now()
                                          .add(const Duration(hours: 1)));
                                  _timeController.text = DateFormat.Hm().format(
                                      DateTime(0, 0, 0, _selectTime.hour,
                                          _selectTime.minute));
                                  sharedPreferences.setString(
                                      'plan_start_time',
                                      DateTime(0, 0, 0, _selectTime.hour,
                                              _selectTime.minute)
                                          .toString());
                                }).show();
                          } else {
                            _timeController.text = DateFormat.Hm().format(
                                DateTime(0, 0, 0, value.hour, value.minute));
                            if (widget.isCreate) {
                              setState(() {
                                _selectTime = value;
                              });
                              sharedPreferences.setString(
                                  'plan_start_time',
                                  DateTime(0, 0, 0, value.hour, value.minute)
                                      .toString());
                            } else {
                              setState(() {
                                widget.plan!.utcDepartAt =
                                    DateFormat.Hm().parse(_timeController.text);
                              });
                            }

                            handleChangeComboDate();
                          }
                        });
                      },
                      onValidate: (value) {
                        if (value!.isEmpty) {
                          return "Ngày của hoạt động không được để trống";
                        }
                      },
                      prefixIcon: const Icon(Icons.watch_later_outlined)),
                ),
              ],
            ),
            SizedBox(
              height: 3.h,
            ),
            const Text(
              'Tổng thời gian chuyến đi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 2.h,
            ),
            const Text(
              'Bao gồm thời gian di chuyển từ địa điểm xuất phát',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(
              height: 3.h,
            ),
            Text(
              '$numberOfDay ngày $numberOfNight đêm',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_timeController.text} ${_dateController.text} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 2.h,
            ),
            const Text(
              'Thời gian trải nghiệm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              !isOverDate
                  ? '$numberOfDay ngày $numberOfNight đêm'
                  : '${_initComboDate.numberOfDay} ngày ${_initComboDate.numberOfNight} đêm',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(
              height: 1.h,
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
                if (formKey.currentState!.validate()) {
                  Navigator.push(
                      context,
                      PageTransition(
                          child:
                              SelectEmergencyService(location: widget.location),
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
