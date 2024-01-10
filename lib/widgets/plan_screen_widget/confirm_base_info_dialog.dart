import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:sizer2/sizer2.dart';

class ConfirmBaseInfoDialog extends StatelessWidget {
  const ConfirmBaseInfoDialog(
      {super.key,
      required this.selectedComboDate,
      required this.endDate,
      required this.numberOfMember,
      required this.startDate});
  final ComboDate selectedComboDate;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfMember;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            child: const Text(
              'Xác nhận thông tin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 1.h,
          ),
          const Text(
            'Bạn sẽ không thể chỉnh sửa những thông tin này trong các bước tiếp theo',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 2.h,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tổng thời gian chuyến đi:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  const Text(
                    "Ngày khởi hành dự kiến:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  const Text(
                    "Ngày kết thúc dự kiến:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  const Text(
                    "Số lượng thành viên:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              ),
              SizedBox(
                width: 1.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${selectedComboDate.numberOfDay} ngày, ${selectedComboDate.numberOfNight} đêm",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    "${startDate.hour}:${startDate.minute.toString().length == 1 ? '0${startDate.minute}' : startDate.minute} ${startDate.day}/${startDate.month}/${startDate.year}",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    "${endDate.day}/${endDate.month}/${endDate.year}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    "$numberOfMember",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
