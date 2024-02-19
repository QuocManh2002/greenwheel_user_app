// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/service/offline_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline_member.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen(
      {super.key, required this.location, required this.isClone, this.isOrder});
  final LocationViewModel location;
  final bool isClone;
  final bool? isOrder;

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  final PlanService _planService = PlanService();
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];
  DateTime? startDate;
  DateTime? endDate;
  int? numberOfMember;
  final OfflineService _offlineService = OfflineService();
  List<OrderViewModel>? orderList = [];
  List<OrderViewModel>? listRestaurantOrder = [];
  List<OrderViewModel>? listMotelOrder = [];
  num total = 0;
  num memberLimit = sharedPreferences.getInt('plan_number_of_member')!;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    setUpData();
  }

  setUpData() async {
    final duration = sharedPreferences.getInt('numOfExpPeriod');
    startDate = DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    // endDate = startDate!.add(Duration(days: (duration!/2).ceil()));
    endDate = DateTime.parse(sharedPreferences.getString('plan_end_date')!);
    numberOfMember = sharedPreferences.getInt('plan_number_of_member');
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
        listRestaurant.add(SupplierOrderCard(order: item, startDate: startDate!));
        listRestaurantOrder!.add(item);
      } else {
        listMotel.add(SupplierOrderCard(order: item, startDate: startDate!,));
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
      total += order.total;
    }
    final budget = ((total / memberLimit)/1000).ceil();
    sharedPreferences.setInt('plan_budget', budget);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text((widget.isOrder != null && widget.isOrder! )? 'Thêm dịch vụ': 'Tạo đơn hàng mẫu'),
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    )
                  ]),
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: _listRestaurant.isEmpty && _listMotel.isEmpty ? 50.h : 46.h,
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(total)} VND',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Khoản thu bình quân: ',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(((total / memberLimit)/1000).ceil())} GCOIN',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 12,
              ),
              // ElevatedButton(
              //     style: elevatedButtonStyle,
              //     onPressed: () {
              //       final dateNotFullyService = checkFullyTimeService();
              //       if (dateNotFullyService == null) {
              //         AwesomeDialog(
              //                 context: context,
              //                 dialogType: DialogType.info,
              //                 body: Padding(
              //                   padding: const EdgeInsets.all(12),
              //                   child: Column(
              //                       mainAxisAlignment: MainAxisAlignment.start,
              //                       crossAxisAlignment: CrossAxisAlignment.start,
              //                       children: [
              //                         Container(
              //                           alignment: Alignment.center,
              //                           child: const Text(
              //                             'Xác nhận thông tin dịch vụ',
              //                             style: TextStyle(
              //                                 fontSize: 18,
              //                                 fontWeight: FontWeight.bold),
              //                             textAlign: TextAlign.center,
              //                           ),
              //                         ),
              //                         const SizedBox(
              //                           height: 16,
              //                         ),
              //                         if (_listRestaurant.isNotEmpty)
              //                           for (final order in listRestaurantOrder!)
              //                             Padding(
              //                               padding: const EdgeInsets.only(
              //                                   left: 16, right: 16),
              //                               child: Text(
              //                                 '${order.supplierName} đã đặt ${order.details!.length} đơn dịch vụ - ${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(order.total)} VND',
              //                                 style: const TextStyle(fontSize: 16),
              //                               ),
              //                             ),
              //                         const SizedBox(
              //                           height: 8,
              //                         ),
              //                         if (_listMotel.isNotEmpty)
              //                           for (final order in listMotelOrder!)
              //                             Padding(
              //                               padding: const EdgeInsets.only(
              //                                   left: 16, right: 16),
              //                               child: Text(
              //                                 '${order.supplierName} đã đặt ${order.details!.length} đơn dịch vụ - ${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(order.total)} VND',
              //                                 style: const TextStyle(fontSize: 16),
              //                               ),
              //                             ),
              //                         const SizedBox(
              //                           height: 16,
              //                         ),
              //                         Padding(
              //                           padding: const EdgeInsets.symmetric(
              //                               horizontal: 16),
              //                           child: Row(
              //                             mainAxisAlignment:
              //                                 MainAxisAlignment.spaceBetween,
              //                             children: [
              //                               const Text(
              //                                 'Tổng cộng: ',
              //                                 style: TextStyle(
              //                                     fontSize: 18,
              //                                     fontWeight: FontWeight.bold),
              //                               ),
              //                               Text(
              //                                   '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(total)} VND')
              //                             ],
              //                           ),
              //                         )
              //                       ]),
              //                 ),
              //                 btnOkColor: Colors.blue,
              //                 btnOkText: 'Xác nhận',
              //                 btnOkOnPress: () {
              //                   completeService();
              //                 },
              //                 btnCancelColor: Colors.orange,
              //                 btnCancelText: 'Chỉnh sửa',
              //                 btnCancelOnPress: () {})
              //             .show();
              //       } else {
              //         AwesomeDialog(
              //                 context: context,
              //                 dialogType: DialogType.info,
              //                 body: Center(
              //                   child: Padding(
              //                     padding: const EdgeInsets.all(12),
              //                     child: Text(
              //                       'Ngày ${dateNotFullyService.day}/${dateNotFullyService.month}/${dateNotFullyService.year} chưa được đặt dịch vụ, bạn có chắc chắn muốn hoàn tất',
              //                       style: const TextStyle(fontSize: 16),
              //                       textAlign: TextAlign.center,
              //                     ),
              //                   ),
              //                 ),
              //                 btnOkText: 'Xác nhận',
              //                 btnOkOnPress: () {
              //                   completeService();
              //                 },
              //                 btnOkColor: Colors.blue,
              //                 btnCancelColor: Colors.orange,
              //                 btnCancelOnPress: () {},
              //                 btnCancelText: 'Chỉnh sửa')
              //             .show();
              //       }
              //     },
              //     child: const Text('Hoàn tất')),
        
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
    //             phone: sharedPreferences
    //                 .getString('userPhone')!,
    //             isLeading: true)
    //       ]));
    // }
  }

  completeService() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      body: const Column(
        children: [
          Text(
            'Thêm dịch vụ thành công',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      btnOkColor: primaryColor,
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
      },
    ).show();
  }
}
