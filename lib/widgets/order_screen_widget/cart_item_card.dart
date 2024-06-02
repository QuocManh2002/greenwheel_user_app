import 'package:flutter/material.dart';
import 'package:phuot_app/models/menu_item_cart.dart';
import 'package:phuot_app/models/service_type.dart';
import 'package:sizer2/sizer2.dart';
import 'package:intl/intl.dart';

class CartItemCard extends StatefulWidget {
  const CartItemCard({
    super.key,
    required this.cartItem,
    this.days,
    required this.serviceType,
  });
  final ItemCart cartItem;
  final int? days;
  final ServiceType serviceType;

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Create a NumberFormat instance for currency formatting
  var currencyFormat = NumberFormat.currency(symbol: 'VND', locale: 'vi_VN');

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 10),
                        child: Text(
                          widget.cartItem.product.name,
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
                            "${currencyFormat.format((widget.cartItem.product.price * widget.cartItem.qty!))} * ${(widget.days != 1) ? "${widget.days} ngày" : ""}",
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
                const Spacer(),
                Container(
                  height: 7.h,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 10),
                  child: 
                  Text('x${widget.cartItem.qty}', 
                  style:const TextStyle(color: Colors.grey, fontSize: 19, fontWeight: FontWeight.bold, fontFamily: 'NotoSans'),)
                )
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
