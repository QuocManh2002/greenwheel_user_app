import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class CreateNoteWeightScreen extends StatefulWidget {
  const CreateNoteWeightScreen(
      {super.key,
      required this.locationId,
      required this.orders,
      required this.listSurcharges,
      required this.total,
      required this.locationName});
  final int locationId;
  final String locationName;
  final List<dynamic> orders;
  final double total;
  final List<Map> listSurcharges;

  @override
  State<CreateNoteWeightScreen> createState() => _CreateNoteWeightScreenState();
}

class _CreateNoteWeightScreenState extends State<CreateNoteWeightScreen> {
  TextEditingController _noteController = TextEditingController();
  bool _isSelecting = false;
  late FixedExtentScrollController _scrollController;
  int _selectedWeight = 1;
  List<int> _listAvailableWeight = [];
  OrderService _orderService = OrderService();
  PlanCreate? plan;
  final memberLimit = sharedPreferences.getInt('plan_number_of_member');
  PlanService _planService = PlanService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  // completeService(BuildContext ctx) {
  //   final departureDate =
  //       DateTime.parse(sharedPreferences.getString('plan_departureDate')!);
  //   DateTime _travelDuration = DateTime(0, 0, 0).add(Duration(
  //       seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
  //           .toInt()));
  //   plan = PlanCreate(
  //       numOfExpPeriod: sharedPreferences.getInt('numOfExpPeriod'),
  //       locationId: widget.locationId,
  //       name: sharedPreferences.getString('plan_name'),
  //       latitude: sharedPreferences.getDouble('plan_start_lat')!,
  //       longitude: sharedPreferences.getDouble('plan_start_lng')!,
  //       memberLimit: sharedPreferences.getInt('plan_number_of_member') ?? 1,
  //       savedContacts: sharedPreferences.getString('plan_saved_emergency')!,
  //       startDate:
  //           DateTime.parse(sharedPreferences.getString('plan_start_date')!),
  //       departureDate: departureDate,
  //       schedule: sharedPreferences.getString('plan_schedule'),
  //       endDate: DateTime.parse(sharedPreferences.getString('plan_end_date')!),
  //       travelDuration: DateFormat.Hm().format(_travelDuration),
  //       tempOrders: _orderService.convertTempOrders(widget.orders).toString(),
  //       note: _noteController.text,
  //       weight: _selectedWeight,
  //       gcoinBudget: ((widget.total / memberLimit!) / 100).ceil());
  //   showModalBottomSheet(
  //       backgroundColor: Colors.white.withOpacity(0.94),
  //       context: context,
  //       builder: (ctx) => SizedBox(
  //             height: 75.h,
  //             child: ConfirmPlanBottomSheet(
  //               locationName: widget.locationName,
  //               total: widget.total / 100).toDouble(),
  //               budgetPerCapita:
  //                   ((widget.total / memberLimit!) / 100).ceil().toDouble(),
  //               orderList: widget.orders,
  //               onCompletePlan: onCompletePlan,
  //               plan: plan,
  //               onJoinPlan: () {},
  //               listSurcharges: widget.listSurcharges,
  //               isJoin: false,
  //             ),
  //           ));
  // }

