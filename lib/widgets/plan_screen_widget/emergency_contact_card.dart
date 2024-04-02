import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:sizer2/sizer2.dart';

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard(
      {super.key,
      required this.emergency,
      required this.index,
      required this.callback,
      required this.isSelected});
  final EmergencyContactViewModel emergency;
  final int index;
  final void Function() callback;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero, // Remove default padding
                shape: RoundedRectangleBorder(
                  // Add a rounded shape if desired
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.white),
            onPressed: () async {
              List<String>? selectedIndex =
                  sharedPreferences.getStringList('selectedIndex');
              if (selectedIndex != null) {
                if (selectedIndex
                    .any((element) => element == index.toString())) {
                  selectedIndex.remove(index.toString());
                } else {
                  selectedIndex.add(index.toString());
                }
                sharedPreferences.setStringList('selectedIndex', selectedIndex);
              } else {
                sharedPreferences
                    .setStringList('selectedIndex', [index.toString()]);
              }
              callback();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80.w,
                        child: Text(
                          emergency.name!,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'NotoSans',
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: primaryColor,
                        ),
                      if (isSelected)
                        SizedBox(
                          width: 2.w,
                        )
                    ],
                  ),
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
                        width: 1.h,
                      ),
                      Text(
                        emergency.phone!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontFamily: 'NotoSans',
                        ),
                      ),
                    ],
                  ),
                ),
                if (emergency.address != null)
                  Padding(
                    padding: EdgeInsets.only(left: 8, top: 0.5.h, bottom: 1.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.home,
                          color: primaryColor,
                          size: 20,
                        ),
                        SizedBox(
                          width: 1.h,
                        ),
                        SizedBox(
                          width: 80.w,
                          child: Text(
                            emergency.address == null ? "" : emergency.address!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'NotoSans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (emergency.address == null)
                  SizedBox(
                    height: 1.h,
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
