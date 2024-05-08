import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/select_start_location_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/craete_plan_header.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

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
  final TextEditingController _maxMemberWeightController = TextEditingController();
  int maxMemberWeight = 1;
  final PlanService _planService = PlanService();
  bool isShowDialog = false;
  int initMemberCount = 0;

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
    maxMemberWeight = getMaxMemberWeight(int.parse(_memberController.text));
  }

  setUpDataCreate() async {
    initMemberCount = sharedPreferences.getInt('plan_number_of_member') ?? 2;
    int? member = sharedPreferences.getInt('plan_number_of_member');
    int? numOfExpPeriod = sharedPreferences.getInt('initNumOfExpPeriod');
    int? _maxMemberWeight = sharedPreferences.getInt('plan_max_member_weight');
    ComboDate selectedComboDate;
    _memberController.text = GlobalConstant().PLAN_MIN_MEMBER_COUNT.toString();
    _maxMemberWeightController.text = '0';
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
      maxMemberWeight = getMaxMemberWeight(int.parse(_memberController.text));
    } else {
      sharedPreferences.setInt('plan_number_of_member', 1);
    }

    if (_maxMemberWeight != null && _maxMemberWeight > 0) {
      setState(() {
        _maxMemberWeightController.text = (_maxMemberWeight - 1).toString();
      });
    } else {
      sharedPreferences.setInt('plan_max_member_weight', 1);
    }
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
      maxMemberWeight = getMaxMemberWeight(int.parse(_memberController.text));
    });
    if (int.parse(_maxMemberWeightController.text) + 1 > maxMemberWeight) {
      if (maxMemberWeight - 1 >= 0) {
        setState(() {
          _maxMemberWeightController.text = (maxMemberWeight - 1).toString();
        });
      }
      if (widget.isCreate) {
        sharedPreferences.setInt('plan_max_member_weight', maxMemberWeight);
      } else {
        widget.plan!.maxMemberWeight = maxMemberWeight;
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
                  stepNumber: 1, stepName: 'Thời gian và số thành viên'),
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
                      height: 320,
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
                                  listComboDate[value].numberOfDay +
                                      listComboDate[value].numberOfNight;
                            }

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
                                    maxMemberWeight =
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
              if (maxMemberWeight != 1)
                const Text(
                  'Số người đi cùng tối đa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              SizedBox(
                height: 2.h,
              ),
              if (maxMemberWeight != 1)
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
                                      selectedNumber > maxMemberWeight - 1) {
                                    sharedPreferences.setInt(
                                        'plan_max_member_weight', 1);
                                    Fluttertoast.showToast(
                                        msg:
                                            "Số lượng người đi cùng phải từ 0 - ${maxMemberWeight - 1}",
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () {
                  if (int.tryParse(_memberController.text) == null ||
                      int.parse(_memberController.text) < 1 ||
                      int.parse(_memberController.text) > 20) {
                    AwesomeDialog(
                            context: context,
                            animType: AnimType.leftSlide,
                            dialogType: DialogType.warning,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            title: 'Số lượng thành viên tối đa không hợp lệ',
                            titleTextStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSans'),
                            btnOkColor: Colors.amber,
                            btnOkOnPress: () {},
                            btnOkText: 'OK')
                        .show();
                  } else if (int.tryParse(_maxMemberWeightController.text) ==
                          null ||
                      int.parse(_maxMemberWeightController.text) < 0 ||
                      int.parse(_maxMemberWeightController.text) >
                          maxMemberWeight - 1) {
                    AwesomeDialog(
                            context: context,
                            animType: AnimType.leftSlide,
                            dialogType: DialogType.warning,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            title: 'Số người đi cùng tối đa không hợp lệ',
                            titleTextStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSans'),
                            btnOkColor: Colors.amber,
                            btnOkOnPress: () {},
                            btnOkText: 'OK')
                        .show();
                  } else {
                    if (widget.isClone) {
                      Utils().updateTempOrder(true);
                    }

                    if (widget.isClone) {
                      if ((sharedPreferences.getInt('initNumOfExpPeriod')! / 2)
                                  .ceil() <
                              json
                                  .decode(sharedPreferences
                                      .getString('plan_schedule')!)
                                  .length || sharedPreferences.getInt('plan_number_of_member')! != initMemberCount) {
                        Utils().updateScheduleAndOrder(context, () {
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: SelectStartLocationScreen(
                                    isCreate: widget.isCreate,
                                    plan: widget.plan,
                                    location: widget.location,
                                    isClone: widget.isClone,
                                  ),
                                  type: PageTransitionType.rightToLeft));
                        }, false);
                      } else {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: SelectStartLocationScreen(
                                  isCreate: widget.isCreate,
                                  plan: widget.plan,
                                  location: widget.location,
                                  isClone: widget.isClone,
                                ),
                                type: PageTransitionType.rightToLeft));
                      }
                    }

                    if (!widget.isClone) {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: SelectStartLocationScreen(
                                isCreate: widget.isCreate,
                                plan: widget.plan,
                                location: widget.location,
                                isClone: widget.isClone,
                              ),
                              type: PageTransitionType.rightToLeft));
                    }
                  }
                },
                child: const Text('Tiếp tục'))
          ],
        ),
      ),
    ));
  }
}
