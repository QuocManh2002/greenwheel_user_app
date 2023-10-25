import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:intl/intl.dart';

class CartItemCard extends StatefulWidget {
  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.updateFinalCart,
  });
  final ItemCart cartItem;
  final Function updateFinalCart;

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
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: Hero(
                      tag: widget.cartItem.item.id,
                      child: FadeInImage(
                        height: 10.h,
                        placeholder: MemoryImage(kTransparentImage),
                        image: NetworkImage(widget.cartItem.item.imgUrl),
                        fit: BoxFit.cover,
                        width: 15.h,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Stack(
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
                                currencyFormat
                                    .format(widget.cartItem.item.price),
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InputQty(
                        maxVal: 100,
                        initVal: widget.cartItem.qty,
                        minVal: -100,
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
                          setState(() {
                            print("CHANGING");
                            print(widget.cartItem.item.name);
                            print(widget.cartItem.qty);
                            print(val);
                            widget.updateFinalCart(widget.cartItem, val);
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            height: 1.8,
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
