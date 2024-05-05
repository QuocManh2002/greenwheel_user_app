import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:sizer2/sizer2.dart';

class ServiceTypeCard extends StatefulWidget {
  const ServiceTypeCard({
    super.key,
    required this.serviceType,
    required this.changeService,
    required this.isPress,
  });
  final ServiceType serviceType;
  final Function changeService;
  final bool isPress;

  @override
  State<ServiceTypeCard> createState() => _ServiceTypeCardState();
}

class _ServiceTypeCardState extends State<ServiceTypeCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero, // Remove default padding
            shape: RoundedRectangleBorder(
              // Add a rounded shape if desired
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: widget.isPress ? Colors.green : lightPrimaryColor),
        onPressed: () async {
          setState(() {
            widget.changeService(
                widget.serviceType); // Call the callback function
          });
        },
        child: SizedBox(
          width: 11.h,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              widget.serviceType.name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
