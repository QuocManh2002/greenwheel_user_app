// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan_surcharge.dart';
import 'package:greenwheel_user_app/service/offline_service.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline_member.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_service_infor.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/surcharge_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen(
      {super.key,
      required this.memberLimit,
      required this.location,
      required this.isClone,
      this.isOrder,
      required this.completePlan});
  final LocationViewModel location;
  final bool isClone;
  final bool? isOrder;
  final Future<int> Function() completePlan;
  final int memberLimit;

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  final PlanService _planService = PlanService();
  final OrderService _orderService = OrderService();
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];
  List<Widget> _listSurcharges = [];
  DateTime? startDate;
  DateTime? endDate;
  int? numberOfMember;
  List<Map> _listSurchargeObjects = [];
  final OfflineService _offlineService = OfflineService();
  List<dynamic>? orderList = [];
  List<OrderViewModel>? listRestaurantOrder = [];
  List<OrderViewModel>? listMotelOrder = [];
  num totalFood = 0;
  num totalRest = 0;
  num totalSurcharge = 0;
  num total = 0;
  String activitiesText = '';
  num memberLimit = sharedPreferences.getInt('plan_number_of_member')!;
  bool _isShowSchedule = false;
  int tabIndex = 0;
  PlanCreate? plan;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(
        length: memberLimit == 1 ? 2 : 3, vsync: this, initialIndex: 0);
    setUpData();
  }

  setUpData() async {
    final duration = sharedPreferences.getInt('numOfExpPeriod');
    startDate = DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    endDate = DateTime.parse(sharedPreferences.getString('plan_end_date')!);
    numberOfMember = sharedPreferences.getInt('plan_number_of_member');
    await callback();
  }

  callback() async {
    orderList = json.decode(sharedPreferences.getString('plan_temp_order')!);
    List<Widget> listRestaurant = [];
    List<Widget> listMotel = [];
    listMotelOrder = [];
    listRestaurantOrder = [];
    // totalSurcharge = 0;
    totalFood = 0;
    totalRest = 0;
    total = 0;
    for (var item in orderList!) {
      List<OrderDetailViewModel> details = [];
      for (final detail in item['details']) {
        details.add(OrderDetailViewModel(
            price: detail['unitPrice'],
            productName: detail['productName'],
            unitPrice: detail['unitPrice'],
            quantity: detail['quantity']));
      }
      final temp = OrderViewModel(
          note: item['note'],
          details: details,
          type: item['type'],
          period: item['period'],
          serveDateIndexes: item['servingDates'],
          total: double.parse(item['total'].toString()),
          createdAt: DateTime.parse(item['createdAt']),
          supplierId: item['supplierId'],
          supplierName: item['supplierName'],
          supplierPhone: item['supplierPhone'],
          supplierAddress: item['supplierAddress'],
          supplierImageUrl: item['supplierImageUrl']);
      if (item['type'] == 'FOOD') {
        listRestaurant
            .add(SupplierOrderCard(order: temp, startDate: startDate!, isTempOrder: false, planId: sharedPreferences.getInt('planId')!));
        listRestaurantOrder!.add(temp);
        totalFood += getTotal(temp);
      } else {
        listMotel.add(SupplierOrderCard(
          order: temp,
          startDate: startDate!,
          isTempOrder: false,
          planId: sharedPreferences.getInt('planId')!,
        ));
        listMotelOrder!.add(temp);
        totalRest += getTotal(temp);
      }
      total += getTotal(temp);
    }
    if (orderList!.isNotEmpty) {
      setState(() {
        _listMotel = listMotel;
        _listRestaurant = listRestaurant;
      });
    }
    final budget = ((total / memberLimit) / 100).ceil();
    if (sharedPreferences.getInt('plan_number_of_member')! != 1) {
      sharedPreferences.setInt('plan_budget', budget);
    }
  }

  getTotal(OrderViewModel order) {
    var total = 0.0;
    for (final detail in order.details!) {
      total += detail.price! * detail.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text((widget.isOrder != null && widget.isOrder!)
              ? 'Thêm dịch vụ'
              : 'Tạo đơn hàng mẫu'),
          actions: [
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (ctx) => ConfirmServiceInfor(
                            listSurcharges: _listSurchargeObjects,
                            total: total / 100.toDouble(),
                            budgetPerCapita:
                                ((total / memberLimit) / 100).ceil().toDouble(),
                            listFood: listRestaurantOrder!,
                            listRest: listMotelOrder!,
                          ));
                  // AwesomeDialog(
                  //         context: context,
                  //         animType: AnimType.leftSlide,
                  //         dialogType: DialogType.info,
                  //         body: Padding(
                  //           padding: const EdgeInsets.all(12),
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Container(
                  //                   alignment: Alignment.center,
                  //                   child: const Text(
                  //                     'Đơn hàng mẫu đã lên',
                  //                     style: TextStyle(
                  //                         fontSize: 20,
                  //                         fontWeight: FontWeight.bold),
                  //                   )),
                  //               const SizedBox(
                  //                 height: 8,
                  //               ),
                  //               for (final order in orderList!)
                  //                 Padding(
                  //                   padding: const EdgeInsets.only(left: 0),
                  //                   child: Text(
                  //                     '- ${order['supplierName']} - ${order['details']!.length} sản phẩm',
                  //                     style: const TextStyle(fontSize: 16),
                  //                   ),
                  //                 ),
                  //               const SizedBox(
                  //                 height: 4,
                  //               ),
                  //               if (_listSurchargeObjects.isNotEmpty)
                  //                 Container(
                  //                     alignment: Alignment.center,
                  //                     child: const Text(
                  //                       'Phụ thu',
                  //                       style: TextStyle(
                  //                           fontSize: 20,
                  //                           fontWeight: FontWeight.bold),
                  //                     )),
                  //               for (final surcharge in _listSurchargeObjects)
                  //                 Padding(
                  //                   padding: const EdgeInsets.only(left: 0),
                  //                   child: Text(
                  //                     '- ${surcharge['note']} - ${surcharge['gcoinAmount']} GCOIN',
                  //                     style: TextStyle(fontSize: 16),
                  //                   ),
                  //                 ),
                  //               const SizedBox(
                  //                 height: 8,
                  //               ),
                  //               Row(
                  //                 children: [
                  //                   const Text(
                  //                     'Tổng cộng: ',
                  //                     style: TextStyle(
                  //                         fontSize: 18,
                  //                         fontWeight: FontWeight.bold),
                  //                   ),
                  //                   const Spacer(),
                  //                   Text(
                  //                     '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(total/100)} GCOIN',
                  //                     style:const TextStyle(fontSize: 18),
                  //                   )
                  //                 ],
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         btnOkColor: Colors.blue,
                  //         btnOkText: 'Tiếp tục',
                  //         btnOkOnPress: () {})
                  //     .show();
                },
                icon: const Icon(
                  Icons.attach_money_outlined,
                  color: Colors.white,
                  size: 35,
                ))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                height: 3.h,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Các loại dịch vụ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5.h,
                        width: 18.h,
                        child: ElevatedButton.icon(
                          label: const Text("Tìm & đặt"),
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            switch (tabController.index) {
                              case 0:
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => ServiceMainScreen(
                                    startDate: startDate!,
                                    endDate: endDate!,
                                    numberOfMember: numberOfMember!,
                                    serviceType: services[4],
                                    location: widget.location,
                                    isOrder: widget.isOrder,
                                    callbackFunction: callback,
                                  ),
                                ));
                                break;
                              case 1:
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => ServiceMainScreen(
                                    endDate: endDate!,
                                    startDate: startDate!,
                                    numberOfMember: numberOfMember!,
                                    serviceType: services[0],
                                    location: widget.location,
                                    isOrder: widget.isOrder,
                                    callbackFunction: callback,
                                  ),
                                ));
                                break;
                              case 2:
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => CreatePlanSurcharge(
                                          callback: callbackSurcharge,
                                        )));
                            }
                          },
                          style: elevatedButtonStyle,
                        ),
                      ),
                    ],
                  )),
              TabBar(
                  controller: tabController,
                  indicatorColor: primaryColor,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey,
                  onTap: (value) {
                    setState(() {
                      tabIndex = value;
                    });
                  },
                  tabs: [
                    Tab(
                      text: "(${_listMotel.length})",
                      icon: const Icon(Icons.hotel),
                    ),
                    Tab(
                      text: "(${_listRestaurant.length})",
                      icon: const Icon(Icons.restaurant),
                    ),
                    if (memberLimit != 1)
                      Tab(
                        text: "(${_listSurcharges.length})",
                        icon: const Icon(Icons.account_balance_wallet),
                      )
                  ]),
              Container(
                margin: const EdgeInsets.only(top: 8),
                height:
                    _listRestaurant.isEmpty && _listMotel.isEmpty ? 50.h : 46.h,
                child: TabBarView(
                    controller: tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _listRestaurant.isEmpty && _listMotel.isEmpty
                          ? Image.asset(
                              empty_plan,
                              fit: BoxFit.cover,
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _listMotel.length,
                              itemBuilder: (context, index) {
                                return _listMotel[index];
                              },
                            ),
                      _listRestaurant.isEmpty && _listMotel.isEmpty
                          ? Image.asset(
                              empty_plan,
                              fit: BoxFit.cover,
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _listRestaurant.length,
                              itemBuilder: (context, index) {
                                return _listRestaurant[index];
                              },
                            ),
                      if (memberLimit != 1)
                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _listSurcharges.length,
                          itemBuilder: (context, index) {
                            return _listSurcharges[index];
                          },
                        ),
                    ]),
              ),
              const Spacer(),
              if (total != 0)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng cộng: ',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(tabIndex == 0 ? totalRest / 100 : tabIndex == 1 ? totalFood / 100 : totalSurcharge / 100)} GCOIN',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Container(
                      height: 2,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    if (memberLimit != 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Khoản thu bình quân: ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(((total / memberLimit) / 100).ceil())} GCOIN',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    if (memberLimit != 1)
                      const SizedBox(
                        height: 16,
                      )
                  ],
                ),
              ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () async {
                    // final dateNotFullyService = checkFullyTimeService();
                    // if (dateNotFullyService == null) {
                    if (memberLimit == 1) {
                      AwesomeDialog(
                              context: context,
                              dialogType: DialogType.info,
                              body: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Xác nhận thông tin dịch vụ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      if (_listRestaurant.isNotEmpty)
                                        for (final order
                                            in listRestaurantOrder!)
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 16),
                                              child: RichText(
                                                text: TextSpan(
                                                    text: order.supplierName,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    children: [
                                                      // - ${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(order.total)} VND
                                                      TextSpan(
                                                          text:
                                                              ' đã đặt ${order.details!.length} đơn dịch vụ ',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal))
                                                    ]),
                                              )),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      if (_listMotel.isNotEmpty)
                                        for (final order in listMotelOrder!)
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 16),
                                              child: RichText(
                                                text: TextSpan(
                                                    text: order.supplierName,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    children: [
                                                      TextSpan(
                                                          text:
                                                              ': đã đặt ${order.details!.length} đơn dịch vụ',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal))
                                                    ]),
                                              )),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Tổng cộng: ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(total / 100)} GCOIN')
                                          ],
                                        ),
                                      )
                                    ]),
                              ),
                              btnOkColor: Colors.blue,
                              btnOkText: 'Xác nhận',
                              btnOkOnPress: () async {
                                // if (widget.memberLimit == 1) {
                                completeService(context);
                                // } else {
                                //   final rs = await widget.completePlan();
                                //   if (rs != 0) {
                                //     AwesomeDialog(
                                //             context: context,
                                //             animType: AnimType.bottomSlide,
                                //             dialogType: DialogType.success,
                                //             padding: const EdgeInsets.all(6),
                                //             title: 'Hoàn tất kế hoạch',
                                //             titleTextStyle: const TextStyle(
                                //                 fontSize: 18,
                                //                 fontWeight: FontWeight.bold))
                                //         .show();

                                //     Future.delayed(
                                //       const Duration(milliseconds: 1500),
                                //       () {
                                //         Utils().clearPlanSharePref();

                                //         Navigator.of(context).pop();

                                //         Navigator.of(context)
                                //             .pushAndRemoveUntil(
                                //           MaterialPageRoute(
                                //               builder: (ctx) => const TabScreen(
                                //                     pageIndex: 1,
                                //                   )),
                                //           (route) => false,
                                //         );
                                //       },
                                //     );
                                // }
                                // }
                              },
                              btnCancelColor: Colors.orange,
                              btnCancelText: 'Chỉnh sửa',
                              btnCancelOnPress: () {})
                          .show();
                    } else {
                      // final rs = await widget.completePlan();
                      // if (rs != 0) {
                      //   AwesomeDialog(
                      //           context: context,
                      //           animType: AnimType.bottomSlide,
                      //           dialogType: DialogType.success,
                      //           padding: const EdgeInsets.all(6),
                      //           title: 'Hoàn tất kế hoạch',
                      //           titleTextStyle: const TextStyle(
                      //               fontSize: 18, fontWeight: FontWeight.bold))
                      //       .show();

                      //   Future.delayed(
                      //     const Duration(milliseconds: 1500),
                      //     () {
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
                      //   );
                      // }

                      completeService(context);
                    }
                  },
                  child: const Text('Hoàn tất')),
              SizedBox(
                height: 1.h,
              )
            ],
          ),
        ),
      ),
    );
  }

  saveToOffline() async {
    PlanDetail? plan =
        await _planService.GetPlanById(sharedPreferences.getInt('planId')!);
    if (plan != null) {
      await _offlineService.savePlanToHive(PlanOfflineViewModel(
          id: plan.id,
          name: plan.name!,
          imageBase64: await Utils().getImageBase64Encoded(plan.imageUrls[0]),
          startDate: plan.startDate!,
          endDate: plan.endDate!,
          memberLimit: plan.memberLimit,
          schedule: plan.schedule,
          memberList: [
            PlanOfflineMember(
                id: int.parse(sharedPreferences.getString('userId')!),
                name: "Quoc Manh",
                phone: sharedPreferences.getString('userPhone')!,
                isLeading: true)
          ]));
    }
  }

  DateTime? checkFullyTimeService() {
    // final startDateText = sharedPreferences.getString('plan_start_date');
    // final endDateText = sharedPreferences.getString('plan_end_date');
    // final _startDate = DateTime.parse(startDateText!);
    // final _endDate = DateTime.parse(endDateText!);
    // final _duration = _endDate.difference(_startDate).inDays + 1;
    // var _servingDatesList = [];
    // for (final order in orderList!) {
    //   _servingDatesList.addAll(order.servingDates);
    // }
    // for (int i = 0; i < _duration; i++) {
    //   final tempDate = _startDate.add(Duration(days: i));
    //   if (tempDate.isAfter(DateTime.now().add(const Duration(days: 3))) &&
    //       !_servingDatesList.any((element) =>
    //           DateTime.parse(element.toString()).difference(tempDate).inDays ==
    //           0)) {
    //     print(tempDate);
    //     return tempDate;
    //   }
    // }
    // return null;
  }

  saveToLocal() {
    // PlanDetail? plan = await _planService.GetPlanById(
    //     sharedPreferences.getInt('planId')!);
    // if (plan != null) {
    //   await _offlineService.savePlanToHive(
    //       PlanOfflineViewModel(
    //           id: plan.id,
    //           name: plan.name,
    //           imageBase64: await Utils()
    //               .getImageBase64Encoded(plan.imageUrls[0]),
    //           startDate: plan.startDate,
    //           endDate: plan.endDate,
    //           memberLimit: plan.memberLimit,
    //           schedule: plan.schedule,
    //           memberList: [
    //         PlanOfflineMember(
    //             id: int.parse(
    //                 sharedPreferences.getString('userId')!),
    //             name: "Quoc Manh",
    //             phone: sharedPreferencesf
    //                 .getString('userPhone')!,
    //             isLeading: true)
    //       ]));
    // }
  }

  completeService(BuildContext ctx) {
    final departureDate =
        DateTime.parse(sharedPreferences.getString('plan_departureDate')!);
    DateTime _travelDuration = DateTime(0, 0, 0).add(Duration(
        seconds: (sharedPreferences.getDouble('plan_duration_value')! * 3600)
            .toInt()));
    plan = PlanCreate(
        numOfExpPeriod: sharedPreferences.getInt('numOfExpPeriod'),
        locationId: widget.location.id,
        name: sharedPreferences.getString('plan_name'),
        latitude: sharedPreferences.getDouble('plan_start_lat')!,
        longitude: sharedPreferences.getDouble('plan_start_lng')!,
        memberLimit: sharedPreferences.getInt('plan_number_of_member') ?? 1,
        savedContacts: sharedPreferences.getString('plan_saved_emergency')!,
        
        // json
        //     .decode(sharedPreferences.getString('plan_saved_emergency')!)
        //     .toString(),
        startDate:
            DateTime.parse(sharedPreferences.getString('plan_start_date')!),
        departureDate: departureDate,
        schedule: sharedPreferences.getString('plan_schedule'),
        endDate: DateTime.parse(sharedPreferences.getString('plan_end_date')!),
        travelDuration: DateFormat.Hm().format(_travelDuration),
        tempOrders: _orderService.convertTempOrders(orderList!).toString(),
        gcoinBudget: ((total / memberLimit) / 100).ceil());
    // final startDate =
    //     DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    // final endDate =
    //     DateTime.parse(sharedPreferences.getString('plan_end_date')!);
    // final scheduleList =
    //     json.decode(sharedPreferences.getString('plan_schedule')!);
    // final emergencyList =
    //     json.decode(sharedPreferences.getString('plan_saved_emergency')!);
    showModalBottomSheet(
        backgroundColor: Colors.white.withOpacity(0.94),
        context: context,
        builder: (ctx) => ConfirmPlanBottomSheet(
              locationName: widget.location.name,
              total: total / 100.toDouble(),
              budgetPerCapita: ((total / memberLimit) / 100).ceil().toDouble(),
              orderList: orderList!,
              onCompletePlan: onCompletePlan,
              plan: plan,
              onJoinPlan: (){},
              listSurcharges: _listSurchargeObjects,
              isJoin: false,
            ));

    // AwesomeDialog(
    //   context: ctx,
    //   dialogType: DialogType.info,
    //   body: Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 16),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Container(
    //           alignment: Alignment.center,
    //           child: const Text(
    //             'Xác nhận kế hoạch chuyến đi',
    //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //           ),
    //         ),
    //         const SizedBox(
    //           height: 8,
    //         ),
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             const Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   'Tên chuyến đi: ',
    //                   style:
    //                       TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //                 ),
    //                 Text(
    //                   'Số lượng thành viên: ',
    //                   style:
    //                       TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //                 ),
    //                 Text(
    //                   'Địa điểm: ',
    //                   style:
    //                       TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //                 ),
    //                 Text(
    //                   'Ngày bắt đầu: ',
    //                   style:
    //                       TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //                 ),
    //                 Text(
    //                   'Ngày kết thúc: ',
    //                   style:
    //                       TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //                 ),
    //                 Text(
    //                   'Thời gian di chuyển: ',
    //                   style:
    //                       TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //                 ),
    //               ],
    //             ),
    //             const SizedBox(
    //               width: 2,
    //             ),
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               children: [
    //                 SizedBox(
    //                   width: 30.w,
    //                   child: Text(
    //                     '${sharedPreferences.getString('plan_name')}',
    //                     style: const TextStyle(
    //                       fontSize: 16,
    //                     ),
    //                     overflow: TextOverflow.ellipsis,
    //                   ),
    //                 ),
    //                 Text(
    //                   '${sharedPreferences.getInt('plan_number_of_member')}',
    //                   style: const TextStyle(fontSize: 16),
    //                 ),
    //                 SizedBox(
    //                   width: 30.w,
    //                   child: Text(
    //                     widget.location.name,
    //                     style: const TextStyle(fontSize: 16),
    //                     overflow: TextOverflow.ellipsis,
    //                   ),
    //                 ),
    //                 Text(
    //                   '${startDate.day}/${startDate.month}/${startDate.year}',
    //                   overflow: TextOverflow.ellipsis,
    //                   style: const TextStyle(fontSize: 16),
    //                 ),
    //                 Text(
    //                   '${endDate.day}/${endDate.month}/${endDate.year}',
    //                   overflow: TextOverflow.ellipsis,
    //                   style: const TextStyle(fontSize: 16),
    //                 ),
    //                 Text(
    //                   '${sharedPreferences.getString('plan_duration_text')}',
    //                   overflow: TextOverflow.ellipsis,
    //                   style: const TextStyle(fontSize: 16),
    //                 ),
    //               ],
    //             )
    //           ],
    //         ),
    //         const Row(
    //           children: [
    //             Text(
    //               'Lịch trình: ',
    //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //             ),
    //           ],
    //         ),
    //         for (final day in scheduleList)
    //           Padding(
    //             padding: const EdgeInsets.only(
    //               left: 10,
    //             ),
    //             child: SizedBox(
    //               width: 60.w,
    //               child: Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     '- Ngày ${scheduleList.indexOf(day) + 1}: ',
    //                     style: const TextStyle(
    //                         fontSize: 16, fontWeight: FontWeight.w500),
    //                   ),
    //                   Container(
    //                     alignment: Alignment.topLeft,
    //                     width: 40.w,
    //                     child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           for (final event in day['events'])
    //                             Text(
    //                               '${json.decode(event['shortDescription'])}, ',
    //                               style: const TextStyle(fontSize: 16),
    //                             )
    //                         ]),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         const Text(
    //           'Liên lạc khẩn cấp đã lưu: ',
    //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //         ),
    //         for (final emer in emergencyList)
    //           Padding(
    //             padding: const EdgeInsets.only(left: 10),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   '- ${json.decode(emer['name'])}',
    //                   style: const TextStyle(fontSize: 16),
    //                 )
    //               ],
    //             ),
    //           ),
    //         const Text(
    //           'Đơn hàng mẫu đã lên: ',
    //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //         ),
    //         for (final order in orderList!)
    //           Padding(
    //             padding: const EdgeInsets.only(left: 10),
    //             child: SizedBox(
    //               width: 70.w,
    //               child: Text(
    //                 '- ${order.supplierName} - ${order.details!.length} đơn hàng',
    //                 style: const TextStyle(fontSize: 16),
    //                 overflow: TextOverflow.ellipsis,
    //               ),
    //             ),
    //           ),
    //         if (_listSurcharges.isNotEmpty)
    //           const Text(
    //             'Phụ thu: ',
    //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //           ),
    //         if (_listSurcharges.isNotEmpty)
    //           for (final sur in _listSurchargeObjects)
    //             Padding(
    //               padding: const EdgeInsets.only(left: 10),
    //               child: SizedBox(
    //                 width: 70.w,
    //                 child: Text(
    //                   '- ${json.decode(sur['note'])} - ${sur['gcoinAmount']} GCOIN',
    //                   style: const TextStyle(fontSize: 16),
    //                   overflow: TextOverflow.ellipsis,
    //                 ),
    //               ),
    //             )
    //       ],
    //     ),
    //   ),
    //   btnOkColor: Colors.blue,
    //   btnOkOnPress: () async {
    //     if (widget.isClone) {
    //       AwesomeDialog(
    //         context: context,
    //         dialogType: DialogType.question,
    //         animType: AnimType.leftSlide,
    //         title: 'Bạn có muốn đánh giá cho kế hoạch bạn đã tham khảo không',
    //         titleTextStyle:
    //             const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //         btnOkText: 'Có',
    //         btnOkOnPress: () {},
    //         btnOkColor: Colors.orange,
    //         btnCancelColor: Colors.blue,
    //         btnCancelText: 'Không',
    //         btnCancelOnPress: () {
    //           Utils().clearPlanSharePref();
    //           Navigator.of(context).pop();
    //           Navigator.of(context).pushAndRemoveUntil(
    //             MaterialPageRoute(
    //                 builder: (ctx) => const TabScreen(
    //                       pageIndex: 1,
    //                     )),
    //             (route) => false,
    //           );
    //         },
    //       ).show();
    //     } else {
    //       if (memberLimit == 1) {
    //         Utils().clearPlanSharePref();
    //         Navigator.of(context).pop();
    //         Navigator.of(context).pushAndRemoveUntil(
    //           MaterialPageRoute(
    //               builder: (ctx) => const TabScreen(
    //                     pageIndex: 1,
    //                   )),
    //           (route) => false,
    //         );
    //       } else {
    //         final startTime =
    //             DateTime.parse(sharedPreferences.getString('plan_start_time')!);
    //         final departureDate = DateTime.parse(
    //                 sharedPreferences.getString('plan_departureDate')!)
    //             .add(Duration(hours: startTime.hour))
    //             .add(Duration(minutes: startTime.minute));
    //         final rs = await _planService.completeCreatePlan(
    //             PlanCreate(
    //                 locationId: widget.location.id,
    //                 name: sharedPreferences.getString('plan_name'),
    //                 latitude: sharedPreferences.getDouble('plan_start_lat')!,
    //                 longitude: sharedPreferences.getDouble('plan_start_lng')!,
    //                 memberLimit:
    //                     sharedPreferences.getInt('plan_number_of_member') ?? 1,
    //                 savedContacts: json
    //                     .decode(sharedPreferences
    //                         .getString('plan_saved_emergency')!)
    //                     .toString(),
    //                 startDate: DateTime.parse(
    //                     sharedPreferences.getString('plan_start_date')!),
    //                 departureDate: departureDate,
    //                 schedule: sharedPreferences.getString('plan_schedule'),
    //                 gcoinBudget: ((total / memberLimit) / 100).ceil()),
    //             sharedPreferences.getInt('planId')!,
    //             _listSurchargeObjects.toString()
    //             );
    //         if (rs != 0) {
    //           Utils().clearPlanSharePref();

    //           Navigator.of(context).pop();

    //           Navigator.of(context).pushAndRemoveUntil(
    //             MaterialPageRoute(
    //                 builder: (ctx) => const TabScreen(
    //                       pageIndex: 1,
    //                     )),
    //             (route) => false,
    //           );
    //         }
    //       }
    //     }
    //   },
    // ).show();
  }

  callbackSurcharge(String amount, String note) {
    setState(() {
      _listSurcharges.add(SurchargeCard(amount: amount, note: note));
      totalSurcharge += int.parse(amount) * 100;
      total += int.parse(amount) * 100;
      _listSurchargeObjects
          .add({'note': json.encode(note), 'gcoinAmount': amount});
      print(_listSurchargeObjects.toString());
    });
  }

  onCompletePlan() async {
    if (widget.isClone) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        animType: AnimType.leftSlide,
        title: 'Bạn có muốn đánh giá cho kế hoạch bạn đã tham khảo không',
        titleTextStyle:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        btnOkText: 'Có',
        btnOkOnPress: () {},
        btnOkColor: Colors.orange,
        btnCancelColor: Colors.blue,
        btnCancelText: 'Không',
        btnCancelOnPress: () {
          Utils().clearPlanSharePref();
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (ctx) => const TabScreen(
                      pageIndex: 1,
                    )),
            (route) => false,
          );
        },
      ).show();
    } else {
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
          Utils().clearPlanSharePref();
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (ctx) => const TabScreen(
                      pageIndex: 1,
                    )),
            (route) => false,
          );
        }
      }
    }
  }
}
