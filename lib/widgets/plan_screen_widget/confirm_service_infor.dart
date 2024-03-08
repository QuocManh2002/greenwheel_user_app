import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class ConfirmServiceInfor extends StatelessWidget {
  const ConfirmServiceInfor(
      {super.key,
      required this.listRest,
      required this.listFood,
      required this.budgetPerCapita,
      required this.total,
      required this.listSurcharges});
  final List<OrderViewModel> listRest;
  final List<OrderViewModel> listFood;
  final double total;
  final double budgetPerCapita;
  final List<Map> listSurcharges;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
        child: SizedBox(
          width: 100.w,
          child: Column(children: [
            Container(
              alignment: Alignment.center,
              height: 6,
              width: 10.h,
              decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
            ),
            if (listFood.isNotEmpty)
            SizedBox(
              height: 1.h,
            ),
            if (listFood.isNotEmpty)
              Container(
                width: 100.w,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.black12,
                        offset: Offset(1, 3),
                      )
                    ],
                    color: Colors.white.withOpacity(0.97),
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ăn uống',
                        style: TextStyle(fontSize: 16),
                      ),
                      for (final order in listFood)
                        SizedBox(
                            width: 80.w,
                            child: Text(
                              '${order.supplierName} - ${order.details!.length} sản phẩm',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ))
                    ]),
              ),
              if (listRest.isNotEmpty)
            SizedBox(
              height: 2.h,
            ),
            if (listRest.isNotEmpty)
              Container(
                width: 100.w,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.black12,
                        offset: Offset(1, 3),
                      )
                    ],
                    color: Colors.white.withOpacity(0.97),
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lưu trú',
                        style: TextStyle(fontSize: 16),
                      ),
                      for (final order in listRest)
                        SizedBox(
                            width: 80.w,
                            child: Text(
                              '${order.supplierName} - ${order.details!.length} sản phẩm',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ))
                    ]),
              ),
              if (listSurcharges.isNotEmpty)
            SizedBox(
              height: 2.h,
            ),
            if (listSurcharges.isNotEmpty)
              Container(
                width: 100.w,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.black12,
                        offset: Offset(1, 3),
                      )
                    ],
                    color: Colors.white.withOpacity(0.97),
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phụ thu',
                        style: TextStyle(fontSize: 16),
                      ),
                      for (final order in listSurcharges)
                        SizedBox(
                            width: 80.w,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 50.w,
                                  child: Text(
                                    '${json.decode(order['note'])}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${order['gcoinAmount']} GCOIN',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ))
                    ]),
              ),
            SizedBox(
              height: 2.h,
            ),
            Container(
              width: 100.w,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 3,
                      color: Colors.black12,
                      offset: Offset(1, 3),
                    )
                  ],
                  color: Colors.white.withOpacity(0.97),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Tổng cộng',
                          style: TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        Text(
                          '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(total)} GCOIN',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Khoản thu bình quân',
                          style: TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        Text(
                          '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(budgetPerCapita)} GCOIN',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ]),
            ),
            SizedBox(
              height: 2.h,
            ),
          ]),
        ),
      ),
    );
  }
}
