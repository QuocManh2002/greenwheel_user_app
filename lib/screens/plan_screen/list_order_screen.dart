import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:sizer2/sizer2.dart';

class ListOrderScreen extends StatelessWidget {
  const ListOrderScreen({super.key, required this.orders, required this.startDate, required this.planId, required this.callback});
  final List<OrderViewModel> orders;
  final DateTime startDate;
  final int planId;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Đặt dịch vụ'),
      ),
      body: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

        const Text('Các đơn hàng mẫu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
        SizedBox(height: 1.h,),
        SizedBox(height:75.h,
        child: ListView.builder(
          itemCount: orders.length,
          physics:const BouncingScrollPhysics(),
          itemBuilder: (ctx, index) => 
          SupplierOrderCard(callback: callback, order: orders[index], startDate: startDate, isTempOrder: true, planId: planId,)
        ),
        ),
        const Spacer(),
        Container(
          alignment: Alignment.center,
          child: ElevatedButton(onPressed: (){
            // Navigator.of(context).push(MaterialPageRoute(builder: ServiceMainScreen))
          }, 
          style: elevatedButtonStyle,
          child:const Text('Đặt đơn hàng mới')),
        ),
        SizedBox(height: 2.h,)
      ]),

      ),
    ));
  }
}
