import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/global_constant.dart';
import '../../core/constants/urls.dart';
import '../../helpers/util.dart';
import '../../main.dart';
import '../../models/holiday.dart';
import '../../models/menu_item_cart.dart';
import '../../models/service_type.dart';
import '../../models/session.dart';
import '../../service/order_service.dart';
import '../../service/plan_service.dart';
import '../../view_models/order.dart';
import '../../view_models/order_create.dart';
import '../../view_models/order_detail.dart';
import '../../view_models/supplier.dart';
import '../../widgets/order_screen_widget/cart_item_card.dart';
import '../sub_screen/select_order_date.dart';

class CartScreen extends StatefulWidget {
  const CartScreen(
      {super.key,
      required this.supplier,
      required this.list,
      required this.total,
      required this.serviceType,
      required this.endDate,
      required this.startDate,
      this.note = "",
      required this.numberOfMember,
      required this.session,
      this.isOrder,
      this.initCart,
      this.orderGuid,
      this.availableGcoinAmount,
      this.servingDates,
      this.holidayServingDates,
      this.holidayUpPCT,
      this.finalTotal,
      required this.callbackFunction});
  final SupplierViewModel supplier;
  final List<ItemCart> list;
  final List<ItemCart>? initCart;
  final double total;
  final ServiceType serviceType;
  final DateTime startDate;
  final DateTime endDate;
  final String note;
  final int numberOfMember;
  final Session session;
  final bool? isOrder;
  final void Function(dynamic tempOrder) callbackFunction;
  final String? orderGuid;
  final int? availableGcoinAmount;
  final List<DateTime>? servingDates;
  final List<DateTime>? holidayServingDates;
  final int? holidayUpPCT;
  final num? finalTotal;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  OrderService orderService = OrderService();
  PlanService planService = PlanService();

  double finalTotal = 0;
  double deposit = 0;
  List<ItemCart> list = [];
  SupplierViewModel? supplier;
  bool isLoading = false;
  bool isIndividual = false;
  bool canPay = false;
  int? planId;
  int quantity = 1;
  int selectedDays = 1;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController noteController = TextEditingController();

  DateTimeRange selectedDates =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  List<DateTime> _servingDates = [];
  List<Holiday> holidays = [];
  List<DateTime> holidayServingDates = [];
  List<DateTime> normalServingDates = [];
  int holidayUpPCT = 0;

  @override
  void initState() {
    super.initState();
    setUpdata();
  }