  setUpData() {
    final memberLimit = sharedPreferences.getInt('plan_number_of_member');
    final planWeight = sharedPreferences.getInt('plan_weight');
    final planNote = sharedPreferences.getString('plan_note');
    if (planNote != null) {
      _noteController.text = planNote;
    }
    for (int i = 0; i < memberLimit!; i++) {
      _listAvailableWeight.add(i + 1);
    }
    if (planWeight != null) {
      _scrollController =
          FixedExtentScrollController(initialItem: planWeight - 1);
    } else {
      _scrollController = FixedExtentScrollController(initialItem: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Hoàn tất kế hoạch'),
          leading: BackButton(
            onPressed: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.warning,
                title:
                    'Kế hoạch cho chuyến đi này chưa được hoàn tất, bạn có chắc chắn muốn rời khỏi màn hình này không?',
                titleTextStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                padding: EdgeInsets.symmetric(horizontal: 2.h),
                desc: 'Kế hoạch này sẽ được lưu lại trong phần bản nháp',
                descTextStyle:
                    const TextStyle(fontSize: 14, color: Colors.grey),
                btnOkColor: Colors.amber,
                btnOkText: "Rời khỏi",
                btnCancelColor: Colors.red,
                btnCancelText: "Hủy",
                btnCancelOnPress: () {},
                btnOkOnPress: () async {
                  var rs = true;
                  if (rs) {
                    Utils().clearPlanSharePref();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
              ).show();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Column(children: [
            SizedBox(
              height: 3.h,
            ),
            TextFormFieldWithLength(
              controller: _noteController,
              inputType: TextInputType.text,
              maxLength: 110,
              maxline: 3,
              minline: 3,
              hinttext:
                  'Bạn có muốn thêm ghi chú cho chuyến đi này hay không ?',
              text: 'Ghi chú',
              isAutoFocus: true,
              onChange: (value) {
                if (value != null) {
                  sharedPreferences.setString('plan_note', value);
                }
              },
            ),
            SizedBox(
              height: 2.h,
            ),
            const Text(
              'Số lượng thành viên của nhóm bạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 2.h,
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
                          setState(() {
                            _selectedWeight = value + 1;
                          });
                          sharedPreferences.setInt(
                              'plan_weight', _selectedWeight);
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
                            _listAvailableWeight,
                            (index, model) => Center(
                                  child: Text(
                                    _listAvailableWeight[index].toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: _selectedWeight == index + 1
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _selectedWeight == index + 1
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
                          initialItem: _selectedWeight - 1);
                    },
                    child: Container(
                        width: 30.w,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black38, width: 2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        child: Text(
                          _selectedWeight.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: elevatedButtonStyle.copyWith(
                      foregroundColor:
                          const MaterialStatePropertyAll(primaryColor),
                      backgroundColor:
                          const MaterialStatePropertyAll(Colors.white),
                      shape: const MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              side:
                                  BorderSide(color: primaryColor, width: 2)))),
                  child: const Text('Quay lại'),
                )),
                SizedBox(
                  width: 2.h,
                ),
                Expanded(
                  child: ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () {
                        // completeService(context);
                      },
                      child: const Text('Hoàn tất')),
                ),
              ],
            ),
            SizedBox(
              height: 2.h,
            )
          ]),
        ),
      ),
    );
  }

  onCompletePlan() async {
    // if (widget.isClone) {
    //   AwesomeDialog(
    //     context: context,
    //     dialogType: DialogType.question,
    //     animType: AnimType.leftSlide,
    //     title: 'Bạn có muốn đánh giá cho kế hoạch bạn đã tham khảo không',
    //     titleTextStyle:
    //         const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //     btnOkText: 'Có',
    //     btnOkOnPress: () {},
    //     btnOkColor: Colors.orange,
    //     btnCancelColor: Colors.blue,
    //     btnCancelText: 'Không',
    //     btnCancelOnPress: () {
    //       Utils().clearPlanSharePref();
    //       Navigator.of(context).pop();
    //       Navigator.of(context).pushAndRemoveUntil(
    //         MaterialPageRoute(
    //             builder: (ctx) => const TabScreen(
    //                   pageIndex: 1,
    //                 )),
    //         (route) => false,
    //       );
    //     },
    //   ).show();
    // } else {
    if (memberLimit == 1) {
      Utils().clearPlanSharePref();
      Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (ctx) => const TabScreen(
                  pageIndex: 1,
                )),
        (route) => false,
      );
    } else {
      final rs = await _planService.createNewPlan(
          plan!, context, widget.listSurcharges.toString());
      if (rs != 0) {
        // ignore: use_build_context_synchronously
        AwesomeDialog(
          context: context,
          animType: AnimType.leftSlide,
          dialogType: DialogType.success,
          title: 'Tạo kế hoạch thành công',
          titleTextStyle:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.all(12),
        ).show;
        Future.delayed(
            const Duration(
              seconds: 2,
            ), () {
          Utils().clearPlanSharePref();
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (ctx) => const TabScreen(
                      pageIndex: 1,
                    )),
            (route) => false,
          );
        });
      }
    }
    // }
  }
}
