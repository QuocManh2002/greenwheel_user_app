import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:sizer2/sizer2.dart';
import 'package:intl/intl.dart';

class OrderDetailCard extends StatefulWidget {
  const OrderDetailCard({
    super.key,
    required this.cartItem,
  });
  final ItemCart cartItem;

  @override
  State<OrderDetailCard> createState() => _OrderDetailCardState();
}

class _OrderDetailCardState extends State<OrderDetailCard> {
  // Create a NumberFormat instance for currency formatting
  var currencyFormat = NumberFormat.currency(symbol: 'VND', locale: 'vi_VN');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 10.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 10),
                        child: Text(
                          widget.cartItem.item.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'NotoSans',
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 55.w,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            currencyFormat.format(widget.cartItem.item.price *
                                widget.cartItem.qty),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'NotoSans',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8), // Add padding
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.green), // Add a green border
                    borderRadius:
                        BorderRadius.circular(8), // Optional: Add border radius
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // To minimize the width of the Row
                    children: [
                      const Text(
                        'SL:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green, // Set the text color to green
                          fontWeight: FontWeight
                              .bold, // Add additional styling if needed
                        ),
                      ),
                      const SizedBox(
                          width: 4), // Add space between "SL" and the quantity
                      Text(
                        widget.cartItem.qty.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 1.8,
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
