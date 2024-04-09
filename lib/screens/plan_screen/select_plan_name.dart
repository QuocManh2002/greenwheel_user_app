import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/service/offline_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class SelectPlanName extends StatefulWidget {
  const SelectPlanName(
      {super.key,
      required this.location,
      required this.isCreate,
      required this.formKey,
      this.plan,
      required this.isClone});
  final LocationViewModel location;
  final bool isCreate;
  final bool isClone;
  final PlanDetail? plan;
  final GlobalKey<FormState> formKey;

  @override
  State<SelectPlanName> createState() => _SelectPlanNameState();
}

class _SelectPlanNameState extends State<SelectPlanName> {
  TextEditingController _nameController = TextEditingController();
  final OfflineService _offlineService = OfflineService();
  DateTime? _endDate;
  late ComboDate _initComboDate;
  TimeOfDay _selectTime = TimeOfDay.now();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  bool isOverDate = false;
  int numberOfDay = 0;
  int numberOfNight = 0;

  handleChangeComboDate() {
    dynamic rs;
    final departureDate = widget.isCreate
        ? DateTime.parse(sharedPreferences.getString('plan_departureDate')!)
        : widget.plan!.departDate;
    if (widget.isCreate) {
      final initialDateTime =
          DateTime.parse(sharedPreferences.getString('plan_start_time')!);
      final startTime =
          DateTime(0, 0, 0, initialDateTime.hour, initialDateTime.minute);
      final arrivedTime = startTime.add(Duration(
          seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
              .ceil()));

      rs = Utils().getNumOfExpPeriod(
          arrivedTime, _initComboDate.duration.toInt(), startTime, null, true);
    } else {
      rs = Utils().getNumOfExpPeriod(
          null,
          widget.plan!.numOfExpPeriod!,
          widget.plan!.departTime!,
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
    _timeController.text = DateFormat.Hm().format(widget.plan!.departTime!);
    _dateController.text =
        DateFormat('dd/MM/yyyy').format(widget.plan!.departDate!);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 2.h,
            ),
            const Text(
              'Hãy đặt tên cho chuyến đi của bạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 2.h,
            ),
            Form(
              key: widget.formKey,
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
                            widget.plan!.departDate = newDay;
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
                      onTap: () async{
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
                                DateTime(0, 0, 0, value.hour,
                                    value.minute));
                            if (widget.isCreate) {
                              setState(() {
                                _selectTime = value;
                              });
                              sharedPreferences.setString(
                                  'plan_start_time',
                                  DateTime(0, 0, 0, value.hour,
                                          value.minute)
                                      .toString());
                            } else {
                              setState(() {
                                widget.plan!.departTime =
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
    );
  }
}
