import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class PlanScheduleActivity extends StatelessWidget {
  const PlanScheduleActivity({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
          child: Container(
            width: 100.w,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
                // gradient: LinearGradient(
                //     colors: [primaryColor, Color(0xFF82E0AA)],
                //     begin: Alignment.topLeft,
                //     end: Alignment.bottomRight),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.black12,
                    offset: Offset(2, 4),
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Dùng bữa tại nhà hàng Ngàn Sao",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_horiz,
                          ))
                    ],
                  ),
                  Container(
                    color: Colors.black54,
                    height: 2,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(
                        DateFormat.yMMMMEEEEd('vi_VN').format(date),
                        style:const  TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  const Row(
                    children: [
                      Icon(Icons.watch_later_outlined),
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        '3:55 PM',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 1.h,
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
