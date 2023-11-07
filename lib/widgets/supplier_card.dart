import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_menu_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class SupplierCard extends StatefulWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    required this.serviceType,
    required this.location,
  });
  final SupplierViewModel supplier;
  final ServiceType serviceType;
  final LocationViewModel location;

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
              var service =
                  services.firstWhere((s) => s.name == widget.supplier.type);
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ServiceMenuScreen(
                    supplier: widget.supplier,
                    serviceType: service,
                    location: widget.location,
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
                    child: FadeInImage(
                      height: 15.h,
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(widget.supplier.thumbnailUrl),
                      fit: BoxFit.cover,
                      width: 15.h,
                      filterQuality: FilterQuality.high,
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
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8, top: 0.5.h),
                            child: const Text(
                              'Số điện thoại: ',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black45,
                                fontFamily: 'NotoSans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8, top: 0.5.h),
                            child: Text(
                              widget.supplier.phone,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontFamily: 'NotoSans',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Container(
                        width: 55.w,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8, top: 0.5.h),
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