  setUpdata() async {
    finalTotal = widget.total *
        (widget.servingDates != null ? widget.servingDates!.length : 1);
    list = widget.list;
    supplier = widget.supplier;
    noteController.text = widget.note;
    _servingDates = widget.isOrder != null && widget.isOrder!
        ? widget.servingDates!
        : widget.servingDates ?? [widget.startDate];
    if (widget.isOrder == null || !widget.isOrder!) {
      callback(_servingDates, finalTotal);
    }

    if (widget.isOrder == null || !widget.isOrder!) {
      final holidaysText = sharedPreferences.getStringList('HOLIDAYS');
      holidays =
          holidaysText!.map((e) => Holiday.fromJson(json.decode(e))).toList();
      final rs = Utils().getHolidayServingDates(holidays, _servingDates);
      holidayServingDates = rs['holidayServingDates'];
      normalServingDates = rs['normalServingDates'];
      holidayUpPCT = Utils().getHolidayUpPct(widget.serviceType.name);
    } else {
      holidayServingDates = widget.holidayServingDates!;
      holidayUpPCT = widget.holidayUpPCT!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text(
                    "Giỏ hàng",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
        body: isLoading
            ? Image.asset(
                'assets/images/loading.gif',
                width: 100.w, // Set the width to your desired size
              )
            : list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(GlobalConstant()
                            .cartEmptyIcon), // Replace with your image path
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 14, top: 6, bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50.w,
                                child: Text(
                                  supplier!.name!,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'NotoSans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(), // Add space between the two elements
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  '+  Thêm món',
                                  style: TextStyle(
                                    color: Colors
                                        .blue, // Set the color of the link text
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 1.8,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: 40.h, minHeight: 20.h),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return CartItemCard(
                                cartItem: list[index],
                                days: selectedDays,
                                serviceType: widget.serviceType,
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        Container(
                          height: 8,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.redAccent,
                            ), // Add the calendar icon
                            Padding(
                              padding: EdgeInsets.only(left: 14),
                              child: Text(
                                "Ngày tiếp nhận",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if ((widget.startDate
                                    .difference(DateTime.now())
                                    .inDays +
                                1) <=
                            3)
                          Padding(
                            padding: const EdgeInsets.only(left: 24, right: 24),
                            child: RichText(
                              text: const TextSpan(
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                  children: [
                                    TextSpan(
                                        text: "Lưu ý: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text:
                                            "Bạn chỉ có thể đặt dịch vụ sau 3 ngày kể từ ngày hôm nay")
                                  ]),
                            ),
                          ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 1.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                10.0), // Set the border radius
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _servingDates.isEmpty
                                  ? Text(
                                      widget.startDate
                                                      .difference(
                                                          DateTime.now())
                                                      .inDays +
                                                  1 <=
                                              3
                                          ? '${DateTime.now().add(const Duration(days: 3)).day}/${DateTime.now().add(const Duration(days: 3)).month}/${DateTime.now().add(const Duration(days: 3)).year}'
                                          : '${widget.startDate.day}/${widget.startDate.month}/${widget.startDate.year}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'NotoSans',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Utils().isConsecutiveDates(_servingDates)
                                      ? _servingDates.first
                                                  .difference(
                                                      _servingDates.last)
                                                  .inDays ==
                                              0
                                          ? Text(
                                              '${_servingDates.first.day}/${_servingDates.first.month}/${_servingDates.first.year}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'NotoSans',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : Text(
                                              '${_servingDates.first.day}/${_servingDates.first.month}/${_servingDates.first.year} - ${_servingDates.last.day}/${_servingDates.last.month}/${_servingDates.last.year}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'NotoSans',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                      : Text(
                                          "${_servingDates.first.day}/${_servingDates.first.month}/${_servingDates.first.year} + ${_servingDates.length - 1} ngày",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'NotoSans',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              if (widget.isOrder == null || !widget.isOrder!)
                                TextButton(
                                  onPressed: pickDateRange,
                                  child: const Text(
                                    'Chỉnh sửa',
                                    style: TextStyle(
                                      color: Colors
                                          .blue, // Set the color of the link text
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        (widget.serviceType.id == 1 ||
                                widget.serviceType.id == 4)
                            ? (Column(
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.w),
                                    child: const Text(
                                      "Đối với mặt hàng thuộc thức ăn và nhu yếu phẩm, số lượng sẽ được nhân lên tương ứng với số ngày được chọn.",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'NotoSans',
                                      ),
                                    ),
                                  )
                                ],
                              ))
                            : Container(),
                        const SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 1.8,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Icon(
                              Icons.note_add,
                              color: Colors.orange,
                            ), // Add the calendar icon
                            Padding(
                              padding: EdgeInsets.only(left: 14),
                              child: Text(
                                "Ghi chú",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
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
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: noteController,
                              maxLength: 110,
                              minLines: 3,
                              maxLines: 3, // Allow for multiple lines of text
                              decoration: const InputDecoration(
                                hintText: 'Thêm ghi chú',
                                counterText: '',
                                border: InputBorder
                                    .none, // Remove the bottom border
                                contentPadding:
                                    EdgeInsets.all(8.0), // Set the padding
                              ),
                              validator: (value) {
                                if (value!.length > 110) {
                                  return "Ghi chú không được quá 110 kí tự";
                                }
                                return null;
                              },
                              style: const TextStyle(
                                height:
                                    1.8, // Adjust the line height (e.g., 1.5 for 1.5 times the font size)
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Divider(
                                color: Colors.grey.withOpacity(0.7),
                                thickness: 1,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.receipt_long,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(
                                    width: 14,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: const Text(
                                      'Đơn giá theo ngày',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NotoSans'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              for (final date in _servingDates)
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(date),
                                      style: const TextStyle(
                                          fontSize: 15, fontFamily: 'NotoSans'),
                                    ),
                                    if (holidayServingDates.contains(date))
                                      const Text(
                                        ' (Ngày lễ)',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: 'NotoSans'),
                                      ),
                                    const Spacer(),
                                    Text(NumberFormat.simpleCurrency(
                                            locale: 'vi_VN',
                                            name: 'đ',
                                            decimalDigits: 0)
                                        .format(
                                            holidayServingDates.contains(date)
                                                ? widget.total *
                                                    (1 + holidayUpPCT / 100)
                                                : widget.total))
                                  ],
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
        bottomNavigationBar: isLoading
            ? Container()
            : list.isEmpty
                ? null
                : Visibility(
                    visible: finalTotal != 0,
                    child: Container(
                      height: 17.h,
                      width: double.infinity,
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 90.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Tổng cộng ', // Replace with your first text
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'NotoSans',
                                      ),
                                    ),
                                    (widget.serviceType.id == 1)
                                        ? Text(
                                            selectedDays == 1
                                                ? ""
                                                : "( ${selectedDays.toString()} ngày )", // Replace with your first text
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'NotoSans',
                                              color: Colors.black38,
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  NumberFormat.simpleCurrency(
                                          locale: 'vi_VN',
                                          decimalDigits: 0,
                                          name: 'đ')
                                      .format(widget.isOrder != null &&
                                              widget.isOrder!
                                          ? widget.finalTotal!
                                          : finalTotal),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoSans',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Row(
                              children: [
                                const Text(
                                  'Quy đổi',
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: 'NotoSans'),
                                ),
                                const Spacer(),
                                Text(
                                  NumberFormat.simpleCurrency(
                                          locale: 'vi_VN',
                                          name: '',
                                          decimalDigits: 0)
                                      .format(finalTotal /
                                          GlobalConstant().VND_CONVERT_RATE),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NotoSans'),
                                ),
                                SvgPicture.asset(
                                  gcoinLogo,
                                  height: 18,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 90.w,
                            height: 6.h,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  addOrder();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Background color
                              ),
                              child: Center(
                                child: Text(
                                  (widget.isOrder != null && widget.isOrder!)
                                      ? 'Thanh toán'
                                      : 'Dự trù kinh phí',
                                  style: const TextStyle(
                                    color: Colors.white, // Text color
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  // Callback function to modify the tags list
  void updateFinalCart(ItemCart cartItem, int newQty) {
    List<ItemCart> updatedList =
        List.from(list); // Create a copy of the original list

    for (var i = 0; i < updatedList.length; i++) {
      if (updatedList[i].product.id == cartItem.product.id) {
        if (newQty != 0) {
          setState(() {
            finalTotal -= cartItem.product.price * cartItem.qty!;
            finalTotal += cartItem.product.price * newQty;

            updatedList[i] = ItemCart(product: cartItem.product, qty: newQty);
          });
        } else {
          setState(() {
            finalTotal -= cartItem.product.price * cartItem.qty!;
          });
          updatedList.removeAt(i);
          break; // Exit the loop since the item was found and removed
        }
      }
    }

    setState(() {
      list = updatedList; // Update the original list with the modified copy
    });
  }

  OrderCreateViewModel convertCart() {
    List<Map> details = list.map((itemCart) {
      return {
        'productId': itemCart.product.id,
        'quantity': itemCart.product.price
      };
    }).toList();

    List<dynamic> dates = [];

    for (final date in _servingDates) {
      dates.add(json.encode(
          "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"));
    }
    OrderCreateViewModel order = OrderCreateViewModel(
        planId: sharedPreferences.getInt('planId'),
        period: widget.session.enumName,
        details: details,
        servingDates: dates,
        note: noteController.text);
    return order;
  }

  addOrder() async {
    var total = 0.0;
    var order = convertCart();
    List<OrderDetailViewModel> details = [];
    List<Map> detailsMap = [];
    List<String> serveDates =
        _servingDates.map((e) => e.toLocal().toString().split(' ')[0]).toList();
    for (final item in list) {
      total += item.product.price * item.qty!;
      details.add(OrderDetailViewModel(
          id: item.product.id,
          productName: item.product.name,
          quantity: item.qty!,
          productId: item.product.id,
          price: item.product.price.toDouble()));
      detailsMap.add({
        'productId': item.product.id,
        'productName': item.product.name,
        'quantity': item.qty,
        'price': item.product.price.toDouble(),
        'partySize': item.product.partySize
      });
    }
    final tempOrder = orderService.convertToTempOrder(
        supplier!,
        noteController.text,
        widget.serviceType.name,
        detailsMap,
        order.period,
        serveDates,
        serveDates
            .map((e) => DateTime.parse(e).difference(widget.startDate).inDays)
            .toList(),
        widget.orderGuid,
        (total * serveDates.length) / GlobalConstant().VND_CONVERT_RATE);
    if (!widget.isOrder!) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.topSlide,
              title: widget.isOrder != null && widget.isOrder!
                  ? "Thanh toán thành công"
                  : "Thêm thành công",
              titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSans'))
          .show();

      Future.delayed(const Duration(seconds: 1), () {
        widget.callbackFunction(tempOrder);
        if ((widget.isOrder == null || !widget.isOrder!) &&
            widget.orderGuid == null) {
          Navigator.of(context).pop();
        }
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      });
    } else {
      if ((total / GlobalConstant().VND_CONVERT_RATE * _servingDates.length) >
          widget.availableGcoinAmount!) {
        AwesomeDialog(
                context: context,
                animType: AnimType.rightSlide,
                dialogType: DialogType.warning,
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      const Text(
                        'Đơn hàng vượt quá ngân sách',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        'Ngân sách hiện tại: ${widget.availableGcoinAmount!.toInt()} GCOIN',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        'Giá trị đơn hàng: ${NumberFormat.simpleCurrency(locale: 'vi_VN', name: 'GCOIN', decimalDigits: 0).format((finalTotal / GlobalConstant().VND_CONVERT_RATE) * (_servingDates.isEmpty ? 1 : _servingDates.length))}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        'Hãy thay đổi đơn hàng của bạn',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      )
                    ],
                  ),
                ),
                btnOkColor: Colors.amber,
                btnOkOnPress: () {},
                btnOkText: 'Ok')
            .show();
      } else {
        final rs = await orderService.createOrder(
            OrderViewModel(
                createdAt: DateTime.now(),
                details: details,
                uuid: widget.orderGuid,
                note: noteController.text,
                type: widget.serviceType.name,
                period: order.period,
                serveDates: _servingDates
                    .map((e) =>
                        json.encode(e.toLocal().toString().split(' ')[0]))
                    .toList(),
                supplier: widget.supplier),
            sharedPreferences.getInt('planId')!,
            context);
        if (rs != 0) {
          AwesomeDialog(
            // ignore: use_build_context_synchronously
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.topSlide,
            showCloseIcon: true,
            padding: const EdgeInsets.all(12),
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSans',
            ),
            title: "Thanh toán thành công",
          ).show();
          Future.delayed(const Duration(seconds: 1), () {
            widget.callbackFunction(null);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          });
        }
      }
    }
  }

  Future pickDateRange() async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => SelectOrderDateScreen(
            callbackFunction: callback,
            isOrder: widget.isOrder ?? false,
            session: widget.session,
            total: widget.total,
            selectedDate: _servingDates.isEmpty ? [] : _servingDates,
            serviceType: widget.serviceType,
            endDate: widget.endDate,
            startDate: widget.startDate)));
  }

  callback(List<DateTime> servingDates, double total) {
    setState(() {
      _servingDates = servingDates;
      finalTotal = total;
      selectedDays = servingDates.length;
    });
    final rs = Utils().getHolidayServingDates(holidays, _servingDates);
    holidayServingDates = rs['holidayServingDates'];
    normalServingDates = rs['normalServingDates'];
    servingDates.sort((a, b) => a.compareTo(b));
  }
}
