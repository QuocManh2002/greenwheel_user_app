import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
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
            height: 40.h,
          ),
          const SizedBox(height: 16,),
          const Text(
            "Bạn chưa có kế hoạch nào ở dạng này",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17),
          )
        ],
      ),
    );
  }
}
