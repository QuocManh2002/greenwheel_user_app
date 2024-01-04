import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_emergency_detail_service.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard(
      {super.key,
      required this.emergency,
      required this.index,
      required this.callback});
  final EmergencyContactViewModel emergency;
  final int index;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    var isEnableToAdd = sharedPreferences
        .getStringList('serviceList')!
        .any((element) => element == index.toString());
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero, // Remove default padding
                shape: RoundedRectangleBorder(
                  // Add a rounded shape if desired
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => SelectEmergencyDetailService(
                        emergency: emergency,
                        index: index,
                        callback: () {
                          callback();
                        },
                      )));
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
                      image: const NetworkImage(
                          "https://vantaihoangminh.com/wp-content/uploads/2021/05/d%E1%BB%8Bch-v%E1%BB%A5-xe-c%E1%BB%A9u-h%E1%BB%99-giao-th%C3%B4ng-v%E1%BA%ADn-t%E1%BA%A3i-ho%C3%A0ng-minh2.jpg"),
                      fit: BoxFit.cover,
                      width: 12.h,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: SizedBox(
                    height: 15.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  emergency.name!,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'NotoSans',
                                  ),
                                ),
                              ),
                              if(isEnableToAdd)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: primaryColor,
                              )
                            ],
                          ),
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
                                '0${emergency.phone!.substring(3)}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'NotoSans',
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 55.w,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8, top: 0.5.h),
                            child: Text(
                              emergency.address == null
                                  ? ""
                                  : emergency.address!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontFamily: 'NotoSans',
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
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
