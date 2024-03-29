import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:intl/intl.dart';

class MenuItemCard extends StatefulWidget {
  const MenuItemCard({
    super.key,
    required this.product,
    required this.updateCart,
    this.quantity,
    required this.numberOfMember,
    required this.serviceType
  });
  final ProductViewModel product;
  final Function updateCart;
  final int? quantity;
  final int numberOfMember;
  final ServiceType serviceType;

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  var currencyFormat = NumberFormat.currency(symbol: 'VND', locale: 'vi_VN');
  bool isQuantity = false;
  bool isFoodOrder = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.quantity != null) {
      setState(() {
        isQuantity = true;
      });
    }
    isFoodOrder = widget.serviceType.id == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white, // Shadow color
                  offset: Offset(0, 0), // Offset of the shadow (x, y)
                  spreadRadius: 0, // Amount of spreading to the shadow
                ),
              ],
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
                    child: FadeInImage(
                      height: 15.h,
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage('$baseBucketImage${widget.product.thumbnailUrl!}'),
                      fit: BoxFit.cover,
                      width: 15.h,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Stack(
                  children: [
                    SizedBox(
                      height: 15.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 44.w,
                                  child: Text(
                                    widget.product.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'NotoSans',
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.product.partySize.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontFamily: 'NotoSans',
                                  ),
                                ),
                                const Icon(
                                  Icons.person,
                                  color: primaryColor,
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 55.w,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                currencyFormat.format(widget.product.price),
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
                      bottom: 10,
                      right: 0,
                      child: isQuantity
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: InputQty(
                                maxVal: 100,
                                initVal: widget.quantity ?? 1,
                                minVal: 0,
                                steps: 1,
                                decoration: const QtyDecorationProps(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 13,
                                  ),
                                  width: 14,
                                  isBordered: false,
                                  fillColor: Colors.black12,
                                ),
                                onQtyChanged: (val) async {
                                  setState(() {
                                    if (val == 0) {
                                      isQuantity = !isQuantity;
                                    }
                                    widget.updateCart(
                                        widget.product, val.toInt());
                                  });
                                },
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(
                                        10), // Remove default padding
                                    shape: RoundedRectangleBorder(
                                      // Add a rounded shape if desired
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    backgroundColor: Colors.green),
                                onPressed: () async {
                                  setState(() {
                                    if (isFoodOrder && !isQuantity) {
                                      widget.updateCart(widget.product, (widget.numberOfMember / widget.product.partySize!).ceil());
                                    } else {
                                      widget.updateCart(widget.product, 1);
                                    }
                                      isQuantity = true;
                                  });
                                },
                                icon: const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                ), // Icon for the cart
                                label: const Text(
                                  'Thêm',
                                  style: TextStyle(
                                      fontFamily: 'NotoSans',
                                      color: Colors.white),
                                ), // Text for the button
                              ),
                            ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 1.8,
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
