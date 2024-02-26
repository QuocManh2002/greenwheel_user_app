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
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline_member.dart';
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
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];
  List<Widget> _listSurcharges = [];
  DateTime? startDate;
  DateTime? endDate;
  int? numberOfMember;
  final OfflineService _offlineService = OfflineService();
  List<OrderViewModel>? orderList = [];
  List<OrderViewModel>? listRestaurantOrder = [];
  List<OrderViewModel>? listMotelOrder = [];
  num total = 0;
  String activitiesText = '';
  num memberLimit = sharedPreferences.getInt('plan_number_of_member')!;

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
    // endDate = startDate!.add(Duration(days: (duration!/2).ceil()));
    endDate = DateTime.parse(sharedPreferences.getString('plan_end_date')!);
    numberOfMember = sharedPreferences.getInt('plan_number_of_member');
    await callback();
  }

  callback() async {
    orderList = await _planService
        .getOrderCreatePlan(sharedPreferences.getInt('planId')!);

    List<Widget> listRestaurant = [];
    List<Widget> listMotel = [];
    listMotelOrder = [];
    listRestaurantOrder = [];

    // orderList!.add(order);
    total = 0;
    for (var item in orderList!) {
      if (item.type == 'FOOD') {
        listRestaurant
            .add(SupplierOrderCard(order: item, startDate: startDate!));
        listRestaurantOrder!.add(item);
      } else {
        listMotel.add(SupplierOrderCard(
          order: item,
          startDate: startDate!,
        ));
        listMotelOrder!.add(item);
      }
    }
    if (orderList!.isNotEmpty) {
      setState(() {
        _listMotel = listMotel;
        _listRestaurant = listRestaurant;
      });
    }
    for (final order in orderList!) {
      total += getTotal(order);
    }
    final budget = ((total / memberLimit) / 100).ceil();
    if (sharedPreferences.getInt('plan_number_of_member')! != 1) {
      sharedPreferences.setInt('plan_budget', budget);
    }
  }

  getTotal(OrderViewModel order) {
    var total = 0.0;
    for (final detail in order.details!) {
      total += detail.unitPrice * detail.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text((widget.isOrder != null && widget.isOrder!)
              ? 'Thêm dịch vụ'
              : 'Tạo đơn hàng mẫu'),
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
                      Container(
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
                        text: "(${_listRestaurant.length})",
                        icon: const Icon(Icons.room_service),
                      )
                  ]),
              Container(
                margin: const EdgeInsets.only(top: 8),
                height:
                    _listRestaurant.isEmpty && _listMotel.isEmpty ? 50.h : 46.h,
                child: TabBarView(controller: tabController, children: [
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
                            '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(total)} VND',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
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
              // const SizedBox(
              //   height: 12,
              // ),
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
                                                '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(total)} VND')
                                          ],
                                        ),
                                      )
                                    ]),
                              ),
                              btnOkColor: Colors.blue,
                              btnOkText: 'Xác nhận',
                              btnOkOnPress: () async {
                                // if (widget.memberLimit == 1) {
                                completeService();
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

                      completeService();
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

  completeService() {
    final startDate =
        DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    final endDate =
        DateTime.parse(sharedPreferences.getString('plan_end_date')!);
    final scheduleList =
        json.decode(sharedPreferences.getString('plan_schedule')!);
    final emergencyList =
        json.decode(sharedPreferences.getString('plan_saved_emergency')!);

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Xác nhận kế hoạch chuyến đi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              '${sharedPreferences.getString('plan_name')}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Số lượng thành viên: ${sharedPreferences.getInt('plan_number_of_member')}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Địa điểm: ${widget.location.name}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Ngày bắt đầu: ${startDate.day}/${startDate.month}/${startDate.year}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Ngày kết thúc: ${endDate.day}/${endDate.month}/${endDate.year}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Thời gian di chuyển: ${sharedPreferences.getString('plan_duration_text')}',
              style: const TextStyle(fontSize: 16),
            ),
            const Text(
              'Lịch trình: ',
              style: TextStyle(fontSize: 16),
            ),
            for (final day in scheduleList)
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: SizedBox(
                  width: 60.w,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngày ${scheduleList.indexOf(day) + 1}: ',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        width: 45.w,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // child: Text(
                              for (final event in day['events'])
                                Text(
                                  '${json.decode(event['shortDescription'])}, ',
                                  style: const TextStyle(fontSize: 16),
                                )
                              // ),
                            ]),
                        // child: Text(
                        //   for (final event in day['events'])
                        //   '${json.decode(event['shortDescription'])}, '
                        // ),
                      ),
                      // for (final event in day['events'])
                      //   Text(
                      //     '${json.decode(event['shortDescription'])}, ',
                      //     style: const TextStyle(fontSize: 16),
                      //   )
                    ],
                  ),
                ),
              ),
            const Text(
              'Liên lạc khẩn cấp đã lưu: ',
              style: TextStyle(fontSize: 16),
            ),
            for (final emer in emergencyList)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '0${emer['phone'].toString().substring(4, emer['phone'].toString().length - 1)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${json.decode(emer['name'])}',
                      style: const TextStyle(fontSize: 16),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
      btnOkColor: Colors.blue,
      btnOkOnPress: () async {
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
            final startTime = DateTime.parse(sharedPreferences.getString('plan_start_time')!);
            final departureDate = DateTime.parse(sharedPreferences.getString('plan_departureDate')!).add(Duration(hours: startTime.hour)).add(Duration(minutes: startTime.minute));
            final rs = await _planService.completeCreatePlan(
                PlanCreate(
                    locationId: widget.location.id,
                    name: sharedPreferences.getString('plan_name'),
                    latitude: sharedPreferences.getDouble('plan_start_lat')!,
                    longitude: sharedPreferences.getDouble('plan_start_lng')!,
                    memberLimit:
                        sharedPreferences.getInt('plan_number_of_member') ?? 1,
                    savedContacts: json
                        .decode(sharedPreferences
                            .getString('plan_saved_emergency')!)
                        .toString(),
                    startDate: DateTime.parse(
                        sharedPreferences.getString('plan_start_date')!),
                    departureDate: departureDate,
                    schedule: sharedPreferences.getString('plan_schedule'),
                    gcoinBudget: ((total / memberLimit) / 100).ceil()),
                sharedPreferences.getInt('planId')!);
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
      },
    ).show();
  }

  callbackSurcharge(String amount, String note) {
    setState(() {
      total += int.parse(amount) * 100;
      _listSurcharges.add(SurchargeCard(amount: amount, note: note));
    });
  }
}
