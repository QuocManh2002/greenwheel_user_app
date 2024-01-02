// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:greenwheel_user_app/constants/colors.dart';
// import 'package:greenwheel_user_app/service/supplier_service.dart';
// import 'package:greenwheel_user_app/view_models/supplier.dart';
// import 'package:greenwheel_user_app/widgets/order_screen_widget/supplier_card.dart';
// import 'package:sizer2/sizer2.dart';

// class TestScreen extends StatefulWidget {
//   const TestScreen({super.key});

//   @override
//   State<TestScreen> createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin {
//   late TabController tabController;
//   TextEditingController noteController = TextEditingController();
//   List<String> dilaiType = ["REPAIR_SHOP", "TAXI", "VEHICLE_SHOP", "GROCERY"];
//   double lng = 105.058;
//   double lat = 10.5851;
//   List<SupplierViewModel> listDiLai = [];
//   List<SupplierViewModel> listTapHoa = [];
//   List<SupplierViewModel> totalList = [];
//   SupplierService _supplierService = SupplierService();
//   bool isLoading = true;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getData();
//     tabController = TabController(length: 2, vsync: this, initialIndex: 0);
//   }

//   getData() async {
//     totalList = await _supplierService.getSuppliers(lng, lat, dilaiType);
//     if (totalList.isNotEmpty) {
//       setState(() {
//         listDiLai = totalList
//             .where(
//               (element) =>
//                   element.type == "REPAIR_SHOP" ||
//                   element.type == "TAXI" ||
//                   element.type == "VEHICLE_SHOP",
//             )
//             .toList();
//         listTapHoa = totalList
//             .where(
//               (element) => element.type == "GROCERY",
//             )
//             .toList();
//         isLoading = false;
//       });
//     }
//   }

//   saveData() async {}

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//             backgroundColor: Colors.white.withOpacity(0.94),
//             appBar: AppBar(),
//             body: 
//             isLoading ?
//             Center(
//               child: Text('Loading...'),
//             ):
//             SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.all(2.h),
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       TabBar(
//                   controller: tabController,
//                   indicatorColor: primaryColor,
//                   labelColor: primaryColor,
//                   unselectedLabelColor: Colors.grey,
//                   tabs: [
//                     Tab(
//                       text: "(${listDiLai.length})",
//                       icon: const Icon(Icons.bed),
//                     ),
//                     Tab(
//                       text: "(${listTapHoa.length})",
//                       icon: const Icon(Icons.restaurant),
//                     )
//                   ]),
//                   TabBarView(controller: tabController, children: [
//  ListView.builder(
//                           physics: const BouncingScrollPhysics(),
//                           shrinkWrap: true,
//                           itemCount: listDiLai.length,
//                           itemBuilder: (context, index) {
//                             return SupplierCard(
//                               location: ,
//                             );
//                           },
//                         ),
//  ListView.builder(
//                           physics: const BouncingScrollPhysics(),
//                           shrinkWrap: true,
//                           itemCount: listTapHoa.length,
//                           itemBuilder: (context, index) {
//                             return listTapHoa[index];
//                           },
//                         ),
//                 ]),
              
//                     ]),
//               ),
//             )));
//   }
// }
