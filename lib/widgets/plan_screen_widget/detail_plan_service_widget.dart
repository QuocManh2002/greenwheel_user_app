import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/screens/plan_screen/list_order_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class DetailPlanServiceWidget extends StatefulWidget {
  const DetailPlanServiceWidget({super.key, required this.plan});
  final PlanDetail plan;

  @override
  State<DetailPlanServiceWidget> createState() => _DetailPlanServiceWidgetState();
}

class _DetailPlanServiceWidgetState extends State<DetailPlanServiceWidget> with TickerProviderStateMixin {
  late TabController tabController;
  LocationService _locationService = LocationService();
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];
  double total = 0;
  List<ProductViewModel> products = [];
  List<OrderViewModel> tempOrders = [];
  List<OrderViewModel> orderList = [];
  double totalTempOrders = 0;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  getOrderList(String? tempOrderGuid) async {
    total = 0;
    // orderList = await _planService.getOrderCreatePlan(widget.plan.id)['orders'];
    List<Widget> listRestaurant = [];
    List<Widget> listMotel = [];
    for (var item in orderList) {
      if (item.type == 'MEAL') {
        listRestaurant.add(SupplierOrderCard(
          order: item,
          startDate: widget.plan.startDate!,
          isTempOrder: false,
          planId: widget.plan.id,
          callback: (String? guid) {},
        ));
      } else {
        listMotel.add(SupplierOrderCard(
          order: item,
          startDate: widget.plan.startDate!,
          isTempOrder: false,
          planId: widget.plan.id,
          callback: (String? guid) {},
        ));
      }
      total += item.total!;
    }
    if (tempOrderGuid != null) {
      final tempOrder = tempOrders.firstWhere(
        (element) => element.guid == tempOrderGuid,
      );
      setState(() {
        tempOrders.remove(tempOrder);
        widget.plan.currentGcoinBudget = widget.plan.currentGcoinBudget! -
            tempOrder.total! / 100.toDouble();
        _listMotel = listMotel;
        _listRestaurant = listRestaurant;
      });
    } else {
      setState(() {
        _listMotel = listMotel;
        _listRestaurant = listRestaurant;
      });
    }
  }

  getTempOrder() => widget.plan.tempOrders!.map((e) {
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
            supplier: SupplierViewModel(id: sampleProduct.supplierId!, name: sampleProduct.supplierName, phone: sampleProduct.supplierPhone, thumbnailUrl: sampleProduct.supplierThumbnailUrl, address: sampleProduct.supplierAddress),
            type: e['type'],
            period: e['period']);
      }).toList();
  
  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    onPressed: () async {
                      if (widget.plan.status == 'READY') {
                        final rs = await _locationService.GetLocationById(
                            widget.plan.locationId);
                        if (rs != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ListOrderScreen(
                                    planId: widget.plan.id,
                                    orders: tempOrders,
                                    startDate: widget.plan.startDate!,
                                    callback: getOrderList,
                                    endDate: widget.plan.endDate!,
                                    memberLimit: widget.plan.memberLimit,
                                    location: rs,
                                  )));
                        }
                      }
                    },
                    child: Text(
                      'Đi đặt hàng',
                      style: TextStyle(
                        color: widget.plan.status == 'READY'
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
                    text: "(${_listMotel.length})",
                    icon: const Icon(Icons.hotel),
                  ),
                  Tab(
                    text: "(${_listRestaurant.length})",
                    icon: const Icon(Icons.restaurant),
                  ),
                  Tab(
                    text: '(${widget.plan.surcharges!.length})',
                    icon: const Icon(Icons.account_balance_wallet),
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
                    '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(widget.plan.currentGcoinBudget! * 100)} VND',
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
  }
}