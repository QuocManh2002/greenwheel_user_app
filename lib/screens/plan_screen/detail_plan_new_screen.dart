// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/loading_screen/plan_detail_loading_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/payment_screen/success_payment_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_new_plan_screen.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/detail_plan_surcharge_note.dart';
import 'package:greenwheel_user_app/screens/plan_screen/join_confirm_plan_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/plan_pdf_view_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/share_plan_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/service/product_service.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/base_information.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/detail_plan_service_widget.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/tab_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../widgets/style_widget/button_style.dart';

class DetailPlanNewScreen extends StatefulWidget {
  const DetailPlanNewScreen(
      {super.key,
      required this.planId,
      this.isFromHost,
      required this.planType,
      required this.isEnableToJoin});
  final int planId;
  final bool isEnableToJoin;
  final bool? isFromHost;
  final String planType;

  @override
  State<DetailPlanNewScreen> createState() => _DetailPlanScreenState();
}

class _DetailPlanScreenState extends State<DetailPlanNewScreen>
    with TickerProviderStateMixin {
  bool isLoading = true;
  PlanService _planService = PlanService();
  LocationService _locationService = LocationService();
  ProductService _productService = ProductService();
  PlanDetail? _planDetail;
  late TabController tabController;
  List<PlanMemberViewModel> _planMembers = [];
  double total = 0;
  int _selectedTab = 0;
  bool _isPublic = false;
  bool _isEnableToInvite = false;
  bool _isEnableToOrder = false;
  List<ProductViewModel> products = [];
  List<OrderViewModel> tempOrders = [];
  List<OrderViewModel> orderList = [];
  bool isLeader = false;
  Widget? activeWidget;
  List<int> availableWeight = [];
  bool _isAlreadyJoin = false;
  var currencyFormat =
      NumberFormat.simpleCurrency(locale: 'vi_VN', name: '', decimalDigits: 0);
  bool _isEnableToConfirm = false;
  String comboDateText = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupData();
    sharedPreferences.setInt('planId', widget.planId);
  }

  setupData() async {
    setState(() {
      isLoading = true;
    });
    _planDetail = null;
    final plan = await _planService.GetPlanById(widget.planId, widget.planType);
    List<int> productIds = [];
    if (plan != null) {
      setState(() {
        _planDetail = plan;
        isLoading = false;
      });
      for (final order in _planDetail!.tempOrders!) {
        Map<String, dynamic> cart = order['cart'];
        for (final proId in cart.keys.toList()) {
          if (!productIds.contains(proId)) {
            productIds.add(int.parse(proId));
          }
        }
      }
      isLeader = sharedPreferences.getInt('userId') == _planDetail!.leaderId;
      tabController = TabController(length: 3, vsync: this, initialIndex: 0);
      for (int i = 0;
          i < _planDetail!.maxMemberCount - _planDetail!.memberCount!;
          i++) {
        availableWeight.add(i + 1);
      }
      products = await _productService.getListProduct(productIds);
      tempOrders = await getTempOrder();
      _isPublic = _planDetail!.joinMethod != 'NONE';
      _isEnableToInvite = _planDetail!.status == 'REGISTERING';
      getOrderList();
      await getPlanMember();
      if (_planDetail != null) {
        setState(() {
          isLoading = false;
        });
      }
      _isEnableToConfirm = _planDetail!.status != 'READY';
    }
    var tempDuration = DateFormat.Hm().parse(_planDetail!.travelDuration!);
    final startTime = DateTime(0, 0, 0, _planDetail!.departTime!.hour,
        _planDetail!.departTime!.minute, 0);
    final arrivedTime = startTime
        .add(Duration(hours: tempDuration.hour))
        .add(Duration(minutes: tempDuration.minute));
    var cmd;
    if (arrivedTime.isAfter(DateTime(0, 0, 0, 16, 0)) &&
        arrivedTime.isBefore(DateTime(0, 0, 1, 6, 0))) {
      cmd = listComboDate.firstWhere(
          (element) => element.duration == _planDetail!.numOfExpPeriod - 1);
      comboDateText = '${cmd.numberOfDay} ngày ${cmd.numberOfNight + 1} đêm';
    } else {
      cmd = listComboDate.firstWhere(
          (element) => element.duration == _planDetail!.numOfExpPeriod);
      comboDateText = '${cmd.numberOfDay} ngày ${cmd.numberOfNight} đêm';
    }
  }

  getPlanMember() async {
    final memberList =
        await _planService.getPlanMember(widget.planId, widget.planType);
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
  }

  getTempOrder() => _planDetail!.tempOrders!.map((e) {
        final Map<String, dynamic> cart = e['cart'];
        ProductViewModel sampleProduct = products.firstWhere(
            (element) => element.id.toString() == cart.entries.first.key);
        return OrderViewModel(
            id: e['id'],
            details: cart.entries.map((e) {
              final product = products
                  .firstWhere((element) => element.id.toString() == e.key);
              return OrderDetailViewModel(
                  id: product.id,
                  productId: product.id,
                  productName: product.name,
                  price: product.price.toDouble(),
                  unitPrice: product.price.toDouble(),
                  quantity: e.value);
            }).toList(),
            note: e['note'],
            serveDates: e["serveDates"],
            total: e['total'].toDouble(),
            createdAt: DateTime.now(),
            supplier: SupplierViewModel(
                type: sampleProduct.supplierType,
                id: sampleProduct.supplierId!,
                name: sampleProduct.supplierName,
                phone: sampleProduct.supplierPhone,
                thumbnailUrl: sampleProduct.supplierThumbnailUrl,
                address: sampleProduct.supplierAddress),
            type: e['type'],
            period: e['period']);
      }).toList();

  getOrderList() async {
    var _total = 0.0;
    if (_planDetail!.status == 'REGISTERING' ||
        _planDetail!.status == 'PENDING') {
      orderList = tempOrders;
    } else {
      final rs = await _planService.getOrderCreatePlan(widget.planId);
      if (rs != null) {
        setState(() {
          orderList = rs['orders'];
          _planDetail!.actualGcoinBudget = rs['currentBudget'];
        });
      }
    }
    _total = orderList.fold(0, (sum, obj) => sum + obj.total!);
    setState(() {
      total = _total;
    });
  }

  updatePlan() async {
    final location =
        await _locationService.GetLocationById(_planDetail!.locationId);
    if (location != null) {
      sharedPreferences.setInt('planId', widget.planId);
      sharedPreferences.setInt(
          "plan_number_of_member", _planDetail!.maxMemberCount);
      sharedPreferences.setDouble(
          'plan_start_lat', _planDetail!.startLocationLat);
      sharedPreferences.setDouble(
          'plan_start_lng', _planDetail!.startLocationLng);
      sharedPreferences.setString(
          'plan_start_date', _planDetail!.startDate.toString());
      sharedPreferences.setString('plan_start_time',
          '${_planDetail!.departTime!.hour}:${_planDetail!.departTime!.minute}');
      sharedPreferences.setString(
          'plan_end_date', _planDetail!.endDate.toString());
      sharedPreferences.setString(
          'plan_schedule', _planDetail!.schedule.toString());
      sharedPreferences.setString(
          'plan_saved_emergency',
          _planDetail!.savedContacts!
              .map((e) => e.toJson(e))
              .toList()
              .toString());
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => CreateNewPlanScreen(
                location: location,
                isCreate: false,
                schedule: _planDetail!.schedule,
              )));
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
                                  : Colors.white38),
                          SpeedDialChild(
                              child: const Icon(
                                Icons.check_circle_outline,
                                size: 30,
                              ),
                              label: 'Chốt',
                              onTap:
                                  _isEnableToConfirm ? onConfirmMember : () {},
                              labelStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              labelBackgroundColor: _isEnableToConfirm
                                  ? primaryColor.withOpacity(0.8)
                                  : Colors.white30,
                              foregroundColor: Colors.white,
                              backgroundColor: _isEnableToConfirm
                                  ? primaryColor
                                  : Colors.white38),
                          SpeedDialChild(
                              child: const Icon(Icons.share),
                              labelStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              onTap: () {
                                sharedPreferences.setInt(
                                    'plan_id_pdf', _planDetail!.id);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) =>
                                        const PlanPdfViewScreen()));
                              },
                              label: 'Chia sẻ',
                              labelBackgroundColor:
                                  Colors.amber.withOpacity(0.8),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.amber),
                        ],
                      )
                    : _isAlreadyJoin
                        ? FloatingActionButton(
                            shape: const CircleBorder(),
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.share),
                            onPressed: () {
                              sharedPreferences.setInt(
                                  'plan_id_pdf', _planDetail!.id);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => const PlanPdfViewScreen()));
                            })
                        : null,
            appBar: AppBar(
              title: Text(
                _planDetail != null ? _planDetail!.name! : '',
                style: const TextStyle(
                    fontSize: 20,
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
                if (_planDetail != null &&
                    (_planDetail!.status == 'PENDING' ||
                        _planDetail!.status == 'REGISTERING'))
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
                                style: TextStyle(
                                    color: Colors.amber, fontSize: 18),
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
                      await setupData();
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
                                    '$baseBucketImage${_planDetail!.imageUrls[0]}',
                                placeholder: (context, url) =>
                                    Image.memory(kTransparentImage),
                                errorWidget: (context, url, error) =>
                                    FadeInImage.assetNetwork(
                                  height: 15.h,
                                  width: 15.h,
                                  fit: BoxFit.cover,
                                  placeholder: 'No Image',
                                  image:
                                      'https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0',
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
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 70.w,
                                          child: Text(
                                            _planDetail!.locationName,
                                            overflow: TextOverflow.clip,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'NotoSans',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          comboDateText,
                                          overflow: TextOverflow.clip,
                                          style: const TextStyle(
                                              fontFamily: 'NotoSans',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (!_isAlreadyJoin &&
                                            _planDetail!.gcoinBudgetPerCapita !=
                                                0)
                                          Row(
                                            children: [
                                              Text(
                                                NumberFormat.simpleCurrency(
                                                        locale: 'vi_VN',
                                                        decimalDigits: 0,
                                                        name: '')
                                                    .format(_planDetail!
                                                        .gcoinBudgetPerCapita),
                                                overflow: TextOverflow.clip,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'NotoSans',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SvgPicture.asset(
                                                gcoin_logo,
                                                height: 25,
                                              )
                                            ],
                                          ),
                                      ],
                                    ),
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
                                        Text(
                                          _isPublic ? 'Công khai' : 'Riêng tư',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontFamily: 'NotoSans',
                                              color: _isPublic
                                                  ? primaryColor
                                                  : Colors.grey),
                                        )
                                      ],
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
                                                basic_information_green,
                                            iconSelectedUrl:
                                                basic_information_white,
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
                                            iconDefaultUrl: schedule_green,
                                            iconSelectedUrl: schedule_white,
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
                                            iconDefaultUrl: service_green,
                                            iconSelectedUrl: service_white,
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
                                            iconDefaultUrl: surcharge_green,
                                            iconSelectedUrl: surcharge_white,
                                            text: 'Tiền mặt & ghi chú',
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
                            widget.isEnableToJoin &&
                            !_isAlreadyJoin)
                          buildNewFooter()
                      ],
                    ),
                  )));
  }

  buildSurchagreNoteWidget() => DetailPlanSurchargeNote(
        plan: _planDetail!,
      );

  buildServiceWidget() => DetailPlanServiceWidget(
      plan: _planDetail!,
      isLeader: isLeader,
      tempOrders: tempOrders,
      orderList: orderList,
      total: total,
      onGetOrderList: getOrderList);

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
            type: widget.planType,
            plan: _planDetail!,
            members: _planMembers,
            refreshData: setupData,
          ),
        ],
      );
  buildScheduleWidget() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
                alignment: Alignment.centerLeft,
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
              height: 60.h,
              child: PLanScheduleWidget(
                schedule: _planDetail!.schedule,
                startDate: _planDetail!.startDate!,
                endDate: _planDetail!.endDate!,
              ),
            ),
          ],
        ),
      );
  onInvite() async {
    var enableToShare = checkEnableToShare();
    if (enableToShare['status']) {
      await getPlanMember();
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
      AwesomeDialog(
              context: context,
              animType: AnimType.bottomSlide,
              dialogType: DialogType.error,
              title: 'Không thể gia nhập chuyến đi',
              titleTextStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              desc: 'Chuyến đi đã đủ số lượng thành viên tham gia',
              descTextStyle: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              btnOkColor: redColor,
              btnOkOnPress: () {},
              btnOkText: 'OK')
          .show();
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
                    departureAddress: _planDetail!.departureAddress,
                    schedule: json.encode(_planDetail!.schedule),
                    savedContacts: json.encode(emerList),
                    name: _planDetail!.name,
                    memberLimit: _planDetail!.maxMemberCount,
                    startDate: _planDetail!.startDate,
                    endDate: _planDetail!.endDate,
                    travelDuration: _planDetail!.travelDuration,
                    departureDate: _planDetail!.departDate,
                    note: _planDetail!.note,
                  ),
                  locationName: _planDetail!.locationName,
                  orderList: tempOrders,
                  onCompletePlan: () {},
                  listSurcharges: _planDetail!.surcharges!
                      .map((e) => {
                            "alreadyDivided":e.alreadyDivided,
                            "gcoinAmount": e.gcoinAmount,
                            "note": json.encode(e.note)
                          })
                      .toList(),
                  isJoin: true,
                  onJoinPlan: () {
                    confirmJoin(isPublic);
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
    }
  }

  confirmJoin(bool isPublic) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => JoinConfirmPlanScreen(
              plan: _planDetail!,
              isPublic: isPublic,
              isConfirm: false,
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
                if (!_isAlreadyJoin) {
                  onJoinPlan(false);
                }
              },
              style: elevatedButtonStyle.copyWith(
                  backgroundColor: MaterialStatePropertyAll(
                      _isAlreadyJoin ? Colors.grey : primaryColor)),
              child: const Text(
                "Tham gia kế hoạch",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    if (_planDetail!.memberCount! < _planDetail!.maxMemberCount) {
      AwesomeDialog(
              context: context,
              animType: AnimType.bottomSlide,
              dialogType: DialogType.warning,
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const Text(
                      'Chuyến đi chưa đủ thành viên',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Text(
                          'Số lượng thành viên',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Spacer(),
                        Text(
                          '${_planDetail!.memberCount! < 10 ? '0${_planDetail!.memberCount}' : _planDetail!.memberCount}/${_planDetail!.maxMemberCount < 10 ? '0${_planDetail!.maxMemberCount}' : _planDetail!.maxMemberCount}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Thời gian',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Spacer(),
                        Text(
                          '${DateFormat('dd/MM/yyyy').format(_planDetail!.departDate!)} - ${DateFormat('dd/MM/yyyy').format(_planDetail!.endDate!)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Chi phí tham gia',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Spacer(),
                        Text(
                          '${currencyFormat.format(_planDetail!.gcoinBudgetPerCapita)} GCOIN',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Hãy cân đối chi phí cho chuyến đi khi đặt dịch vụ. Bạn sẽ phải bù tiền nếu như vượt quá ngân sách',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              btnOkColor: Colors.blue,
              btnOkOnPress: () {
                confirmMember();
              },
              btnOkText: 'Chơi',
              btnCancelColor: Colors.amber,
              btnCancelOnPress: () {},
              btnCancelText: 'Huỷ')
          .show();
    } else if (_planDetail!.memberCount == _planDetail!.maxMemberCount) {
      confirmMember();
    }
  }

  confirmMember() async {
    final rs = await _planService.confirmMember(widget.planId);
    if (rs != 0) {
      AwesomeDialog(
        context: context,
        animType: AnimType.rightSlide,
        dialogType: DialogType.success,
        title: 'Đã chốt số lượng thành viên của chuyến đi',
        titleTextStyle:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.all(12),
      ).show();
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(context).pop();
        setState(() {
          _planDetail!.status = 'READY';
          _isEnableToInvite = false;
          _isEnableToOrder = true;
        });
      });
    }
  }

  callbackConfirmMember() {
    setState(() {
      _planDetail!.status = 'READY';
      _isEnableToInvite = false;
      _isEnableToOrder = true;
      _isEnableToConfirm = false;
      _planDetail!.memberCount = _planDetail!.maxMemberCount;
    });
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
    final memberId = _planMembers.firstWhere((element) => element.accountId == sharedPreferences.getInt('userId')).memberId;
    final rs = await _planService.removeMember(memberId, isBlock);
    if (rs != 0) {
      AwesomeDialog(
              context: context,
              animType: AnimType.leftSlide,
              dialogType: DialogType.info,
              padding: const EdgeInsets.all(12),
              title: 'Đã rời khỏi chuyến đi',
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

  handleCancelPlan(){
    AwesomeDialog(context: context,
    animType: AnimType.leftSlide,
    dialogType: DialogType.question,
    title: 'Bạn có chắc chắn muốn huỷ kế hoạch "${_planDetail!.name}"',
    titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSans'),
    padding: const EdgeInsets.all(10),
    btnOkColor: Colors.deepOrangeAccent,
    btnOkOnPress: onCancelPlan,
    btnOkText: 'Có',
    btnCancelColor: Colors.blue,
    btnCancelOnPress: () {
      
    },
    btnCancelText: 'Không' 
    ).show();
  }

  onCancelPlan()async{
    int? rs = await _planService.cancelPlan(widget.planId);
    if(rs != 0){
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
        handlePublicizePlan(false, null);
      } else {
        final rs = await _planService.updateJoinMethod(_planDetail!.id, 'NONE');
        if (rs) {
          setState(() {
            _planDetail!.joinMethod = 'NONE';
          });
        }
      }
    }
  }

  handlePublicizePlan(bool isFromJoinScreen, int? amount) async {
    await showModalBottomSheet(
        context: context,
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
                        onTap: () async {
                          final rs = await _planService.updateJoinMethod(
                              _planDetail!.id, 'INVITE');
                          if (rs) {
                            setState(() {
                              _planDetail!.joinMethod = 'INVITE';
                            });
                            Navigator.of(context).pop();
                            if (isFromJoinScreen) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) => SuccessPaymentScreen(
                                            amount: amount!,
                                          )),
                                  (route) => false);
                            }
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
                        onTap: () async {
                          final rs = await _planService.updateJoinMethod(
                              _planDetail!.id, 'SCAN');
                          if (rs) {
                            setState(() {
                              _planDetail!.joinMethod = 'SCAN';
                            });
                            Navigator.of(context).pop();
                            if (isFromJoinScreen) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) => SuccessPaymentScreen(
                                            amount: amount!,
                                          )),
                                  (route) => false);
                            }
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
}
