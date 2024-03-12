import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/sessions.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_menu_screen.dart';
import 'package:greenwheel_user_app/screens/sub_screen/select_session_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
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
      required this.endDate});
  final DateTime startDate;
  final DateTime endDate;
  final SupplierViewModel supplier;
  final ServiceType serviceType;
  final LocationViewModel location;
  final int numberOfMember;
  final bool? isOrder;
  final bool? isFromTempOrder;
  final double? availableGcoinAmount;
  final void Function(String? orderGuid) callbackFunction;

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
              // ServiceType service = services[0];
              // if (supplier.type == "VEHICLE_SHOP") {
              //   service = services[4];
              // } 
              // else {
              //   service = services.firstWhere((s) => s.name == supplier.type);
              // }
              // Navigator.of(context).pop();
              if (serviceType.id == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => SelectSessionScreen(
                      startDate: startDate,
                      endDate: endDate,
                      numberOfMember: 0,
                      supplier: supplier,
                      serviceType:serviceType,
                      location: location,
                      isOrder: isOrder,
                      availableGcoinAmount: availableGcoinAmount,
                      isFromTempOrder: isFromTempOrder,
                      callbackFunction: callbackFunction,
                    ),
                  ),
                );
              } else if (serviceType.id == 5) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ServiceMenuScreen(
                      startDate: startDate,
                      endDate: endDate,
                      numberOfMember: numberOfMember,
                      supplier: supplier,
                      serviceType:serviceType,
                      isOrder: isOrder,
                      session: sessions[1],
                      isFromTempOrder: isFromTempOrder,
                      availableGcoinAmount: availableGcoinAmount,
                      callbackFunction: callbackFunction,
                    ),
                  ),
                );}
              //  else if (service.id == 4) {
              //   Navigator.of(context).push(MaterialPageRoute(
              //       builder: (ctx) => EmergencySupplier(supplier: supplier)));
              // } else if (service.id == 5) {
              //   Navigator.of(context).push(MaterialPageRoute(
              //       builder: (ctx) => EmergencySupplier(supplier: supplier)));
              // }
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
                      image: NetworkImage(supplier.thumbnailUrl!),
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
                          supplier.name!,
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
                              '0${supplier.phone!.substring(3)}',
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
                            supplier.address!,
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
