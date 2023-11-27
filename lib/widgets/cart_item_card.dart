import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:sizer2/sizer2.dart';
import 'package:intl/intl.dart';

class CartItemCard extends StatefulWidget {
  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.updateFinalCart,
    required this.updateFinalTotal,
    this.days,
  });
  final ItemCart cartItem;
  final Function updateFinalCart;
  final Function updateFinalTotal;
  final int? days;

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Create a NumberFormat instance for currency formatting
  var currencyFormat = NumberFormat.currency(symbol: 'GCOIN', locale: 'vi_VN');

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
                  height: 10.h,
                  child: Column(
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
                            currencyFormat.format(
                                (widget.cartItem.product.price *
                                        widget.cartItem.qty) /
                                    1000),
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
                  child: InputQty(
                    maxVal: 100,
                    initVal: widget.cartItem.qty,
                    minVal: 0,
                    steps: 1,
                    decoration: const QtyDecorationProps(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 10,
                      ),
                      width: 8,
                      isBordered: false,
                      fillColor: Colors.black12,
                    ),
                    onQtyChanged: (val) async {
                      widget.updateFinalCart(widget.cartItem, val);
                      widget.updateFinalTotal(
                          widget.cartItem, val, widget.days);
                    },
                  ),
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
