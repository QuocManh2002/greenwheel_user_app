import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/screens/order_screen/detail_order_screen.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class SupplierOrderCard extends StatelessWidget {
  const SupplierOrderCard({super.key,this.isFromTempOrder,this.availableGcoinAmount, this.memberLimit, this.endDate, required this.callback, required this.order, required this.startDate, required this.isTempOrder, this.planId});
  final OrderViewModel order;
  final DateTime startDate;
  final bool isTempOrder;
  final int? planId;
  final int? memberLimit;
  final DateTime? endDate;
  final bool? isFromTempOrder;
  final double? availableGcoinAmount;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    var total = 0.0;
    for(final detail in order.details!){
      total += detail.price! * detail.quantity;
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => OrderDetailScreen(
                  memberLimit: memberLimit,
                  availableGcoinAmount: availableGcoinAmount,
                  endDate: endDate,
                  order: order,
                  startDate: startDate,
                  isFromTempOrder: isFromTempOrder,
                  isTempOrder: isTempOrder,
                  planId: planId,
                  callback: callback,
                )));
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black12,
              offset: Offset(1, 3),
            )
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        height: 15.h,
        width: double.infinity,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: Row(children: [
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(14)),
              child: Hero(
                  tag: UniqueKey(),
                  child: FadeInImage(
                    height: 15.h,
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(order.supplier!.thumbnailUrl!),
                    fit: BoxFit.cover,
                    width: 15.h,
                    filterQuality: FilterQuality.high,
                  )),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 45.w,
                        child: Text(order.supplier!.name!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      if(order.id != null)
                      const Icon(Icons.check_circle, color: primaryColor, size: 30,)
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text("Đã đặt ${order.details!.length.toString()} sản phẩm"),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Tổng: ${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(total * order.serveDates!.length)} VND",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
