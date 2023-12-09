import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_menu_screen.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order_create.dart';
import 'package:greenwheel_user_app/view_models/order_detail_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/cart_item_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class CartScreen extends StatefulWidget {
  CartScreen(
      {super.key,
      required this.location,
      required this.supplier,
      required this.list,
      required this.total,
      required this.serviceType,
      this.pickupDate,
      this.returnDate,
      required this.endDate,
      required this.startDate,
      this.note = "",
      required this.numberOfMember});
  final LocationViewModel location;
  final SupplierViewModel supplier;
  final List<ItemCart> list;
  final double total;
  final ServiceType serviceType;
  final DateTime? pickupDate;
  final DateTime? returnDate;
  final DateTime startDate;
  final DateTime endDate;
  final String note;
  final int numberOfMember;

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
  PlanDetail? plan;
  int quantity = 1;

  TextEditingController noteController = TextEditingController();
  var currencyFormat = NumberFormat.currency(symbol: 'GCOIN', locale: 'vi_VN');
  var _range = "";
  int? days;
  DateTimeRange selectedDates =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pickDateRange();
    finalTotal = widget.total;
    list = widget.list;
    supplier = widget.supplier;
    if (widget.pickupDate != null) {
      _range =
          '${DateFormat('dd/MM/yyyy').format(widget.pickupDate ?? DateTime.now())} - ${DateFormat('dd/MM/yyyy').format(widget.returnDate ?? DateTime.now())}';
      if (widget.serviceType.id == 1 || widget.serviceType.id == 4) {
        days = widget.returnDate!.difference(widget.pickupDate!).inDays + 1;
      } else {
        days = 1;
      }
    } else {
      days = 1;
    }
    noteController.text = widget.note;

    planId = sharedPreferences.getInt("planId");
    if (planId != null) {
      setUpdata();
    }
    if (planId == null) {
      isIndividual = true;
    }
  }

  setUpdata() async {
    plan = await planService.GetPlanById(planId!);
    print("PLAN END DATE: ${plan!.endDate}");
  }

  @override
  Widget build(BuildContext context) {
    final start = selectedDates.start;
    final end = selectedDates.end;
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ServiceMenuScreen(
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                          supplier: widget.supplier,
                          currentCart: list,
                          serviceType: widget.serviceType,
                          iniPickupDate: widget.pickupDate,
                          iniReturnDate: widget.returnDate,
                          iniNote: noteController.text,
                          location: widget.location,
                          numberOfMember: widget.numberOfMember,
                        ),
                      ),
                    );
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
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                              cartEmptyIcon), // Replace with your image path
                        ],
                      ),
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
                              Text(
                                supplier!.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(), // Add space between the two elements
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => ServiceMenuScreen(
                                        startDate: widget.startDate,
                                        endDate: widget.endDate,
                                        numberOfMember: widget.numberOfMember,
                                        location: widget.location,
                                        supplier: widget.supplier,
                                        currentCart: list,
                                        serviceType: widget.serviceType,
                                        iniPickupDate: widget.pickupDate,
                                        iniReturnDate: widget.returnDate,
                                        iniNote: noteController.text,
                                      ),
                                    ),
                                  );
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
                          child: Container(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                return Dismissible(
                                  key:
                                      UniqueKey(), // Unique key for each Dismissible item
                                  background: Container(
                                    color: Colors
                                        .red, // Background color when swiped
                                    alignment: Alignment.centerRight,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    // Handle the item removal here
                                    setState(() {
                                      finalTotal -= list[index].product.price *
                                          list[index].qty;
                                      list.removeAt(index);
                                    });
                                  },
                                  child: CartItemCard(
                                    cartItem: list[index],
                                    updateFinalCart: updateFinalCart,
                                    days: days,
                                    serviceType: widget.serviceType,
                                  ),
                                );
                              },
                            ),
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
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 1.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                10.0), // Set the border radius
                            color: Colors.grey.withOpacity(0.4),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(), // Add space between the two elements
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
                                      "Đối với mặt hàng thuộc thức ăn và như yếu phẩm, số lượng sẽ được nhân lên tương ứng với số ngày được chọn.",
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
                            color: Colors.grey.withOpacity(0.4),
                          ),
                          child: TextField(
                            controller: noteController,
                            maxLines: null, // Allow for multiple lines of text
                            decoration: const InputDecoration(
                              hintText: 'Thêm ghi chú',
                              border:
                                  InputBorder.none, // Remove the bottom border
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
                          height: 16,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "Thông tin hóa đơn",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 22,
                            ),
                            SvgPicture.asset(
                              "assets/images/gcoin_logo.svg",
                              height: 32,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 14),
                              child: Text(
                                "Thanh toán bằng số dư GCOIN ",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
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
                      height: days == 1 ? 19.h : 23.h,
                      width: double.infinity,
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          days != 1
                              ? Column(
                                  children: [
                                    Container(
                                      width: 90.w,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Tạm tổng', // Replace with your first text
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'NotoSans',
                                                color: Colors.black),
                                          ),
                                          Text(
                                            currencyFormat.format(((finalTotal *
                                                        30 /
                                                        100) /
                                                    1000) *
                                                quantity), // Replace with your second text
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'NotoSans',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                )
                              : Container(),
                          Container(
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
                                        color: Colors.black,
                                      ),
                                    ),
                                    (widget.serviceType.id == 1 ||
                                            widget.serviceType.id == 4)
                                        ? Text(
                                            days == 1
                                                ? ""
                                                : "( ${days.toString()} ngày )", // Replace with your first text
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'NotoSans',
                                              color: Colors.black38,
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                                Text(
                                  currencyFormat.format((finalTotal / 1000) *
                                      quantity!), // Replace with your second text
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoSans',
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 90.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Đặt cọc (30%)', // Replace with your first text
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'NotoSans',
                                      color: Colors.black),
                                ),
                                Text(
                                  currencyFormat.format(((finalTotal *
                                              30 /
                                              100) /
                                          1000) *
                                      quantity), // Replace with your second text
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: 90.w,
                            height: 6.h,
                            child: ElevatedButton(
                              onPressed: () async {
                                // if (widget.pickupDate == null) {
                                //   Fluttertoast.showToast(
                                //     msg: 'Vui lòng thêm ngày nhận!',
                                //     toastLength: Toast.LENGTH_LONG,
                                //     gravity: ToastGravity.BOTTOM,
                                //     timeInSecForIosWeb:
                                //         1, // Duration in seconds
                                //   );
                                // }
                                // else if (plan != null &&
                                //     plan!.endDate
                                //         .isBefore(widget.returnDate!)) {
                                //   Fluttertoast.showToast(
                                //     msg:
                                //         'Ngày kết thúc kế hoạch không thể sớm hơn ngày nhận đơn!',
                                //     toastLength: Toast.LENGTH_LONG,
                                //     gravity: ToastGravity.BOTTOM,
                                //     timeInSecForIosWeb:
                                //         1, // Duration in seconds
                                //   );
                                // } else {
                                if (isIndividual) {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.topSlide,
                                    showCloseIcon: true,
                                    title: "Xác nhận thanh toán",
                                    desc: "Bạn sẽ thanh toán theo cá nhân",
                                    btnOkText: "OK",
                                    btnOkOnPress: () async {
                                      await paymentStart();
                                    },
                                  ).show();
                                } else {
                                  await paymentStart();
                                }
                                // }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Background color
                              ),
                              child: const Center(
                                child: Text(
                                  'Thanh toán',
                                  style: TextStyle(
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
            finalTotal -= cartItem.product.price * cartItem.qty;
            finalTotal += cartItem.product.price * newQty;

            updatedList[i] = ItemCart(product: cartItem.product, qty: newQty);
          });
        } else {
          setState(() {
            finalTotal -= cartItem.product.price * cartItem.qty;
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
    List<OrderDetailCreateViewModel> details = list.map((itemCart) {
      return OrderDetailCreateViewModel(
        productId: itemCart.product
            .id, // Replace with the actual property from ProductViewModel
        quantity: quantity,
      );
    }).toList();

    List<dynamic> dates = [];
    DateTime startDate = selectedDates.start;
    DateTime endDate = selectedDates.end;

    dates.add(json.encode(
        "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}"));
    while (startDate.isBefore(endDate)) {
      startDate = startDate.add(const Duration(days: 1));
      dates.add(json.encode(
          "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}"));
    }
    OrderCreateViewModel order = OrderCreateViewModel(
        planId: sharedPreferences.getInt('planId'),
        period: "AFTERNOON",
        details: details,
        servingDates: dates);

    if (widget.note.isNotEmpty) {
      order.note = noteController.text;
    }

    return order;
  }

  paymentStart() async {
    int? check = await orderService.addOrder(convertCart());
    if (check != null) {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: "Thanh toán thành công",
        desc: "Ấn tiếp tục để trở về",
        btnOkText: "Tiếp tục",
        btnOkOnPress: () {
          Navigator.of(context).pop();

          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (ctx) =>
          //         //     OrderHistoryScreen(
          //         //   serviceType:
          //         //       widget.serviceType,
          //         // ),
          //         ServiceMainScreen(
          //       serviceType:
          //           widget.serviceType,
          //       location: widget.location,
          //       callbackFunction: (List<OrderCreatePlan> orderList){},
          //     ),
          //   ),
          // );
        },
      ).show();
    } else {
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: "Thanh toán thất bại",
        desc: "Xuất hiện lỗi trong quá trình thanh toán",
        btnOkText: "OK",
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future pickDateRange() async {
    DateTimeRange? newSelectedDate = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDates,
      firstDate: DateTime.now(),
      lastDate: DateTime(2024),
      builder: (context, child) {
        return Theme(
          data: ThemeData().copyWith(
              colorScheme: const ColorScheme.light(
                  primary: primaryColor, onPrimary: Colors.white)),
          child: DateRangePickerDialog(
            initialDateRange: selectedDates,
            firstDate: widget.startDate,
            lastDate: widget.endDate,
          ),
        );
      },
    );
    if (newSelectedDate == null) {
      return;
    }
    setState(() {
      quantity = newSelectedDate.duration.inDays + 1;
      selectedDates = newSelectedDate;
    });
  }
}
