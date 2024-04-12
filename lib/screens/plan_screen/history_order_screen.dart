import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/loading_screen/service_supplier_loading_screen.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:sizer2/sizer2.dart';

class HistoryOrderScreen extends StatefulWidget {
  const HistoryOrderScreen({super.key, required this.planId});
  final int planId;

  @override
  State<HistoryOrderScreen> createState() => _HistoryOrderScreenState();
}

class _HistoryOrderScreenState extends State<HistoryOrderScreen> {
  final OrderService _orderService = OrderService();
  List<OrderViewModel>? _orderList = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData()async{
    final list = await _orderService.getOrderListByPlanId(widget.planId, context);
    if(list != null){
      setState(() {
        _orderList = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng'),
      ),
      body:
      _isLoading ?
      const ServiceSupplierLoadingScreen() :
      _orderList!.isEmpty ? 
        Column(
          children: [
            Image.asset(empty_plan, height: 50.w,),
            SizedBox(height: 1.h,),
            const Text('Chuyến đi này không có đơn hàng nào', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'NotoSans'
            ),)
          ],
        ):
       SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            for(final order in _orderList!)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SupplierOrderCard(
                callback: (d){}, 
                order: order, 
                startDate: DateTime.now(), 
                isTempOrder: false),
            )
          ],
        ),
      ),
    ));
  }
}
