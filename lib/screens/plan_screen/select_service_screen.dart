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
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:sizer2/sizer2.dart';

class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen({super.key, required this.location});
  final LocationViewModel location;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    setUpData();
  }

  setUpData() async {
    startDate = DateTime.parse(sharedPreferences.getString('plan_start_date')!);
    endDate = DateTime.parse(sharedPreferences.getString('plan_end_date')!);
    numberOfMember = sharedPreferences.getInt('plan_number_of_member');
  }

  callback(List<OrderViewModel> orderList) async {
    List<Widget> listRestaurant = [];
    List<Widget> listMotel = [];
    for (var item in orderList) {
      if (item.supplierType == "RESTAURANT") {
        listRestaurant.add(SupplierOrderCard(order: item));
      } else {
        listMotel.add(SupplierOrderCard(order: item));
      }
    }
    if (orderList.isNotEmpty) {
      setState(() {
        _listMotel = listMotel;
        _listRestaurant = listRestaurant;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thêm dịch vụ'),
          leading: BackButton(
            onPressed: () async {
              await saveToOffline();
              Utils().clearPlanSharePref();
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const TabScreen(pageIndex: 1)));
            },
          ),
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
                                    serviceType: services[1],
                                    location: widget.location,
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
                height:
                    _listRestaurant.isEmpty && _listMotel.isEmpty ? 50.h : 60.h,
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
              Spacer(),
              ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      body: const Column(
                        children: [
                          Text(
                            'Thêm dịch vụ thành công',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.all(8.0),
                          //   child: Text(
                          //     'Bạn có muốn lưu lại các dịch vụ khẩn cấp cho chuyến đi không?',
                          //     style: TextStyle(fontSize: 15),
                          //     textAlign: TextAlign.center,
                          //   ),
                          // )
                        ],
                      ),
                      // btnCancelText: "Không",
                      // btnCancelColor: Colors.blue,
                      // btnCancelOnPress: () async {
                      //   PlanDetail? plan = await _planService.GetPlanById(
                      //       sharedPreferences.getInt('planId')!);
                      //   if (plan != null) {
                      //     await _offlineService.savePlanToHive(
                      //         PlanOfflineViewModel(
                      //             id: plan.id,
                      //             name: plan.name,
                      //             imageBase64: await Utils()
                      //                 .getImageBase64Encoded(plan.imageUrls[0]),
                      //             startDate: plan.startDate,
                      //             endDate: plan.endDate,
                      //             memberLimit: plan.memberLimit,
                      //             schedule: plan.schedule,
                      //             memberList: [
                      //           PlanOfflineMember(
                      //               id: int.parse(
                      //                   sharedPreferences.getString('userId')!),
                      //               name: "Quoc Manh",
                      //               phone: sharedPreferences
                      //                   .getString('userPhone')!,
                      //               isLeading: true)
                      //         ]));
                      //   }
                      //   Utils().clearPlanSharePref();
                      //   Navigator.of(context).pop();
                      //   Navigator.of(context).push(MaterialPageRoute(
                      //       builder: (ctx) => const TabScreen(pageIndex: 1)));
                      // },
                      // btnOkText: "Có",
                      btnOkColor: primaryColor,
                      btnOkOnPress: () async {
                        PlanDetail? plan = await _planService.GetPlanById(
                            sharedPreferences.getInt('planId')!);
                                              if (plan != null) {
                          await _offlineService.savePlanToHive(
                              PlanOfflineViewModel(
                                  id: plan.id,
                                  name: plan.name,
                                  imageBase64: await Utils()
                                      .getImageBase64Encoded(plan.imageUrls[0]),
                                  startDate: plan.startDate,
                                  endDate: plan.endDate,
                                  memberLimit: plan.memberLimit,
                                  schedule: plan.schedule,
                                  memberList: [
                                PlanOfflineMember(
                                    id: int.parse(
                                        sharedPreferences.getString('userId')!),
                                    name: "Quoc Manh",
                                    phone: sharedPreferences
                                        .getString('userPhone')!,
                                    isLeading: true)
                              ]));
                        }
                        Utils().clearPlanSharePref();
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => const TabScreen(
                                  pageIndex: 1,
                                )));
                      },
                    ).show();
                  },
                  child: Text('Hoàn tất')),
              SizedBox(
                height: 3.h,
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
          name: plan.name,
          imageBase64: await Utils().getImageBase64Encoded(plan.imageUrls[0]),
          startDate: plan.startDate,
          endDate: plan.endDate,
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
}
