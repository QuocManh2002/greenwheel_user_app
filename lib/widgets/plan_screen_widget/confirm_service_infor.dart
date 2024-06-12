import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phuot_app/core/constants/colors.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/main.dart';
import 'package:phuot_app/view_models/order.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class ConfirmServiceInfor extends StatelessWidget {
  const ConfirmServiceInfor(
      {super.key,
      required this.listRest,
      required this.listFood,
      required this.budgetPerCapita,
      required this.listVehicle,
      required this.total,
      required this.listSurcharges});
  final List<OrderViewModel> listRest;
  final List<OrderViewModel> listFood;
  final List<OrderViewModel> listVehicle;
  final double total;
  final double budgetPerCapita;
  final List<dynamic> listSurcharges;

  @override
  Widget build(BuildContext context) {
    var totalSurcharge = listSurcharges.fold(
        0,
        (previousValue, element) =>
            previousValue +
            (element['alreadyDivided']
                ? int.parse(element['gcoinAmount'].toString()) *
                    sharedPreferences.getInt('plan_number_of_member')!
                : int.parse(element['gcoinAmount'].toString())));
                
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
                              '${order.supplier!.name} - ${order.details!.length} sản phẩm',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.clip,
                            ))
                    ]),
              ),
            if (listRest.isNotEmpty)
              SizedBox(
                height: 1.h,
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
                              '${order.supplier!.name} - ${order.details!.length} sản phẩm',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.clip,
                            ))
                    ]),
              ),
            if (listVehicle.isNotEmpty)
              SizedBox(
                height: 1.h,
              ),
            if (listVehicle.isNotEmpty)
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
                        'Thuê phương tiện',
                        style: TextStyle(fontSize: 16),
                      ),
                      for (final order in listFood)
                        SizedBox(
                            width: 80.w,
                            child: Text(
                              '${order.supplier!.name} - ${order.details!.length} sản phẩm',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.clip,
                            ))
                    ]),
              ),
            if (listSurcharges.isNotEmpty)
              SizedBox(
                height: 1.h,
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
                      for (final sur in listSurcharges)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 50.w,
                              child: Text(
                                '${json.decode(sur['note'])}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              alignment: Alignment.centerRight,
                              width: 20.w,
                              child: Text(
                                NumberFormat.simpleCurrency(
                                        locale: 'vi_VN',
                                        decimalDigits: 0,
                                        name: '')
                                    .format(sur['alreadyDivided']
                                        ? sur['gcoinAmount'] *
                                            sharedPreferences
                                                .getInt('plan_number_of_member')
                                        : sur['gcoinAmount']),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            SvgPicture.asset(
                              gcoinLogo,
                              height: 25,
                            )
                          ],
                        )
                    ]),
              ),
            SizedBox(
              height: 1.h,
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
                          NumberFormat.simpleCurrency(
                                  locale: 'vi_VN', decimalDigits: 0, name: "")
                              .format((total + totalSurcharge) * sharedPreferences.getDouble('BUDGET_ASSURANCE_RATE')!),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SvgPicture.asset(
                          gcoinLogo,
                          height: 25,
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
                          NumberFormat.simpleCurrency(
                                  locale: 'vi_VN', decimalDigits: 0, name: "")
                              .format((total + totalSurcharge) * sharedPreferences.getDouble('BUDGET_ASSURANCE_RATE')! / sharedPreferences.getInt('plan_number_of_member')!),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SvgPicture.asset(
                          gcoinLogo,
                          height: 25,
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
