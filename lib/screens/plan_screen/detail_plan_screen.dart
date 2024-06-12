// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:phuot_app/helpers/util.dart';
import 'package:phuot_app/screens/plan_screen/rating_report_plan.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/plan_statuses.dart';
import '../../core/constants/urls.dart';
import '../../main.dart';
import '../../models/plan_status.dart';
import '../../service/location_service.dart';
import '../../service/order_service.dart';
import '../../service/plan_service.dart';
import '../../service/product_service.dart';
import '../../view_models/location_viewmodels/emergency_contact.dart';
import '../../view_models/order.dart';
import '../../view_models/plan_member.dart';
import '../../view_models/plan_viewmodels/plan_create.dart';
import '../../view_models/plan_viewmodels/plan_detail.dart';
import '../../view_models/product.dart';
import '../../widgets/plan_screen_widget/base_information.dart';
import '../../widgets/plan_screen_widget/clone_plan_options_bottom_sheet.dart';
import '../../widgets/plan_screen_widget/confirm_member_dialog_body.dart';
import '../../widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import '../../widgets/plan_screen_widget/detail_plan_header.dart';
import '../../widgets/plan_screen_widget/detail_plan_service_widget.dart';
import '../../widgets/plan_screen_widget/detail_plan_surcharge_note.dart';
import '../../widgets/plan_screen_widget/plan_join_method_combobox.dart';
import '../../widgets/plan_screen_widget/plan_schedule.dart';
import '../../widgets/plan_screen_widget/tab_icon_button.dart';
import '../../widgets/style_widget/button_style.dart';
import '../../widgets/style_widget/dialog_style.dart';
import '../loading_screen/plan_detail_loading_screen.dart';
import '../main_screen/tabscreen.dart';
import 'create_plan/select_start_location_screen.dart';
import 'join_confirm_plan_screen.dart';
import 'plan_pdf_view_screen.dart';
import 'share_plan_screen.dart';

class DetailPlanNewScreen extends StatefulWidget {
  const DetailPlanNewScreen(
      {super.key,
      required this.planId,
      this.isFromHost,
      this.isClone,
      required this.planType,
      required this.isEnableToJoin});
  final int planId;
  final bool isEnableToJoin;
  final bool? isFromHost;
  final String planType;
  final bool? isClone;

  @override
  State<DetailPlanNewScreen> createState() => _DetailPlanScreenState();
}

