import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/service_types.dart';
import 'package:greenwheel_user_app/core/constants/sessions.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_menu_screen.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/widgets/order_screen_widget/cancel_order_bottom_sheet.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen(
      {super.key,
      required this.order,
      required this.startDate,
      this.endDate,
      this.memberLimit,
      this.planId,
      required this.callback,
      this.isFromTempOrder,
      this.availableGcoinAmount,
      required this.isTempOrder});
  final OrderViewModel order;
  final DateTime startDate;
  final bool isTempOrder;
  final int? planId;
  final int? memberLimit;
  final DateTime? endDate;
  final bool? isFromTempOrder;
  final int? availableGcoinAmount;
  final void Function() callback;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  TextEditingController noteController = TextEditingController();
  bool isExpanded = false;
  List<DateTime> _servingDates = [];
  String _servingTime = '';
  List<OrderDetailViewModel> details = [];

  // OrderService _orderService = OrderService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.order.note == null || widget.order.note!.isEmpty) {
      noteController.text = 'Không có ghi chú';
    } else {
      noteController.text = widget.order.note!;
    }
    _servingDates =
        widget.order.serveDates!.map((e) => DateTime.parse(e)).toList();
    _servingTime = sessions
        .firstWhere((element) => element.enumName == widget.order.period)
        .range;
        final tmp =
        widget.order.details!.groupListsBy((element) => element.productId);
    for (final temp in tmp.values) {
      details.add(temp.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
             const PopupMenuItem(
              value: 0,
                child: Row(
                  children: [
                    Icon(
                      Icons.remove_shopping_cart_outlined,
                      color: Colors.redAccent,
                      size: 25,
                    ),
                    SizedBox(width: 8,),
                    Text(
                      'Huỷ đơn hàng',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSans',
                          color: Colors.redAccent),
                    )
                  ],
                ),
              )
            ],
            onSelected: (value) {
              if(value == 0){
                showModalBottomSheet(
                  context: context, 
                  isDismissible: true,
                  builder: (context) => CancelOrderBottomSheet(
                    orderCreatedAt: widget.order.createdAt!,
                    total: widget.order.total!.toInt(),
                    callback: (p0) {
                      
                    },
                    orderId: widget.order.id!,),);
              }
            },
          ),
          SizedBox(
            width: 2.w,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      SizedBox(
                        height: 30.h,
                        width: double.infinity,
                        child: Image.network(
                          '$baseBucketImage${widget.order.supplier!.thumbnailUrl!}',
                          fit: BoxFit.fitWidth,
                          height: 30.h,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 20.h),
                          width: 90.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 3,
                                color: Colors.black12,
                                offset: Offset(2, 4),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.h, vertical: 1.5.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding:
                                      EdgeInsets.symmetric(vertical: 0.5.h),
                                  child: Text(
                                    widget.order.supplier!.name!,
                                    style: const TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (widget.order.supplier!.standard != null)
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 0.2.h),
                                    child: RatingBar.builder(
                                        unratedColor:
                                            Colors.grey.withOpacity(0.5),
                                        itemBuilder: (context, index) =>
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                        initialRating:
                                            widget.order.supplier!.standard!,
                                        itemSize: 25,
                                        ignoreGestures: true,
                                        itemCount: 5,
                                        onRatingUpdate: (value) {}),
                                  ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding:
                                      EdgeInsets.symmetric(vertical: 0.5.h),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          color: primaryColor, size: 20),
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                      Text(
                                        '0${widget.order.supplier!.phone!.substring(2)}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding:
                                      EdgeInsets.symmetric(vertical: 0.5.h),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.home,
                                        color: primaryColor,
                                        size: 20,
                                      ),
                                      SizedBox(
                                        width: 2.w,
                                      ),
                                      SizedBox(
                                        width: 70.w,
                                        child: Text(
                                          widget.order.supplier!.address!,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.h),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: Colors.purple,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Text(
                                'Ngày đặt: ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${widget.order.createdAt!.day}/${widget.order.createdAt!.month}/${widget.order.createdAt!.year}',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: primaryColor,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Text(
                                'Ngày phục vụ: ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              if (!isExpanded)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_servingDates[0].day}/${_servingDates[0].month}/${_servingDates[0].year}',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    if (_servingDates.length > 1)
                                      Text(
                                        '+${_servingDates.length - 1} ngày',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    if (widget.order.serveDates!.length > 1)
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isExpanded = !isExpanded;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                            size: 36,
                                          ))
                                  ],
                                ),
                              if (isExpanded)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (final date in _servingDates)
                                          Text(
                                            '${date.day}/${date.month}/${date.year}',
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isExpanded = !isExpanded;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.arrow_drop_up,
                                          size: 36,
                                        ))
                                  ],
                                )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.watch_later,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                widget.order.type != 'FOOD'
                                    ? 'Thời gian check-in:'
                                    : 'Thời gian phục vụ:',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                widget.order.type! != 'FOOD'
                                    ? '12:00 SA'
                                    : _servingTime,
                                style: const TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: yellowColor,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Ghi chú:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            height: 10.h,
                            margin: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 1.h),
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set the border radius
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            child: TextField(
                              readOnly: true,
                              controller: noteController,
                              maxLines:
                                  null, // Allow for multiple lines of text
                              decoration: const InputDecoration(
                                border: InputBorder
                                    .none, // Remove the bottom border
                                contentPadding:
                                    EdgeInsets.all(8.0), // Set the padding
                              ),
                              style: const TextStyle(
                                height:
                                    1.8, // Adjust the line height (e.g., 1.5 for 1.5 times the font size)
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.7),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12))),
                            height: 0.5.h,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Text(
                            'Sản phẩm',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          for (final detail in details)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${detail.quantity}x',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 18,
                                      ),
                                      Text(
                                        detail.productName,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const Spacer(),
                                      Text(
                                        NumberFormat.simpleCurrency(
                                                locale: 'vi_VN',
                                                decimalDigits: 0,
                                                name: "")
                                            .format(detail.unitPrice),
                                        style: const TextStyle(fontSize: 14),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.7),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12))),
                                  height: 0.2.h,
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Tổng',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '${NumberFormat.simpleCurrency(locale: 'vi-VN', decimalDigits: 0, name: "").format(widget.order.total)}VND',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isTempOrder)
            SizedBox(
              height: 1.h,
            ),
          if (widget.isTempOrder)
            ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () async {
                  Session? session;
                  switch (widget.order.period) {
                    case 'MORNING':
                      session = sessions[0];
                      break;
                    case 'NOON':
                      session = sessions[1];
                      break;
                    case 'AFTERNOON':
                      session = sessions[2];
                      break;
                    case 'EVENING':
                      session = sessions[3];
                      break;
                  }
                  List<ItemCart> cart = [];
                  for (final detail in widget.order.details!) {
                    cart.add(ItemCart(
                        product: ProductViewModel(
                          id: detail.productId,
                          name: detail.productName,
                          price: detail.price!.toInt(),
                        ),
                        qty: detail.quantity));
                  }
                  List<String> ids = [];
                  for (final item in cart) {
                    if (!ids.contains(item.product.id.toString())) {
                      ids.add(item.product.id.toString());
                    }
                  }
                  sharedPreferences.setStringList('initCartIds', ids);

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => ServiceMenuScreen(
                          availableGcoinAmount: widget.availableGcoinAmount,
                          initCart: cart,
                          session: session,
                          orderGuid: widget.order.guid,
                          isFromTempOrder: widget.isFromTempOrder,
                          currentCart: cart,
                          supplier: widget.order.supplier!,
                          serviceType: services.firstWhere(
                              (element) => element.name == widget.order.type),
                          numberOfMember: widget.memberLimit!,
                          endDate: widget.endDate!,
                          period: widget.order.period,
                          startDate: widget.startDate,
                          isOrder: true,
                          callbackFunction: (tempOrder) {
                            
                          },)));
                },
                child: const Text('Xác nhận đơn hàng mẫu')),
          if (widget.isTempOrder)
            SizedBox(
              height: 1.h,
            ),
        ],
      ),
    ));
  }
}
