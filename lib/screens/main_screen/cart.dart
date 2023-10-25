import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/supplier.dart';
import 'package:greenwheel_user_app/widgets/cart_item_card.dart';
import 'package:sizer2/sizer2.dart';

class CartScreen extends StatefulWidget {
  const CartScreen(
      {super.key,
      required this.supplier,
      required this.list,
      required this.total});
  final Supplier supplier;
  final List<ItemCart> list;
  final double total;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double finalTotal = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    finalTotal = widget.total;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (ctx) => const FoodServiceScreen(),
                    //   ),
                    // );
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 14, right: 14, top: 20, bottom: 12),
                child: Row(
                  children: [
                    Text(
                      widget.supplier.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(), // Add space between the two elements
                    TextButton(
                      onPressed: () {
                        // Handle the link action here
                        // For example, you can use Navigator to navigate to a new screen.
                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => YourScreen()));
                      },
                      child: const Text(
                        '+  Thêm món',
                        style: TextStyle(
                          color: Colors.blue, // Set the color of the link text
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
              const SizedBox(
                width: 8,
              ),
              Container(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.list.length,
                  itemBuilder: (context, index) {
                    print("Build");
                    return CartItemCard(
                      cartItem: widget.list[index],
                      updateFinalCart: updateFinalCart,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Callback function to modify the tags list
  void updateFinalCart(ItemCart item, int newQty) {
    setState(() {
      for (var cartItem in widget.list) {
        if (item.item.id == cartItem.item.id) {
          finalTotal -= cartItem.item.price * cartItem.qty;
          finalTotal += cartItem.item.price * newQty;
          widget.list.remove(cartItem);
          widget.list.add(ItemCart(item: cartItem.item, qty: newQty));
        }
      }
    });
  }
}
