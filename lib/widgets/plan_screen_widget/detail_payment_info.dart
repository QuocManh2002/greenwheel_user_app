import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/view_models/transaction_detail.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        );
    buildOrderDetailTextWidget(String text) => Text(
          text,
          textAlign: TextAlign.start,
          overflow: TextOverflow.clip,
          style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        );
    Icon? icon;
    Color? color;
    switch (transactionDetail.transaction!.type) {
      case 'GIFT':
        color = Colors.pinkAccent;
        icon = const Icon(
          Icons.monetization_on_outlined,
          color: Colors.pinkAccent,
          size: 40,
        );
        break;
      case 'ORDER':
        color = primaryColor;
        icon = const Icon(Icons.shopping_cart_checkout_outlined,
            color: primaryColor, size: 40);
        break;
      case 'ORDER_REFUND':
        color = Colors.orange;
        icon = const Icon(
          Icons.remove_shopping_cart_outlined,
          color: Colors.orange,
          size: 40,
        );
        break;
      case 'PLAN_FUND':
        color = Colors.blueAccent;
        icon = const Icon(
          Icons.backpack,
          color: Colors.blueAccent,
          size: 40,
        );
        break;
      case 'PLAN_REFUND':
        color = Colors.amber;
        icon = const Icon(
          Icons.no_backpack_outlined,
          color: Colors.amber,
          size: 40,
        );
        break;
      case 'TOPUP':
        color = Colors.redAccent.withOpacity(0.8);
        icon = Icon(
          Icons.account_balance,
          color: Colors.redAccent.withOpacity(0.8),
          size: 40,
        );
        break;
    }
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
                        color: color!.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.5), width: 0.5)),
                    child: icon,
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 62.w,
                        child: Text(
                          transactionDetail.transaction!.description!,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            NumberFormat.simpleCurrency(
                                    locale: 'vi_VN', decimalDigits: 0, name: '')
                                .format(
                                    transactionDetail.transaction!.gcoinAmount),
                            style: const TextStyle(
                              fontSize: 19,
                              fontFamily: 'NotoSans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SvgPicture.asset(
                            gcoin_logo,
                            height: 25,
                          )
                        ],
                      ),
                    ],
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
                  const Spacer(),
                  SizedBox(
                    width: 60.w,
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
                          gcoin_logo,
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
                              .format(
                                  transactionDetail.transaction!.gcoinAmount)),
                        ),
                        SvgPicture.asset(
                          gcoin_logo,
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
                            SizedBox(
                                width: 60.w,
                                child: buildOrderDetailTextWidget(
                                    detail.productName)),
                            const Spacer(),
                            SizedBox(
                                width: 30,
                                child: buildTextWidget('X${detail.quantity}'))
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
                            .format(transactionDetail.transaction!.gcoinAmount!)),
                            SvgPicture.asset(gcoin_logo, height: 25,)
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
