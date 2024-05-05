import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/bottom_sheet_container_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleActivityView extends StatefulWidget {
  const PlanScheduleActivityView(
      {super.key,
      required this.isLeader,
      required this.item,
      required this.order});
  final PlanScheduleItem item;
  final bool isLeader;
  final dynamic order;

  @override
  State<PlanScheduleActivityView> createState() =>
      _PlanScheduleActivityViewState();
}

class _PlanScheduleActivityViewState extends State<PlanScheduleActivityView> {
  bool isLoading = true;
  List<int> ids = [];
  List<ProductViewModel>? products = [];
  dynamic _order;
  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    if (!widget.isLeader || widget.item.orderUUID == null) {
      setState(() {
        isLoading = false;
      });
    } else {
      if (widget.order.runtimeType == OrderViewModel) {
        _order = widget.order;
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 6, right: 6),
      child: InkWell(
        onTap: () {
          if (!isLoading) {
            showModalBottomSheet(
                context: context,
                builder: (ctx) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 23, vertical: 8),
                      child: SizedBox(
                        width: 100.w,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 2.h,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.6),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12))),
                              height: 6,
                              width: 10.h,
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            BottomSheetContainerWidget(
                                content: widget.item.shortDescription!,
                                title: 'Mô tả'),
                            SizedBox(
                              height: 1.h,
                            ),
                            BottomSheetContainerWidget(
                                content: widget.item.description!,
                                title: 'Chi tiết'),
                            SizedBox(
                              height: 1.h,
                            ),
                            BottomSheetContainerWidget(
                                content:
                                    '${widget.item.activityTime!.inHours > 0 ? '${widget.item.activityTime!.inHours} giờ' : ''}${widget.item.activityTime!.inMinutes.remainder(60) > 0 ? ' ${widget.item.activityTime!.inMinutes.remainder(60)} phút' : ''}',
                                title: 'Thời gian'),
                            SizedBox(
                              height: 2.h,
                            ),
                            if (widget.item.orderUUID != null &&
                                widget.isLeader)
                              Container(
                                width: 100.w,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Colors.black12,
                                        offset: Offset(1, 3),
                                      )
                                    ],
                                    color: Colors.white.withOpacity(0.97),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Chi tiết dự trù kinh phí',
                                      style: TextStyle(
                                          fontSize: 16, fontFamily: 'NotoSans'),
                                    ),
                                    // if (_order['details'] != null)
                                    //   for (final detail in _order['details'])
                                    //     Row(
                                    //       mainAxisAlignment:
                                    //           MainAxisAlignment.spaceBetween,
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: [
                                    //         SizedBox(
                                    //           width: 65.w,
                                    //           child: Text(
                                    //             detail['productName'],
                                    //             style: const TextStyle(
                                    //                 fontSize: 18,
                                    //                 fontWeight: FontWeight.bold,
                                    //                 fontFamily: 'NotoSans'),
                                    //             overflow: TextOverflow.clip,
                                    //           ),
                                    //         ),
                                    //         SizedBox(
                                    //           width: 15.w,
                                    //           child: Text(
                                    //             'x${detail['quantity']}',
                                    //             textAlign: TextAlign.end,
                                    //             style: const TextStyle(
                                    //                 fontSize: 18,
                                    //                 fontWeight: FontWeight.bold,
                                    //                 fontFamily: 'NotoSans'),
                                    //             overflow: TextOverflow.clip,
                                    //           ),
                                    //         )
                                    //       ],
                                    //     ),
                                    if (_order.details != null)
                                      for (final detail in _order.details)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 60.w,
                                              child: Text(
                                                detail.productName,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'NotoSans'),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 15.w,
                                              child: Text(
                                                'x${detail.quantity}',
                                                textAlign: TextAlign.end,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'NotoSans'),
                                                overflow: TextOverflow.clip,
                                              ),
                                            )
                                          ],
                                        ),
                                    // if (_order['cart'] != null)
                                    //   for (final detail
                                    //       in _order['cart'].entries)
                                    //     Row(
                                    //       mainAxisAlignment:
                                    //           MainAxisAlignment.spaceBetween,
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: [
                                    //         SizedBox(
                                    //           width: 65.w,
                                    //           child: Text(
                                    //             products!
                                    //                 .firstWhere((element) =>
                                    //                     element.id ==
                                    //                     int.parse(detail.key))
                                    //                 .name,
                                    //             style: const TextStyle(
                                    //                 fontSize: 18,
                                    //                 fontWeight: FontWeight.bold,
                                    //                 fontFamily: 'NotoSans'),
                                    //             overflow: TextOverflow.clip,
                                    //           ),
                                    //         ),
                                    //         SizedBox(
                                    //           width: 15.w,
                                    //           child: Text(
                                    //             detail.value.toString(),
                                    //             textAlign: TextAlign.end,
                                    //             style: const TextStyle(
                                    //                 fontSize: 18,
                                    //                 fontWeight: FontWeight.bold,
                                    //                 fontFamily: 'NotoSans'),
                                    //             overflow: TextOverflow.clip,
                                    //           ),
                                    //         )
                                    //       ],
                                    //     ),
                                    SizedBox(
                                      height: 0.5.h,
                                    ),
                                    const Divider(
                                      color: Colors.black54,
                                      height: 2,
                                    ),
                                    SizedBox(
                                      height: 0.5.h,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tổng cộng',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'NotoSans'),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: 45.w,
                                          child: Text(
                                            NumberFormat.simpleCurrency(
                                                    locale: 'vi_VN',
                                                    decimalDigits: 0,
                                                    name: '')
                                                .format(_order.total),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'NotoSans',
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          gcoinLogo,
                                          height: 18,
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 0.5.h,
                                    )
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                    ));
          }
        },
        child: Container(
          width: 100.w,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              color: const Color(0xFFf2f2f2),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 3,
                  color: Colors.black12,
                  offset: Offset(2, 4),
                )
              ],
              border: widget.item.isStarred != null && widget.item.isStarred!
                  ? Border.all(color: Colors.amber, width: 2)
                  : widget.item.type == 'Ăn uống' ||
                          widget.item.type == 'Check-in'
                      ? Border.all(color: primaryColor, width: 2)
                      : const Border(),
              borderRadius: const BorderRadius.all(Radius.circular(12))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 65.w,
                      child: Text(
                        widget.item.shortDescription ?? 'Không có mô tả',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    const Spacer(),
                    if (widget.item.type == 'Ăn uống' ||
                        widget.item.type == 'Check-in')
                      Icon(
                        widget.item.type == 'Ăn uống'
                            ? Icons.restaurant
                            : Icons.hotel,
                        color: primaryColor,
                      )
                  ],
                ),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                  color: widget.item.isStarred != null && widget.item.isStarred!
                      ? Colors.amber
                      : widget.item.type == 'Ăn uống' ||
                              widget.item.type == 'Check-in'
                          ? primaryColor
                          : Colors.black26,
                  height: 1.5,
                ),
                SizedBox(
                  height: 1.h,
                ),
                Row(
                  children: [
                    const Icon(Icons.watch_later_outlined),
                    SizedBox(
                      width: 1.h,
                    ),
                    Text(
                      '${widget.item.activityTime!.inHours > 0 ? '${widget.item.activityTime!.inHours} giờ' : ''}${widget.item.activityTime!.inMinutes.remainder(60) > 0 ? ' ${widget.item.activityTime!.inMinutes.remainder(60)} phút' : ''}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
