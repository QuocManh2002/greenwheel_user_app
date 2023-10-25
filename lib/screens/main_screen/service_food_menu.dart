import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/cart.dart';
import 'package:greenwheel_user_app/models/menu_item.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/supplier.dart';
import 'package:greenwheel_user_app/screens/main_screen/cart.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_food_screen.dart';
import 'package:greenwheel_user_app/widgets/menu_item_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class FoodServiceMenu extends StatefulWidget {
  const FoodServiceMenu({super.key, required this.supplier});
  final Supplier supplier;

  @override
  State<FoodServiceMenu> createState() => _FoodServiceMenuState();
}

class _FoodServiceMenuState extends State<FoodServiceMenu> {
  var currencyFormat = NumberFormat.currency(symbol: 'VND', locale: 'vi_VN');

  double total = 0;
  List<ItemCart> items = [];

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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const FoodServiceScreen(),
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
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 14, top: 14),
                child: Text(
                  'Menu',
                  style: TextStyle(
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
                  return MenuItemCard(
                    item: widget.supplier.items[index],
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
            height: 13.h,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 90.w,
                  height: 8.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => CartScreen(
                            supplier: widget.supplier,
                            list: items,
                            total: total,
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
                              fontSize: 20,
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
                              fontSize: 20,
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

  // Callback function to modify the tags list
  void updateCart(MenuItem item, int qty) {
    setState(() {
      bool unExisted = true;
      if (items.isEmpty) {
        items.add(ItemCart(item: item, qty: qty));
        total += item.price * qty;
        print(items.length);
        print(total);
      } else {
        for (var i = 0; i < items.length; i++) {
          if (items[i].item.id == item.id) {
            if (qty != 0) {
              total -= items[i].item.price * items[i].qty;
              total += items[i].item.price * qty;
              items.remove(items[i]);
              items.add(ItemCart(item: item, qty: qty));
            } else {
              total -= items[i].item.price * items[i].qty;
              items.remove(items[i]);
            }
            unExisted = false;
          }
        }
        if (unExisted) {
          items.add(ItemCart(item: item, qty: qty));
          total += item.price * qty;
        }
      }
    });
  }
}
