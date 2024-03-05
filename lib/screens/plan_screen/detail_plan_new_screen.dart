// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_new_plan_screen.dart';
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
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/base_information.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_view.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/tab_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../widgets/style_widget/button_style.dart';

class DetailPlanNewScreen extends StatefulWidget {
  const DetailPlanNewScreen(
      {super.key, required this.planId, required this.isEnableToJoin});
  final int planId;
  final bool isEnableToJoin;

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
  int _currentIndexEmergencyCard = 0;
  int _selectedTab = 0;
  bool _isPublic = true;
  bool _isEnableToShare = false;
  bool _isEnableToOrder = false;
  List<ProductViewModel> products = [];
  List<OrderViewModel> tempOrders = [];
  bool _isShowRealOrder = false;
  List<OrderViewModel> orderList = [];
  bool isLeader = false;
  Widget? activeWidget;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    newItemController = TextEditingController();
    setupData();
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
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _isPublic = _planDetail!.isPublic;
    _isEnableToShare = _isPublic && _planDetail!.status != 'READY';
    products = await _productService.getListProduct(productIds);
    tempOrders = getTempOrder();
    getOrderList();
    getPlanMember();
    if (_planDetail != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  getPlanMember() {
    for (final mem in _planDetail!.members!) {
      // _planMembers = _planDetail!.members!;
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
        return OrderViewModel(
            id: e['id'],
            details: cart.entries.map((e) {
              final product = products
                  .firstWhere((element) => element.id.toString() == e.key);
              return OrderDetailViewModel(
                  id: product.id,
                  productName: product.name,
                  price: product.price.toDouble(),
                  unitPrice: product.price.toDouble(),
                  quantity: e.value);
            }).toList(),
            note: e['note'],
            serveDateIndexes: e["serveDateIndexes"],
            total: orderTotal,
            createdAt: DateTime.now(),
            supplierName: sampleProduct.supplierName,
            type: e['type'],
            supplierPhone: sampleProduct.supplierPhone,
            supplierAddress: sampleProduct.supplierAddress,
            supplierImageUrl: sampleProduct.supplierThumbnailUrl,
            period: e['period']);
      }).toList();

  getOrderList() async {
    total = 0;
    orderList = await _planService.getOrderCreatePlan(widget.planId);
    List<Widget> listRestaurant = [];
    List<Widget> listMotel = [];
    for (var item in orderList) {
      if (item.type == 'MEAL') {
        listRestaurant.add(SupplierOrderCard(
          order: item,
          startDate: _planDetail!.startDate!,
          isTempOrder: false,
          planId: widget.planId,
          callback: () {},
        ));
      } else {
        listMotel.add(SupplierOrderCard(
          order: item,
          startDate: _planDetail!.startDate!,
          isTempOrder: false,
          planId: widget.planId,
          callback: () {},
        ));
      }
      total += item.total!;
    }
    setState(() {
      _listMotel = listMotel;
      _listRestaurant = listRestaurant;
    });
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
                              height: 35.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
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
                                            // final planStatus =
                                            await _planService
                                                .publicizePlan(widget.planId);
                                            setState(() {
                                              // _isPublic = planStatus;
                                              _isEnableToShare = _isPublic &&
                                                  _planDetail!.status !=
                                                      'READY';
                                            });
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
                                    if (isLeader)
                                      const SizedBox(
                                        width: 16,
                                      ),
                                    if (isLeader)
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
                      if (_planDetail!.memberLimit != 1) buildNewFooter()
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
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => ListOrderScreen(
                                planId: widget.planId,
                                orders: tempOrders,
                                startDate: _planDetail!.startDate!,
                                callback: getOrderList,
                              )));
                    },
                    child: const Text(
                      'Đi đặt hàng',
                      style: TextStyle(color: primaryColor),
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
                    text: "(${_listMotel.length})",
                    icon: const Icon(Icons.hotel),
                  ),
                  Tab(
                    text: "(${_listRestaurant.length})",
                    icon: const Icon(Icons.restaurant),
                  )
                ]),
            Container(
              margin: const EdgeInsets.only(top: 8),
              height:
                  _listRestaurant.isEmpty && _listMotel.isEmpty ? 0.h : 35.h,
              child: TabBarView(controller: tabController, children: [
                ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _listMotel.length,
                  itemBuilder: (context, index) {
                    return _listMotel[index];
                  },
                ),
                ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _listRestaurant.length,
                  itemBuilder: (context, index) {
                    return _listRestaurant[index];
                  },
                ),
              ]),
            ),
            const SizedBox(
              height: 16,
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
                        Container(height: 1.5.h, child: buildIndicator(i)),
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
                          style: const ButtonStyle(
                              foregroundColor:
                                  MaterialStatePropertyAll(primaryColor)),
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (ctx) => Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 100.w,
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: primaryColor
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(12)),
                                                ),
                                                width: 10.h,
                                                height: 6,
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              for (final mem in _planMembers)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    width: 100.w,
                                                    decoration:
                                                        const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            12)),
                                                            color:
                                                                Colors.white),
                                                    child: Row(
                                                      children: [
                                                        Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                mem.name,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                '0${mem.phone.substring(3)}',
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            19),
                                                              )
                                                            ]),
                                                        const Spacer(),
                                                        mem.accountType == 2
                                                            ? Container()
                                                            : mem.accountType ==
                                                                    3
                                                                ? PopupMenuButton(
                                                                    itemBuilder:
                                                                        (ctx) =>
                                                                            [
                                                                      const PopupMenuItem(
                                                                        value:
                                                                            0,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.close,
                                                                              color: primaryColor,
                                                                              size: 32,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 8,
                                                                            ),
                                                                            Text(
                                                                              'Xoá',
                                                                              style: TextStyle(color: primaryColor, fontSize: 18),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const PopupMenuItem(
                                                                        value:
                                                                            1,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.block,
                                                                              color: redColor,
                                                                              size: 32,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 8,
                                                                            ),
                                                                            Text(
                                                                              'Chặn',
                                                                              style: TextStyle(color: redColor, fontSize: 18),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                    onSelected:
                                                                        (value) {
                                                                      if (value ==
                                                                          0) {
                                                                        AwesomeDialog(
                                                                                context: context,
                                                                                animType: AnimType.bottomSlide,
                                                                                dialogType: DialogType.question,
                                                                                title: 'Bạn có chắc chắn muốn xoá tài khoản này khỏi chuyến đi không ?',
                                                                                titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                                btnOkColor: Colors.blue,
                                                                                btnOkText: 'Có',
                                                                                padding: const EdgeInsets.all(12),
                                                                                btnOkOnPress: () {
                                                                                  onRemoveMember(mem.memberId, false);
                                                                                },
                                                                                btnCancelColor: Colors.orange,
                                                                                btnCancelText: 'Không',
                                                                                btnCancelOnPress: () {})
                                                                            .show();
                                                                      } else {
                                                                        AwesomeDialog(
                                                                                context: context,
                                                                                animType: AnimType.bottomSlide,
                                                                                dialogType: DialogType.question,
                                                                                title: 'Bạn có chắc chắn muốn chặn tài khoản này hay không ?',
                                                                                titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                                btnOkColor: Colors.blue,
                                                                                padding: const EdgeInsets.all(12),
                                                                                btnOkText: 'Có',
                                                                                btnOkOnPress: () {
                                                                                  onRemoveMember(mem.memberId, true);
                                                                                },
                                                                                btnCancelColor: Colors.orange,
                                                                                btnCancelText: 'Không',
                                                                                btnCancelOnPress: () {})
                                                                            .show();
                                                                      }
                                                                    },
                                                                  )
                                                                : const Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            right:
                                                                                8),
                                                                    child: Icon(
                                                                      Icons
                                                                          .star,
                                                                      color:
                                                                          yellowColor,
                                                                      size: 30,
                                                                    ),
                                                                  )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                            ]),
                                      ),
                                    ));
                          },
                          child: const Row(
                            children: [
                              Text(
                                'Xem tất cả',
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right,
                                color: primaryColor,
                                size: 23,
                              )
                            ],
                          ))
                    ],
                  ),
                  for (final member in _planMembers)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      child: Text(
                        "- ${member.name} - 0${member.phone.substring(3)}",
                        style: const TextStyle(fontSize: 18),
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

  onJoinPlan() async {
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
      showModalBottomSheet(
          context: context,
          builder: (ctx) => ConfirmPlanBottomSheet(
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
              orderList: orderList,
              onCompletePlan: () {},
              listSurcharges: [],
              budgetPerCapita: _planDetail!.gcoinBudgetPerCapita!.toDouble(),
              isJoin: true,
              onJoinPlan: confirmJoin,
              total: total / 100));
    }
  }

  confirmJoin() {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        animType: AnimType.topSlide,
        title: "Xác nhận tham gia",
        desc:
            "Kinh phí cho chuyến đi này là ${_planDetail!.gcoinBudgetPerCapita} GCOIN. Kinh phí sẽ được trừ vào số GCOIN có sẵn của bạn. Bạn có sẵn sàng tham gia không?",
        btnOkText: "Xác nhận",
        btnOkOnPress: () async {
          int? rs = await _planService.joinPlan(widget.planId);
          if (rs != null) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.topSlide,
              showCloseIcon: true,
              title: "Tham gia kế hoạch thành công",
              desc: "Ấn tiếp tục để trở về",
              btnOkText: "Tiếp tục",
              btnOkOnPress: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (ctx) => const TabScreen(pageIndex: 1)),
                    (route) => false);
              },
            ).show();
          }
        }).show();
  }

  Widget buildNewFooter() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
          alignment: Alignment.center,
          height: 6.h,
          child: widget.isEnableToJoin
              ? ElevatedButton(
                  onPressed: () {
                    onJoinPlan();
                  },
                  style: elevatedButtonStyle,
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
          _isEnableToShare = false;
          _isEnableToOrder = true;
        });
      });
    }
  }
}
