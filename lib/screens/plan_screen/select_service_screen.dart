import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/plan_item.dart';
import 'package:greenwheel_user_app/models/supplier_order.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/order_plan.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
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
  PlanService _planService = PlanService();
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];
  List<PlanItem> planDetail = [];
  List<OrderCreatePlan> _orderList = [];
  DateTime? startDate;
  DateTime? endDate;
  int? numberOfMember;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    setUpData();
  }

  setUpData() async {}

  callback(List<OrderCreatePlan> orderList) async {
    List<Widget> listRestaurant = [];
    List<Widget> listMotel = [];
    for (var item in orderList) {
      if (item.type == "RESTAURANT") {
        listRestaurant.add(SupplierOrderCard(
            order: SupplierOrder(
                id: item.id,
                imgUrl: item.thumbnailUrl,
                price: item.deposit.toDouble(),
                quantity: item.details.length,
                supplierName: item.details[0].supplierName,
                type: item.type)));
      } else {
        listMotel.add(SupplierOrderCard(
            order: SupplierOrder(
                id: item.id,
                imgUrl: item.thumbnailUrl,
                price: item.deposit.toDouble(),
                quantity: item.details.length,
                supplierName: item.details[0].supplierName,
                type: item.type)));
      }
    }
    if (orderList.isNotEmpty) {
      PlanDetail? _planDetail =
          await _planService.GetPlanById(sharedPreferences.getInt("planId")!);

      setState(() {
        // planDetail = generateItems(
        //     _planDetail!.schedule, _planDetail.startDate, _planDetail.orders!);
        _listMotel = listMotel;
        _listRestaurant = listRestaurant;
        _orderList = orderList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
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
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (ctx) => const TestScreen()));
                      },
                      style: elevatedButtonStyle,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
