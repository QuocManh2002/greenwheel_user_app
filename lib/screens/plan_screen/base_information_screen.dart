import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class BaseInformationScreen extends StatefulWidget {
  const BaseInformationScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<BaseInformationScreen> createState() => _BaseInformationState();
}

class _BaseInformationState extends State<BaseInformationScreen> {
  int _selectedCombo = 0;
  int _selectedQuantity = 1;
  late FixedExtentScrollController _scrollController;
  bool isWarning = false;
  ComboDate? _suggestComboDate;
  TimeOfDay _selectTime = TimeOfDay.now();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();

  onChangeQuantity(String type) {
    if (type == "add") {
      setState(() {
        _selectedQuantity += 1;
      });
    } else {
      setState(() {
        _selectedQuantity -= 1;
      });
    }
    sharedPreferences.setInt('plan_number_of_member', _selectedQuantity);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() {
    int? member = sharedPreferences.getInt('plan_number_of_member');
    int? combodate = sharedPreferences.getInt('plan_combo_date');
    if (combodate != null) {
      setState(() {
        _selectedCombo = combodate;
        _scrollController = FixedExtentScrollController(initialItem: combodate);
      });
    } else {
      final defaultComboDate = listComboDate
              .firstWhere((element) =>
                  element.duration == widget.location.suggestedTripLength * 2)
              .id -
          1;
      sharedPreferences.setInt('plan_combo_date', defaultComboDate);
      setState(() {
        _selectedCombo = defaultComboDate;
        _scrollController =
            FixedExtentScrollController(initialItem: defaultComboDate);
      });

      // _scrollController.animateToItem(defaultComboDate,
      //     duration: Duration(seconds: 1), curve: Curves.easeInOut);
    }
    if (member != null) {
      setState(() {
        _selectedQuantity = member;
      });
    } else {
      sharedPreferences.setInt('plan_number_of_member', 1);
    }
    _suggestComboDate = listComboDate.firstWhere((element) =>
        element.duration == widget.location.suggestedTripLength * 2);

    String? timeText = sharedPreferences.getString('plan_start_time');
    if (timeText != null) {
      final initialDateTime = DateFormat.Hm().parse(timeText);
      setState(() {
        _selectTime = TimeOfDay.fromDateTime(initialDateTime);
        _timeController.text = timeText;
      });
    } else {
      _selectTime =
          TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
      _timeController.text = DateFormat.Hm()
          .format(DateTime(0, 0, 0, _selectTime.hour, _selectTime.minute));
      sharedPreferences.setString('plan_start_time', _timeController.text);
    }

    String? dateText = sharedPreferences.getString('plan_start_date');
    if (dateText != null) {
      setState(() {
        _selectedDate = DateTime.parse(dateText);
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    } else {
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      sharedPreferences.setString(
          'plan_start_date', _selectedDate!.toLocal().toString().split(' ')[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 2.h,
        ),
        const Text(
          'Thời gian trải nghiệm',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 1.h,
        ),
        const Text(
          'Chưa bao gồm thời gian di chuyển đến địa điểm xuất phát',
          style: TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 230,
          child: CupertinoPicker(
              itemExtent: 64,
              diameterRatio: 0.7,
              looping: true,
              scrollController: _scrollController,
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: primaryColor.withOpacity(0.12)),
              onSelectedItemChanged: (value) {
                setState(() {
                  _selectedCombo = value;
                });
                if (listComboDate[value].duration <
                    widget.location.templatePlan.length * 2) {
                  setState(() {
                    isWarning = true;
                  });
                } else {
                  setState(() {
                    isWarning = false;
                  });
                }
                sharedPreferences.setBool("plan_is_change", false);
                sharedPreferences.setInt('plan_combo_date', value);
              },
              children: Utils.modelBuilder(
                  listComboDate,
                  (index, model) => Center(
                        child: Text(
                          '${model.numberOfDay} ngày, ${model.numberOfNight} đêm',
                          style: TextStyle(
                              fontWeight: _selectedCombo == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedCombo == index
                                  ? primaryColor
                                  : Colors.black),
                        ),
                      ))),
        ),
        SizedBox(
          height: 2.h,
        ),
        if (isWarning)
          Text(
            'Địa điểm này thích hợp hơn với các chuyến đi có thời gian trải nghiệm từ ${_suggestComboDate!.numberOfDay} ngày, ${_suggestComboDate!.numberOfNight} đêm.',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        if (isWarning)
          SizedBox(
            height: 2.h,
          ),
        const Text(
          'Thời điểm xuất phát',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2.h,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
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
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2025),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData().copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: primaryColor,
                                      onPrimary: Colors.white)),
                              child: DatePickerDialog(
                                cancelText: 'HỦY',
                                confirmText: 'LƯU',
                                initialDate: _selectedDate!,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2025),
                              ),
                            );
                          });
                      if (newDay != null) {
                        _selectedDate = newDay;
                        _dateController.text =
                            DateFormat('dd/MM/yyyy').format(newDay);
                        sharedPreferences.setString(
                            'plan_start_date', newDay.toString());
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
                            DateTime(_selectedDate!.year, _selectedDate!.month,
                                _selectedDate!.day))) {
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
                                    'plan_start_time', _timeController.text);
                              }).show();
                        } else {
                          _selectTime = value;
                          _timeController.text = DateFormat.Hm().format(
                              DateTime(0, 0, 0, _selectTime.hour,
                                  _selectTime.minute));
                          sharedPreferences.setString(
                              'plan_start_time', _timeController.text);
                          sharedPreferences.setBool('plan_is_change', false);
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
        ),
        SizedBox(
          height: 6.h,
        ),
        const Text(
          'Số lượng thành viên ước tính',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                color: primaryColor,
                iconSize: 30,
                onPressed: () {
                  if (_selectedQuantity > 1) {
                    onChangeQuantity("subtract");
                  }
                },
                icon: const Icon(Icons.remove)),
            Container(
              alignment: Alignment.center,
              height: 5.h,
              width: 10.h,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                _selectedQuantity.toString(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
                color: primaryColor,
                iconSize: 30,
                onPressed: () {
                  onChangeQuantity("add");
                },
                icon: const Icon(Icons.add)),
          ],
        ),
      ],
    );
  }

  handleTimeBeforeNow1Hour() {
    print(_selectedDate!
        .add(Duration(hours: _selectTime.hour))
        .add(Duration(minutes: _selectTime.minute))
        .isBefore(DateTime.now().add(const Duration(hours: 1))));
    if (_selectedDate!.difference(DateTime.now()).inDays == 0 &&
        _selectedDate!
            .add(Duration(hours: _selectTime.hour))
            .add(Duration(minutes: _selectTime.minute))
            .isAfter(DateTime.now().add(const Duration(hours: 1)))) {}
  }
}
