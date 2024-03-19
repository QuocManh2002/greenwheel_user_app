import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:sizer2/sizer2.dart';
import 'package:table_calendar/table_calendar.dart';

class BaseInformationScreen extends StatefulWidget {
  const BaseInformationScreen({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<BaseInformationScreen> createState() => _BaseInformationState();
}

class _BaseInformationState extends State<BaseInformationScreen> {
  int _selectedCombo = 0;
  late FixedExtentScrollController _scrollController;
  bool isWarning = false;
  DateTime? _focusedDay;
  DateTime? _selectedDate;
  bool _isSelecting = false;
  TextEditingController _memberController = TextEditingController();
  TextEditingController _maxMemberWeightController = TextEditingController();

  onChangeQuantity(String type) {
    if (type == "add") {
      setState(() {
        _memberController.text =
            (int.parse(_memberController.text) + 1).toString();
      });
    } else {
      setState(() {
        _memberController.text =
            (int.parse(_memberController.text) - 1).toString();
      });
      if (int.parse(_memberController.text) <
          int.parse(_maxMemberWeightController.text)) {
        setState(() {
          _maxMemberWeightController.text = _memberController.text;
        });
      }
    }
    sharedPreferences.setInt(
        'plan_number_of_member', int.parse(_memberController.text));
  }

  onChangeMaxWeightMember(String type) {
    if (type == "add") {
      setState(() {
        _maxMemberWeightController.text =
            (int.parse(_maxMemberWeightController.text) + 1).toString();
      });
    } else {
      setState(() {
        _maxMemberWeightController.text =
            (int.parse(_maxMemberWeightController.text) - 1).toString();
      });
    }
    sharedPreferences.setInt(
        'plan_max_member_weight', int.parse(_maxMemberWeightController.text));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() {
    int? member = sharedPreferences.getInt('plan_number_of_member');
    int? numOfExpPeriod = sharedPreferences.getInt('initNumOfExpPeriod');
    int? maxMemberWeight = sharedPreferences.getInt('plan_max_member_weight');
    ComboDate _selectedComboDate;
    _memberController.text = '1';
    _maxMemberWeightController.text = '0';
    _focusedDay = DateTime.now().add(const Duration(days: 4));
    sharedPreferences.setString('plan_closeRegDate', _focusedDay.toString());
    if (numOfExpPeriod != null) {
      _selectedComboDate = listComboDate.firstWhere(
        (element) =>
            element.numberOfDay + element.numberOfNight == numOfExpPeriod,
      );

      setState(() {
        _selectedCombo = _selectedComboDate.id - 1;
        _scrollController =
            FixedExtentScrollController(initialItem: _selectedComboDate.id - 1);
      });
    } else {
      _selectedComboDate = listComboDate.first;
      sharedPreferences.setInt('plan_combo_date', _selectedComboDate.id - 1);
      sharedPreferences.setInt('initNumOfExpPeriod',
          _selectedComboDate.numberOfDay + _selectedComboDate.numberOfNight);
      setState(() {
        _selectedCombo = _selectedComboDate.id - 1;
        _scrollController =
            FixedExtentScrollController(initialItem: _selectedComboDate.id - 1);
      });
    }
    sharedPreferences.setInt('plan_combo_date', _selectedComboDate.id - 1);
    if (member != null) {
      setState(() {
        _memberController.text = member.toString();
      });
    } else {
      sharedPreferences.setInt('plan_number_of_member', 1);
    }
    if (maxMemberWeight != null) {
      setState(() {
        _maxMemberWeightController.text = maxMemberWeight.toString();
      });
    } else {
      sharedPreferences.setInt('plan_max_member_weight', 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 3.h,
          ),
          const Text(
            'Thời gian trải nghiệm mong muốn',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 3.h,
          ),
          const Text(
            'Chưa gồm thời gian di chuyển đến điểm xuất phát',
            style: TextStyle(fontSize: 15, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 3.h,
          ),
          _isSelecting
              ? SizedBox(
                  height: 320,
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
                        sharedPreferences.setInt('plan_combo_date', value);
                        sharedPreferences.setInt(
                            'initNumOfExpPeriod',
                            listComboDate[value].numberOfDay +
                                listComboDate[value].numberOfNight);
                        Future.delayed(
                          const Duration(seconds: 2),
                          () {
                            setState(() {
                              _isSelecting = false;
                            });
                          },
                        );
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
                )
              : InkWell(
                  onTap: () {
                    setState(() {
                      _isSelecting = true;
                    });
                    _scrollController = FixedExtentScrollController(
                        initialItem: _selectedCombo);
                  },
                  child: Container(
                      width: 70.w,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38, width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12))),
                      child: Text(
                        '${listComboDate[_selectedCombo].numberOfDay} ngày, ${listComboDate[_selectedCombo].numberOfNight} đêm',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                ),
          SizedBox(
            height: 3.h,
          ),
          const Text(
            'Số lượng thành viên tối đa',
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
                    if (int.parse(_memberController.text) > 1) {
                      onChangeQuantity("subtract");
                    }
                  },
                  icon: const Icon(Icons.remove)),
              SizedBox(
                  width: 10.h,
                  height: 5.h,
                  child: defaultTextFormField(
                      maxLength: 2,
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        setState(() {
                          _isSelecting = false;
                        });
                      },
                      onChange: (value) {
                        if (value == null || value.isEmpty) {
                          sharedPreferences.setInt('plan_number_of_member', 0);
                          Fluttertoast.showToast(
                              msg: "Số lượng thành viên không được để trống",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 18.0);
                        } else {
                          var selectedNumber =
                              int.tryParse(_memberController.text);
                          if (selectedNumber == null) {
                            sharedPreferences.setInt(
                                'plan_number_of_member', 0);
                            Fluttertoast.showToast(
                                msg: "Số lượng thành viên không hợp lệ",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                fontSize: 18.0);
                          } else {
                            if (selectedNumber < 0) {
                              sharedPreferences.setInt(
                                  'plan_number_of_member', 0);
                              Fluttertoast.showToast(
                                  msg: "Số lượng thành viên không hợp lệ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  fontSize: 18.0);
                            } else {
                              sharedPreferences.setInt(
                                  'plan_number_of_member', int.parse(value));
                            }
                          }
                        }
                      },
                      borderSize: 2,
                      textAlign: TextAlign.center,
                      controller: _memberController,
                      inputType: TextInputType.number)),
              IconButton(
                  color: primaryColor,
                  iconSize: 30,
                  onPressed: () {
                    if (int.parse(_memberController.text) < 20) {
                      onChangeQuantity('add');
                    }
                  },
                  icon: const Icon(Icons.add)),
            ],
          ),
          SizedBox(
            height: 3.h,
          ),
          const Text(
            'Số người đi cùng tối đa',
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
                    if (int.parse(_maxMemberWeightController.text) > 0) {
                      onChangeMaxWeightMember("subtract");
                    }
                  },
                  icon: const Icon(Icons.remove)),
              SizedBox(
                  width: 10.h,
                  height: 5.h,
                  child: defaultTextFormField(
                      maxLength: 2,
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        setState(() {
                          _isSelecting = false;
                        });
                      },
                      onChange: (value) {
                        if (value == null || value.isEmpty) {
                          sharedPreferences.setInt('plan_max_member_weight', 0);
                          Fluttertoast.showToast(
                              msg: "Số lượng người đi cùng không được để trống",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 18.0);
                        } else {
                          var selectedNumber =
                              int.tryParse(_memberController.text);
                          if (selectedNumber == null) {
                            sharedPreferences.setInt(
                                'plan_max_member_weight', 0);
                            Fluttertoast.showToast(
                                msg: "Số lượng người đi cùng không hợp lệ",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                fontSize: 18.0);
                          } else {
                            if (selectedNumber < 0) {
                              sharedPreferences.setInt(
                                  'plan_max_member_weight', 0);
                              Fluttertoast.showToast(
                                  msg: "Số lượng người đi cùng không hợp lệ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  fontSize: 18.0);
                            } else {
                              sharedPreferences.setInt(
                                  'plan_max_member_weight', int.parse(value));
                            }
                          }
                        }
                      },
                      borderSize: 2,
                      textAlign: TextAlign.center,
                      controller: _maxMemberWeightController,
                      inputType: TextInputType.number)),
              IconButton(
                  color: primaryColor,
                  iconSize: 30,
                  onPressed: () {
                    if (int.parse(_maxMemberWeightController.text) + 1 <
                       ( int.parse(_memberController.text) / 3 ).ceil()) {
                      onChangeMaxWeightMember('add');
                    }
                  },
                  icon: const Icon(Icons.add)),
            ],
          ),
          SizedBox(
            height: 2.h,
          ),
        ],
      ),
    );
  }

  _onDaySelected(DateTime selectDay, DateTime focusDay) {
    if (!isSameDay(_selectedDate, selectDay)) {
      setState(() {
        _selectedDate = selectDay;
        _focusedDay = focusDay;
        sharedPreferences.setString(
            'plan_closeRegDate', _selectedDate.toString());
      });
    }
  }
}
