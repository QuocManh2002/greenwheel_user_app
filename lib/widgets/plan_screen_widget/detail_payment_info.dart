import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/transaction_types.dart';
import 'package:greenwheel_user_app/models/transaction_type.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/urls.dart';
import '../../view_models/transaction_detail.dart';

class DetailPaymentInfo extends StatelessWidget {
  const DetailPaymentInfo({super.key, required this.transactionDetail});
  final TransactionDetailViewModel transactionDetail;

  @override
  Widget build(BuildContext context) {
    buildTextWidget(String text) => Text(
          text,
          textAlign: TextAlign.end,
          overflow: TextOverflow.clip,
          style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        );
    buildOrderDetailTextWidget(String text) => Text(
          text,
          textAlign: TextAlign.start,
          overflow: TextOverflow.clip,
          style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        );
    TransactionType transactionType = transactionTypes.firstWhere(
      (element) => element.engName == transactionDetail.transaction!.type,
    );
    String? description = transactionType.index == 4 ? 'Hoàn tiền từ kế hoạch "${transactionDetail.plan!.name}".' : transactionDetail.transaction!.description;

    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Chi tiết thanh toán',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black54),
          ),
        ),
        SizedBox(
          height: 0.7.h,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              border:
                  Border.all(color: primaryColor.withOpacity(0.7), width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(12))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 0.7.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                        color: transactionType.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.5), width: 0.5)),
                    child: Icon(transactionType.icon, color: transactionType.color,),
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description ?? 'Không có thông tin',
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              NumberFormat.simpleCurrency(
                                      locale: 'vi_VN',
                                      decimalDigits: 0,
                                      name: '')
                                  .format(
                                      transactionDetail.transaction!.amount),
                              style: const TextStyle(
                                fontSize: 19,
                                fontFamily: 'NotoSans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SvgPicture.asset(
                              gcoinLogo,
                              height: 25,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Divider(
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Trạng thái',
                    style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 15,
                        color: Colors.grey),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color:
                            transactionDetail.transaction!.status == 'ACCEPTED'
                                ? primaryColor.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15)),
                    child: Text(
                      transactionDetail.transaction!.status == 'ACCEPTED'
                          ? 'Thành công'
                          : 'Thất bại',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.bold,
                          color: transactionDetail.transaction!.status ==
                                  'ACCEPTED'
                              ? primaryColor
                              : Colors.red),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Divider(
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Thời gian',
                    style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 15,
                        color: Colors.grey),
                  ),
                  Expanded(
                    child: buildTextWidget(
                        '${DateFormat.Hm().format(transactionDetail.transaction!.createdAt!.toLocal())} ${DateFormat('dd/MM/yyyy').format(transactionDetail.transaction!.createdAt!.toLocal())}'),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Divider(
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              if (transactionDetail.plan != null)
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chi phí tham gia',
                          style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 15,
                              color: Colors.grey),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 35.w,
                          child: buildTextWidget(NumberFormat.simpleCurrency(
                                  locale: 'vi_VN', decimalDigits: 0, name: '')
                              .format(transactionDetail
                                  .plan!.gcoinBudgetPerCapita)),
                        ),
                        SvgPicture.asset(
                          gcoinLogo,
                          height: 25,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Divider(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Số thành viên',
                          style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 15,
                              color: Colors.grey),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 20.w,
                          child: buildTextWidget(
                              transactionDetail.memberWeight.toString()),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Divider(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng cộng',
                          style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 15,
                              color: Colors.grey),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 50.w,
                          child: buildTextWidget(NumberFormat.simpleCurrency(
                                  locale: 'vi_VN', decimalDigits: 0, name: '')
                              .format(transactionDetail.transaction!.amount)),
                        ),
                        SvgPicture.asset(
                          gcoinLogo,
                          height: 25,
                        )
                      ],
                    ),
                  ],
                ),
              if (transactionDetail.order != null)
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Chi tiết',
                        style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 15,
                            color: Colors.grey),
                      ),
                    ),
                    for (final detail in transactionDetail.order!.details!)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child: buildOrderDetailTextWidget(
                                    detail.productName)),
                            Text(
                              'x${detail.quantity}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'NotoSans',
                                  color: Colors.black54),
                            )
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Divider(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Tổng cộng',
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'NotoSans',
                              color: Colors.grey),
                        ),
                        const Spacer(),
                        buildTextWidget(NumberFormat.simpleCurrency(
                                locale: 'vi_VN', decimalDigits: 0, name: '')
                            .format(transactionDetail.transaction!.amount!)),
                        SvgPicture.asset(
                          gcoinLogo,
                          height: 25,
                        )
                      ],
                    )
                  ],
                )
            ],
          ),
        )
      ],
    );
  }
}
