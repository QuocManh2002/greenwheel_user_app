import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/constants/sessions.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_menu_screen.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
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
  final double? availableGcoinAmount;
  final void Function() callback;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  TextEditingController noteController = TextEditingController();
  bool isExpanded = false;
  List<DateTime> _servingDates = [];
  String _servingTime = '';
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
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
                          widget.order.supplier!.thumbnailUrl!,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                    top: 2.h,
                                    right: 2.h,
                                    left: 2.h,
                                    bottom: 1.h),
                                child: Text(
                                  widget.order.supplier!.name!,
                                  style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.7),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12))),
                                  height: 0.2.h,
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.h, vertical: 1.5.h),
                                child: Text(
                                  '0${widget.order.supplier!.phone!.substring(3)}',
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black54),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.7),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12))),
                                  height: 0.2.h,
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                    left: 2.h,
                                    right: 2.h,
                                    top: 1.5.h,
                                    bottom: 2.h),
                                child: Text(
                                  widget.order.supplier!.address!,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black54),
                                ),
                              ),
                            ],
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
                          for (final detail in widget.order.details!)
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
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
                                                locale: 'en-US',
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
                                '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(widget.order.total)} VND',
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
                  // final rs = await _orderService.createOrder(
                  //     widget.order, widget.planId!);
                  // if (rs != 0) {
                  //   // ignore: use_build_context_synchronously
                  //   AwesomeDialog(
                  //           context: context,
                  //           animType: AnimType.leftSlide,
                  //           dialogType: DialogType.success,
                  //           title: 'Tạo đơn hàng thành công',
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 12, vertical: 6),
                  //           titleTextStyle: const TextStyle(
                  //               fontSize: 20, fontWeight: FontWeight.bold))
                  //       .show();
                  //   Future.delayed(const Duration(seconds: 2), () {
                  //     widget.callback(widget.order.guid);
                  //     Navigator.of(context).pop();
                  //     Navigator.of(context).pop();
                  //     Navigator.of(context).pop();
                  //   });
                  // }
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
                          callbackFunction: widget.callback)));
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

  getInitIds() {}
}
