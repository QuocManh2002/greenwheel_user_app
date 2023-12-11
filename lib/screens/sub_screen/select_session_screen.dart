import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/sessions.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/session_card.dart';
import 'package:sizer2/sizer2.dart';

class SelectSessionScreen extends StatefulWidget {
  const SelectSessionScreen({
    super.key,
    required this.supplier,
    required this.serviceType,
    required this.location,
    required this.numberOfMember,
    required this.startDate,
    required this.endDate,
  });
  final DateTime startDate;
  final DateTime endDate;
  final SupplierViewModel supplier;
  final ServiceType serviceType;
  final LocationViewModel location;
  final int numberOfMember;

  @override
  State<SelectSessionScreen> createState() => _SelectSessionScreenState();
}

class _SelectSessionScreenState extends State<SelectSessionScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() async {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(7.7.h),
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
                      onPressed: () async {
                        Navigator.of(context).pop();
                        // Close the current page
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 14),
                      child: Text(
                        "Chọn buổi check-in",
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
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
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  return SessionCard(
                    session: sessions[index],
                    endDate: widget.endDate,
                    startDate: widget.startDate,
                    location: widget.location,
                    numberOfMember: widget.numberOfMember,
                    serviceType: widget.serviceType,
                    supplier: widget.supplier,
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
