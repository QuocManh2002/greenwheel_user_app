import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:sizer2/sizer2.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.serviceType,
    required this.location,
    required this.numberOfMember,
    required this.startDate,
    required this.callbackFunction,
    required this.endDate,
    this.isOrder,
    this.availableGcoinAmount,
    this.isFromTempOrder,
    this.initSession,
    this.isEndAtNoon
  });
  final Session session;
  final DateTime startDate;
  final DateTime endDate;
  final ServiceType serviceType;
  final LocationViewModel location;
  final int numberOfMember;
  final void Function(dynamic) callbackFunction;
  final bool? isOrder;
  final bool? isFromTempOrder;
  final bool? isEndAtNoon;
  final int? availableGcoinAmount;
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
              if (isEndAtNoon == null && initSession != null && initSession != session) {
                AwesomeDialog(
                        context: context,
                        animType: AnimType.leftSlide,
                        dialogType: DialogType.warning,
                        body: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Bạn đang chọn khung giờ phục vụ khác với mô tả của hoạt động',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'NotoSans'),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Điều này có thể làm bạn không tìm được những món ăn mình mong muốn',
                                style: TextStyle(
                                    fontSize: 15, fontFamily: 'NotoSans'),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Vẫn giữ lựa chọn này ?',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoSans'),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                        btnOkColor: Colors.amber,
                        btnOkOnPress: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ServiceMainScreen(
                                initSession: session,
                                isOrder: isOrder,
                                startDate: startDate,
                                location: location,
                                endDate: endDate,
                                numberOfMember: numberOfMember,
                                serviceType: serviceType,
                                isFromTempOrder: isFromTempOrder,
                                availableGcoinAmount: availableGcoinAmount,
                                callbackFunction: callbackFunction,
                              ),
                            ),
                          );
                        },
                        btnOkText: 'Vẫn giữ',
                        btnCancelColor: Colors.blueAccent,
                        btnCancelOnPress: () {},
                        btnCancelText: 'Không')
                    .show();
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ServiceMainScreen(
                      isOrder: isOrder,
                      startDate: startDate,
                      endDate: endDate,
                      location: location,
                      initSession: session,
                      numberOfMember: numberOfMember,
                      serviceType: serviceType,
                      isFromTempOrder: isFromTempOrder,
                      availableGcoinAmount: availableGcoinAmount,
                      callbackFunction: callbackFunction,
                    ),
                  ),
                );
              }
            },
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: Image.asset(
                      session.image,
                      height: 12.h,
                      fit: BoxFit.cover,
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
                        padding: EdgeInsets.only(left: 4.w, top: 4.h),
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
