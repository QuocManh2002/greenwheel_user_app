import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greenwheel_user_app/config/stripe_config.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_menu_screen.dart';
import 'package:greenwheel_user_app/screens/sub_screen/select_order_date.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order_create.dart';
import 'package:greenwheel_user_app/view_models/order_detail_create.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/cart_item_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class CartScreen extends StatefulWidget {
  CartScreen({
    super.key,
    required this.location,
    required this.supplier,
    required this.list,
    required this.total,
    required this.serviceType,
    this.pickupDate,
    this.returnDate,
    this.note = "",
  });
  final LocationViewModel location;
  final SupplierViewModel supplier;
  final List<ItemCart> list;
  final double total;
  final ServiceType serviceType;
  final DateTime? pickupDate;
  final DateTime? returnDate;
  final String note;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  OrderService orderService = OrderService();
  double finalTotal = 0;
  double deposit = 0;
  List<ItemCart> list = [];
  SupplierViewModel? supplier;
  bool isLoading = false;

  TextEditingController noteController = TextEditingController();
  var currencyFormat = NumberFormat.currency(symbol: 'VND', locale: 'vi_VN');
  var _range = "";
  var _single = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    finalTotal = widget.total;
    list = widget.list;
    supplier = widget.supplier;
    if (widget.pickupDate != null) {
      if (widget.serviceType.id == 2 || widget.serviceType.id == 3) {
        _range =
            '${DateFormat('dd/MM/yyyy').format(widget.pickupDate ?? DateTime.now())} - ${DateFormat('dd/MM/yyyy').format(widget.returnDate ?? DateTime.now())}';
      } else {
        _single = DateFormat('dd/MM/yyyy')
            .format(widget.pickupDate ?? DateTime.now());
      }
    }
    noteController.text = widget.note;
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ServiceMenuScreen(
                          supplier: widget.supplier,
                          currentCart: list,
                          serviceType: widget.serviceType,
                          iniPickupDate: widget.pickupDate,
                          iniReturnDate: widget.returnDate,
                          iniNote: noteController.text,
                          location: widget.location,
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
                                widget.pickupDate == null
                                    ? "N/A"
                                    : ((widget.serviceType.id == 2 ||
                                            widget.serviceType.id == 3)
                                        ? _range
                                        : _single),
                                style: const TextStyle(
                                  fontSize: 14,
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
                                      builder: (ctx) => SelectOrderDateScreen(
                                        location: widget.location,
                                        supplier: widget.supplier,
                                        list: list,
                                        total: finalTotal,
                                        serviceType: widget.serviceType,
                                        iniPickupDate: widget.pickupDate,
                                        iniReturnDate: widget.returnDate,
                                        iniNote: noteController.text,
                                      ),
                                    ),
                                  );
                                },
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
                            const Icon(
                              Icons.money,
                              color: Colors.green,
                            ), // Add the calendar icon
                            const Padding(
                              padding: EdgeInsets.only(left: 14),
                              child: Text(
                                "Thanh toán trực tiếp",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                // Add your onPressed action here
                              },
                              child: const Icon(
                                Icons
                                    .arrow_forward, // Replace with your desired icon
                              ),
                            ),
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
                      height: 19.h,
                      width: double.infinity,
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: 90.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tổng cộng', // Replace with your first text
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'NotoSans',
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(
                                      finalTotal), // Replace with your second text
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
                                  currencyFormat.format(finalTotal *
                                      30 /
                                      100), // Replace with your second text
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
                                if (widget.pickupDate == null) {
                                  Fluttertoast.showToast(
                                    msg: 'Vui lòng thêm ngày nhận!',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb:
                                        1, // Duration in seconds
                                  );
                                } else {
                                  var items = [
                                    {
                                      "productPrice": finalTotal * 30 ~/ 100,
                                      "productName": "Thanh toán dịch vụ",
                                      "qty": 1,
                                    },
                                  ];
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await StripeConfig.stripePaymentCheckout(
                                    items,
                                    finalTotal * 30 ~/ 100,
                                    context,
                                    mounted,
                                    onSuccess: () async {
                                      bool check = await orderService
                                          .addOrder(convertCart());
                                      setState(() {
                                        isLoading = false;
                                      });
                                      if (check) {
                                        // ignore: use_build_context_synchronously
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.success,
                                          animType: AnimType.topSlide,
                                          title: "Thanh toán thành công",
                                          desc:
                                              "Ấn tiếp tục để trở về kế hoạch",
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
                                          desc:
                                              "Xuất hiện lỗi trong quá trình thanh toán",
                                          btnOkText: "OK",
                                          btnOkOnPress: () {},
                                        ).show();
                                      }
                                    },
                                    onCancel: () {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.warning,
                                        animType: AnimType.topSlide,
                                        title: "Hủy thanh toán",
                                        desc:
                                            "Bạn đã hủy thanh toán thành công",
                                        btnOkText: "OK",
                                        btnOkOnPress: () {},
                                      ).show();
                                    },
                                    onError: (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.error,
                                        animType: AnimType.topSlide,
                                        title: "Thanh toán thất bại",
                                        desc:
                                            "Xuất hiện lỗi trong quá trình thanh toán",
                                        btnOkText: "OK",
                                        btnOkOnPress: () {},
                                      ).show();
                                    },
                                  );
                                }
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

  void updatePickupDate(DateTime newDate) {
    setState(() {
      // widget.pickupDate = newDate;
    });
  }

  OrderCreateViewModel convertCart() {
    List<OrderDetailCreateViewModel> details = list.map((itemCart) {
      return OrderDetailCreateViewModel(
        productId: itemCart.product
            .id, // Replace with the actual property from ProductViewModel
        quantity: itemCart.qty,
      );
    }).toList();

    int? id = sharedPreferences.getInt("planId");
    String? transactionId = sharedPreferences.getString("transactionId");

    OrderCreateViewModel order = OrderCreateViewModel(
      planId: id!,
      pickupDate: widget.pickupDate!,
      paymentMethod: "PAYPAL",
      transactionId: transactionId!,
      deposit: finalTotal.toInt(),
      details: details,
    );

    if (widget.returnDate != null) {
      order.returnDate = widget.returnDate;
    }
    if (widget.note.isNotEmpty) {
      order.note = noteController.text;
    }

    return order;
  }
}
