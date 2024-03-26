import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan_surcharge.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_new_screen.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/surcharge_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class CreateNoteSurchargeScreen extends StatefulWidget {
  const CreateNoteSurchargeScreen({super.key, this.orderList, required this.location, required this.totalService});
  final List<dynamic>? orderList;
  final LocationViewModel location;
  final double totalService;

  @override
  State<CreateNoteSurchargeScreen> createState() =>
      _CreateNoteSurchargeScreenState();
}

class _CreateNoteSurchargeScreenState extends State<CreateNoteSurchargeScreen> {
  int _selectedIndex = 0;
  HtmlEditorController controller = HtmlEditorController();
  List<Map> _listSurchargeObjects = [];
  double _totalSurcharge = 0;
  List<Widget> _listSurcharges = [];
  PlanCreate? plan;
  PlanService _planService = PlanService();
  OrderService _orderService = OrderService();
  int memberLimit = sharedPreferences.getInt('plan_number_of_member')!;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() {
    callbackSurcharge();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: lightPrimaryTextColor,
      appBar: AppBar(
        title: const Text('Ghi chú và phụ thu'),
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
                  }
                },
              ).show();
            },
          ),
        actions: [
          InkWell(
              onTap: () {
                DateTime? _travelDuration =
                    sharedPreferences.getDouble('plan_duration_value') != null
                        ? DateTime(0, 0, 0).add(Duration(
                            seconds: (sharedPreferences
                                        .getDouble('plan_duration_value')! *
                                    3600)
                                .toInt()))
                        : null;
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) => SizedBox(
                          height: 80.h,
                          child: ConfirmPlanBottomSheet(
                            isFromHost: false,
                            isJoin: false,
                            locationName: widget.location.name,
                            isInfo: true,
                            orderList: widget.orderList,
                            listSurcharges: json.decode(
                                sharedPreferences.getString('plan_surcharge') ??
                                    "[]"),
                            plan: PlanCreate(
                                startDate: DateTime.parse(sharedPreferences
                                    .getString('plan_start_date')!),
                                endDate:
                                    sharedPreferences.getString('plan_end_date') == null
                                        ? null
                                        : DateTime.parse(sharedPreferences
                                            .getString('plan_end_date')!),
                                memberLimit: sharedPreferences
                                    .getInt('plan_number_of_member'),
                                departureDate:
                                    sharedPreferences.getString('plan_departureDate') == null
                                        ? null
                                        : DateTime.parse(sharedPreferences
                                            .getString('plan_departureDate')!),
                                name: sharedPreferences.getString('plan_name'),
                                schedule: sharedPreferences
                                    .getString('plan_schedule'),
                                note: sharedPreferences.getString('plan_note'),
                                savedContacts: sharedPreferences
                                    .getString('plan_saved_emergency'),
                                travelDuration: _travelDuration == null ? null : DateFormat.Hm().format(_travelDuration)),
                          ),
                        ));
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
            ),
          if (_selectedIndex == 0)
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => CreatePlanSurcharge(
                            callback: callbackSurcharge,
                          )));
                },
                icon: const Icon(
                  Icons.add,
                  size: 30,
                )),
          SizedBox(
            width: 2.w,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          children: [
            Container(
              width: 100.w,
              height: 7.h,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  color: primaryColor.withOpacity(0.5),
                  offset: const Offset(1, 3),
                )
              ], borderRadius: const BorderRadius.all(Radius.circular(12))),
              child: Row(
                children: [
                  Expanded(
                      child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      saveNote();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedIndex == 0
                            ? primaryColor.withOpacity(0.6)
                            : Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: _selectedIndex == 0
                                ? Colors.white
                                : primaryColor,
                            size: 25,
                          ),
                          SizedBox(
                            height: 0.5.h,
                          ),
                          Text(
                            'Phụ thu',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: _selectedIndex == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedIndex == 0
                                    ? Colors.white
                                    : primaryColor,
                                fontFamily: 'NotoSans'),
                          ),
                        ],
                      ),
                    ),
                  )),
                  Expanded(
                      child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedIndex == 1
                            ? primaryColor.withOpacity(0.6)
                            : Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            color: _selectedIndex == 1
                                ? Colors.white
                                : primaryColor,
                            size: 25,
                          ),
                          SizedBox(
                            height: 0.5.h,
                          ),
                          Text(
                            'Ghi chú',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: _selectedIndex == 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedIndex == 1
                                    ? Colors.white
                                    : primaryColor,
                                fontFamily: 'NotoSans'),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            _selectedIndex == 0
                ? SizedBox(
                    height: 65.h,
                    child: _listSurcharges.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20.h,
                              ),
                              Image.asset(
                                empty_plan,
                                height: 30.h,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              const Text(
                                'Chuyến đi này chưa có phụ thu',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontFamily: 'NotoSans'),
                              )
                            ],
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                for (final sur in _listSurcharges) sur,
                              ],
                            ),
                          ),
                  )
                : Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.5), width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    clipBehavior: Clip.hardEdge,
                    padding: const EdgeInsets.all(8),
                    child: HtmlEditor(
                      key: UniqueKey(),
                      controller: controller,
                      callbacks: Callbacks(
                        onChangeContent: (p0) async {
                          final rs = await controller.getText();
                          sharedPreferences.setString('plan_note', rs);
                        },
                      ),
                      otherOptions: OtherOptions(
                        height: 100.h,
                      ),
                      htmlEditorOptions: HtmlEditorOptions(
                          inputType: HtmlInputType.text,
                          initialText:
                              sharedPreferences.getString('plan_note')),
                      htmlToolbarOptions: const HtmlToolbarOptions(
                          toolbarType: ToolbarType.nativeExpandable),
                    ),
                  ),
            const Spacer(),
            if (_selectedIndex == 0 && _totalSurcharge != 0)
              Row(
                children: [
                  const Text(
                    'Tổng cộng: ',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans'),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.simpleCurrency(
                            locale: 'vi_VN', decimalDigits: 0, name: 'đ')
                        .format(_totalSurcharge),
                    style: const TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (_selectedIndex == 0 && _totalSurcharge != 0)
              Row(
                children: [
                  const Text(
                    'Chi phí bình quân: ',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans'),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.simpleCurrency(
                            locale: 'vi_VN', decimalDigits: 0, name: 'đ')
                        .format(_totalSurcharge /
                            memberLimit),
                    style: const TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            SizedBox(
              height: 1.h,
            ),
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
                  width: 1.h,
                ),
                Expanded(
                  child: ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () {
                        completeService();
                      },
                      child: const Text('Tiếp tục')),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  saveNote() async {}

  callbackSurcharge() {
    String? surchargeText = sharedPreferences.getString('plan_surcharge');
    List<Widget> listSurcharges = [];
    _listSurchargeObjects = [];
    _totalSurcharge = 0;
    if (surchargeText != null) {
      final surcharges = json.decode(surchargeText);
      for (final sur in surcharges) {
        listSurcharges.add(SurchargeCard(
            amount: sur['amount'], note: json.decode(sur['note'])));
        _totalSurcharge += sur['amount'];
        _listSurchargeObjects.add(sur);
      }
    }
    setState(() {
      _listSurcharges = listSurcharges;
    });
    sharedPreferences.setString(
        'plan_surcharge', json.encode(_listSurchargeObjects));
  }

  completeService() {
    DateTime departureDate =
        DateTime.parse(sharedPreferences.getString('plan_departureDate')!);
    final departureTime =
        DateTime.parse(sharedPreferences.getString('plan_start_time')!);
    departureDate =
        DateTime(departureDate.year, departureDate.month, departureDate.day)
            .add(Duration(hours: departureTime.hour))
            .add(Duration(minutes: departureTime.minute));
    DateTime _travelDuration = DateTime(0, 0, 0).add(Duration(
        seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
            .toInt()));
    plan = PlanCreate(
        departureAddress: sharedPreferences.getString('plan_start_address'),
        numOfExpPeriod: sharedPreferences.getInt('numOfExpPeriod'),
        locationId: widget.location.id,
        name: sharedPreferences.getString('plan_name'),
        latitude: sharedPreferences.getDouble('plan_start_lat')!,
        longitude: sharedPreferences.getDouble('plan_start_lng')!,
        memberLimit: sharedPreferences.getInt('plan_number_of_member') ?? 1,
        savedContacts: sharedPreferences.getString('plan_saved_emergency')!,
        startDate:
            DateTime.parse(sharedPreferences.getString('plan_start_date')!),
        departureDate: departureDate,
        schedule: sharedPreferences.getString('plan_schedule'),
        endDate: DateTime.parse(sharedPreferences.getString('plan_end_date')!),
        travelDuration: DateFormat.Hm().format(_travelDuration),
        tempOrders: _orderService.convertTempOrders(widget.orderList!).toString(),
        note: sharedPreferences.getString('plan_note'),
        maxMemberWeight: sharedPreferences.getInt('plan_max_member_weight'),
        gcoinBudget: (((widget.totalService + _totalSurcharge * 100) / memberLimit) / 100).ceil());
    showModalBottomSheet(
        backgroundColor: Colors.white.withOpacity(0.94),
        context: context,
        isScrollControlled: true,
        builder: (ctx) => SizedBox(
              height: 90.h,
              child: ConfirmPlanBottomSheet(
                isFromHost: false,
                isInfo: false,
                locationName: widget.location.name,
                orderList: widget.orderList!,
                onCompletePlan: onCompletePlan,
                plan: plan,
                onJoinPlan: () {},
                listSurcharges: _listSurchargeObjects,
                isJoin: false,
              ),
            ));
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
          plan!, context, _listSurchargeObjects.toString());
      if (rs != 0) {
        await AwesomeDialog(
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
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (ctx) => const TabScreen(pageIndex: 1)),
              (route) => false);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) =>
                  DetailPlanNewScreen(planId: rs, isEnableToJoin: false)));
        });
      }
    }
    // }
  }
}
