import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/service/product_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_schedule_item.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/bottom_sheet_container_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleActivity extends StatefulWidget {
  const PlanScheduleActivity({
    super.key,
    required this.item,
    required this.isCreate,
    required this.orderList,
    required this.onAdd,
    required this.onDetele,
    required this.onUpdate,
    required this.callback,
    this.isValidPeriodOfOrder,
    this.itemIndex,
  });
  final PlanScheduleItem item;
  final bool isCreate;
  final dynamic orderList;
  final int? itemIndex;
  final bool? isValidPeriodOfOrder;
  final void Function(PlanScheduleItem item) onUpdate;
  final void Function(PlanScheduleItem item, String? orderUUID) onDetele;
  final void Function(bool isUpper, int itemIndex) onAdd;
  final void Function(
      {required PlanScheduleItem item,
      required bool isCreate,
      PlanScheduleItem? oldItem,
      bool? isUpper,
      int? itemIndex}) callback;

  @override
  State<PlanScheduleActivity> createState() => _PlanScheduleActivityState();
}

class _PlanScheduleActivityState extends State<PlanScheduleActivity> {
  List<ProductViewModel>? products = [];
  final ProductService _productService = ProductService();
  bool isLoading = true;
  dynamic order;
  bool isSelected = false;

  @override
  void initState() {
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
        order = widget.orderList.firstWhere((e) =>
            e['orderUUID'] ==
            (widget.item.orderUUID!.substring(0, 2) == '""'
                ? json.decode(widget.item.orderUUID!)
                : widget.item.orderUUID));
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
                                        '${widget.item.activityTime!.inHours > 0 ? '${widget.item.activityTime!.inHours} giờ' : ''}${widget.item.activityTime!.inMinutes.remainder(60) > 0 ? ' ${widget.item.activityTime!.inMinutes.remainder(60)} phút' : ''}',
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
                                          Column(
                                            children: [
                                              SizedBox(height: 0.2.h,),
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                child: RichText(
                                                  text: TextSpan(
                                                      text:
                                                          order['providerName'],
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'NotoSans',
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                            text:
                                                                ' (${Utils().getPeriodString(order['period'])['text']})',
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black54,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal))
                                                      ]),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                              SizedBox(height: 0.2.h,),
                                              const Divider(
                                                color: Colors.black54,
                                                height: 2,
                                              ),
                                              for (final detail
                                                  in order['details'])
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 60.w,
                                                      child: Text(
                                                        detail['productName'],
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'NotoSans'),
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 15.w,
                                                      child: Text(
                                                        'x${detail['quantity']}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black54,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontFamily:
                                                                'NotoSans'),
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                    )
                                                  ],
                                                ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                                                    .format(order['total'] / order['serveDates'].length),
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontFamily: 'NotoSans',
                                                    fontWeight:
                                                        FontWeight.bold),
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
                  color: isSelected
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.shortDescription ?? 'Không có mô tả',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        if(widget.isValidPeriodOfOrder != null && !widget.isValidPeriodOfOrder!)
                        const Icon(Icons.warning, color: Colors.red, size: 23,),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_upward,
                                      color: primaryColor,
                                    ),
                                    SizedBox(
                                      width: 1.w,
                                    ),
                                    const Text(
                                      'Thêm',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 16,
                                          fontFamily: 'NotoSans'),
                                    )
                                  ],
                                )),
                            PopupMenuItem(
                                value: 1,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.edit_square,
                                      color: Colors.blueAccent,
                                    ),
                                    SizedBox(
                                      width: 1.w,
                                    ),
                                    const Text(
                                      'Chỉnh sửa',
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 16,
                                          fontFamily: 'NotoSans'),
                                    )
                                  ],
                                )),
                            PopupMenuItem(
                                value: 2,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(
                                      width: 1.w,
                                    ),
                                    const Text(
                                      'Xoá',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 16,
                                          fontFamily: 'NotoSans'),
                                    )
                                  ],
                                )),
                            PopupMenuItem(
                                value: 3,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_downward,
                                      color: primaryColor,
                                    ),
                                    SizedBox(
                                      width: 1.w,
                                    ),
                                    const Text(
                                      'Thêm',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 16,
                                          fontFamily: 'NotoSans'),
                                    )
                                  ],
                                ))
                          ],
                          onOpened: () {
                            setState(() {
                              isSelected = true;
                            });
                          },
                          onSelected: (value) {
                            setState(() {
                              isSelected = false;
                            });
                            switch (value) {
                              case 0:
                                widget.onAdd(true, widget.itemIndex!);
                                break;
                              case 1:
                                widget.onUpdate(
                                  widget.item,
                                );
                                break;
                              case 2:
                                widget.onDetele(widget.item, null);
                                break;
                              case 3:
                                widget.onAdd(false, widget.itemIndex!);
                                break;
                            }
                          },
                          constraints: BoxConstraints(maxWidth: 35.w),
                          onCanceled: () {
                            setState(() {
                              isSelected = false;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
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
                              '${widget.item.activityTime!.inHours > 0 ? '${widget.item.activityTime!.inHours} giờ' : ''}${widget.item.activityTime!.inMinutes.remainder(60) > 0 ? ' ${widget.item.activityTime!.inMinutes.remainder(60)} phút' : ''}',
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
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
