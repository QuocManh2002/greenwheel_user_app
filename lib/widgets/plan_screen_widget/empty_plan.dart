import 'package:flutter/material.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:sizer2/sizer2.dart';

class EmptyPlan extends StatelessWidget {
  const EmptyPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            emptyPlan,
            height: 20.h,
          ),
          const SizedBox(height: 8,),
          const Text(
            "Không có kế hoạch",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: Colors.black54, fontFamily: 'NotoSans'),
          )
        ],
      ),
    );
  }
}
