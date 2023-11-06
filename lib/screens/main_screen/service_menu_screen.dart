import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/menu_item.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/supplier.dart';
import 'package:greenwheel_user_app/screens/main_screen/cart.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/widgets/menu_item_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class ServiceMenuScreen extends StatefulWidget {
  const ServiceMenuScreen({
    super.key,
    required this.supplier,
    required this.serviceType,
    this.currentCart = const [],
    this.iniPickupDate,
    this.iniReturnDate,
    this.iniNote = "",
  });
  final Supplier supplier;
  final ServiceType serviceType;
  final List<ItemCart> currentCart;
  final DateTime? iniPickupDate;
  final DateTime? iniReturnDate;
  final String iniNote;

  @override
  State<ServiceMenuScreen> createState() => _ServiceMenuScreenState();
}

class _ServiceMenuScreenState extends State<ServiceMenuScreen> {
  var currencyFormat = NumberFormat.currency(symbol: 'VND', locale: 'vi_VN');

  double total = 0;
  List<ItemCart> items = [];
  DateTime? pickupDate;
  DateTime? returnDate;
  String note = "";
  String title = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.currentCart.isNotEmpty) {
      double tmp = 0;
      if (widget.currentCart.isNotEmpty) {}
      for (var cartItem in widget.currentCart) {
        tmp += cartItem.item.price * cartItem.qty;
      }
      setState(() {
        items = widget.currentCart;
        total = tmp;
      });
    }
    pickupDate = widget.iniPickupDate;
    returnDate = widget.iniReturnDate;
    note = widget.iniNote;

    if (widget.serviceType.id == 1) {
      title = "Món ăn";
    } else if (widget.serviceType.id == 2) {
      title = "Vật dụng";
    } else if (widget.serviceType.id == 3) {
      title = "Phương tiện";
    } else {
      title = "Hàng hóa";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(15.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the current page
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => ServiceMainScreen(
                              serviceType: widget.serviceType,
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        widget.supplier.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            // prefixIcon: const Icon(
                            //   Icons.search,
                            //   color: Colors.black,
                            // ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  // var tagsByName =
                                  //     searchTagsByName(searchController.text);
                                  // if (tagsByName.isEmpty) {
                                  //   // var locationsByName =
                                  //   //     searchTagsByName(searchController.text);
                                  //   print("empty");
                                  // } else {
                                  //   print("not empty");
                                  //   setState(() {
                                  //     currentTags = tagsByName;
                                  //   });
                                  // }
                                });
                              },
                            ),
                            hintText: "Bạn đang cần gì?",
                            contentPadding: EdgeInsets.all(4.w),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 14),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.supplier.items.length,
                itemBuilder: (context, index) {
                  int? qty;
                  ItemCart? itemCart = getItemCartByMenuItemId(
                      widget.currentCart, widget.supplier.items[index].id);
                  if (itemCart != null) {
                    qty = itemCart.qty;
                  }
                  return MenuItemCard(
                    item: widget.supplier.items[index],
                    quantity: qty,
                    updateCart: updateCart,
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: Visibility(
          visible: total != 0,
          child: Container(
            height: 10.h,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 90.w,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => CartScreen(
                            supplier: widget.supplier,
                            list: items,
                            total: total,
                            serviceType: widget.serviceType,
                            pickupDate: pickupDate,
                            returnDate: returnDate,
                            note: note,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Giỏ hàng',
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                              width:
                                  10), // Add a space between the text and dot
                          const Icon(
                            Icons.fiber_manual_record,
                            color: Colors.white, // Dot color
                            size: 10,
                          ),
                          const SizedBox(
                              width:
                                  10), // Add a space between the dot and the price
                          Text(
                            currencyFormat.format(total),
                            style: const TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ItemCart? getItemCartByMenuItemId(List<ItemCart> cartList, int selectId) {
    try {
      return cartList.firstWhere((cart) => cart.item.id == selectId);
    } catch (e) {
      // Handle the case when no matching item is found
      return null;
    }
  }

  void updateCart(MenuItem item, int qty) {
    setState(() {
      final existingItemIndex =
          items.indexWhere((cartItem) => cartItem.item.id == item.id);

      if (existingItemIndex != -1) {
        final existingItem = items[existingItemIndex];
        total -= existingItem.item.price * existingItem.qty;

        if (qty != 0) {
          total += item.price * qty;
          items[existingItemIndex] = ItemCart(item: item, qty: qty);
        } else {
          items.removeAt(existingItemIndex);
        }
      } else if (qty != 0) {
        items.add(ItemCart(item: item, qty: qty));
        total += item.price * qty;
      }

      if (items.isEmpty) {
        pickupDate = null;
        returnDate = null;
        note = "";
      }
    });
  }
}
