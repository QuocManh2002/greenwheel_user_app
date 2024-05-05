import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class OrderTotalInformationDialog extends StatelessWidget {
  const OrderTotalInformationDialog(
      {super.key,
      required this.selectedDate,
      required this.holidayUpPCT,
      required this.selectedHolidays,
      required this.total});
  final List<DateTime> selectedDate;
  final List<DateTime> selectedHolidays;
  final double total;
  final int holidayUpPCT;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Thông tin đơn hàng',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSans',
            ),
          ),
          SizedBox(
            height: 1.h,
          ),
          const Row(
            children: [
              Text(
                'Ngày phục vụ',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSans'),
              ),
              Spacer(),
              Text(
                'Đơn giá',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSans'),
              ),
            ],
          ),
          if (selectedDate.isNotEmpty)
            SizedBox(
              height: 0.5.h,
            ),
          if (selectedDate.isNotEmpty)
            for (final date in selectedDate)
              Row(
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'NotoSans'
                    ),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.simpleCurrency(
                      locale: 'vi_VN',
                      name: 'đ',
                      decimalDigits: 0
                    ).format(total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'NotoSans'
                    ),
                  )
                  ],
              ),
          if(selectedHolidays.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for(final date in selectedHolidays)
              Row(
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 16, 
                      fontFamily: 'NotoSans'
                    ),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.simpleCurrency(decimalDigits: 0, locale: 'vi_VN', name: 'đ').format(
                      total * (1 + holidayUpPCT / 100)
                    ),
                    style:const TextStyle(
                      fontSize: 16, 
                      fontFamily: 'NotoSans'
                    ),
                  )
                ],
              ),
              SizedBox(height: 0.5.h,),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(12))
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                    color: Colors.amber,
                    ),
                    SizedBox(width: 2.w,),
                    SizedBox(
                      width: 55.w,
                      child: const Text('Chúng tôi xin phép được cập nhật giá của đơn hàng cho những ngày phục vụ thuộc ngày lễ',
                      style: TextStyle(
                        fontSize: 12, 
                        fontFamily: 'NotoSans',
                        color: Colors.amber
                      ),
                      overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h,)
            ],
          ),
          const Divider(
            color: Colors.black54,
            height: 1.5,
          ),
          SizedBox(height: 0.5.h,),
          Row(
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'NotoSans'
                ),
              ),
              const Spacer(),
              Text(
                NumberFormat.simpleCurrency(
                  locale: 'vi_VN',
                  decimalDigits: 0,
                  name: 'đ'
                ).format(
                  total * selectedDate.length +
                  total * selectedHolidays.length * (1 + holidayUpPCT / 100)
                ),
                style: const TextStyle(
                  fontSize: 17,
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
