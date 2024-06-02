import 'package:flutter/material.dart';
import 'package:phuot_app/core/constants/colors.dart';
import 'package:sizer2/sizer2.dart';

class CreatePlanHeader extends StatelessWidget {
  const CreatePlanHeader(
      {super.key, required this.stepNumber, required this.stepName});
  final int stepNumber;
  final String stepName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 2.h),
      alignment: Alignment.center,
      width: 100.w,
      child: Column(
        children: [
          SizedBox(
            height: 0.5.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: primaryColor, shape: BoxShape.circle),
                child: Text(
                  '${stepNumber.toString()}.',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 1.h,
              ),
              Text(
                stepName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 0.5.h,
          ),
          Divider(
            color: primaryColor.withOpacity(0.8),
            height: 2,
          )
        ],
      ),
    );
  }
}
