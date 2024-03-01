import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer2/sizer2.dart';

class SurchargeCard extends StatelessWidget {
  const SurchargeCard({super.key, required this.amount, required this.note});
  final String amount;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: const BorderRadius.all(Radius.circular(14))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 60.w,
                  child: Text(
                    note,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  color: Colors.grey,
                  width: 2,
                  height: 7.h,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '$amount GCOIN',
                  style: const TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        ),
      );
  }
}