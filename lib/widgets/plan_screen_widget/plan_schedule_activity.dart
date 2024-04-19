import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/service/product_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/bottom_sheet_container_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleActivity extends StatefulWidget {
  const PlanScheduleActivity(
      {super.key,
      required this.item,
      required this.showBottomSheet,
      required this.isCreate,
      required this.orderList,
      required this.isSelected});
  final PlanScheduleItem item;
  final void Function(PlanScheduleItem item) showBottomSheet;
  final bool isSelected;
  final bool isCreate;
  final dynamic orderList;

  @override
  State<PlanScheduleActivity> createState() => _PlanScheduleActivityState();
}

class _PlanScheduleActivityState extends State<PlanScheduleActivity> {
  List<ProductViewModel>? products = [];
  ProductService _productService = ProductService();
  bool isLoading = true;
  dynamic order;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() async {
    List<int> ids = [];
    if (widget.item.orderUUID == null) {
      setState(() {
        isLoading = false;
      });
    } else {
      if (widget.orderList.isNotEmpty) {
        order = widget.orderList
            .firstWhere((e) => e['orderUUID'] == widget.item.orderUUID);
        if (order != null) {
          if (order['cart'] != null) {
            dynamic cart = order['cart'];
            if (cart.runtimeType == List<dynamic>) {
              for (final proId in cart) {
                if (!ids.contains(int.parse(proId['key'].toString()))) {
                  ids.add(int.parse(proId['key'].toString()));
                }
              }
            } else {
              for (final proId in cart.entries) {
                if (!ids.contains(int.parse(proId.key))) {
                  ids.add(int.parse(proId.key));
                }
              }
            }
            products = await _productService.getListProduct(ids);
            if (products != null) {
              setState(() {
                isLoading = false;
              });
            }
          } else if (order['details'] != null) {
            setState(() {
              isLoading = false;
            });
          }
        } else {
          isLoading = false;
        }
      } else {
        isLoading = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            if (!isLoading) {
              showModalBottomSheet(
                  context: context,
                  builder: (ctx) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 23, vertical: 8),
                        child: SizedBox(
                          width: 100.w,
                          child: SingleChildScrollView(
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
                                    title: 'Mô tả chi tiết'),
                                SizedBox(
                                  height: 1.h,
                                ),
                                BottomSheetContainerWidget(
                                    content:
                                        '${widget.item.activityTime.toString()} giờ',
                                    title: 'Thời gian'),
                                SizedBox(
                                  height: 1.h,
                                ),
                                if (order != null)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Chi tiết dự trù kinh phí',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'NotoSans'),
                                        ),
                                        if (order['details'] != null)
                                          for (final detail in order['details'])
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 65.w,
                                                  child: Text(
                                                    detail['productName'],
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'NotoSans'),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15.w,
                                                  child: Text(
                                                    'x${detail['quantity']}',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'NotoSans'),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                )
                                              ],
                                            ),
                                        if (order['cart'] != null)
                                          for (final detail
                                              in order['cart'].entries)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 65.w,
                                                  child: Text(
                                                    products!
                                                        .firstWhere((element) =>
                                                            element.id ==
                                                            int.parse(
                                                                detail.key))
                                                        .name,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'NotoSans'),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15.w,
                                                  child: Text(
                                                    detail.value.toString(),
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'NotoSans'),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                )
                                              ],
                                            ),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                            SizedBox(
                                              width: 45.w,
                                              child: Text(
                                                NumberFormat.simpleCurrency(
                                                        locale: 'vi_VN',
                                                        decimalDigits: 0,
                                                        name: 'Đ')
                                                    .format(order['total']),
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontFamily: 'NotoSans',
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.end,
                                              ),
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
                        ),
                      ));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Container(
              width: 100.w,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  color: widget.isSelected
                      ? primaryColor.withOpacity(0.3)
                      : lightPrimaryTextColor.withOpacity(0.8),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 3,
                      color: Colors.black12,
                      offset: Offset(2, 4),
                    )
                  ],
                  border:
                      widget.item.isStarred != null && widget.item.isStarred!
                          ? Border.all(color: Colors.amber, width: 2)
                          : widget.item.type == 'Ăn uống' ||
                                  widget.item.type == 'Check-in'
                              ? Border.all(color: primaryColor, width: 2)
                              : const Border(),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.shortDescription ?? 'Không có mô tả',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        IconButton(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              widget.showBottomSheet(widget.item);
                            },
                            icon: const Icon(
                              Icons.more_horiz,
                            ))
                      ],
                    ),
                    Container(
                      color: widget.item.isStarred != null &&
                              widget.item.isStarred!
                          ? Colors.amber
                          : widget.item.type == 'Ăn uống'
                              ? primaryColor
                              : Colors.black54,
                      height: 2,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_activity,
                          size: 22,
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Text(
                          widget.item.type!,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.watch_later_outlined,
                          size: 22,
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Text(
                          '${widget.item.activityTime.toString()} giờ',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
