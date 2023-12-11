import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_menu_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:sizer2/sizer2.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.supplier,
    required this.serviceType,
    required this.location,
    required this.numberOfMember,
    required this.startDate,
    required this.endDate,
  });
  final Session session;
  final DateTime startDate;
  final DateTime endDate;
  final SupplierViewModel supplier;
  final ServiceType serviceType;
  final LocationViewModel location;
  final int numberOfMember;

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
              var service = services.firstWhere((s) => s.name == supplier.type);
              // Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ServiceMenuScreen(
                    startDate: startDate,
                    endDate: endDate,
                    numberOfMember: 0,
                    supplier: supplier,
                    serviceType: service,
                    location: location,
                    session: session,
                  ),
                ),
              );
            },
            child: SizedBox(
              height: 15.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, top: 2.h),
                    child: Text(
                      session.name.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
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
                        padding: EdgeInsets.only(left: 4.w, top: 0.5.h),
                        child: Text(
                          session.range,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontFamily: 'NotoSans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
