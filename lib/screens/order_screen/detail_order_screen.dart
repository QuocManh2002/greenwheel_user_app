import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/global_constant.dart';
import '../../core/constants/plan_statuses.dart';
import '../../core/constants/service_types.dart';
import '../../core/constants/sessions.dart';
import '../../core/constants/urls.dart';
import '../../helpers/util.dart';
import '../../main.dart';
import '../../models/menu_item_cart.dart';
import '../../models/order_input_model.dart';
import '../../models/session.dart';
import '../../service/product_service.dart';
import '../../service/supplier_service.dart';
import '../../view_models/location.dart';
import '../../view_models/order.dart';
import '../../view_models/order_detail.dart';
import '../../view_models/product.dart';
import '../../widgets/order_screen_widget/cancel_order_bottom_sheet.dart';
import '../../widgets/style_widget/button_style.dart';
import '../../widgets/style_widget/dialog_style.dart';
import '../loading_screen/order_detail_loading_screen.dart';
import '../main_screen/service_main_screen.dart';
import '../main_screen/service_menu_screen.dart';
import 'rate_order_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen(
      {super.key,
      required this.order,
      required this.startDate,
      this.endDate,
      this.numberOfMember,
      this.planId,
      required this.callback,
      this.isFromTempOrder,
      this.planStatus,
      this.availableGcoinAmount,
      this.location,
      this.cancelReason,
      required this.isCancel,
      required this.isTempOrder});
  final OrderViewModel order;
  final DateTime startDate;
  final bool isTempOrder;
  final int? planId;
  final int? numberOfMember;
  final DateTime? endDate;
  final bool? isFromTempOrder;
  final int? availableGcoinAmount;
  final String? planStatus;
  final LocationViewModel? location;
  final void Function() callback;
  final String? cancelReason;
  final bool isCancel;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  TextEditingController noteController = TextEditingController();
  final SupplierService supplierService = SupplierService();
  final ProductService productService = ProductService();
  bool isExpanded = false;
  String servingTime = '';
  List<OrderDetailViewModel> details = [];
  List<DateTime> servingDates = [];
  List<DateTime> normalServingDates = [];
  List<DateTime> holidayServingDates = [];
  int holidayUpPCT = 0;
  bool isLoading = true;
  num listedPricePerDay = 0;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    noteController.text = widget.order.note ?? '';
    servingDates =
        (widget.order.serveDates ?? []).map((e) => DateTime.parse(e)).toList();
    servingTime = sessions
        .firstWhere((element) => element.enumName == widget.order.period)
        .range;
    final tmp =
        widget.order.details!.groupListsBy((element) => element.productId);
    for (final temp in tmp.values) {
      details.add(temp.first);
      listedPricePerDay += (temp.first.price! * temp.first.quantity);
    }
    holidayUpPCT = Utils().getHolidayUpPct(widget.order.type!);
    final dates = Utils().getHolidayServingDates(servingDates);
    normalServingDates = dates['normalServingDates'];
    holidayServingDates = dates['holidayServingDates'];
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        actions: [
          if (widget.planStatus == planStatuses[2].engName ||
              (widget.order.currentStatus != null &&
                  widget.order.currentStatus == OrderStatus.SERVED.name &&
                  widget.order.rating == null))
            PopupMenuButton(
              itemBuilder: (context) => [
                if (widget.planStatus == planStatuses[2].engName)
                  const PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(
                          Icons.remove_shopping_cart_outlined,
                          color: Colors.redAccent,
                          size: 25,
                        ),
                        SizedBox(
                          width: 8,
                        ),
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
                  ),
                if (widget.order.currentStatus != null &&
                    widget.order.currentStatus == OrderStatus.SERVED.name &&
                    widget.order.rating == null)
                  const PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: Colors.redAccent,
                          size: 25,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Báo cáo đơn hàng',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans',
                              color: Colors.redAccent),
                        )
                      ],
                    ),
                  ),
              ],
              onSelected: (value) {
                if (value == 0) {
                  showModalBottomSheet(
                    context: context,
                    isDismissible: true,
                    builder: (context) => CancelOrderBottomSheet(
                      orderCreatedAt: widget.order.createdAt!,
                      total: widget.order.total!.toInt(),
                      callback: (p0) {},
                      orderId: widget.order.id!,
                    ),
                  );
                } else {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: RateOrderScreen(
                            order: widget.order,
                            isRate: false,
                          ),
                          type: PageTransitionType.topToBottom));
                }
              },
            ),
          SizedBox(
            width: 2.w,
          )
        ],
      ),
      body: isLoading
          ? const OrderDetailLoadingScreen()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            CachedNetworkImage(
                                key: UniqueKey(),
                                height: 30.h,
                                width: 100.w,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Image.memory(kTransparentImage),
                                errorWidget: (context, url, error) =>
                                    Image.asset(emptyPlan),
                                imageUrl:
                                    '$baseBucketImage${widget.order.supplier!.thumbnailUrl!}'),
                            Container(
                                margin: EdgeInsets.only(top: 20.h),
                                width: 90.w,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
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
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.5.h),
                                        child: Text(
                                          widget.order.supplier!.name!,
                                          style: const TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (widget.order.supplier!.standard !=
                                          null)
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0.2.h),
                                          child: RatingBar.builder(
                                              unratedColor:
                                                  Colors.grey.withOpacity(0.5),
                                              itemBuilder: (context, index) =>
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                              initialRating: widget
                                                  .order.supplier!.standard!,
                                              itemSize: 25,
                                              ignoreGestures: true,
                                              itemCount: 5,
                                              onRatingUpdate: (value) {}),
                                        ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.5.h),
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
                                            const Spacer(),
                                            InkWell(
                                                onTap: () async {
                                                  final Uri url = Uri(
                                                      scheme: 'tel',
                                                      path:
                                                          '0${widget.order.supplier!.phone!.substring(2)}');
                                                  if (await canLaunchUrl(url)) {
                                                    await launchUrl(url);
                                                  }
                                                },
                                                child: Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                      color: primaryColor
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: primaryColor,
                                                          width: 1.5)),
                                                  child: const Icon(
                                                    Icons.phone,
                                                    size: 20,
                                                    color: primaryColor,
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.5.h),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.home,
                                              color: primaryColor,
                                              size: 20,
                                            ),
                                            SizedBox(
                                              width: 2.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                widget.order.supplier!.address!,
                                                overflow: TextOverflow.clip,
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
                                if (widget.order.createdAt != null)
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
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(widget.order.createdAt!),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            for (final date
                                                in widget.order.serveDates ??
                                                    [])
                                              Text(
                                                DateFormat('dd/MM/yyyy').format(
                                                    date.runtimeType == String
                                                        ? DateTime.parse(date)
                                                        : date),
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      widget.order.type! != 'FOOD'
                                          ? '12:00 SA'
                                          : servingTime,
                                      style: const TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                                if (widget.isCancel && widget.cancelReason != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Divider(
                                        color: Colors.grey.withOpacity(0.7),
                                        thickness: 0.2.h,
                                        height: 3.h,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.w, vertical: 0.5.h),
                                        decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        child: const Text(
                                          'Đã huỷ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'NotoSans',
                                              color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      RichText(
                                          text: TextSpan(
                                              text: 'Lí do: ',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                              children: [
                                            TextSpan(
                                                text: '${widget.cancelReason}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal))
                                          ]))
                                    ],
                                  ),
                                if (widget.order.note != null &&
                                    widget.order.note!.isNotEmpty)
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 1.h,
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
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 10.h,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.w, vertical: 1.h),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w),
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
                                            contentPadding: EdgeInsets.all(
                                                8.0), // Set the padding
                                          ),
                                          style: const TextStyle(
                                            height:
                                                1.8, // Adjust the line height (e.g., 1.5 for 1.5 times the font size)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Divider(
                                  color: Colors.grey.withOpacity(0.7),
                                  thickness: 0.2.h,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                const Text(
                                  'Sản phẩm',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                for (final detail in details)
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
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
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                            const Spacer(),
                                            Text(
                                              NumberFormat.simpleCurrency(
                                                      locale: 'vi_VN',
                                                      decimalDigits: 0,
                                                      name: "đ")
                                                  .format(detail.price),
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            )
                                          ],
                                        ),
                                      ),
                                      if (detail != details.last)
                                        Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.7),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(12))),
                                          height: 0.1.h,
                                        ),
                                    ],
                                  ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Divider(
                                  color: Colors.grey.withOpacity(0.7),
                                  thickness: 0.2.h,
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                const Text(
                                  'Đơn giá từng ngày',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NotoSans'),
                                ),
                                SizedBox(
                                  height: 1.h,
                                ),
                                for (final date in servingDates)
                                  Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('dd/MM/yyyy')
                                                .format(date),
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontFamily: 'NotoSans',
                                                fontWeight: FontWeight.w500),
                                          ),
                                          if (holidayServingDates
                                              .contains(date))
                                            const Text(
                                              ' (Ngày lễ)',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'NotoSans'),
                                            ),
                                          const Spacer(),
                                          Text(
                                            NumberFormat.simpleCurrency(
                                                    locale: 'vi_VN',
                                                    decimalDigits: 0,
                                                    name: 'đ')
                                                .format(holidayServingDates
                                                        .contains(date)
                                                    ? listedPricePerDay *
                                                        (1 + holidayUpPCT / 100)
                                                    : listedPricePerDay),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'NotoSans'),
                                          )
                                        ],
                                      ),
                                      if (date != servingDates.last)
                                        Divider(
                                          color: Colors.grey.withOpacity(0.7),
                                          thickness: 0.1.h,
                                        )
                                    ],
                                  ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Divider(
                                  color: Colors.grey.withOpacity(0.7),
                                  thickness: 0.2.h,
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Tổng cộng',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Text(
                                      NumberFormat.simpleCurrency(
                                              locale: 'vi-VN',
                                              decimalDigits: 0,
                                              name: "đ")
                                          .format(widget.order.id == null
                                              ? (widget.order.actualTotal ??
                                                      0) *
                                                  GlobalConstant()
                                                      .VND_CONVERT_RATE
                                              : widget.order.total ?? 0),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Giá trị quy đổi',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Text(
                                      NumberFormat.simpleCurrency(
                                              locale: 'vi_VN',
                                              decimalDigits: 0,
                                              name: "")
                                          .format(widget.order.id == null
                                              ? (widget.order.actualTotal ?? 0)
                                              : (widget.order.total ?? 0) /
                                                  GlobalConstant()
                                                      .VND_CONVERT_RATE),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SvgPicture.asset(
                                      gcoinLogo,
                                      height: 18,
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
                        final invalidSupplierIds = await supplierService
                            .getInvalidSupplierByIds(
                                [widget.order.supplier!.id], context);

                        List<ItemCart> cart = [];
                        for (final detail in widget.order.details!) {
                          cart.add(ItemCart(
                              product: ProductViewModel(
                                id: detail.productId,
                                name: detail.productName,
                                price: detail.price!,
                              ),
                              qty: detail.quantity));
                        }
                        List<int> ids = [];
                        for (final item in cart) {
                          if (!ids.contains(item.product.id.toString())) {
                            ids.add(item.product.id);
                          }
                        }

                        final invalidProductIds = await productService
                            // ignore: use_build_context_synchronously
                            .getInvalidProductByIds(ids, context);

                        if (invalidSupplierIds.isNotEmpty) {
                          DialogStyle().basicDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              title:
                                  'Rất tiếc! Nhà cung cấp này đã không còn khả dụng',
                              desc:
                                  'Vui lòng chọn lại một nhà cung cấp khác cho đơn dịch vụ',
                              onOk: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        child: ServiceMainScreen(
                                          inputModel: OrderInputModel(
                                            availableGcoinAmount:
                                                widget.availableGcoinAmount,
                                            callbackFunction: (tempOrder) {
                                              widget.callback();
                                            },
                                            serviceType: services.firstWhere(
                                                (element) =>
                                                    element.name ==
                                                    widget.order.type),
                                            startDate: widget.startDate,
                                            endDate: widget.endDate!,
                                            location: widget.location,
                                            isOrder: true,
                                            session: sessions.firstWhere(
                                                (element) =>
                                                    element.enumName ==
                                                    widget.order.period),
                                            numberOfMember:
                                                widget.numberOfMember!,
                                            orderGuid: widget.order.uuid,
                                            servingDates: widget
                                                .order.serveDates!
                                                .map((e) => DateTime.parse(e))
                                                .toList(),
                                          ),
                                        ),
                                        type: PageTransitionType.rightToLeft));
                              },
                              type: DialogType.warning);
                        } else if (invalidProductIds.isNotEmpty) {
                          DialogStyle().basicDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              title:
                                  'Rất tiếc! Các sản phẩm ${invalidProductIds.map((productId) => '${details.firstWhere((detail) => detail.productId == productId).productName} ,')} đã không còn khả dụng',
                              desc:
                                  'Vui lòng chọn lại các sản phẩm khác thay thế',
                              onOk: () {},
                              type: DialogType.warning);
                        } else {
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

                          sharedPreferences.setStringList('initCartIds',
                              ids.map((e) => e.toString()).toList());

                          // ignore: use_build_context_synchronously
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ServiceMenuScreen(
                                    inputModel: OrderInputModel(
                                      startDate: widget.startDate,
                                      endDate: widget.endDate,
                                      availableGcoinAmount:
                                          widget.availableGcoinAmount,
                                      initCart: cart,
                                      session: session,
                                      orderGuid: widget.order.uuid,
                                      currentCart: cart,
                                      supplier: widget.order.supplier!,
                                      serviceType: services.firstWhere(
                                          (element) =>
                                              element.name ==
                                              widget.order.type),
                                      numberOfMember: widget.numberOfMember!,
                                      period: widget.order.period,
                                      isOrder: true,
                                      holidayUpPCT: holidayUpPCT,
                                      servingDates: servingDates,
                                      holidayServingDates: holidayServingDates,
                                      callbackFunction: (tempOrder) {
                                        widget.callback();
                                      },
                                    ),
                                  )));
                        }
                      },
                      child: const Text('Xác nhận đơn hàng mẫu')),
                if (widget.isTempOrder)
                  SizedBox(
                    height: 1.h,
                  ),
              ],
            ),
      bottomNavigationBar: widget.order.currentStatus != null &&
              widget.order.currentStatus == OrderStatus.SERVED.name &&
              widget.order.currentStatus != OrderStatus.COMPLAINED.name
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: RateOrderScreen(
                              order: widget.order,
                              isRate: true,
                            ),
                            type: PageTransitionType.bottomToTop));
                  },
                  child: const Text('Đánh giá đơn hàng')),
            )
          : null,
    ));
  }
}