class _DetailPlanScreenState extends State<DetailPlanNewScreen>
    with TickerProviderStateMixin {
  bool isLoading = true;
  final PlanService _planService = PlanService();
  final LocationService _locationService = LocationService();
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();
  PlanDetail? _planDetail;
  double _totalOrder = 0;
  int _selectedTab = 0;
  bool _isEnableToInvite = false;
  List<ProductViewModel> products = [];
  List<OrderViewModel>? tempOrders = [];
  bool _isEnableToJoin = false;
  bool isLeader = false;
  bool _isAlreadyJoin = false;
  bool _isEnableToConfirm = false;
  bool _isEnableToRegisterMore = false;
  PlanMemberViewModel? myAccount;
  late PlanStatus status;
  final myId = sharedPreferences.getInt('userId');

  @override
  void initState() {
    super.initState();
    setupData();
    sharedPreferences.setInt('planId', widget.planId);
  }

  setupData() async {
    setState(() {
      isLoading = true;
    });

    _planDetail = null;
    final plan = await _planService.getPlanById(widget.planId, widget.planType);
    List<int> productIds = [];

    if (plan == null ||
        plan.members!.any((member) =>
            member.accountId == myId &&
            member.status == MemberStatus.BLOCKED.name)) {
      DialogStyle().basicDialog(
          context: context,
          title: 'Chuyến đi không tồn tại hoặc không còn khả dụng',
          desc: 'Vui lòng kiểm tra lại thông tin',
          onOk: () {
            Navigator.of(context).pop();
          },
          type: DialogType.warning);
    } else {
      setState(() {
        _planDetail = plan;
        isLoading = false;
        status = planStatuses
            .firstWhere((element) => element.engName == _planDetail!.status!);
      });
      isLeader = myId == _planDetail!.leaderId;
      for (final order in _planDetail!.tempOrders ?? []) {
        for (final detail in order['cart'].entries) {
          if (!productIds.contains(int.parse(detail.key))) {
            productIds.add(int.parse(detail.key));
          }
        }
      }
      products = await _productService.getListProduct(productIds);
      if (tempOrders!.isEmpty) {
        tempOrders = _orderService.convertFromTempOrder(products,
            _planDetail!.tempOrders!, _planDetail!.utcStartAt!.toLocal());
      }
      _planDetail!.tempOrders = tempOrders;
      _isEnableToInvite = _planDetail!.status == planStatuses[1].engName &&
          _planDetail!.memberCount! < _planDetail!.maxMemberCount!;
      _totalOrder =
          _planDetail!.orders!.fold(0, (sum, obj) => sum + obj.total!);
      if (_planDetail != null) {
        setState(() {
          isLoading = false;
        });
      }
      _isEnableToConfirm = _planDetail!.status == planStatuses[1].engName;

      _isAlreadyJoin = _planDetail!.members!.any((element) =>
          element.accountId == myId &&
          element.status == MemberStatus.JOINED.name);
      if (_isAlreadyJoin) {
        myAccount = _planDetail!.members!
            .firstWhere((element) => element.accountId == myId);
        _isEnableToRegisterMore = planStatuses
                    .firstWhere(
                        (element) => element.engName == _planDetail!.status!)
                    .value <
                2 &&
            myAccount!.weight < _planDetail!.maxMemberWeight! &&
            _planDetail!.memberCount! < _planDetail!.maxMemberCount!;
      } else {
        _isEnableToJoin = status.value < 2 &&
            _planDetail!.memberCount! < _planDetail!.maxMemberCount! &&
            !_planDetail!.members!.any((member) =>
                member.accountId == myId &&
                (member.status == MemberStatus.BLOCKED.name ||
                    member.status == MemberStatus.SELF_BLOCKED.name));
      }
    }
  }

  updatePlan() async {
    final location =
        await _locationService.getLocationById(_planDetail!.locationId!);
    if (location != null) {
      PlanCreate plan = PlanCreate(
          surcharges: _planDetail!.surcharges,
          travelDuration: _planDetail!.travelDuration,
          departAt: _planDetail!.utcDepartAt!.toLocal(),
          departAddress: _planDetail!.departureAddress,
          locationId: _planDetail!.locationId,
          locationName: _planDetail!.locationName,
          maxMemberCount: _planDetail!.maxMemberCount,
          maxMemberWeight: _planDetail!.maxMemberWeight,
          name: _planDetail!.name,
          savedContacts: json.encode(_planDetail!.savedContacts!
              .map((e) => EmergencyContactViewModel().toJson(e))
              .toList()),
          note: _planDetail!.note,
          endDate: _planDetail!.utcEndAt!.toLocal(),
          startDate: _planDetail!.utcStartAt!.toLocal(),
          departCoordinate: PointLatLng(
              _planDetail!.startLocationLat!, _planDetail!.startLocationLng!),
          numOfExpPeriod: _planDetail!.numOfExpPeriod,
          savedContactIds: [],
          arrivedAt: _planDetail!.utcStartAt,
          tempOrders: tempOrders,
          schedule: json.encode(_planDetail!.schedule));
      sharedPreferences.setInt('planId', widget.planId);
      Navigator.of(context).pop();
      Navigator.push(
          context,
          PageTransition(
              child: SelectStartLocationScreen(
                isCreate: false,
                location: location,
                plan: plan,
                isClone: false,
              ),
              type: PageTransitionType.rightToLeft));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            floatingActionButton: _planDetail == null ||
                    (_planDetail != null && _planDetail!.memberCount! == 0) ||
                    _planDetail!.joinMethod == JoinMethod.NONE.name
                ? null
                : isLeader
                    ? SpeedDial(
                        animatedIcon: AnimatedIcons.menu_close,
                        backgroundColor: primaryColor.withOpacity(0.9),
                        foregroundColor: Colors.white,
                        activeBackgroundColor: redColor.withOpacity(0.9),
                        children: [
                          if (_isEnableToInvite)
                            SpeedDialChild(
                                child: const Icon(Icons.send),
                                labelStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                label: 'Mời',
                                onTap: _isEnableToInvite ? onInvite : () {},
                                labelBackgroundColor: _isEnableToInvite
                                    ? Colors.blue.withOpacity(0.8)
                                    : Colors.white30,
                                foregroundColor: Colors.white,
                                backgroundColor: _isEnableToInvite
                                    ? Colors.blue
                                    : const Color.fromARGB(97, 15, 7, 7)),
                          if (_isEnableToRegisterMore)
                            SpeedDialChild(
                                child: const Icon(Icons.person_add),
                                labelStyle: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                                label: 'Đăng ký thêm',
                                onTap: () {
                                  confirmJoin(
                                      _planDetail!.joinMethod!, myAccount);
                                },
                                labelBackgroundColor: Colors.pinkAccent,
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.pinkAccent),
                          if (_isEnableToConfirm)
                            SpeedDialChild(
                                child: const Icon(
                                  Icons.check_circle_outline,
                                  size: 30,
                                ),
                                label: 'Chốt',
                                onTap: onConfirmMember,
                                labelStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                labelBackgroundColor:
                                    primaryColor.withOpacity(0.8),
                                foregroundColor: Colors.white,
                                backgroundColor: primaryColor),
                          SpeedDialChild(
                              child: const Icon(Icons.share),
                              labelStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              onTap: () {
                                sharedPreferences.setInt(
                                    'plan_id_pdf', _planDetail!.id!);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) =>
                                        const PlanPdfViewScreen()));
                              },
                              label: 'Chia sẻ',
                              labelBackgroundColor:
                                  Colors.amber.withOpacity(0.8),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.amber),
                          if (_planDetail!.status == planStatuses[3].engName)
                            SpeedDialChild(
                                child: const Icon(Icons.check),
                                labelStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: SizedBox(
                                        height: 10.h,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  var coordinate =
                                      await _planService.getCurrentLocation();
                                  if (coordinate != null) {
                                    final rs = await _planService.verifyPlan(
                                        widget.planId, coordinate, context);
                                    if (rs != null) {
                                      Navigator.of(context).pop();
                                      DialogStyle().successDialog(
                                          context, 'Đã xác nhận kế hoạch');
                                      setupData();
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        Navigator.of(context).pop();
                                      });
                                    }
                                  }
                                },
                                label: 'Xác nhận kế hoạch',
                                labelBackgroundColor:
                                    primaryColor.withOpacity(0.8),
                                foregroundColor: Colors.white,
                                backgroundColor: primaryColor),
                          if (_planDetail!.status == planStatuses[5].engName &&
                              !_planDetail!.isPublished!)
                            SpeedDialChild(
                                child: const Icon(Icons.print),
                                labelStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: SizedBox(
                                        height: 10.h,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  final rs = await _planService.publishPlan(
                                      widget.planId, context);
                                  if (rs != null) {
                                    Navigator.of(context).pop();
                                    DialogStyle().successDialog(
                                        context, 'Đã xuất bản kế hoạch');
                                    setupData();
                                    Future.delayed(const Duration(seconds: 1),
                                        () {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                                label: 'Xuất bản kế hoạch',
                                labelBackgroundColor:
                                    primaryColor.withOpacity(0.8),
                                foregroundColor: Colors.white,
                                backgroundColor: primaryColor),
                        ],
                      )
                    : _isAlreadyJoin && widget.planType != 'PUBLISH'
                        ? FloatingActionButton(
                            shape: const CircleBorder(),
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.share),
                            onPressed: () {
                              sharedPreferences.setInt(
                                  'plan_id_pdf', _planDetail!.id!);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => const PlanPdfViewScreen()));
                            })
                        : null,
            appBar: AppBar(
              title: Text(
                _planDetail != null ? _planDetail!.name! : '',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              leading: BackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.white)),
              ),
              actions: [
                if (_planDetail != null)
                  if ((isLeader &&
                          (_planDetail!.status == planStatuses[0].engName ||
                              _planDetail!.status ==
                                  planStatuses[1].engName)) ||
                      (!isLeader &&
                          _isAlreadyJoin &&
                          _planDetail!.status == planStatuses[1].engName))
                    PopupMenuButton(
                      itemBuilder: (ctx) => [
                        if (isLeader &&
                            _planDetail!.status == planStatuses[0].engName)
                          const PopupMenuItem(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_square,
                                  color: Colors.blueAccent,
                                  size: 32,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Chỉnh sửa',
                                  style: TextStyle(
                                      color: Colors.blueAccent, fontSize: 18),
                                )
                              ],
                            ),
                          ),
                        if (!isLeader &&
                            _isAlreadyJoin &&
                            _planDetail!.status == planStatuses[1].engName)
                          const PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Rời khỏi',
                                  style: TextStyle(
                                      color: Colors.amber, fontSize: 18),
                                )
                              ],
                            ),
                          ),
                        if (isLeader &&
                            (_planDetail!.status == planStatuses[0].engName ||
                                _planDetail!.status == planStatuses[1].engName))
                          const PopupMenuItem(
                            value: 2,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.redAccent,
                                  size: 32,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Huỷ kế hoạch',
                                  style: TextStyle(
                                      color: Colors.redAccent, fontSize: 18),
                                )
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 0:
                            updatePlan();
                            break;
                          case 1:
                            handleQuitPlan();
                            break;
                          case 2:
                            handleCancelPlan();
                            break;
                        }
                      },
                    )
              ],
            ),
            body: isLoading
                ? const PlanDetailLoadingScreen()
                : RefreshIndicator(
                    color: primaryColor,
                    onRefresh: () async {
                      setupData();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              CachedNetworkImage(
                                height: 25.h,
                                width: double.infinity,
                                fit: BoxFit.fill,
                                imageUrl:
                                    '$baseBucketImage${_planDetail!.imageUrls![0]}',
                                placeholder: (context, url) =>
                                    Image.memory(kTransparentImage),
                                errorWidget: (context, url, error) =>
                                    Image.asset(emptyPlan),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: DetailPlanHeader(
                                          isAlreadyJoin: _isAlreadyJoin,
                                          plan: _planDetail!),
                                    ),
                                    if (isLeader &&
                                        (_planDetail!.status ==
                                                planStatuses[0].engName ||
                                            _planDetail!.status ==
                                                planStatuses[1].engName))
                                      PlanJoinMethod(
                                        joinMethod: _planDetail!.joinMethod!,
                                        updateJoinMethod: updateJoinMethod,
                                      ),
                                    if (!isLeader &&
                                        (_planDetail!.status ==
                                                planStatuses[3].engName ||
                                            _planDetail!.status ==
                                                planStatuses[4].engName) &&
                                        myAccount!.reportReason == null)
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  child: RatingReportPlan(
                                                    isRate: false,
                                                    plan: _planDetail!,
                                                    callback: setupData,
                                                  ),
                                                  type: PageTransitionType
                                                      .rightToLeft));
                                        },
                                        child: const Column(
                                          children: [
                                            Icon(
                                              Icons.flag_circle_outlined,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                            Text(
                                              'Báo cáo',
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.red,
                                                  fontFamily: 'NotoSans',
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ),
                                    SizedBox(
                                      width: 2.w,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Container(
                                  height: 1.8,
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                          onTap: () {
                                            setState(() {
                                              _selectedTab = 0;
                                            });
                                          },
                                          child: TabIconButton(
                                            iconDefaultUrl:
                                                basicInformationGreen,
                                            iconSelectedUrl:
                                                basicInformationWhite,
                                            text: 'Thông tin',
                                            isSelected: _selectedTab == 0,
                                            index: 0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                          onTap: () {
                                            setState(() {
                                              _selectedTab = 1;
                                            });
                                          },
                                          child: TabIconButton(
                                            iconDefaultUrl: scheduleGreen,
                                            iconSelectedUrl: scheduleWhite,
                                            text: 'Lịch trình',
                                            isSelected: _selectedTab == 1,
                                            index: 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                          onTap: () {
                                            setState(() {
                                              _selectedTab = 2;
                                            });
                                          },
                                          child: TabIconButton(
                                            iconDefaultUrl: serviceGreen,
                                            iconSelectedUrl: serviceWhite,
                                            text: 'Dịch vụ',
                                            isSelected: _selectedTab == 2,
                                            index: 2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                          onTap: () {
                                            setState(() {
                                              _selectedTab = 3;
                                            });
                                          },
                                          child: TabIconButton(
                                            iconDefaultUrl: surchargeGreen,
                                            iconSelectedUrl: surchargeWhite,
                                            text: 'Phụ thu & ghi chú',
                                            isSelected: _selectedTab == 3,
                                            index: 3,
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                  child: _selectedTab == 2
                                      ? buildServiceWidget()
                                      : _selectedTab == 1
                                          ? buildScheduleWidget()
                                          : _selectedTab == 0
                                              ? buildInforWidget()
                                              : buildSurchagreNoteWidget()),
                              SizedBox(
                                height: 2.h,
                              )
                            ],
                          )),
                        ),
                        if ((!isLeader && _isEnableToJoin) ||
                            (!isLeader &&
                                _isAlreadyJoin &&
                                (_planDetail!.status ==
                                        planStatuses[5].engName ||
                                    _planDetail!.status ==
                                        planStatuses[6].engName)) ||
                            widget.planType == 'PUBLISH')
                          buildNewFooter()
                      ],
                    ),
                  )));
  }

  buildSurchagreNoteWidget() => DetailPlanSurchargeNote(
        plan: _planDetail!,
        isLeader: isLeader,
        totalOrder: _totalOrder,
        isOffline: false,
        onRefreshData: setupData,
      );

  buildServiceWidget() => DetailPlanServiceWidget(
      plan: _planDetail!,
      isLeader: isLeader,
      tempOrders: tempOrders!,
      totalOrder: _totalOrder,
      onGetOrderList: setupData);

  buildInforWidget() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Thông tin cơ bản',
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          BaseInformationWidget(
            plan: _planDetail!,
            refreshData: setupData,
            isLeader: isLeader,
            planType: widget.planType,
            locationLatLng: _planDetail!.locationLatLng!,
          ),
        ],
      );
  buildScheduleWidget() => Column(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24),
              child: const Text(
                "Lịch trình",
                style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 80.h,
            child: PLanScheduleWidget(
              orders: tempOrders,
              planId: widget.planId,
              isLeader: isLeader,
              planType: widget.planType,
              schedule: _planDetail!.schedule!,
              startDate: _planDetail!.utcStartAt!.toLocal(),
              endDate: _planDetail!.utcEndAt!.toLocal(),
            ),
          ),
        ],
      );
  onInvite() async {
    var enableToShare = checkEnableToShare();
    if (enableToShare['status']) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => SharePlanScreen(
                joinMethod: _planDetail!.joinMethod!,
                isFromHost: _planDetail!.leaderId == myId!,
                planId: widget.planId,
              )));
    } else {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text(
                        'Không thể chia sẻ kế hoạch',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans'),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Text(
                        enableToShare['message'],
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans',
                            color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              btnOkColor: Colors.orange,
              btnOkText: 'Ok',
              btnOkOnPress: () {})
          .show();
    }
  }

  onJoinPlan(String joinMethod) async {
    var emerList = [];
    if (_planDetail!.memberCount == _planDetail!.maxMemberCount) {
      DialogStyle().basicDialog(
          context: context,
          title: 'Không thể gia nhập chuyến đi',
          type: DialogType.error,
          btnOkColor: redColor,
          desc: 'Chuyến đi đã đủ số lượng thành viên tham gia');
    } else {
      for (final emer in _planDetail!.savedContacts!) {
        emerList.add({
          "name": emer.name,
          "phone": emer.phone,
          "address": emer.address,
          "imageUrl": emer.imageUrl,
          "type": emer.type
        });
      }
      final rs = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) => SizedBox(
                height: 90.h,
                child: ConfirmPlanBottomSheet(
                  isInfo: false,
                  isFromHost: isLeader,
                  plan: PlanCreate(
                      departAddress: _planDetail!.departureAddress,
                      schedule: json.encode(_planDetail!.schedule),
                      savedContacts: json.encode(emerList),
                      name: _planDetail!.name,
                      maxMemberCount: _planDetail!.maxMemberCount,
                      startDate: _planDetail!.utcStartAt,
                      endDate: _planDetail!.utcEndAt,
                      travelDuration: _planDetail!.travelDuration,
                      departAt: _planDetail!.utcDepartAt!.toLocal(),
                      note: _planDetail!.note,
                      numOfExpPeriod: _planDetail!.numOfExpPeriod),
                  locationName: _planDetail!.locationName!,
                  orderList: tempOrders,
                  onCompletePlan: () {},
                  surchargeList: _planDetail!.surcharges,
                  isJoin: true,
                  onJoinPlan: () {
                    confirmJoin(_planDetail!.joinMethod!, null);
                  },
                  onCancel: () {
                    setState(() {
                      _planDetail!.joinMethod = JoinMethod.NONE.name;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ));
      if (rs == null && isLeader) {
        setState(() {
          _planDetail!.joinMethod = JoinMethod.NONE.name;
        });
      }
    }
  }

  confirmJoin(String joinMethod, PlanMemberViewModel? member) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => JoinConfirmPlanScreen(
              plan: _planDetail!,
              isConfirm: false,
              member: member,
              joinMethod: (isLeader && !_isAlreadyJoin)
                  ? _planDetail!.joinMethod
                  : null,
            )));
  }

  Widget buildNewFooter() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
            alignment: Alignment.center,
            height: 6.h,
            child: ElevatedButton(
              onPressed: () {
                if (widget.planType == 'PUBLISH') {
                  onClonePlan();
                } else {
                  if (!_isAlreadyJoin) {
                    onJoinPlan(_planDetail!.joinMethod!);
                  } else {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: RatingReportPlan(
                                plan: _planDetail!,
                                isRate: true,
                                callback: setupData),
                            type: PageTransitionType.rightToLeft));
                  }
                }
              },
              style: elevatedButtonStyle.copyWith(
                  backgroundColor:
                      const MaterialStatePropertyAll(primaryColor)),
              child: Text(
                widget.planType == 'PUBLISH'
                    ? "Sao chép kế hoạch"
                    : !_isAlreadyJoin
                        ? "Tham gia kế hoạch"
                        : "Đánh giá kế hoạch",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )),
      );

  checkEnableToShare() {
    var enableToShare = {
      'status': true,
      'message': 'Kế hoạch đủ điều kiện để chia sẻ'
    };
    if (_planDetail!.maxMemberCount == _planDetail!.members!.length) {
      return {
        'status': false,
        'message': 'Đã đủ số lượng thành viên của chuyến đi'
      };
    }
    return enableToShare;
  }

  onConfirmMember() async {
    if (_planDetail!.memberCount! < _planDetail!.maxMemberCount!) {
      AwesomeDialog(
              context: context,
              animType: AnimType.bottomSlide,
              dialogType: DialogType.warning,
              body: ConfirmMemberDialogBody(
                plan: _planDetail!,
              ),
              btnOkColor: Colors.amber,
              btnOkOnPress: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: JoinConfirmPlanScreen(
                          callback: callbackConfirmMember,
                          plan: _planDetail!,
                          isConfirm: true,
                        ),
                        type: PageTransitionType.rightToLeft));
              },
              btnOkText: 'Đồng ý',
              btnCancelColor: Colors.blueAccent,
              btnCancelOnPress: () {},
              btnCancelText: 'Huỷ')
          .show();
    } else if (_planDetail!.memberCount == _planDetail!.maxMemberCount) {
      confirmMember();
    }
  }

  confirmMember() async {
    final rs = await _planService.confirmMember(widget.planId, context);
    if (rs != 0) {
      DialogStyle()
          .successDialog(context, 'Đã chốt số lượng thành viên của chuyến đi');
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(context).pop();
        setupData();
      });
    }
  }

  callbackConfirmMember() {
    setupData();
  }

  handleQuitPlan() async {
    bool isBlock = false;
    final systemTime = await Utils().getSystemTime(context);
    final diffDay = systemTime.difference(myAccount!.modifiedAt!).inDays;
    final rfAmount = diffDay == 0
        ? _planDetail!.gcoinBudgetPerCapita
        : _planDetail!.gcoinBudgetPerCapita! *
            (1 -
                (sharedPreferences
                        .getInt('MEMBER_REFUND_SELF_REMOVE_1_DAY_PCT')!) /
                    100);
    AwesomeDialog(
            context: context,
            dialogType: DialogType.question,
            btnOkColor: Colors.deepOrangeAccent,
            btnOkText: 'Rời khỏi',
            btnOkOnPress: () async {
              final rs = await _planService.removeMember(
                  myAccount!.memberId, isBlock, context);
              if (rs != 0) {
                DialogStyle().successDialog(context, 'Đã rời khỏi chuyến đi');
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      PageTransition(
                          child: const TabScreen(pageIndex: 1),
                          type: PageTransitionType.rightToLeft),
                      (route) => false);
                });
              }
            },
            body: StatefulBuilder(
              builder: (context, setState) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      'Rời khỏi "${_planDetail!.name}"',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Divider(
                      color: Colors.grey.withOpacity(0.5),
                      height: 2.h,
                      thickness: 1,
                    ),
                    Row(
                      children: [
                        const Text(
                          'Được hoàn lại:',
                          style:
                              TextStyle(fontSize: 14, fontFamily: 'NotoSans'),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              NumberFormat.simpleCurrency(
                                      decimalDigits: 0,
                                      locale: 'vi_VN',
                                      name: '')
                                  .format(rfAmount),
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NotoSans'),
                            ),
                            SvgPicture.asset(
                              gcoinLogo,
                              height: 20,
                            )
                          ],
                        )
                      ],
                    ),
                    Divider(
                      color: Colors.grey.withOpacity(0.5),
                      height: 2.h,
                      thickness: 1,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: primaryColor,
                          value: isBlock,
                          onChanged: (value) {
                            setState(() {
                              isBlock = !isBlock;
                            });
                          },
                        ),
                        SizedBox(
                          width: 55.w,
                          child: const Text(
                            'Ngăn mọi người mời bạn tham gia lại chuyến đi này',
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                                fontFamily: 'NotoSans',
                                color: Colors.grey,
                                fontSize: 15),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            btnCancelText: 'Huỷ',
            btnCancelColor: Colors.blue,
            btnCancelOnPress: () {})
        .show();
  }

  handleCancelPlan() {
    DialogStyle().basicDialog(
        context: context,
        type: DialogType.question,
        title: 'Bạn có chắc chắn muốn huỷ kế hoạch "${_planDetail!.name}"',
        btnOkColor: Colors.deepOrangeAccent,
        btnOkText: 'Có',
        onOk: onCancelPlan,
        onCancel: () {},
        btnCancelColor: Colors.blue,
        btnCancelText: 'Không');
  }

  onCancelPlan() async {
    int? rs = await _planService.cancelPlan(widget.planId, context);
    if (rs != 0) {
      AwesomeDialog(
              context: context,
              animType: AnimType.leftSlide,
              dialogType: DialogType.info,
              padding: const EdgeInsets.all(12),
              title: 'Đã huỷ kế hoạch "${_planDetail!.name}"',
              titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSans'))
          .show();

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
                child: const TabScreen(pageIndex: 1),
                type: PageTransitionType.rightToLeft),
            (route) => false);
      });
    }
  }

  updateJoinMethod(String joinMethod) async {
    if (_planDetail!.joinMethod != joinMethod) {
      if (!_isAlreadyJoin) {
        await AwesomeDialog(
            context: context,
            animType: AnimType.bottomSlide,
            dialogType: DialogType.info,
            title:
                'Bạn phải tham gia chuyến đi này để có thể công khai chuyến đi',
            titleTextStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            btnOkColor: Colors.blue,
            btnOkOnPress: () {
              setState(() {
                _planDetail!.joinMethod = joinMethod;
              });
              onJoinPlan(_planDetail!.joinMethod!);
            },
            btnOkText: 'Tham gia',
            btnCancelColor: Colors.orange,
            btnCancelText: 'Huỷ',
            onDismissCallback: (type) {
              setState(() {
                _planDetail!.joinMethod = JoinMethod.NONE.name;
              });
            },
            btnCancelOnPress: () {
              setState(() {
                _planDetail!.joinMethod = JoinMethod.NONE.name;
              });
            }).show();
      } else {
        final rs = await _planService.updateJoinMethod(
            _planDetail!.id!, joinMethod, context);
        if (!rs) {
          setState(() {
            _planDetail!.joinMethod = JoinMethod.NONE.name;
          });
        } else {
          _planDetail!.joinMethod = joinMethod;
        }
      }
    }
  }

  onClonePlan() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ClonePlanOptionsBottomSheet(
        plan: _planDetail!,
      ),
    );
  }
}
