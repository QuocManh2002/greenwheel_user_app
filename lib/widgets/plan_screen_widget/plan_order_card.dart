import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:greenwheel_user_app/core/constants/service_types.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/screens/order_screen/detail_order_screen.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class PlanOrderCard extends StatefulWidget {
  const PlanOrderCard(
      {super.key,
      required this.isShowQuantity,
      required this.order,
      this.planStatus,
      required this.callback,
      required this.isLeader});
  final OrderViewModel order;
  final bool isLeader;
  final String? planStatus;
  final bool isShowQuantity;
  final void Function() callback;

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
    final tmp =
        widget.order.details!.groupListsBy((element) => element.productId);
    for (final temp in tmp.values) {
      details.add(temp.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () {
          if (widget.isLeader) {
            Navigator.push(
                context,
                PageTransition(
                    child: OrderDetailScreen(
                        order: widget.order,
                        planStatus: widget.planStatus,
                        startDate: DateTime.now(),
                        callback: widget.callback,
                        isTempOrder: false),
                    type: PageTransitionType.rightToLeft));
          }
        },
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Text(
                      widget.order.type == services[2].name
                          ? '${Utils().getSupplierType(widget.order.supplier!.type!)}'
                          : '${widget.order.type == services[1].name ? 'Nghỉ tại ' : 'Dùng bữa tại '}${Utils().getSupplierType(widget.order.supplier!.type!)}',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 2.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final day in widget.order.serveDates!)
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            '${widget.order.type != 'RIDING' ? '${Utils().getPeriodString(widget.order.period!)['text']} ' : ''}${DateFormat('dd/MM').format(day.runtimeType == String ? DateTime.parse(day) : day)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NotoSans',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 30.w,
                    child: Text(
                      NumberFormat.simpleCurrency(
                              locale: 'vi_VN', decimalDigits: 0, name: '')
                          .format(widget.order.id == null ? widget.order.total! : widget.order.total!/GlobalConstant().VND_CONVERT_RATE),
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSans'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SvgPicture.asset(gcoin_logo, height: 20,),
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
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'NotoSans'),
                        ),
                        const Spacer(),
                        if (widget.isShowQuantity)
                          Text(
                            'x${detail.quantity}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'NotoSans'),
                          ),
                      ],
                    ),
                  )
            ],
          ),
        ),
      ),
    );
  }
}
