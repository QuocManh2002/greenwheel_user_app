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
import 'package:greenwheel_user_app/screens/plan_screen/create_note_screen.dart';
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
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_plan_bottom_sheet.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/confirm_service_infor.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/surcharge_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:greenwheel_user_app/widgets/test_screen.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen({
    super.key,
    required this.memberLimit,
    required this.location,
    required this.isClone,
    this.isOrder,
  });
  final LocationViewModel location;
  final bool isClone;
  final bool? isOrder;
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
  int tabIndex = 0;
  PlanCreate? plan;
  TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(
        length: memberLimit == 1 ? 2 : 3, vsync: this, initialIndex: 0);
    setUpData();
  }

  setUpData() async {
    startDate = DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    endDate = DateTime.parse(sharedPreferences.getString('plan_end_date')!);
    numberOfMember = sharedPreferences.getInt('plan_number_of_member');
    callback(null);
    callbackSurcharge();
  }

  callback(String? orderGuid) {
    final orderText = sharedPreferences.getString('plan_temp_order');
    if (orderText != null) {
      orderList = json.decode(orderText);
      List<Widget> listRestaurant = [];
      List<Widget> listMotel = [];
      listMotelOrder = [];
      listRestaurantOrder = [];
      totalFood = 0;
      totalRest = 0;
      for (var item in orderList!) {
        List<OrderDetailViewModel> details = [];
        for (final detail in item['details']) {
          details.add(OrderDetailViewModel(
              productId: detail['productId'],
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
            supplier: SupplierViewModel(
                id: item['supplierId'],
                name: item['supplierName'],
                phone: item['supplierPhone'],
                thumbnailUrl: item['supplierImageUrl'],
                address: item['supplierAddress']));

        if (item['type'] == 'MEAL') {
          listRestaurant.add(SupplierOrderCard(
            order: temp,
            startDate: startDate!,
            isTempOrder: false,
            callback: (String? guid) {},
          ));
          listRestaurantOrder!.add(temp);
          totalFood += double.parse(item['total'].toString());
        } else {
          listMotel.add(SupplierOrderCard(
            order: temp,
            startDate: startDate!,
            isTempOrder: false,
            callback: (String? guid) {},
          ));
          listMotelOrder!.add(temp);
          totalRest += double.parse(item['total'].toString());
        }
      }
      if (orderList!.isNotEmpty) {
        setState(() {
          _listMotel = listMotel;
          _listRestaurant = listRestaurant;
        });
      }

      getTotal();
    }
  }

  getOrderTotal(OrderViewModel order) {
    var _total = 0.0;
    for (final detail in order.details!) {
      _total += detail.price! * detail.quantity;
    }
    return _total;
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
                                      .getDouble('plan_duration_value')! * 3600)
                              .toInt()))
                      : null;
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => SizedBox(
                    height: 80.h,
                    child: ConfirmPlanBottomSheet(
                          isJoin: false,
                          locationName: widget.location.name,
                          isInfo: true,
                          orderList: orderList,
                          total: total.toDouble()/100,
                          budgetPerCapita: (total/100)  /sharedPreferences
                                  .getInt('plan_number_of_member')!,
                          plan: PlanCreate(
                              endDate:
                                  sharedPreferences.getString('plan_end_date') == null
                                      ? null
                                      : DateTime.parse(sharedPreferences
                                          .getString('plan_end_date')!),
                              memberLimit: sharedPreferences
                                  .getInt('plan_number_of_member'),
                              departureDate: sharedPreferences
                                          .getString('plan_departureDate') ==
                                      null
                                  ? null
                                  : DateTime.parse(sharedPreferences
                                      .getString('plan_departureDate')!),
                              name: sharedPreferences.getString('plan_name'),
                              schedule:
                                  sharedPreferences.getString('plan_schedule'),
                              note: sharedPreferences.getString('plan_note'),
                              savedContacts: sharedPreferences
                                  .getString('plan_saved_emergency'),
                              travelDuration: _travelDuration ==
                                      null
                                  ? null
                                  : DateFormat.Hm().format(_travelDuration)),
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
                    Container(
                      height: 2,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
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
                    // SizedBox(
                    //   height: 1.h,
                    // ),
                    // if (memberLimit != 1)
                    //   Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 12),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         const Text(
                    //           'Khoản thu bình quân: ',
                    //           style: TextStyle(
                    //               fontSize: 18, fontWeight: FontWeight.bold),
                    //         ),
                    //         Text(
                    //           '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(((total / memberLimit) / 100).ceil())} GCOIN',
                    //           style: const TextStyle(fontSize: 18),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // if (memberLimit != 1)
                    //   const SizedBox(
                    //     height: 16,
                    //   )
                  ],
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
                                side: BorderSide(
                                    color: primaryColor, width: 2)))),
                    child: const Text('Quay lại'),
                  )),
                  SizedBox(
                    width: 1.h,
                  ),
                  Expanded(
                    child: ElevatedButton(
                        style: elevatedButtonStyle,
                        onPressed: () async {
                          AwesomeDialog(
                              context: context,
                              animType: AnimType.bottomSlide,
                              dialogType: DialogType.question,
                              title:
                                  'Bạn có muốn thêm ghi chú cho chuyến đi hay không ?',
                              titleTextStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              btnOkColor: Colors.blue,
                              btnOkOnPress: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => CreateNoteScreen(onCompletePlan: completeService,)));
                              },
                              btnOkText: 'Có',
                              btnCancelText: 'Không',
                              btnCancelColor: Colors.orangeAccent,
                              btnCancelOnPress: () {
                                completeService(context);
                              }).show();
                        },
                        child: const Text('Tiếp tục')),
                  ),
                ],
              ),
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
        startDate:
            DateTime.parse(sharedPreferences.getString('plan_start_date')!),
        departureDate: departureDate,
        schedule: sharedPreferences.getString('plan_schedule'),
        endDate: DateTime.parse(sharedPreferences.getString('plan_end_date')!),
        travelDuration: DateFormat.Hm().format(_travelDuration),
        tempOrders: _orderService.convertTempOrders(orderList!).toString(),
        note: sharedPreferences.getString('plan_note'),
        gcoinBudget: ((total / memberLimit) / 100).ceil());
    showModalBottomSheet(
        backgroundColor: Colors.white.withOpacity(0.94),
        context: context,
        isScrollControlled: true,
        builder: (ctx) => SizedBox(
              height: 90.h,
              child: ConfirmPlanBottomSheet(
                isInfo: false,
                locationName: widget.location.name,
                total: (total / 100).toDouble(),
                budgetPerCapita:
                    ((total / memberLimit) / 100).ceil().toDouble(),
                orderList: orderList!,
                onCompletePlan: onCompletePlan,
                plan: plan,
                onJoinPlan: () {},
                listSurcharges: _listSurchargeObjects,
                isJoin: false,
              ),
            ));
  }

  callbackSurcharge() {
    String? surchargeText = sharedPreferences.getString('plan_surcharge');
    List<Widget> listSurcharges = [];
    _listSurchargeObjects = [];
    if (surchargeText != null) {
      final surcharges = json.decode(surchargeText);
      for (final sur in surcharges) {
        listSurcharges.add(SurchargeCard(
            amount: sur['gcoinAmount'], note: json.decode(sur['note'])));
        totalSurcharge += int.parse(sur['gcoinAmount']) * 100;
        total += int.parse(sur['gcoinAmount'].toString()) * 100;
        _listSurchargeObjects.add(sur);
      }
    }
    setState(() {
      _listSurcharges = listSurcharges;
    });
    sharedPreferences.setString(
        'plan_surcharge', json.encode(_listSurchargeObjects));
    getTotal();
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

  getTotal() {
    total = 0;
    for (final order in listMotelOrder!) {
      // total += getOrderTotal(order);
      total += order.total!;
    }
    for (final order in listRestaurantOrder!) {
      // total += getOrderTotal(order);
      total += order.total!;
    }
    for (final sur in _listSurchargeObjects) {
      total += double.parse(sur['gcoinAmount'].toString()) * 100;
    }

    final budget = ((total / memberLimit) / 100).ceil();
    if (sharedPreferences.getInt('plan_number_of_member')! != 1) {
      sharedPreferences.setInt('plan_budget', budget);
    }
  }
}
