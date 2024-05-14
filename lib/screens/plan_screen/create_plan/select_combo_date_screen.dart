import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/select_emergency_service.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/combo_date_plan.dart';
import '../../../core/constants/global_constant.dart';
import '../../../core/constants/urls.dart';
import '../../../helpers/util.dart';
import '../../../main.dart';
import '../../../service/plan_service.dart';
import '../../../view_models/location.dart';
import '../../../view_models/plan_viewmodels/combo_date.dart';
import '../../../view_models/plan_viewmodels/plan_create.dart';
import '../../../widgets/plan_screen_widget/craete_plan_header.dart';
import '../../../widgets/style_widget/button_style.dart';
import '../../../widgets/style_widget/dialog_style.dart';
import '../../../widgets/style_widget/text_form_field_widget.dart';

class SelectComboDateScreen extends StatefulWidget {
  const SelectComboDateScreen(
      {super.key,
      required this.location,
      required this.isCreate,
      this.plan,
      required this.isClone});
  final bool isCreate;
  final PlanCreate? plan;
  final LocationViewModel location;
  final bool isClone;

  @override
  State<SelectComboDateScreen> createState() => _SelectComboDateScreenState();
}

class _SelectComboDateScreenState extends State<SelectComboDateScreen> {
  int _selectedCombo = 0;
  late FixedExtentScrollController _scrollController;
  bool isWarning = false;
  bool _isSelecting = false;
  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _maxMemberWeightController =
      TextEditingController();
  int _maxMemberWeight = 1;
  final PlanService _planService = PlanService();
  bool isShowDialog = false;
  int initMemberCount = 0;
  int _maxCombodateIndex = 0;
  // ComboDate? initCombodate;
  int? numberOfNight;
  DateTime? _departureTime;
  DateTime? _departureDate;
  DateTime? _endDate;
  bool? isOverDate;


  @override
  void initState() {
    super.initState();
    if (widget.isCreate && widget.plan == null) {
      setUpDataCreate();
    } else {
      setUpDataUpdate();
    }
  }

  setUpDataUpdate() async {
    _selectedCombo = listComboDate
            .firstWhere(
                (element) => element.duration == widget.plan!.numOfExpPeriod)
            .id -
        1;
    _scrollController =
        FixedExtentScrollController(initialItem: _selectedCombo);
    _memberController.text = widget.plan!.maxMemberCount.toString();
    _maxMemberWeightController.text =
        (widget.plan!.maxMemberWeight! - 1).toString();
    _maxMemberWeight = getMaxMemberWeight(int.parse(_memberController.text));
  }

  setUpDataCreate() async {
    initMemberCount = sharedPreferences.getInt('plan_number_of_member') ?? 2;
    int? member = sharedPreferences.getInt('plan_number_of_member');
    int? numOfExpPeriod = sharedPreferences.getInt('initNumOfExpPeriod');
    int? maxMemberWeight = sharedPreferences.getInt('plan_max_member_weight');
    ComboDate selectedComboDate;
    _maxCombodateIndex = listComboDate.length + 1;
    _memberController.text = GlobalConstant().PLAN_MIN_MEMBER_COUNT.toString();
    _maxMemberWeightController.text = '0';
    if (widget.isClone) {
      _maxCombodateIndex = listComboDate
          .firstWhere((element) =>
              element.duration == sharedPreferences.getInt('maxCombodateValue'))
          .id;
    }
    if (numOfExpPeriod != null) {
      selectedComboDate = listComboDate.firstWhere(
        (element) =>
            element.numberOfDay + element.numberOfNight == numOfExpPeriod,
      );
      setState(() {
        _selectedCombo = selectedComboDate.id - 1;
        _scrollController =
            FixedExtentScrollController(initialItem: selectedComboDate.id - 1);
      });
    } else {
      selectedComboDate = listComboDate.first;
      sharedPreferences.setInt('plan_combo_date', selectedComboDate.id - 1);
      sharedPreferences.setInt('initNumOfExpPeriod',
          selectedComboDate.numberOfDay + selectedComboDate.numberOfNight);
      setState(() {
        _selectedCombo = selectedComboDate.id - 1;
        _scrollController =
            FixedExtentScrollController(initialItem: selectedComboDate.id - 1);
      });
    }
    sharedPreferences.setInt('plan_combo_date', selectedComboDate.id - 1);
    if (member != null) {
      setState(() {
        _memberController.text = member.toString();
      });
      _maxMemberWeight = getMaxMemberWeight(int.parse(_memberController.text));
    } else {
      sharedPreferences.setInt('plan_number_of_member', 1);
    }

    if (maxMemberWeight != null && maxMemberWeight > 0) {
      setState(() {
        _maxMemberWeightController.text = (maxMemberWeight - 1).toString();
      });
    } else {
      sharedPreferences.setInt('plan_max_member_weight', 1);
    }
    handleChangeComboDate();
  }

