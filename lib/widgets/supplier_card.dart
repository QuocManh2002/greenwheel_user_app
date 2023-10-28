import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/supplier.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_menu_screen.dart';
import 'package:greenwheel_user_app/widgets/rating_bar.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class SupplierCard extends StatefulWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    required this.serviceType,
  });
  final Supplier supplier;
  final ServiceType serviceType;

  @override
  State<SupplierCard> createState() => _SupplierCardState();
}

class _SupplierCardState extends State<SupplierCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero, // Remove default padding
                shape: RoundedRectangleBorder(
                  // Add a rounded shape if desired
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ServiceMenuScreen(
                    supplier: widget.supplier,
                    serviceType: widget.serviceType,
                  ),
                ),
              );
            },
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
                      tag: widget.supplier.id,
                      child: FadeInImage(
                        height: 15.h,
                        placeholder: MemoryImage(kTransparentImage),
                        image: NetworkImage(widget.supplier.imgUrl),
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
                SizedBox(
                  height: 15.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 10),
                        child: Text(
                          widget.supplier.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'NotoSans',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Row(
                          children: [
                            RatingBar(
                              rating: widget.supplier.rating,
                              ratingCount: widget.supplier.numberOfReviews,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              '${widget.supplier.numberOfReviews} Đánh giá',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Container(
                        width: 55.w,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            widget.supplier.address,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'NotoSans',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
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
