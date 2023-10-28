import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/suppliers.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/supplier.dart';
import 'package:greenwheel_user_app/widgets/supplier_card.dart';
import 'package:sizer2/sizer2.dart';

class ServiceMainScreen extends StatefulWidget {
  const ServiceMainScreen({super.key, required this.serviceType});
  final ServiceType serviceType;

  @override
  State<ServiceMainScreen> createState() => _ServiceMainScreenState();
}

class _ServiceMainScreenState extends State<ServiceMainScreen> {
  List<Supplier> list = [
    suppliers[0],
    suppliers[1],
    suppliers[2],
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // Handle return icon action here
                    // Navigator.of(context).pop(); // Close the current page
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (ctx) => SearchScreen(
                    //       search: widget.search,
                    //     ),
                    //   ),
                    // );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text(
                    "Dịch vụ ăn uống",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return SupplierCard(
                    supplier: list[index],
                    serviceType: widget.serviceType,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