  getMaxMemberWeight(int member) {
    if (member <= 3) {
      return 1;
    } else {
      return (member / 3).floor();
    }
  }

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
    }
    setState(() {
      _maxMemberWeight = getMaxMemberWeight(int.parse(_memberController.text));
    });
    if (int.parse(_maxMemberWeightController.text) + 1 > _maxMemberWeight) {
      if (_maxMemberWeight - 1 >= 0) {
        setState(() {
          _maxMemberWeightController.text = (_maxMemberWeight - 1).toString();
        });
      }
      if (widget.isCreate) {
        sharedPreferences.setInt('plan_max_member_weight', _maxMemberWeight);
      } else {
        widget.plan!.maxMemberWeight = _maxMemberWeight;
      }
    }
    if (widget.isCreate) {
      sharedPreferences.setInt(
          'plan_number_of_member', int.parse(_memberController.text));
    } else {
      widget.plan!.maxMemberCount = int.parse(_memberController.text);
    }
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
    if (widget.isCreate) {
      sharedPreferences.setInt('plan_max_member_weight',
          int.parse(_maxMemberWeightController.text) + 1);
    } else {
      widget.plan!.maxMemberWeight =
          int.parse(_maxMemberWeightController.text) + 1;
    }
  }

  handleChangeComboDate() {
    dynamic rs;
    _departureDate = DateTime.parse(sharedPreferences.getString('plan_departureDate')!);
    _departureTime = DateTime.parse(sharedPreferences.getString('plan_departureTime')!);
    if (widget.isCreate) {
      final arrivedTime = Utils().getArrivedTimeFromLocal();
      sharedPreferences.setString('plan_arrivedTime', arrivedTime.toString());
      rs = Utils().getNumOfExpPeriod(
          arrivedTime,
           listComboDate[_selectedCombo].duration.toInt(),
          _departureTime!,
          null,
          true);
    } else {
      rs = Utils().getNumOfExpPeriod(
          null,
          widget.plan!.numOfExpPeriod!,
          widget.plan!.departAt!.toLocal(),
          DateFormat.Hms().parse(widget.plan!.travelDuration!),
          true);
    }

    isOverDate = rs['isOverDate'];
    if (isOverDate!) {
      if (widget.plan == null) {
        sharedPreferences.setString(
            'plan_start_date',
            _departureDate!
                .add(const Duration(days: 1))
                .toString()
                .split(' ')[0]);

        numberOfNight = listComboDate[_selectedCombo].numberOfNight + 1;
        _endDate = _departureDate!
            .add(Duration(days: listComboDate[_selectedCombo].numberOfDay));
      } else {
        widget.plan!.startDate = _departureDate!
            .add(const Duration(days: 1))
            .add(Duration(hours: _departureTime!.hour))
            .add(Duration(minutes: _departureTime!.minute));
      }
    } else {
      if (rs['numOfExpPeriod'] != listComboDate[_selectedCombo].duration.toInt()) {
        setState(() {
          numberOfNight = listComboDate[_selectedCombo].numberOfNight + 1;
        });
        _endDate = _departureDate!
            .add(Duration(days: listComboDate[_selectedCombo].numberOfDay));
      } else {
        setState(() {
          numberOfNight = listComboDate[_selectedCombo].numberOfNight;
        });
        _endDate = _departureDate!
            .add(Duration(days: listComboDate[_selectedCombo].numberOfDay - 1));
      }
      if (widget.plan == null) {
        sharedPreferences.setString(
            'plan_start_date',_departureDate!
                .toString()
                .split(' ')[0]);
      } else {
        widget.plan!.startDate = _departureDate!
            .add(Duration(hours: _departureTime!.hour))
            .add(Duration(minutes: _departureTime!.minute));
      }
    }
    if (widget.plan == null) {
      sharedPreferences.setString(
          'plan_end_date', _endDate.toString().split(' ')[0]);
    } else {
      widget.plan!.endDate = _endDate;
    }

    if (rs['numOfExpPeriod'] != listComboDate[_selectedCombo].duration.toInt()) {
      if (widget.isCreate) {
        sharedPreferences.setInt('numOfExpPeriod', listComboDate[_selectedCombo].numberOfDay + numberOfNight!);
      } else {
        setState(() {
          widget.plan!.numOfExpPeriod = listComboDate[_selectedCombo].numberOfDay + numberOfNight!;
        });
      }
    } else {
      sharedPreferences.setInt(
          'numOfExpPeriod', listComboDate[_selectedCombo].duration.toInt());
    }
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
              _planService.handleShowPlanInformation(
                  context, widget.location, widget.plan);
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
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 3.h, right: 2.w),
          child: Column(
            children: [
              const CreatePlanHeader(
                  stepNumber: 3, stepName: 'Thời gian và số thành viên'),
              const Text(
                'Thời gian trải nghiệm mong muốn',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 2.h,
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
                      height: 250,
                      child: CupertinoPicker(
                          itemExtent: 64,
                          diameterRatio: 0.7,
                          looping: true,
                          scrollController: _scrollController,
                          selectionOverlay:
                              CupertinoPickerDefaultSelectionOverlay(
                                  background: primaryColor.withOpacity(0.12)),
                          onSelectedItemChanged: (value) {
                            if (widget.isCreate) {
                              setState(() {
                                _selectedCombo = value;
                              });
                              sharedPreferences.setInt(
                                  'plan_combo_date', value);
                              sharedPreferences.setInt(
                                  'initNumOfExpPeriod',
                                  listComboDate[value].numberOfDay +
                                      listComboDate[value].numberOfNight);
                            } else {
                              widget.plan!.numOfExpPeriod =
                                  listComboDate[value].duration.toInt();
                            }

                            Future.delayed(
                              const Duration(seconds: 2),
                              () {
                                handleChangeComboDate();
                                setState(() {
                                  _isSelecting = false;
                                });
                              },
                            );
                          },
                          children: Utils.modelBuilder(
                              listComboDate.sublist(0, _maxCombodateIndex),
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
                              border:
                                  Border.all(color: Colors.black38, width: 2),
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
                        if (int.parse(_memberController.text) > 2) {
                          onChangeQuantity("subtract");
                        }
                      },
                      icon: const Icon(Icons.remove)),
                  Container(
                      alignment: Alignment.center,
                      width: 10.h,
                      height: 5.h,
                      child: defaultTextFormField(
                          maxLength: 2,
                          isNumber: true,
                          contentPadding: const EdgeInsets.only(top: 4),
                          onTap: () {
                            setState(() {
                              _isSelecting = false;
                            });
                          },
                          onChange: (value) {
                            if (value == null || value.isEmpty) {
                              sharedPreferences.setInt(
                                  'plan_number_of_member', 2);
                              Fluttertoast.showToast(
                                  msg:
                                      "Số lượng thành viên không được để trống",
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
                                    'plan_number_of_member', 2);
                                Fluttertoast.showToast(
                                    msg: "Số lượng thành viên không hợp lệ",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                    fontSize: 18.0);
                              } else {
                                if (selectedNumber < 2 || selectedNumber > 20) {
                                  sharedPreferences.setInt(
                                      'plan_number_of_member', 2);
                                  Fluttertoast.showToast(
                                      msg: "Số lượng thành viên phải từ 2 - 20",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                      fontSize: 18.0);
                                } else {
                                  sharedPreferences.setInt(
                                      'plan_number_of_member',
                                      int.parse(value));
                                  setState(() {
                                    _maxMemberWeight =
                                        getMaxMemberWeight(int.parse(value));
                                  });
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
              if (_maxMemberWeight != 1)
                const Text(
                  'Số người đi cùng tối đa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              SizedBox(
                height: 2.h,
              ),
              if (_maxMemberWeight != 1)
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
                            isNumber: true,
                            padding: const EdgeInsets.all(16),
                            contentPadding: const EdgeInsets.only(top: 4),
                            onTap: () {
                              setState(() {
                                _isSelecting = false;
                              });
                            },
                            onChange: (value) {
                              if (value == null || value.isEmpty) {
                                sharedPreferences.setInt(
                                    'plan_max_member_weight', 1);
                                Fluttertoast.showToast(
                                    msg:
                                        "Số lượng người đi cùng không được để trống",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                    fontSize: 18.0);
                              } else {
                                var selectedNumber = int.tryParse(
                                    _maxMemberWeightController.text);
                                if (selectedNumber == null) {
                                  sharedPreferences.setInt(
                                      'plan_max_member_weight', 1);
                                  Fluttertoast.showToast(
                                      msg:
                                          "Số lượng người đi cùng không hợp lệ",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                      fontSize: 18.0);
                                } else {
                                  if (selectedNumber < 0 ||
                                      selectedNumber > _maxMemberWeight - 1) {
                                    sharedPreferences.setInt(
                                        'plan_max_member_weight', 1);
                                    Fluttertoast.showToast(
                                        msg:
                                            "Số lượng người đi cùng phải từ 0 - ${_maxMemberWeight - 1}",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.white,
                                        textColor: Colors.black,
                                        fontSize: 18.0);
                                  } else {
                                    sharedPreferences.setInt(
                                        'plan_max_member_weight',
                                        int.parse(value) + 1);
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
                              (int.parse(_memberController.text) / 3).floor()) {
                            onChangeMaxWeightMember('add');
                          }
                        },
                        icon: const Icon(Icons.add)),
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
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 3.h,
            ),
            Text(
              '${listComboDate[_selectedCombo].numberOfDay} ngày $numberOfNight đêm',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              '${DateFormat.Hm().format(_departureTime!)} ${DateFormat('dd/MM/yyyy').format(_departureDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
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
              !isOverDate!
                  ? '${listComboDate[_selectedCombo].numberOfDay} ngày $numberOfNight đêm'
                  : '${listComboDate[_selectedCombo].numberOfDay} ngày ${listComboDate[_selectedCombo].numberOfNight} đêm',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(
              height: 1.h,
            ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: ElevatedButton(
                    style: outlinedButtonStyle,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Quay lại'))),
            SizedBox(
              width: 2.w,
            ),
            Expanded(
              child: ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () async {
                    if (int.tryParse(_memberController.text) == null ||
                        int.parse(_memberController.text) < 1 ||
                        int.parse(_memberController.text) > 20) {
                          DialogStyle().basicDialog(context: context, title: 'Số lượng thành viên tối đa không hợp lệ', type: DialogType.warning);
                    } else if (int.tryParse(_maxMemberWeightController.text) ==
                            null ||
                        int.parse(_maxMemberWeightController.text) < 0 ||
                        int.parse(_maxMemberWeightController.text) >
                            _maxMemberWeight - 1) {
                          DialogStyle().basicDialog(context: context, title: 'Số người đi cùng tối đa không hợp lệ', type: DialogType.warning);
                    } else {
                      if (widget.isClone) {
                        await Utils().updateTempOrder(true, _maxMemberWeight);
                        if ((sharedPreferences.getInt('initNumOfExpPeriod')! /
                                        2)
                                    .ceil() <
                                json
                                    .decode(sharedPreferences
                                        .getString('plan_schedule')!)
                                    .length ||
                            sharedPreferences
                                    .getInt('plan_number_of_member')! !=
                                initMemberCount) {
                          // ignore: use_build_context_synchronously
                          Utils().updateScheduleAndOrder(context, () {
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: SelectEmergencyService(
                                      isCreate: widget.isCreate,
                                      plan: widget.plan,
                                      location: widget.location,
                                      isClone: widget.isClone,
                                    ),
                                    type: PageTransitionType.rightToLeft));
                          }, true);
                        } else {
                          Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              PageTransition(
                                  child: SelectEmergencyService(
                                    isCreate: widget.isCreate,
                                    plan: widget.plan,
                                    location: widget.location,
                                    isClone: widget.isClone,
                                  ),
                                  type: PageTransitionType.rightToLeft));
                        }
                      } else {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: SelectEmergencyService(
                                  isCreate: widget.isCreate,
                                  plan: widget.plan,
                                  location: widget.location,
                                  isClone: widget.isClone,
                                ),
                                type: PageTransitionType.rightToLeft));
                      }
                    }
                  },
                  child: const Text('Tiếp tục')),
            )
          ],
        ),
      ),
    ));
  }
}
