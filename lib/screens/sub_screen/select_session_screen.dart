import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/sessions.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/order_screen_widget/session_card.dart';
import 'package:sizer2/sizer2.dart';

class SelectSessionScreen extends StatefulWidget {
  const SelectSessionScreen(
      {super.key,
      required this.serviceType,
      required this.location,
      required this.numberOfMember,
      required this.startDate,
      required this.endDate,
      this.isOrder,
      this.availableGcoinAmount,
      this.isFromTempOrder,
      required this.callbackFunction,
      this.initSession,
      this.isEndAtNoon});
  final DateTime startDate;
  final DateTime endDate;
  final ServiceType serviceType;
  final LocationViewModel location;
  final int numberOfMember;
  final bool? isOrder;
  final bool? isFromTempOrder;
  final int? availableGcoinAmount;
  final void Function(dynamic) callbackFunction;
  final Session? initSession;
  final bool? isEndAtNoon;

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
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              //   child: RichText(
              //       text: TextSpan(
              //           text: widget.supplier.name,
              //           style: const TextStyle(
              //               fontSize: 20,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.black),
              //           children: const [
              //         TextSpan(text: ' có 4 khung giờ phục vụ khách hàng', style: TextStyle(
              //           fontWeight: FontWeight.normal
              //         ))
              //       ])),
              // ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                child: Text(
                  'Hãy chọn khung giờ mà bạn muốn nhân dịch vụ',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.isEndAtNoon != null && widget.isEndAtNoon!
                    ? 2
                    : widget.initSession != null
                        ? sessions.length -
                            sessions.indexOf(widget.initSession!)
                        : sessions.length,
                itemBuilder: (context, index) {
                  return SessionCard(
                    availableGcoinAmount: widget.availableGcoinAmount,
                    isOrder: widget.isOrder,
                    session: widget.initSession != null
                        ? sessions[
                            index + sessions.indexOf(widget.initSession!)]
                        : sessions[index],
                    endDate: widget.endDate,
                    startDate: widget.startDate,
                    location: widget.location,
                    numberOfMember: widget.numberOfMember,
                    serviceType: widget.serviceType,
                    initSession: widget.initSession,
                    callbackFunction: widget.callbackFunction,
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
