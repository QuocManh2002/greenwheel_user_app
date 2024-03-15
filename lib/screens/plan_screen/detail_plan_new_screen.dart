// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_new_plan_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/join_confirm_plan_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/list_order_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/share_plan_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/service/product_service.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_join_service_infor.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/base_information.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/detail_plan_service_widget.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_view.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/member_list_widget.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/surcharge_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/tab_icon_button.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../widgets/style_widget/button_style.dart';

class DetailPlanNewScreen extends StatefulWidget {
  const DetailPlanNewScreen(
      {super.key,
      required this.planId,
      this.isFromHost,
      required this.isEnableToJoin});
  final int planId;
  final bool isEnableToJoin;
  final bool? isFromHost;

  @override
  State<DetailPlanNewScreen> createState() => _DetailPlanScreenState();
}

class _DetailPlanScreenState extends State<DetailPlanNewScreen>
    with TickerProviderStateMixin {
  bool isLoading = true;
  PlanService _planService = PlanService();
  LocationService _locationService = LocationService();
  ProductService _productService = ProductService();
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];
  PlanDetail? _planDetail;
  late TabController tabController;
  late TextEditingController newItemController;
  List<PlanMemberViewModel> _planMembers = [];
  List<PlanMemberViewModel> _joinedMember = [];
  double total = 0;
  double totalTempOrders = 0;
  int _currentIndexEmergencyCard = 0;
  int _selectedTab = 0;
  bool _isPublic = false;
  bool _isEnableToShare = false;
  bool _isEnableToOrder = false;
  List<ProductViewModel> products = [];
  List<OrderViewModel> tempOrders = [];
  List<OrderViewModel> orderList = [];
  bool isLeader = false;
  Widget? activeWidget;
  List<int> availableWeight = [];
  bool _isAlreadyJoin = false;
  List<PlanJoinServiceInfor> listRoom = [];
  List<PlanJoinServiceInfor> listFood = [];
  dynamic indexService;
  HtmlEditorController controller = HtmlEditorController();
  bool _isShowNote = false;
  var currencyFormat =
      NumberFormat.simpleCurrency(locale: 'vi_VN', name: '', decimalDigits: 0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    newItemController = TextEditingController();
    setupData();
    sharedPreferences.setInt('planId', widget.planId);
  }

  setupData() async {
    _planDetail = null;
    _planDetail = await _planService.GetPlanById(widget.planId);
    List<String> productIds = [];
    for (final order in _planDetail!.tempOrders!) {
      Map<String, dynamic> cart = order['cart'];
      for (final proId in cart.keys.toList()) {
        if (!productIds.contains(proId)) {
          productIds.add(proId);
        }
      }
    }
    isLeader = sharedPreferences.getString('userId') ==
        _planDetail!.leaderId.toString();
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    for (int i = 0;
        i < _planDetail!.memberLimit - _planDetail!.memberCount!;
        i++) {
      availableWeight.add(i + 1);
    }
    products = await _productService.getListProduct(productIds);
    tempOrders = getTempOrder();
    _isPublic = _planDetail!.status != 'PRIVATE';
    _isEnableToShare = _isPublic && _planDetail!.status != 'READY';

    getOrderList(null);
    getPlanMember();
    if (_planDetail != null) {
      setState(() {
        isLoading = false;
      });
    }
    indexService = getIndexTempOrder();
  }

  getPlanMember() {
    for (final mem in _planDetail!.members!) {
      int type = 0;
      if (mem.accountId == _planDetail!.leaderId) {
        type = 1;
      } else if (mem.accountId.toString() ==
          sharedPreferences.getString('userId')) {
        type = 2;
      } else {
        type = 3;
      }
      _planMembers.add(PlanMemberViewModel(
          name: mem.name,
          memberId: mem.memberId,
          phone: mem.phone,
          status: mem.status,
          accountId: mem.accountId,
          accountType: type,
          weight: mem.weight));
    }
    _isAlreadyJoin = _planMembers.any((element) =>
        element.accountId ==
            int.parse(sharedPreferences.getString('userId')!) &&
        element.status == 'JOINED');
  }

  getTempOrder() => _planDetail!.tempOrders!.map((e) {
        var orderTotal = 0.0;
        final Map<String, dynamic> cart = e['cart'];
        for (final cart in cart.entries) {
          orderTotal += products
                  .firstWhere((element) => element.id.toString() == cart.key)
                  .price *
              cart.value;
        }
        ProductViewModel sampleProduct = products.firstWhere(
            (element) => element.id.toString() == cart.entries.first.key);
        totalTempOrders += orderTotal * e['serveDateIndexes'].length;
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
            guid: e['guid'],
            serveDateIndexes: e["serveDateIndexes"],
            total: orderTotal * e['serveDateIndexes'].length,
            createdAt: DateTime.now(),
            supplier: SupplierViewModel(
                id: sampleProduct.supplierId!,
                name: sampleProduct.supplierName,
                phone: sampleProduct.supplierPhone,
                thumbnailUrl: sampleProduct.supplierThumbnailUrl,
                address: sampleProduct.supplierAddress),
            type: e['type'],
            period: e['period']);
      }).toList();

  getIndexTempOrder() {
    List<int> indexRoomOrder = [];
    List<int> indexFoodOrder = [];
    List<OrderViewModel> roomOrderList = [];
    List<OrderViewModel> foodOrderList = [];
    for (var item in tempOrders) {
      if (item.type == 'MEAL') {
        foodOrderList.add(item);
      } else {
        roomOrderList.add(item);
      }
      total += item.total!;
    }

    for (final order in roomOrderList) {
      for (final index in order.serveDateIndexes!) {
        if (!indexRoomOrder.contains(index)) {
          indexRoomOrder.add(index);
        }
      }
    }

    for (final order in foodOrderList) {
      for (final index in order.serveDateIndexes!) {
        if (!indexFoodOrder.contains(index)) {
          indexFoodOrder.add(index);
        }
      }
    }
    List<Map> periodList = [];
    for (final index in indexFoodOrder) {
      List<OrderViewModel> orders = [];
      for (final order in foodOrderList) {
        if (order.serveDateIndexes!.contains(index)) {
          orders.add(order);
        }
      }
      List<dynamic> keys = orders.groupListsBy((e) => e.period).keys.toList();
      var periods = keys.map((e) => Utils().getPeriodString(e)).toList();
      Utils().sortPeriodList(periods);
      periodList.add({'periods': periods});
    }
    return {
      'roomIndex': indexRoomOrder,
      'foodIndex': indexFoodOrder,
      'foodPeriodList': periodList
    };
  }

  getOrderList(String? tempOrderGuid) async {
    total = 0;
    List<OrderViewModel> roomOrderList = [];
    List<OrderViewModel> foodOrderList = [];
    List<PlanJoinServiceInfor> _listRoom = [];
    List<PlanJoinServiceInfor> _listFood = [];

    final rs = await _planService.getOrderCreatePlan(widget.planId);
    if (rs != null) {
      orderList = rs['orders'];
      for (final order in orderList) {
        if (order.type == 'MEAL') {
          foodOrderList.add(order);
        } else {
          roomOrderList.add(order);
        }
      }

      for (final day in indexService['roomIndex']) {
        var _orderList = [];
        for (final order in roomOrderList) {
          if (order.serveDateIndexes!.contains(day)) {
            _orderList.add(order);
          }
        }
        _listRoom
            .add(PlanJoinServiceInfor(dayIndex: day, orderList: _orderList));
      }
      for (final day in indexService['foodIndex']) {
        var _orderList = [];
        List<String> _periodList = [];
        for (final order in foodOrderList) {
          if (order.serveDateIndexes!.contains(day)) {
            _orderList.add(order);
          }
        }
        _orderList.sort(
          (a, b) => Utils()
              .getPeriodString(a.period)['value']
              .compareTo(Utils().getPeriodString(b.period)['value']),
        );
        _listFood.add(PlanJoinServiceInfor(
            dayIndex: day, orderList: _orderList, periodString: _periodList));
      }
      setState(() {
        listRoom = _listRoom;
        listFood = _listFood;
      });
    }
  }

  updatePlan() async {
    final location =
        await _locationService.GetLocationById(_planDetail!.locationId);
    if (location != null) {
      final defaultComboDate = listComboDate
              .firstWhere((element) =>
                  element.duration == location.suggestedTripLength! * 2)
              .id -
          1;
      sharedPreferences.setInt('planId', widget.planId);
      sharedPreferences.setInt(
          "plan_number_of_member", _planDetail!.memberLimit);
      sharedPreferences.setInt('plan_combo_date', defaultComboDate);
      sharedPreferences.setDouble(
          'plan_start_lat', _planDetail!.startLocationLat);
      sharedPreferences.setDouble(
          'plan_start_lng', _planDetail!.startLocationLng);
      sharedPreferences.setString(
          'plan_start_date', _planDetail!.startDate.toString());
      sharedPreferences.setString('plan_start_time',
          '${_planDetail!.departureDate!.hour}:${_planDetail!.departureDate!.minute}');
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
            appBar: AppBar(
              title: const Text(
                'Kế hoạch',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              leading: BackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.white)),
              ),
              actions: [
                if (isLeader)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      onPressed: updatePlan,
                      icon: const Icon(
                        Icons.edit_square,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  )
              ],
            ),
            body: isLoading
                ? const Center(
                    child: Text("Loading..."),
                  )
                : Column(
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
                              imageUrl: _planDetail!.imageUrls[0],
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
                                  Expanded(
                                    child: Text(
                                      _planDetail!.name ??
                                          'Chuyến đi chưa đặt tên',
                                      overflow: TextOverflow.clip,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
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
                                      width: 16,
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
                                      width: 16,
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
                                        : buildInforWidget())
                          ],
                        )),
                      ),
                      if (_planDetail!.memberLimit != 1)
                        if (widget.isFromHost == null || widget.isFromHost!)
                          buildNewFooter()
                    ],
                  )));
  }

  buildServiceWidget() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Các đơn dịch vụ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                const Spacer(),
                if (isLeader)
                  TextButton(
                      onPressed: () async {
                        if (_planDetail!.status == 'READY') {
                          final rs = await _locationService.GetLocationById(
                              _planDetail!.locationId);
                          if (rs != null) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => ListOrderScreen(
                                      availableGcoinAmount:
                                          _planDetail!.currentGcoinBudget,
                                      planId: widget.planId,
                                      orders: tempOrders,
                                      startDate: _planDetail!.startDate!,
                                      callback: getOrderList,
                                      endDate: _planDetail!.endDate!,
                                      memberLimit: _planDetail!.memberLimit,
                                      location: rs,
                                    )));
                          }
                        }
                      },
                      child: Text(
                        'Đi đặt hàng',
                        style: TextStyle(
                          color: _planDetail!.status == 'READY'
                              ? primaryColor
                              : Colors.grey,
                        ),
                      ))
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            TabBar(
                controller: tabController,
                indicatorColor: primaryColor,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.hotel),
                    text: '(${indexService['roomIndex'].length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.restaurant),
                    text: '(${indexService['foodIndex'].length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.account_balance_wallet),
                    text: '(${_planDetail!.surcharges!.length})',
                  )
                ]),
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: indexService['roomIndex'].isEmpty &&
                      indexService['foodIndex'].isEmpty &&
                      _planDetail!.surcharges!.isEmpty
                  ? 0.h
                  : 35.h,
              child: TabBarView(controller: tabController, children: [
                ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: indexService['roomIndex'].length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100.w,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.8),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                child: Text(
                                  'Ngày ${indexService['roomIndex'][index] + 1}',
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(
                                width: 1.h,
                              ),
                              const Text(
                                'Nghỉ ngơi tại khách sạn',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          if (isLeader)
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Column(
                                children: [
                                  for (final order in listRoom[index].orderList)
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                                width: 43.w,
                                                child: Text(order.supplier.name,
                                                    overflow: TextOverflow.clip,
                                                    style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 1.h,
                                            ),
                                            Container(
                                              color: Colors.grey,
                                              width: 2,
                                              height: 40,
                                            ),
                                            SizedBox(
                                              width: 1.h,
                                            ),
                                            SizedBox(
                                              width: 30.w,
                                              child: Text(
                                                  '${(order.total / 100).toInt()} GCOIN',
                                                  overflow: TextOverflow.clip,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            )
                                          ],
                                        ),
                                        if (order !=
                                                listRoom[index]
                                                    .orderList
                                                    .last &&
                                            listRoom[index].orderList.last != 1)
                                          Container(
                                            color: Colors.grey,
                                            height: 2,
                                          )
                                      ],
                                    ),
                                ],
                              ),
                            )
                        ],
                      ),
                    );
                  },
                ),
                ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: indexService['foodIndex'].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: 100.w,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.8),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8))),
                                  child: Text(
                                    'Ngày ${indexService['foodIndex'][index] + 1}',
                                    style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                  width: 1.h,
                                ),
                                SizedBox(
                                  width: 60.w,
                                  child: Text(
                                    '(${Utils().buildTextFromListString(indexService['foodPeriodList'][index]['periods'].map((e) => e['text']).toList())}) Ăn uống tại nhà hàng',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.clip,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            if (isLeader)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final detail
                                        in listFood[index].orderList)
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 12.w,
                                                child: Text(
                                                    detail ==
                                                                listFood[index]
                                                                    .orderList
                                                                    .first ||
                                                            detail.period !=
                                                                listFood[index]
                                                                    .orderList[listFood[index]
                                                                            .orderList
                                                                            .indexOf(
                                                                                detail) +
                                                                        -1]
                                                                    .period
                                                        ? Utils().getPeriodString(
                                                            detail
                                                                .period)['text']
                                                        : '',
                                                    style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Container(
                                                color: Colors.grey,
                                                width: 2,
                                                height: 40,
                                              ),
                                              SizedBox(
                                                width: 1.h,
                                              ),
                                              SizedBox(
                                                width: 46.w,
                                                child: Text(
                                                    detail.supplier.name,
                                                    style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Container(
                                                color: Colors.grey,
                                                width: 2,
                                                height: 40,
                                              ),
                                              SizedBox(
                                                width: 1.h,
                                              ),
                                              SizedBox(
                                                width: 14.w,
                                                child: Text(
                                                    '${(detail.total / 100).toInt()} GCOIN',
                                                    style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                          if (detail !=
                                                  listFood[index]
                                                      .orderList
                                                      .last &&
                                              listFood[index].orderList.last !=
                                                  1)
                                            Container(
                                              color: Colors.grey,
                                              height: 2,
                                            )
                                        ],
                                      )
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _planDetail!.surcharges!.length,
                  itemBuilder: (context, index) {
                    return SurchargeCard(
                        amount: _planDetail!.surcharges![index].gcoinAmount,
                        note: _planDetail!.surcharges![index].note);
                  },
                )
              ]),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ngân sách chuyến đi: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${NumberFormat.simpleCurrency(locale: 'vi-VN', decimalDigits: 0, name: "").format(_planDetail!.currentGcoinBudget! * 100)} VND',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            if (total != 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng cộng: ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(total)} VND',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );

  buildInforWidget() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Thông tin cơ bản',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          BaseInformationWidget(plan: _planDetail!),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Dịch vụ khẩn cấp đã lưu: ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 1.h,
                ),
                SizedBox(
                  height: 13.h,
                  width: double.infinity,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _planDetail!.savedContacts!.length,
                    onPageChanged: (value) {
                      setState(() {
                        _currentIndexEmergencyCard = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      return EmergencyContactView(
                        emergency: _planDetail!.savedContacts![index],
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                if (_planDetail!.savedContacts!.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0;
                          i < _planDetail!.savedContacts!.length;
                          i++)
                        SizedBox(height: 1.5.h, child: buildIndicator(i)),
                    ],
                  ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  height: 1.8,
                  color: Colors.grey.withOpacity(0.4),
                ),
                const SizedBox(
                  height: 8,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isShowNote = !_isShowNote;
                    });
                  },
                  child: Row(
                    children: [
                      const Text(
                        'Ghi chú',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Icon(
                        _isShowNote
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: primaryColor,
                        size: 40,
                      )
                    ],
                  ),
                ),
                if (_isShowNote)
                  HtmlWidget(_planDetail!.note ?? ''),
                  // HtmlEditor(
                  //   controller: controller,
                  //   htmlEditorOptions: HtmlEditorOptions(
                  //       disabled: true, initialText: _planDetail!.note),
                  //   otherOptions: const OtherOptions(
                  //     height: 200,
                  //   ),
                  // ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  height: 1.8,
                  color: Colors.grey.withOpacity(0.4),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Thành viên đã tham gia: ",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const Spacer(),
                      TextButton(
                          style: ButtonStyle(
                              foregroundColor: MaterialStatePropertyAll(
                                  _planDetail!.memberCount! != 0
                                      ? primaryColor
                                      : Colors.grey)),
                          onPressed: () {
                            if (_planDetail!.memberCount != 0) {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (ctx) => MemberListWidget(
                                        members: _planMembers
                                            .where((element) =>
                                                element.weight != 0)
                                            .toList(),
                                        onRemoveMember: onRemoveMember,
                                      ));
                            }
                          },
                          child: const Row(
                            children: [
                              Text(
                                'Xem tất cả',
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right,
                                size: 23,
                              )
                            ],
                          ))
                    ],
                  ),
                  for (final member in _planMembers)
                    if (member.weight != 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                                height: 25,
                                width: 25,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                clipBehavior: Clip.hardEdge,
                                child: CachedNetworkImage(
                                  key: UniqueKey(),
                                  height: 25,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      member.imageUrl ?? defaultUserAvatarLink,
                                  placeholder: (context, url) =>
                                      Image.memory(kTransparentImage),
                                  errorWidget: (context, url, error) =>
                                      FadeInImage.assetNetwork(
                                    height: 25,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: '',
                                    image: empty_plan,
                                  ),
                                )),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              " ${member.name} (${member.weight})",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      )
                ],
              ),
            ),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
  onShare() async {
    var enableToShare = checkEnableToShare();
    if (enableToShare['status']) {
      if (_planDetail!.joinMethod == "NONE") {
        bool updateJoinMethod =
            await _planService.updateJoinMethod(widget.planId);
        print(updateJoinMethod);
      }
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => SharePlanScreen(
                isFromHost: _planDetail!.leaderId ==
                    int.parse(sharedPreferences.getString('userId')!),
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

  onRemoveMember(int memberId, bool isBlock) async {
    final rs = await _planService.removeMember(memberId, isBlock);
    if (rs != 0) {
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        dialogType: DialogType.success,
        title: 'Đã ${isBlock ? 'chặn' : 'xoá'} người dùng khỏi chuyến đi',
        titleTextStyle:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.all(12),
      ).show();
      Future.delayed(const Duration(seconds: 1), () async {
        final planMembers = await _planService.getPlanMember(widget.planId);

        if (planMembers.isNotEmpty) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          setState(() {
            _planMembers = planMembers;
          });
        }
      });
    }
  }

  onJoinPlan(bool isPublic) async {
    var emerList = [];
    if (_planDetail!.memberCount == _planDetail!.memberLimit) {
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
                  plan: PlanCreate(
                    schedule: json.encode(_planDetail!.schedule),
                    savedContacts: json.encode(emerList),
                    name: _planDetail!.name,
                    memberLimit: _planDetail!.memberLimit,
                    startDate: _planDetail!.startDate,
                    endDate: _planDetail!.endDate,
                    travelDuration: _planDetail!.travelDuration,
                    departureDate: _planDetail!.departureDate,
                    note: _planDetail!.note,
                  ),
                  locationName: _planDetail!.locationName,
                  orderList: tempOrders,
                  onCompletePlan: () {},
                  listSurcharges: _planDetail!.surcharges!
                      .map((e) => {
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
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => JoinConfirmPlanScreen(
              plan: _planDetail!,
              isPublic: isPublic,
              isConfirm: false,
            )));
  }

  Widget buildNewFooter() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
          alignment: Alignment.center,
          height: 6.h,
          child: widget.isEnableToJoin || _planDetail!.memberCount! == 0
              ? ElevatedButton(
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
                )
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        onPressed: _isEnableToShare ? onShare : () {},
                        style: _isEnableToShare
                            ? elevatedButtonStyle
                            : elevatedButtonStyle.copyWith(
                                backgroundColor: MaterialStatePropertyAll(
                                  Colors.grey.withOpacity(0.5),
                                ),
                                foregroundColor: const MaterialStatePropertyAll(
                                    Colors.grey)),
                        label: const Text(
                          "Mời",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (_isEnableToShare)
                      SizedBox(
                        width: 1.h,
                      ),
                    if (_isEnableToShare && isLeader)
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 28,
                          ),
                          onPressed: onConfirmMember,
                          style: elevatedButtonStyle.copyWith(
                              backgroundColor:
                                  const MaterialStatePropertyAll(Colors.blue)),
                          label: const Text(
                            "Chốt",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      );

  Widget buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceInOut,
      height: 0.5,
      margin: const EdgeInsets.only(left: 16),
      width: _currentIndexEmergencyCard == index ? 35 : 12,
      decoration: BoxDecoration(
          color: _currentIndexEmergencyCard == index
              ? Colors.grey
              : Colors.grey.withOpacity(0.7),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, offset: Offset(2, 3), blurRadius: 3)
          ]),
    );
  }

  checkEnableToShare() {
    var enableToShare = {
      'status': true,
      'message': 'Kế hoạch đủ điều kiện để chia sẻ'
    };
    if (_planDetail!.memberLimit == _joinedMember.length) {
      return {
        'status': false,
        'message': 'Đã đủ số lượng thành viên của chuyến đi'
      };
    }
    return enableToShare;
  }

  onConfirmMember() async {
    if (_planDetail!.memberCount! < _planDetail!.memberLimit) {
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
                          '${_planDetail!.memberCount! < 10 ? '0${_planDetail!.memberCount}' : _planDetail!.memberCount}/${_planDetail!.memberLimit < 10 ? '0${_planDetail!.memberLimit}' : _planDetail!.memberLimit}',
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
                          '${DateFormat('dd/MM/yyyy').format(_planDetail!.departureDate!)} - ${DateFormat('dd/MM/yyyy').format(_planDetail!.endDate!)}',
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
                    Text(
                      'Thanh toán thêm ${currencyFormat.format(_planDetail!.gcoinBudgetPerCapita)}${_planDetail!.memberLimit - _planDetail!.memberCount! > 1 ? ' x ${_planDetail!.memberLimit - _planDetail!.memberCount!} = ${currencyFormat.format(_planDetail!.gcoinBudgetPerCapita! * (_planDetail!.memberLimit - _planDetail!.memberCount!))}' : ''}GCOIN để chốt số lượng thành viên cho chuyến đi',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              btnOkColor: Colors.blue,
              btnOkOnPress: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => JoinConfirmPlanScreen(
                        callback: callbackConfirmMember,
                        plan: _planDetail!,
                        isPublic: false,
                        isConfirm: true)));
              },
              btnOkText: 'Chơi',
              btnCancelColor: Colors.amber,
              btnCancelOnPress: () {},
              btnCancelText: 'Huỷ')
          .show();
    } else if (_planDetail!.memberCount == _planDetail!.memberLimit) {
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
          _isEnableToShare = false;
          _isEnableToOrder = true;
        });
      });
    }
  }

  callbackConfirmMember() {
    setState(() {
      _planDetail!.status = 'READY';
      _isEnableToShare = false;
      _isEnableToOrder = true;
      _planDetail!.memberCount = _planDetail!.memberLimit;
    });
  }

  onPublicizePlan() async {
    if (_planDetail!.memberCount! == 0) {
      final rs = await AwesomeDialog(
          context: context,
          animType: AnimType.bottomSlide,
          dialogType: DialogType.info,
          title:
              'Bạn phải đóng tiền cho chuyến đi này để có thể công khai chuyến đi',
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
      await _planService.publicizePlan(widget.planId);
      setState(() {
        _isEnableToShare = _isPublic && _planDetail!.status != 'READY';
      });
    }
  }
}
