// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/plan_statuses.dart';
import '../../core/constants/urls.dart';
import '../../main.dart';
import '../../models/plan_status.dart';
import '../../service/location_service.dart';
import '../../service/plan_service.dart';
import '../../service/product_service.dart';
import '../../service/traveler_service.dart';
import '../../view_models/location_viewmodels/emergency_contact.dart';
import '../../view_models/order.dart';
import '../../view_models/order_detail.dart';
import '../../view_models/plan_member.dart';
import '../../view_models/plan_viewmodels/plan_create.dart';
import '../../view_models/plan_viewmodels/plan_detail.dart';
import '../../view_models/product.dart';
import '../../view_models/supplier.dart';
import '../../widgets/plan_screen_widget/base_information.dart';
import '../../widgets/plan_screen_widget/clone_plan_options_bottom_sheet.dart';
import '../../widgets/plan_screen_widget/confirm_member_dialog_body.dart';
import '../../widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import '../../widgets/plan_screen_widget/detail_plan_header.dart';
import '../../widgets/plan_screen_widget/detail_plan_service_widget.dart';
import '../../widgets/plan_screen_widget/detail_plan_surcharge_note.dart';
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
  final CustomerService _customerService = CustomerService();
  final OrderService _orderService = OrderService();
  PlanDetail? _planDetail;
  List<PlanMemberViewModel> _planMembers = [];
  double _totalOrder = 0;
  int _selectedTab = 0;
  bool _isPublic = false;
  bool _isEnableToInvite = false;
  List<ProductViewModel> products = [];
  List<OrderViewModel>? tempOrders = [];
  List<OrderViewModel> orderList = [];
  bool isLeader = false;
  bool _isAlreadyJoin = false;
  bool _isEnableToConfirm = false;
  bool _isEnableToRegisterMore = false;
  PlanMemberViewModel? myAccount;
  late PlanStatus status;
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
    if (plan != null) {
      setState(() {
        _planDetail = plan;
        isLoading = false;
        status = planStatuses
            .firstWhere((element) => element.engName == _planDetail!.status!);
      });
      isLeader = sharedPreferences.getInt('userId') == _planDetail!.leaderId;
      for (final order in _planDetail!.tempOrders ?? []) {
        for (final detail in order['cart'].entries) {
          if (!productIds.contains(int.parse(detail.key))) {
            productIds.add(int.parse(detail.key));
          }
        }
      }
      products = await _productService.getListProduct(productIds);
      if (tempOrders!.isEmpty) {
        tempOrders = getTempOrder();
      }
      _isPublic = _planDetail!.joinMethod != 'NONE';
      _isEnableToInvite = _planDetail!.status == 'REGISTERING' &&
          _planDetail!.memberCount! < _planDetail!.maxMemberCount!;
      await getOrderList();
      await getPlanMember();
      if (_planDetail != null) {
        setState(() {
          isLoading = false;
        });
      }
      _isEnableToConfirm = _planDetail!.status == 'REGISTERING';
    } else {
      DialogStyle().basicDialog(
          context: context,
          title: 'Không tìm thấy chuyến đi',
          desc: 'Vui lòng kiểm tra lại thông tin',
          onOk: () {
            Navigator.of(context).pop();
          },
          type: DialogType.warning);
    }
  }

  getPlanMember() async {
    final memberList = await _planService.getPlanMember(
        widget.planId, widget.planType, context);
    _planMembers = [];
    for (final mem in memberList) {
      if (mem.status == 'JOINED') {
        int type = 0;
        if (mem.accountId == _planDetail!.leaderId) {
          type = 1;
        } else if (mem.accountId == sharedPreferences.getInt('userId')) {
          type = 2;
        } else {
          type = 3;
        }
        _planMembers.add(PlanMemberViewModel(
            name: mem.name,
            memberId: mem.memberId,
            phone: mem.phone,
            status: mem.status,
            companions: mem.companions,
            accountId: mem.accountId,
            accountType: type,
            isMale: mem.isMale,
            imagePath: mem.imagePath,
            weight: mem.weight));
      }
    }

    _isAlreadyJoin = _planMembers.any((element) =>
        element.accountId == sharedPreferences.getInt('userId')! &&
        element.status == 'JOINED');
    if (_isAlreadyJoin) {
      myAccount = _planMembers.firstWhere((element) =>
          element.accountId == sharedPreferences.getInt('userId')!);
      _isEnableToRegisterMore = planStatuses
                  .firstWhere(
                      (element) => element.engName == _planDetail!.status!)
                  .value <
              2 &&
          myAccount!.weight < _planDetail!.maxMemberWeight! &&
          _planDetail!.memberCount! < _planDetail!.maxMemberCount!;
    }
  }

  getTempOrder() => _planDetail!.tempOrders!.map((e) {
        final Map<String, dynamic> cart = e['cart'];
        ProductViewModel sampleProduct = products.firstWhere(
            (element) => element.id.toString() == cart.entries.first.key);
        List<String> serveDates = [];
        for (final index in e["serveDateIndexes"]) {
          serveDates.add(_planDetail!.utcStartAt!
              .toLocal()
              .add(Duration(days: index))
              .toString()
              .split(' ')[0]);
        }
        return OrderViewModel(
            id: e['id'],
            uuid: e['uuid'],
            details: cart.entries.map((e) {
              final product = products
                  .firstWhere((element) => element.id.toString() == e.key);
              return OrderDetailViewModel(
                  id: product.id,
                  productId: product.id,
                  productName: product.name,
                  price: product.price.toDouble(),
                  isAvailable: product.isAvailable,
                  quantity: e.value);
            }).toList(),
            note: e['note'],
            serveDates: serveDates,
            total: e['totalGcoin'].toDouble(),
            createdAt: DateTime.now(),
            supplier: SupplierViewModel(
                type: sampleProduct.supplierType,
                id: sampleProduct.supplierId!,
                name: sampleProduct.supplierName,
                phone: sampleProduct.supplierPhone,
                thumbnailUrl: sampleProduct.supplierThumbnailUrl,
                isActive: sampleProduct.supplierIsActive,
                address: sampleProduct.supplierAddress),
            type: e['type'],
            period: e['period']);
      }).toList();

  getOrderList() async {
    var totalOrder = 0.0;
    if (_planDetail!.status == planStatuses[0].engName ||
        _planDetail!.status == planStatuses[1].engName) {
      orderList = tempOrders!;
    } else {
      final rs =
          await _orderService.getOrderByPlan(widget.planId, widget.planType);
      if (rs != null) {
        setState(() {
          orderList = rs['orders'];
          _planDetail!.orders = rs['orders'];
          _planDetail!.actualGcoinBudget = rs['currentBudget'].toInt();
        });
      }
    }
    totalOrder = orderList.fold(0, (sum, obj) => sum + obj.total!);
    setState(() {
      _totalOrder = totalOrder;
    });
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
                    _planDetail!.joinMethod == 'NONE'
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
                                  confirmJoin(false, myAccount);
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
                PopupMenuButton(
                  itemBuilder: (ctx) => [
                    if (isLeader && _planDetail!.status == 'PENDING')
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
                        (_planDetail!.status == 'PENDING' ||
                            _planDetail!.status == 'REGISTERING'))
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
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    if (isLeader &&
                        (_planDetail!.status == 'PENDING' ||
                            _planDetail!.status == 'REGISTERING'))
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
                                    DetailPlanHeader(
                                        isAlreadyJoin: _isAlreadyJoin,
                                        plan: _planDetail!),
                                    const Spacer(),
                                    Column(
                                      children: [
                                        if (!widget.isEnableToJoin && isLeader)
                                          CupertinoSwitch(
                                            value: _isPublic,
                                            activeColor: primaryColor,
                                            onChanged: (value) async {
                                              setState(() {
                                                _isPublic = !_isPublic;
                                              });
                                              onPublicizePlan();
                                            },
                                          ),
                                        if (!widget.isEnableToJoin && isLeader)
                                          Text(
                                            _isPublic
                                                ? 'Công khai'
                                                : 'Riêng tư',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'NotoSans',
                                                fontWeight: FontWeight.bold,
                                                color: _isPublic
                                                    ? primaryColor
                                                    : Colors.grey),
                                          ),
                                        SizedBox(
                                          height: 1.h,
                                        ),
                                        if (_isAlreadyJoin &&
                                            (_planDetail!.status ==
                                                    planStatuses[5].engName ||
                                                _planDetail!.status ==
                                                    planStatuses[6].engName))
                                          Column(
                                            children: [
                                              IconButton(
                                                  style: const ButtonStyle(
                                                      shape: MaterialStatePropertyAll(
                                                          CircleBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .red,
                                                                  width: 1)))),
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                    Icons.flag,
                                                    color: Colors.red,
                                                    size: 30,
                                                  )),
                                              const Text(
                                                'Báo cáo',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'NotoSans'),
                                              )
                                            ],
                                          )
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 24,
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
                        if ((widget.isFromHost == null || widget.isFromHost!) &&
                                (widget.isEnableToJoin && !_isAlreadyJoin) &&
                                status.value < 2 ||
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
      orderList: orderList,
      planType: widget.planType,
      totalOrder: _totalOrder,
      onGetOrderList: () async {
        setupData();
      });

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
            members: _planMembers,
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
                isFromHost: _planDetail!.leaderId ==
                    sharedPreferences.getInt('userId')!,
                planMembers: _planMembers,
                isEnableToJoin: widget.isEnableToJoin,
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

  onJoinPlan(bool isPublic) async {
    var emerList = [];
    if (_planDetail!.memberCount == _planDetail!.maxMemberCount) {
      DialogStyle().basicDialog(
          context: context,
          title: 'Không thể gia nhập chuyến đi',
          type: DialogType.error,
          btnOkColor: redColor,
          desc: 'Chuyến đi đã đủ số lượng thành viên tham gia');
    } else {
      final int balance = await _customerService
          .getTravelerBalance(sharedPreferences.getInt('userId')!);
      if (balance >= _planDetail!.gcoinBudgetPerCapita!) {
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
                      departAt: _planDetail!.utcDepartAt,
                      note: _planDetail!.note,
                    ),
                    locationName: _planDetail!.locationName!,
                    orderList: tempOrders,
                    onCompletePlan: () {},
                    surchargeList: _planDetail!.surcharges,
                    isJoin: true,
                    onJoinPlan: () {
                      confirmJoin(isPublic, null);
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _isPublic = false;
                      });
                    },
                  ),
                ));
        if (rs == null) {
          setState(() {
            _isPublic = false;
          });
        }
      } else {
        DialogStyle().basicDialog(
            context: context,
            type: DialogType.error,
            title: 'Số dư của bạn không đủ để tham gia kế hoạch này',
            desc: 'Vui lòng nạp thêm GCOIN',
            btnOkColor: Colors.red,
            onOk: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: const TabScreen(pageIndex: 4),
                      type: PageTransitionType.rightToLeft));
            },
            btnOkText: 'Nạp thêm',
            btnCancelColor: Colors.amber,
            btnCancelText: 'Huỷ');
      }
    }
  }

  confirmJoin(bool isPublic, PlanMemberViewModel? member) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => JoinConfirmPlanScreen(
              plan: _planDetail!,
              isPublic: isPublic,
              isConfirm: false,
              isView: false,
              member: member,
              onPublicizePlan: handlePublicizePlan,
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
                    onJoinPlan(false);
                  }
                }
              },
              style: elevatedButtonStyle.copyWith(
                  backgroundColor: MaterialStatePropertyAll(
                      _isAlreadyJoin && widget.planType != 'PUBLISH'
                          ? Colors.grey
                          : primaryColor)),
              child: Text(
                widget.planType == 'PUBLISH'
                    ? "Sao chép kế hoạch"
                    : "Tham gia kế hoạch",
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
    if (_planDetail!.maxMemberCount == _planMembers.length) {
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
                            isView: false,
                            isPublic: false,
                            isConfirm: true),
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

  handleQuitPlan() {
    bool isBlock = false;
    AwesomeDialog(
            context: context,
            dialogType: DialogType.question,
            btnOkColor: Colors.deepOrangeAccent,
            btnOkText: 'Rời khỏi',
            btnOkOnPress: () {
              onQuitPlan(isBlock);
            },
            body: StatefulBuilder(
              builder: (context, setState) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      'Rời khỏi ${_planDetail!.name}',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 2.h,
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

  onQuitPlan(bool isBlock) async {
    final memberId = _planMembers
        .firstWhere((element) =>
            element.accountId == sharedPreferences.getInt('userId'))
        .memberId;
    final rs = await _planService.removeMember(memberId, isBlock, context);
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

  onPublicizePlan() async {
    if (_planDetail!.memberCount! == 0) {
      final rs = await AwesomeDialog(
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
            onJoinPlan(true);
          },
          btnOkText: 'Tham gia',
          btnCancelColor: Colors.orange,
          btnCancelText: 'Huỷ',
          btnCancelOnPress: () {
            setState(() {
              _isPublic = false;
            });
          }).show();
      if (rs == null) {
        setState(() {
          _isPublic = false;
        });
      }
    } else {
      if (_planDetail!.joinMethod == 'NONE') {
        handlePublicizePlan(false, null, context);
      } else {
        final rs = await _planService.updateJoinMethod(
            _planDetail!.id!, 'NONE', context);
        if (rs) {
          setState(() {
            _planDetail!.joinMethod = 'NONE';
          });
        }
      }
    }
  }

  handlePublicizePlan(
      bool isFromJoinScreen, int? amount, BuildContext buildContext) {
    showModalBottomSheet(
        context: buildContext,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.white.withOpacity(0.94),
        builder: (ctx) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Cách chia sẻ chuyến đi',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans'),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        onTap: () async {
                          final rs = await _planService.updateJoinMethod(
                              _planDetail!.id!, 'INVITE', context);
                          if (rs) {
                            setState(() {
                              _planDetail!.joinMethod = 'INVITE';
                            });
                            Navigator.of(buildContext).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.withOpacity(0.7)),
                                padding: const EdgeInsets.all(10),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Mời',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      )),
                      SizedBox(
                        width: 2.h,
                      ),
                      Expanded(
                          child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        onTap: () async {
                          final rs = await _planService.updateJoinMethod(
                              _planDetail!.id!, 'SCAN', buildContext);
                          if (rs) {
                            setState(() {
                              _planDetail!.joinMethod = 'SCAN';
                            });
                            Navigator.of(buildContext).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.orange.withOpacity(0.7)),
                                padding: const EdgeInsets.all(10),
                                child: const Icon(
                                  Icons.qr_code,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'QR',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ));
  }

  // handleHistoryOrder() {
  //   Navigator.push(
  //       context,
  //       PageTransition(
  //           child: HistoryOrderScreen(
  //             planId: widget.planId,
  //           ),
  //           type: PageTransitionType.rightToLeft));
  // }

  onClonePlan() async {
    _planDetail!.orders = orderList;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ClonePlanOptionsBottomSheet(
        plan: _planDetail!,
      ),
    );
  }
}
