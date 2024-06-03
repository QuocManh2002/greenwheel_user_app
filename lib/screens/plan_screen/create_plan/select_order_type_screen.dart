// import 'package:flutter/material.dart';
// import 'package:phuot_app/core/constants/colors.dart';
// import 'package:phuot_app/core/constants/service_types.dart';
// import 'package:phuot_app/screens/main_screen/service_main_screen.dart';
// import 'package:phuot_app/screens/sub_screen/select_session_screen.dart';
// import 'package:phuot_app/view_models/location.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:sizer2/sizer2.dart';

// class SelectOrderType extends StatelessWidget {
//   const SelectOrderType(
//       {super.key,
//       required this.availableGcoinAmount,
//       required this.endDate,
//       required this.startDate,
//       required this.location,
//       required this.memberLimit});
//   final DateTime startDate;
//   final DateTime endDate;
//   final int memberLimit;
//   final LocationViewModel location;
//   final int availableGcoinAmount;

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//       backgroundColor: lightPrimaryTextColor,
//       appBar: AppBar(
//         title: const Text('Đặt đơn hàng mới'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 3.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             InkWell(
//               onTap: () {
//                 Navigator.of(context).pop();
//                 Navigator.push(
//                     context,
//                     PageTransition(
//                         child: ServiceMainScreen(
//                           serviceType: services[1],
//                           location: location,
//                           isOrder: true,
//                           availableGcoinAmount: availableGcoinAmount,
//                           numberOfMember: memberLimit,
//                           startDate: startDate,
//                           isFromTempOrder: false,
//                           endDate: endDate,
//                           callbackFunction: (tempOrder) {},
//                         ),
//                         type: PageTransitionType.rightToLeft));
//               },
//               child: buildOrderTypeButton(
//                   Icons.hotel, 'Lưu trú', Colors.blueAccent),
//             ),
//             SizedBox(
//               height: 1.h,
//             ),
//             InkWell(
//               onTap: () {
//                 Navigator.of(context).pop();
//                 Navigator.push(
//                     context,
//                     PageTransition(
//                         child: SelectSessionScreen(
//                           serviceType: services[0],
//                           location: location,
//                           isOrder: true,
//                           availableGcoinAmount: availableGcoinAmount,
//                           numberOfMember: memberLimit,
//                           startDate: startDate,
//                           isFromTempOrder: false,
//                           endDate: endDate,
//                           callbackFunction: (tempOrder) {},
//                         ),
//                         type: PageTransitionType.rightToLeft));
//               },
//               child: buildOrderTypeButton(
//                   Icons.restaurant, 'Ăn uống', Colors.amber),
//             ),
//             SizedBox(
//               height: 1.h,
//             ),
//             InkWell(
//               onTap: () {
//                 Navigator.of(context).pop();
//                 Navigator.push(
//                     context,
//                     PageTransition(
//                         child: ServiceMainScreen(
//                           serviceType: services[2],
//                           location: location,
//                           isOrder: true,
//                           availableGcoinAmount: availableGcoinAmount,
//                           numberOfMember: memberLimit,
//                           startDate: startDate,
//                           isFromTempOrder: false,
//                           endDate: endDate,
//                           callbackFunction: (tempOrder) {},
//                         ),
//                         type: PageTransitionType.rightToLeft));
//               },
//               child: buildOrderTypeButton(
//                   Icons.directions_car, 'Phương tiện đi lại', primaryColor),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }

//   buildOrderTypeButton(IconData icon, String type, Color color) => Container(
//         height: 12.h,
//         decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.all(Radius.circular(12))),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 4.w,
//             ),
//             Container(
//               height: 7.h,
//               width: 7.h,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                   shape: BoxShape.circle, color: color.withOpacity(0.7)),
//               child: Icon(
//                 icon,
//                 size: 4.h,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(
//               width: 4.w,
//             ),
//             Text(
//               type,
//               overflow: TextOverflow.clip,
//               style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey),
//             ),
//             const Spacer(),
//             const Icon(
//               Icons.add,
//               color: Colors.grey,
//               size: 30,
//             ),
//             SizedBox(
//               width: 5.w,
//             ),
//           ],
//         ),
//       );
// }
