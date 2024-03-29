import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanOrderCard extends StatefulWidget {
  const PlanOrderCard({super.key, required this.order, required this.isLeader});
  final OrderViewModel order;
  final bool isLeader;

  @override
  State<PlanOrderCard> createState() => _PlanOrderCardState();
}

class _PlanOrderCardState extends State<PlanOrderCard> {
  bool isShowDetail = false;
  List<OrderDetailViewModel> details = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final tmp = widget.order.details!.groupListsBy((element) => element.productId);
    for(final temp in tmp.values){
      details.add(temp.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 0.5.h,
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.7),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Text(
                    '${widget.order.type == 'LODGING' ? 'Nghỉ tại ' : 'Dùng bữa tại '}${Utils().getSupplierType(widget.order.supplier!.type!)}',
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                if (widget.isLeader)
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        isShowDetail = !isShowDetail;
                      });
                    },
                    child: Icon(
                      isShowDetail
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: primaryColor,
                      size: 40,
                    ),
                  )
              ],
            ),
            SizedBox(
              height: 0.5.h,
            ),
            Row(
              children: [
                SizedBox(
                  width: 2.w,
                ),
                SizedBox(
                  width: 45.w,
                  child: Text(
                    '${Utils().getPeriodString(widget.order.period!)['text']} ${Utils().buildServingDatesText(widget.order.serveDates!)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'NotoSans',
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  NumberFormat.simpleCurrency(
                          locale: 'vi_VN', decimalDigits: 0, name: '')
                      .format(widget.order.total! / 100),
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSans'),
                ),
                SvgPicture.asset(
                  gcoin_logo,
                  height: 25,
                )
              ],
            ),
            if (isShowDetail)
              for (final detail in details)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Row(
                    children: [
                      Text(
                        detail.productName,
                        style:const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'NotoSans'),
                      ),
                      const Spacer(),
                      Text('x${detail.quantity}',
                        style:const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'NotoSans'),),
                    ],
                  ),
                )
          ],
        ),
      ),
    );
  }
}
