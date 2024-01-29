import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/screens/plan_screen/select_emergency_detail_service.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:sizer2/sizer2.dart';

class EmergencyContactView extends StatelessWidget {
  const EmergencyContactView({super.key, required this.emergency});
  final EmergencyContactViewModel emergency;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => SelectEmergencyDetailService(
                emergency: emergency,
                index: 1,
                isView: true,
                callback: () {})));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFFf2f2f2),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              emergency.name ?? 'Không có thông tin',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 1.h,
            ),
            Row(
              children: [
                const Icon(
                  Icons.call,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 1.h,
                ),
                Text(
                  emergency.phone == null
                      ? 'Không có thông tin'
                      : '0${emergency.phone!.substring(3)}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
