import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/rating_clone_plan.dart';
import 'package:greenwheel_user_app/service/offline_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class SelectPlanName extends StatefulWidget {
  const SelectPlanName(
      {super.key,
      required this.location,
      required this.isCreate,
      required this.isClone});
  final LocationViewModel location;
  final bool isCreate;
  final bool isClone;

  @override
  State<SelectPlanName> createState() => _SelectPlanNameState();
}

class _SelectPlanNameState extends State<SelectPlanName> {
  TextEditingController _nameController = TextEditingController();
  PlanService _planService = PlanService();
  bool isCreate = false;
  final OfflineService _offlineService = OfflineService();
  DateTime? _rangeEnd;
  late ComboDate _selectedComboDate;
  late ComboDate _initComboDate;
  bool _isChangeComboDate = false;
  TimeOfDay _selectTime = TimeOfDay.now();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  bool isOverDate = false;

  createPlan() async {
    int memberLimit = sharedPreferences.getInt('plan_number_of_member')!;
    double lat = sharedPreferences.getDouble('plan_start_lat')!;
    double lng = sharedPreferences.getDouble('plan_start_lng')!;
    String startDate = sharedPreferences.getString('plan_start_date')!;
    String endDate = sharedPreferences.getString('plan_end_date')!;
    String schedule = sharedPreferences.getString('plan_schedule')!;
    String startTime = sharedPreferences.getString('plan_start_time')!;
    int numOfExpPeriod = sharedPreferences.getInt('numOfExpPeriod')!;

    final initialDateTime = DateFormat.Hm().parse(startTime);
    final initialDate =
        DateTime.parse(sharedPreferences.getString('plan_departureDate')!);
    DateTime departureDate =
        DateTime(initialDate.year, initialDate.month, initialDate.day)
            .add(Duration(hours: initialDateTime.hour))
            .add(Duration(minutes: initialDateTime.minute));

    int planId = sharedPreferences.getInt('planId')!;
    var _startDate = DateTime.parse(startDate);

    int? rs = await _planService.createDraftPlan(
      PlanCreate(
          gcoinBudget: sharedPreferences.getInt('plan_budget'),
          numOfExpPeriod: numOfExpPeriod,
          locationId: widget.location.id,
          startDate: _startDate,
          departureDate: departureDate,
          endDate: DateTime.parse(endDate),
          latitude: lat,
          longitude: lng,
          memberLimit: memberLimit,
          name: _nameController.text,
          schedule: json.decode(schedule).toString(),
          savedContacts: sharedPreferences.getString('plan_saved_emergency')),
    );

    if (rs != 0) {
      setState(() {
        isCreate = true;
      });
      // bool isEnableToAddService = DateTime.parse(endDate)
      //     .isAfter(DateTime.now().add(const Duration(days: 3)));
      // if (isEnableToAddService) {
      //   // ignore: use_build_context_synchronously
      //   AwesomeDialog(
      //       context: context,
      //       dialogType: DialogType.success,
      //       body: Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           Text(
      //             widget.isCreate
      //                 ? "Tạo kế hoạch thành công"
      //                 : 'Cập nhật kế hoạch thành công',
      //             style: const TextStyle(
      //                 fontSize: 16, fontWeight: FontWeight.bold),
      //           ),
      // SizedBox(
      //   height: 2.h,
      // ),
      // const Padding(
      //   padding: EdgeInsets.symmetric(horizontal: 24),
      //   child: Text(
      //     'Bạn có muốn đặt dịch vụ cho kế hoạch này không ?',
      //     style: TextStyle(fontSize: 14, color: Colors.grey),
      //     textAlign: TextAlign.center,
      //   ),
      // )
      //   ],
      // ),
      // btnCancelText: 'Không',
      // btnCancelColor: Colors.blue,
      // btnCancelOnPress: () {
      //   if (widget.isClone) {
      //     AwesomeDialog(
      //       context: context,
      //       dialogType: DialogType.question,
      //       animType: AnimType.leftSlide,
      //       title:
      //           'Bạn có muốn đánh giá cho kế hoạch bạn đã tham khảo không',
      //       titleTextStyle: const TextStyle(
      //           fontSize: 18, fontWeight: FontWeight.bold),
      //       btnOkText: 'Có',
      //       btnOkOnPress: () {},
      //       btnOkColor: Colors.orange,
      //       btnCancelColor: Colors.blue,
      //       btnCancelText: 'Không',
      //       btnCancelOnPress: () {
      //         Utils().clearPlanSharePref();
      //         // ignore: use_build_context_synchronously
      //         Navigator.of(context).pop();
      //         // ignore: use_build_context_synchronously
      //         Navigator.of(context).pushAndRemoveUntil(
      //           MaterialPageRoute(
      //               builder: (ctx) => const TabScreen(
      //                     pageIndex: 1,
      //                   )),
      //           (route) => false,
      //         );
      //       },
      //     ).show();
      //   } else {
      //     Utils().clearPlanSharePref();
      //     // ignore: use_build_context_synchronously
      //     Navigator.of(context).pop();
      //     // ignore: use_build_context_synchronously
      //     Navigator.of(context).pushAndRemoveUntil(
      //       MaterialPageRoute(
      //           builder: (ctx) => const TabScreen(
      //                 pageIndex: 1,
      //               )),
      //       (route) => false,
      //     );
      //   }
      // },
      //       btnOkText: 'Ok',
      //       btnOkColor: primaryColor,
      //       btnOkOnPress: () {
      //         print(sharedPreferences.getString('plan_schedule'));
      //         print(sharedPreferences.getString('plan_saved_emergency'));
      //         sharedPreferences.setInt("planId", rs);
      //         Navigator.of(context).pop();
      //         Navigator.of(context).push(MaterialPageRoute(
      //             builder: (ctx) => SelectServiceScreen(
      //                   location: widget.location,
      //                   isClone: widget.isClone,
      //                 )));
      //       }).show();
      // } else {
      // PlanDetail? plan = await _planService.GetPlanById(rs);
      // if (plan != null) {
      //   await _offlineService.savePlanToHive(PlanOfflineViewModel(
      //       id: rs,
      //       name: _nameController.text,
      //       imageBase64:
      //           await Utils().getImageBase64Encoded(plan.imageUrls[0]),
      //       startDate: plan.startDate,
      //       endDate: plan.endDate,
      //       memberLimit: memberLimit,
      //       schedule: plan.schedule,
      //       memberList: [
      //         PlanOfflineMember(
      //             id: int.parse(sharedPreferences.getString('userId')!),
      //             name: "Quoc Manh",
      //             phone: sharedPreferences.getString('userPhone')!,
      //             isLeading: true)
      //       ]));
      // }

      // ignore: use_build_context_synchronously
      AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          body: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Tạo kế hoạch thành công",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          btnOkText: 'Ok',
          btnOkColor: primaryColor,
          btnOkOnPress: () {
            if (widget.isClone) {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.question,
                animType: AnimType.leftSlide,
                title:
                    'Bạn có muốn đánh giá cho kế hoạch bạn đã tham khảo không',
                titleTextStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                btnOkText: 'Có',
                btnOkOnPress: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (ctx) => RatingClonePlan()),
                      (route) => false);
                },
                btnOkColor: Colors.orange,
                btnCancelColor: Colors.blue,
                btnCancelText: 'Không',
                btnCancelOnPress: () {
                  Utils().clearPlanSharePref();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (ctx) => const TabScreen(
                              pageIndex: 1,
                            )),
                    (route) => false,
                  );
                },
              ).show();
            } else {
              Utils().clearPlanSharePref();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (ctx) => const TabScreen(
                          pageIndex: 1,
                        )),
                (route) => false,
              );
            }
          }).show();
    }
  }

  handleChangeComboDate() {
    final initialDateTime =
        DateTime.parse(sharedPreferences.getString('plan_start_time')!);
    final startTime =
        DateTime(0, 0, 0, initialDateTime.hour, initialDateTime.minute);
    final arrivedTime = startTime.add(Duration(
        seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
            .ceil()));
    final departureDate =
        DateTime.parse(sharedPreferences.getString('plan_departureDate')!);
    if (arrivedTime.isAfter(DateTime(0, 0, 0, 16, 0)) &&
        arrivedTime.isBefore(DateTime(0, 0, 1, 6, 0))) {
      if (arrivedTime.isBefore(DateTime(0, 0, 0, 20, 0))) {
        setState(() {
          isOverDate = true;
        });
      } else {
        setState(() {
          isOverDate = false;
          _rangeEnd =
              departureDate.add(Duration(days: _initComboDate.numberOfDay));
          _selectedComboDate = listComboDate.firstWhere(
              (element) => element.duration == _initComboDate.duration + 1);
        });
        sharedPreferences.setString(
            'plan_start_date',
            departureDate
                .add(const Duration(days: 1))
                .toLocal()
                .toString()
                .split(' ')[0]);
        sharedPreferences.setString(
            'plan_end_date',
            departureDate
                .add(Duration(days: _initComboDate.numberOfNight))
                .toString()
                .split(' ')[0]);
      }
    } else {
      setState(() {
        _rangeEnd =
            departureDate.add(Duration(days: _initComboDate.numberOfDay - 1));
        _selectedComboDate = _initComboDate;
      });
      sharedPreferences.setString(
          'plan_end_date',
          departureDate
              .add(Duration(days: _initComboDate.numberOfDay - 1))
              .toString()
              .split(' ')[0]);
    }
    sharedPreferences.setInt('plan_combo_date', _selectedComboDate.id);
    if (isOverDate) {
      sharedPreferences.setInt(
          'numOfExpPeriod', _selectedComboDate.duration.toInt());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() {
    final name = sharedPreferences.getString('plan_name');
    if(name != null){
      _nameController.text = name;
    }
    var _numOfExpPeriod = sharedPreferences.getInt('numOfExpPeriod');
    _selectedComboDate = listComboDate.firstWhere((element) =>
        element.numberOfDay + element.numberOfNight == _numOfExpPeriod);
    _initComboDate = _selectedComboDate;
    final _duration = (sharedPreferences.getInt('numOfExpPeriod')! / 2).ceil();
    final initDate = DateTime.now().add(const Duration(days: 7));
    _dateController.text = DateFormat('dd/MM/yyyy').format(initDate);
    _timeController.text =
        DateFormat.Hm().format(DateTime.now().add(const Duration(hours: 1)));
    _rangeEnd = initDate.add(Duration(days: _duration - 1));
    final _startTime =
        DateTime(0, 0, 0, DateTime.now().hour + 1, DateTime.now().minute);
    sharedPreferences.setString('plan_departureDate', initDate.toString());
    sharedPreferences.setString('plan_start_time', _startTime.toString());
    sharedPreferences.setString(
        'plan_start_date', initDate.toString().split(' ')[0]);
    sharedPreferences.setString('plan_end_date',
        initDate.add(Duration(days: _duration - 1)).toString());
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
            defaultTextFormField(
              autofocus: true,
              padding: const EdgeInsets.only(left: 12),
              controller: _nameController,
              inputType: TextInputType.name,
              onChange: (p0) {
                sharedPreferences.setString('plan_name', p0!);
              },
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
                            locale: const Locale('vi_VN'),
                            initialDate: _selectedDate,
                            firstDate: _selectedDate!,
                            lastDate:
                                _selectedDate!.add(const Duration(days: 830)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData().copyWith(
                                    colorScheme: const ColorScheme.light(
                                        primary: primaryColor,
                                        onPrimary: Colors.white)),
                                child: DatePickerDialog(
                                  cancelText: 'HỦY',
                                  confirmText: 'LƯU',
                                  initialDate:
                                      DateTime.now().add(Duration(days: 7)),
                                  firstDate:
                                      DateTime.now().add(Duration(days: 7)),
                                  lastDate: _selectedDate!
                                      .add(const Duration(days: 830)),
                                ),
                              );
                            });
                        if (newDay != null) {
                          _selectedDate = newDay;
                          _dateController.text =
                              DateFormat('dd/MM/yyyy').format(newDay);
                          sharedPreferences.setString(
                              'plan_start_date', newDay.toString());
                          sharedPreferences.setString(
                              'plan_departureDate', newDay.toString());
                          final duration =
                              (sharedPreferences.getInt('numOfExpPeriod')! / 2)
                                  .ceil();
                          setState(() {
                            _rangeEnd = _selectedDate!
                                .add(Duration(days: duration - 1));
                          });
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
                      onTap: () {
                        showTimePicker(
                          context: context,
                          initialTime: _selectTime,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData().copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: primaryColor,
                                      onPrimary: Colors.white)),
                              child: TimePickerDialog(
                                initialTime: _selectTime,
                              ),
                            );
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
                            setState(() {
                              _selectTime = value;
                              _timeController.text = DateFormat.Hm().format(
                                  DateTime(0, 0, 0, _selectTime.hour,
                                      _selectTime.minute));
                            });
                            sharedPreferences.setString(
                                'plan_start_time',
                                DateTime(0, 0, 0, _selectTime.hour,
                                        _selectTime.minute)
                                    .toString());
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
              '${_selectedComboDate.numberOfNight} ngày ${_selectedComboDate.numberOfDay} đêm',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            // if (_selectedDate != null)
            Text(
              '${_timeController.text} ${_dateController.text} - ${DateFormat('dd/MM/yyyy').format(_rangeEnd!)}',
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
              isOverDate
                  ? '${_selectedComboDate.numberOfNight} ngày ${_selectedComboDate.numberOfDay} đêm'
                  : '${_initComboDate.numberOfDay} ngày, ${_initComboDate.numberOfNight} đêm',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(
              height: 1.h,
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: TableCalendar(
            //     locale: 'vi_VN',
            //     focusedDay: _focusedDay!,
            //     selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            //     calendarFormat: _calendarFormat,
            //     onDaySelected: _onDaySelected,
            //     firstDay: DateTime.now(),
            //     lastDay: DateTime(2025),
            //     rangeStartDay: _rangeStart,
            //     rangeEndDay: _rangeEnd,
            //     calendarStyle: CalendarStyle(
            //         todayTextStyle: const TextStyle(color: Colors.black),
            //         rangeStartDecoration: const BoxDecoration(
            //             shape: BoxShape.circle, color: primaryColor),
            //         selectedDecoration: const BoxDecoration(
            //             color: primaryColor, shape: BoxShape.circle),
            //         todayDecoration: const BoxDecoration(
            //             shape: BoxShape.circle, color: Colors.transparent),
            //         rangeEndDecoration: const BoxDecoration(
            //             shape: BoxShape.circle, color: primaryColor),
            //         rangeHighlightColor: primaryColor.withOpacity(0.3)),
            //     onFormatChanged: (format) {
            //       if (_calendarFormat != format) {
            //         setState(() {
            //           _calendarFormat = format;
            //         });
            //       }
            //     },
            //     onPageChanged: (focusedDay) {
            //       _focusedDay = focusedDay;
            //     },
            //   ),
            // )
            // SizedBox(
            //   height: 3.h,
            // ),
            // if (!isCreate)
            //   ElevatedButton(
            //       style: elevatedButtonStyle,
            //       onPressed: createPlan,
            //       child: const Text('Tạo kế hoạch'))
          ],
        ),
      ),
    );
  }
}
