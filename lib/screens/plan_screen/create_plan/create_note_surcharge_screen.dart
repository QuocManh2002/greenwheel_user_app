// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/create_plan_surcharge.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/surcharge.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/craete_plan_header.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/surcharge_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/dialog_style.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class CreateNoteSurchargeScreen extends StatefulWidget {
  const CreateNoteSurchargeScreen(
      {super.key,
      this.orderList,
      required this.location,
      this.plan,
      required this.isCreate,
      required this.isClone,
      required this.totalService});
  final List<dynamic>? orderList;
  final LocationViewModel location;
  final double totalService;
  final PlanCreate? plan;
  final bool isCreate;
  final bool isClone;

  @override
  State<CreateNoteSurchargeScreen> createState() =>
      _CreateNoteSurchargeScreenState();
}

class _CreateNoteSurchargeScreenState extends State<CreateNoteSurchargeScreen> {
  int _selectedIndex = 0;
  HtmlEditorController controller = HtmlEditorController();
  List<dynamic> _listSurchargeObjects = [];
  double _totalSurcharge = 0;
  List<Widget> _listSurcharges = [];
  final PlanService _planService = PlanService();
  int? memberLimit;
  PlanCreate? _plan;
  bool _isAvailableToOrder = false;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() {
    if (widget.plan == null) {
      memberLimit = sharedPreferences.getInt('plan_number_of_member');
    } else {
      memberLimit = widget.plan!.maxMemberCount;
    }
    callbackSurcharge(null);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lên kế hoạch'),
        leading: BackButton(
          onPressed: () {
            _planService.handleQuitCreatePlanScreen(() {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
          ),
          if (_selectedIndex == 0)
            IconButton(
                onPressed: () {
                  if (_listSurcharges.length == 10) {
                    DialogStyle().basicDialog(
                      context: context,
                      title:
                          'Chỉ được tạo tối đa ${GlobalConstant().PLAN_SURCHARGE_MAX_COUNT}',
                      type: DialogType.warning,
                    );
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => CreatePlanSurcharge(
                              callback: callbackSurcharge,
                              isCreate: true,
                            )));
                  }
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
        padding: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 3.h),
        child: Column(
          children: [
            const CreatePlanHeader(
                stepNumber: 6, stepName: 'Phụ thu & ghi chú'),
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
                    height: 55.h,
                    child: _listSurcharges.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20.h,
                              ),
                              Image.asset(
                                emptyPlan,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
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
                              locale: 'vi_VN', decimalDigits: 0, name: '')
                          .format(_totalSurcharge),
                      style: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SvgPicture.asset(
                      gcoinLogo,
                      height: 18,
                    )
                  ],
                ),
              ),
            if (_selectedIndex == 0 && _totalSurcharge != 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Text(
                      'Bình quân: ',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSans'),
                    ),
                    const Spacer(),
                    Text(
                      NumberFormat.simpleCurrency(
                              locale: 'vi_VN', decimalDigits: 0, name: '')
                          .format(_totalSurcharge / memberLimit!),
                      style: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SvgPicture.asset(
                      gcoinLogo,
                      height: 18,
                    )
                  ],
                ),
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
                completeService();
              },
              child: const Text('Tiếp tục'),
            )),
          ],
        ),
      ),
    ));
  }

  saveNote() async {}

  callbackSurcharge(dynamic surcharge) {
    List<Widget> listSurcharges = [];
    _listSurchargeObjects = [];
    _totalSurcharge = 0;

    final surcharges = widget.plan == null
        ? json.decode(sharedPreferences.getString('plan_surcharge') ?? '[]')
        : widget.plan!.surcharges!;
    _listSurchargeObjects = surcharges
        .map((e) => {
              'gcoinAmount': e.runtimeType == SurchargeViewModel
                  ? e.alreadyDivided
                      ? e.amount
                      : (e.amount / memberLimit).ceil()
                  : e['alreadyDivided'] ?? true
                      ? e['gcoinAmount']
                      : (e['gcoinAmount'] / memberLimit).ceil(),
              'note': e.runtimeType == SurchargeViewModel
                  ? json.encode(e.note)
                  : e['note'],
            })
        .toList();
    for (final sur in surcharges) {
      listSurcharges.add(SurchargeCard(
        isLeader: null,
        maxMemberCount: widget.plan == null
            ? sharedPreferences.getInt('plan_number_of_member')!
            : widget.plan!.maxMemberCount!,
        isEnableToUpdate: true,
        isCreate: true,
        surcharge: sur.runtimeType == SurchargeViewModel
            ? sur
            : SurchargeViewModel.fromJsonLocal(sur),
        callbackSurcharge: callbackSurcharge,
      ));
      if (sur.runtimeType == SurchargeViewModel) {
        if (sur.alreadyDivided) {
          _totalSurcharge += sur.amount * memberLimit;
        } else {
          _totalSurcharge += sur.amount;
        }
      } else {
        if (sur['alreadyDivided'] ?? true) {
          _totalSurcharge += sur['gcoinAmount'] * memberLimit;
        } else {
          _totalSurcharge += sur['gcoinAmount'];
        }
      }
    }

    setState(() {
      _listSurcharges = listSurcharges;
    });
  }

  completeService() async {
    dynamic rs;
    if (widget.plan == null) {
      DateTime departureDate =
          DateTime.parse(sharedPreferences.getString('plan_departureDate')!);
      final departureTime =
          DateTime.parse(sharedPreferences.getString('plan_departureTime')!);
      departureDate =
          DateTime(departureDate.year, departureDate.month, departureDate.day)
              .add(Duration(hours: departureTime.hour))
              .add(Duration(minutes: departureTime.minute));
      DateTime travelDuration = DateTime(0, 0, 0).add(Duration(
          seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
              .toInt()));
      rs = json.decode(sharedPreferences.getString('plan_temp_order') ?? '[]');

      _plan = PlanCreate(
        tempOrders: rs,
        departAddress: sharedPreferences.getString('plan_start_address'),
        numOfExpPeriod: sharedPreferences.getInt('initNumOfExpPeriod'),
        locationId: widget.location.id,
        name: sharedPreferences.getString('plan_name'),
        departCoordinate: PointLatLng(
            sharedPreferences.getDouble('plan_start_lat')!,
            sharedPreferences.getDouble('plan_start_lng')!),
        maxMemberCount: sharedPreferences.getInt('plan_number_of_member') ?? 1,
        savedContacts: sharedPreferences.getString('plan_saved_emergency')!,
        startDate:
            DateTime.parse(sharedPreferences.getString('plan_start_date')!),
        departAt: departureDate,
        schedule: sharedPreferences.getString('plan_schedule'),
        endDate: DateTime.parse(sharedPreferences.getString('plan_end_date')!),
        travelDuration: DateFormat.Hm().format(travelDuration),
        note: sharedPreferences.getString('plan_note'),
        maxMemberWeight: sharedPreferences.getInt('plan_max_member_weight'),
      );
    }
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
                orderList: rs,
                onCompletePlan: onCompletePlan,
                plan: widget.plan ?? _plan,
                onJoinPlan: () {},
                listSurcharges: _listSurchargeObjects,
                isJoin: false,
              ),
            ));
  }

  onCompletePlan() async {
    int? rs;
    if (widget.plan == null) {
      final departDate =
          DateTime.parse(sharedPreferences.getString('plan_departureDate')!);
      final departTime =
          DateTime.parse(sharedPreferences.getString('plan_departureTime')!);
      _isAvailableToOrder = DateTime(departDate.year, departDate.month,
              departDate.day, departTime.hour, departTime.minute)
          .isAfter(DateTime.now().add(const Duration(days: 7)));
      if (_isAvailableToOrder) {
        if (widget.isClone) {
          rs = await _planService.clonePlan(
              _plan!, context, _listSurchargeObjects.toString());
        } else {
          rs = await _planService.createNewPlan(
              _plan!, context, _listSurchargeObjects.toString());
        }
      } else {
        rs = 1;
      }
    } else {
      rs = await _planService.updatePlan(
          widget.plan!, json.encode(_listSurchargeObjects), context);
    }

    if (rs != 0) {
      Navigator.of(context).pop();
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        dialogType: DialogType.success,
        title: widget.plan == null
            ? widget.isClone
                ? 'Sao chép kế hoạch thành công'
                : 'Tạo kế hoạch thành công'
            : 'Cập nhật kế hoạch thành công',
        titleTextStyle:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.all(12),
      ).show();
      Future.delayed(
          const Duration(
            seconds: 2,
          ), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => const TabScreen(pageIndex: 1)),
            (route) => false);

        if (_isAvailableToOrder) {
          Utils().clearPlanSharePref();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => DetailPlanNewScreen(
                    planId: rs!,
                    isEnableToJoin: false,
                    planType: "OWNED",
                  )));
        }
      });
    }
  }
}
