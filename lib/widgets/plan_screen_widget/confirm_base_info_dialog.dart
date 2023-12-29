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
            '(Bạn sẽ không thể chỉnh sửa những thông tin này trong các bước tiếp theo)',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 2.h,
          ),
          RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: "Tổng thời gian chuyến đi:  ",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text:
                            '${selectedComboDate.numberOfDay} ngày, ${selectedComboDate.numberOfNight} đêm',
                        style: const TextStyle(fontWeight: FontWeight.normal))
                  ])),
          SizedBox(
            height: 1.h,
          ),
          RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: "Ngày khởi hành:  ",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text:
                            '${startDate.day}/${startDate.month}/${startDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.normal))
                  ])),
          SizedBox(
            height: 1.h,
          ),
          RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: "Ngày kết thúc:  ",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text: '${endDate.day}/${endDate.month}/${endDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.normal))
                  ])),
          SizedBox(
            height: 1.h,
          ),
          RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: "Số lượng thành viên:  ",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text: '$numberOfMember',
                        style: const TextStyle(fontWeight: FontWeight.normal))
                  ])),
          SizedBox(
            height: 2.h,
          ),
        ],
      ),
    );
  }
}
