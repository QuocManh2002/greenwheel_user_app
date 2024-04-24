import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/sessions.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/models/order_input_model.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_menu_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class SupplierCard extends StatelessWidget {
  const SupplierCard(
      {super.key,
      required this.supplier,
      required this.serviceType,
      required this.location,
      required this.numberOfMember,
      required this.startDate,
      required this.callbackFunction,
      this.isFromTempOrder,
      this.isOrder,
      this.availableGcoinAmount,
      this.initSession,
      required this.endDate});
  final DateTime startDate;
  final DateTime endDate;
  final SupplierViewModel supplier;
  final ServiceType serviceType;
  final LocationViewModel location;
  final int numberOfMember;
  final bool? isOrder;
  final bool? isFromTempOrder;
  final int? availableGcoinAmount;
  final void Function(dynamic tempOrder) callbackFunction;
  final Session? initSession;

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
              Navigator.push(
                  context,
                  PageTransition(
                      child: ServiceMenuScreen(
                        inputModel: OrderInputModel(
                          startDate: startDate,
                          endDate: endDate,
                          period: 'NOON',
                          numberOfMember: numberOfMember,
                          supplier: supplier,
                          serviceType: serviceType,
                          isOrder: isOrder,
                          session:
                              serviceType.id == 1 ? initSession : sessions[1],
                          availableGcoinAmount: availableGcoinAmount,
                          callbackFunction: callbackFunction,
                        ),
                      ),
                      type: PageTransitionType.rightToLeft));
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
                    child: CachedNetworkImage(
                      height: 15.h,
                      placeholder: (context, url) =>
                          Image.memory(kTransparentImage),
                      imageUrl: '$baseBucketImage${supplier.thumbnailUrl!}',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Image.asset(empty_plan),
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
                      SizedBox(
                        width: 50.w,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, top: 10),
                          child: Text(
                            supplier.name!,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'NotoSans',
                            ),
                          ),
                        ),
                      ),
                      if (supplier.standard != null)
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 0.5.h),
                          child: RatingBar.builder(
                              itemCount: 5,
                              itemSize: 20,
                              initialRating: supplier.standard!,
                              allowHalfRating: true,
                              ignoreGestures: true,
                              unratedColor: Colors.grey.withOpacity(0.5),
                              itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                              onRatingUpdate: (value) {}),
                        ),
                      const SizedBox(
                        height: 2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, top: 0.5.h),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: primaryColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: 1.w,
                            ),
                            Text(
                              '0${supplier.phone!.substring(2)}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontFamily: 'NotoSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, top: 0.5.h),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.home,
                              color: primaryColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: 1.w,
                            ),
                            SizedBox(
                              width: 45.w,
                              child: Text(
                                supplier.address!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'NotoSans',
                                ),
                              ),
                            ),
                          ],
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
