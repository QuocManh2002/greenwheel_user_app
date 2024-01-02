import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_emergency_detail_service.dart';
import 'package:greenwheel_user_app/service/offline_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/service/supplier_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/order_screen_widget/supplier_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:sizer2/sizer2.dart';

class SelectEmergencyService extends StatefulWidget {
  const SelectEmergencyService(
      {super.key, required this.location, required this.planId});

  final int planId;

  final LocationViewModel location;

  @override
  State<SelectEmergencyService> createState() => _SelectEmergencyServiceState();
}

class _SelectEmergencyServiceState extends State<SelectEmergencyService>
    with TickerProviderStateMixin {
  late TabController tabController;

  bool isLoading = true;
  List<SupplierViewModel> listDiLai = [];
  List<SupplierViewModel> listTapHoa = [];
  List<SupplierViewModel> totalList = [];
  SupplierService _supplierService = SupplierService();
  PlanDetail? planDetail;
  PlanService _planService = PlanService();
  OfflineService _offlineService = OfflineService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    sharedPreferences.setStringList('serviceList', []);
  }

  getData() async {
    planDetail = await _planService.GetPlanById(widget.planId);
    totalList = await _supplierService.getSuppliers(
        widget.location.longitude,
        widget.location.latitude,
        ["REPAIR_SHOP", "TAXI", "VEHICLE_SHOP", "GROCERY"]);
  }

  callback() {
    List<String>? serviceList = sharedPreferences.getStringList('serviceList');
    final _selectedList = serviceList!
        .map((e) =>
            totalList.firstWhere((element) => element.id.toString() == e))
        .toList();
    setState(() {
      listDiLai = _selectedList
          .where((element) =>
              element.type == "REPAIR_SHOP" ||
              element.type == "TAXI" ||
              element.type == "VEHICLE_SHOP")
          .toList();
      listTapHoa =
          _selectedList.where((element) => element.type == "GROCERY").toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Dịch vụ khẩn cấp'),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(children: [
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
                                      builder: (ctx) =>
                                          SelectEmergencyDetailService(
                                            location: widget.location,
                                            planId: widget.planId,
                                            type: 0,
                                            callback: callback,
                                          )));
                                  break;
                                case 1:
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (ctx) =>
                                          SelectEmergencyDetailService(
                                            location: widget.location,
                                            planId: widget.planId,
                                            type: 1,
                                            callback: callback,
                                          )));
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
                        text: "(${listDiLai.length})",
                        icon: const Icon(Icons.car_crash),
                      ),
                      Tab(
                        text: "(${listTapHoa.length})",
                        icon: const Icon(Icons.shopping_cart),
                      )
                    ]),
                SizedBox(
                  height: listDiLai.isEmpty && listTapHoa.isEmpty ? 50.h : 60.h,
                  child: TabBarView(controller: tabController, children: [
                    listDiLai.isEmpty && listTapHoa.isEmpty
                        ? Image.asset(
                            empty_plan,
                            fit: BoxFit.cover,
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listDiLai.length,
                            itemBuilder: (context, index) {
                              return SupplierCard(
                                location: widget.location,
                                startDate: planDetail!.startDate,
                                endDate: planDetail!.endDate,
                                serviceType: services[4],
                                numberOfMember: planDetail!.memberLimit,
                                supplier: listDiLai[index],
                              );
                            },
                          ),
                    listDiLai.isEmpty && listTapHoa.isEmpty
                        ? Image.asset(
                            empty_plan,
                            fit: BoxFit.cover,
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listTapHoa.length,
                            itemBuilder: (context, index) {
                              return SupplierCard(
                                location: widget.location,
                                startDate: planDetail!.startDate,
                                endDate: planDetail!.endDate,
                                serviceType: services[3],
                                numberOfMember: planDetail!.memberLimit,
                                supplier: listTapHoa[index],
                              );
                            },
                          ),
                  ]),
                ),
                Spacer(),
                ElevatedButton(
                    style: elevatedButtonStyle,
                    onPressed: () async {
                      List<int> serviceIds = [];
                      serviceIds.addAll(sharedPreferences
                          .getStringList('serviceList')!
                          .map((e) => int.parse(e))
                          .toList());
                      final plan_schedule = planDetail!.schedule;
                      final plan_schedule_list =
                          _planService.GetPlanScheduleFromJsonNew(
                              plan_schedule,
                              planDetail!.startDate,
                              planDetail!.endDate
                                      .difference(planDetail!.startDate)
                                      .inDays +
                                  1);
                      final rs = _planService
                          .convertPlanScheduleToJson(plan_schedule_list);
                      print(plan_schedule);
                      print(plan_schedule_list);
                      print(rs.toString());
                      print(serviceIds);
                      int? planId = await _planService.updateEmergencyService(
                          PlanCreate(
                              locationId: planDetail!.id,
                              startDate: planDetail!.startDate,
                              endDate: planDetail!.endDate,
                              latitude: widget.location.latitude,
                              longitude: widget.location.longitude,
                              memberLimit: planDetail!.memberLimit,
                              name: planDetail!.name,
                              schedule: rs.toString()),
                          serviceIds,
                          widget.planId);

                      if (planId != 0) {
                        print('Thanh cong');
                        print(planId);
                        // ignore: use_build_context_synchronously
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          body: const Text(
                            'Thêm dịch vụ thành công',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          btnOkColor: primaryColor,
                          btnOkOnPress: () async {
                            sharedPreferences.setStringList('serviceList', []);
                            // PlanDetail? plan = await _planService.GetPlanById(
                            //     sharedPreferences.getInt('planId')!);
                            // if (plan != null) {
                              await _offlineService.savePlanToHive(
                                  PlanOfflineViewModel(
                                      id: widget.planId,
                                      name: planDetail!.name,
                                      imageBase64: await Utils()
                                          .getImageBase64Encoded(
                                              planDetail!.imageUrls[0]),
                                      startDate: planDetail!.startDate,
                                      endDate: planDetail!.endDate,
                                      memberLimit: planDetail!.memberLimit,
                                      schedule: planDetail!.schedule,
                                      memberList: [
                                    PlanOfflineMember(
                                        id: int.parse(sharedPreferences
                                            .getString('userId')!),
                                        name: "Quoc Manh",
                                        phone: sharedPreferences
                                            .getString('userPhone')!,
                                        isLeading: true)
                                  ]));
                                  Utils().clearPlanSharePref();
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => const TabScreen(pageIndex: 1)));
                            }
                        ).show();
                      }
                    },
                    child: Text('Hoàn tất')),
                SizedBox(
                  height: 3.h,
                )
              ]),
            )));
  }
}
