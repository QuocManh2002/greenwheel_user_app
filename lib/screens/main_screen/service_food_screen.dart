import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/suppliers.dart';
import 'package:greenwheel_user_app/models/cart.dart';
import 'package:greenwheel_user_app/models/supplier.dart';
import 'package:greenwheel_user_app/widgets/supplier_card.dart';
import 'package:sizer2/sizer2.dart';

class FoodServiceScreen extends StatefulWidget {
  const FoodServiceScreen({super.key, this.cart});
  final Cart? cart;

  @override
  State<FoodServiceScreen> createState() => _FoodServiceScreenState();
}

class _FoodServiceScreenState extends State<FoodServiceScreen> {
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
                  return SupplierCard(supplier: list[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
