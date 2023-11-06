import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/suppliers.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/supplier.dart';
import 'package:greenwheel_user_app/widgets/supplier_card.dart';
import 'package:sizer2/sizer2.dart';

class ServiceMainScreen extends StatefulWidget {
  const ServiceMainScreen({
    super.key,
    required this.serviceType,
  });
  final ServiceType serviceType;

  @override
  State<ServiceMainScreen> createState() => _ServiceMainScreenState();
}

class _ServiceMainScreenState extends State<ServiceMainScreen> {
  List<Supplier> list = [];
  String title = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.serviceType.id == 1) {
      title = "Dịch vụ ăn uống";
      list = [
        suppliers[0],
        suppliers[1],
        suppliers[2],
      ];
    } else if (widget.serviceType.id == 2) {
      title = "Dịch vụ lưu trú";
      list = [
        suppliers[5],
      ];
    } else if (widget.serviceType.id == 3) {
      title = "Dịch vụ đi lại";
      list = [
        suppliers[5],
      ];
    } else {
      title = "Dịch vụ tiện lợi";
      list = [
        suppliers[5],
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(15.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the current page
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 14),
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  // var tagsByName =
                                  //     searchTagsByName(searchController.text);
                                  // if (tagsByName.isEmpty) {
                                  //   // var locationsByName =
                                  //   //     searchTagsByName(searchController.text);
                                  //   print("empty");
                                  // } else {
                                  //   print("not empty");
                                  //   setState(() {
                                  //     currentTags = tagsByName;
                                  //   });
                                  // }
                                });
                              },
                            ),
                            hintText: "Bạn cần tìm dịch vụ nào?",
                            contentPadding: EdgeInsets.all(4.w),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
