import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:sizer2/sizer2.dart';

class UpdateOrderClonePlanBottomSheet extends StatelessWidget {
  const UpdateOrderClonePlanBottomSheet(
      {super.key,
      required this.onConfirm,
      required this.cancelOrders,
      required this.updatedOrders});
  final List<dynamic> updatedOrders;
  final List<dynamic> cancelOrders;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    final totalOrders = [...updatedOrders, ...cancelOrders];
    return Container(
      height: 90.h,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 1.h,
            ),
            Container(
              alignment: Alignment.center,
              height: 6,
              width: 10.h,
              decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
            ),
            SizedBox(
              height: 1.h,
            ),
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Thay đổi quan trọng',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSans'),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Hệ thống tự động tối ưu chi phí dựa trên các thay đổi về số thành viên & thời gian trải nghiệm',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, fontFamily: 'NotoSans', color: Colors.grey),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            for (int index = 0; index < totalOrders.length; index++)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                    color: index.isOdd
                        ? primaryColor.withOpacity(0.1)
                        : lightPrimaryTextColor.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft:
                          index == 0 ? const Radius.circular(10) : Radius.zero,
                      topRight:
                          index == 0 ? const Radius.circular(10) : Radius.zero,
                      bottomLeft: index == totalOrders.length - 1
                          ? const Radius.circular(10)
                          : Radius.zero,
                      bottomRight: index == totalOrders.length - 1
                          ? const Radius.circular(10)
                          : Radius.zero,
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalOrders[index]['type'] == 'EAT'
                          ? 'Dùng bữa tại:'
                          : totalOrders[index]['type'] == 'VISIT'
                              ? 'Thuê phương tiện:'
                              : 'Nghỉ ngơi tại:',
                      style:
                          const TextStyle(fontSize: 13, fontFamily: 'NotoSans'),
                    ),
                    RichText(
                        text: TextSpan(
                            text: totalOrders[index]['providerName'],
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'NotoSans'),
                            children: [
                          TextSpan(
                              text:
                                  '  (${Utils().getPeriodString(totalOrders[index]['period'])['text']})',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'NotoSans'))
                        ])),
                    SizedBox(
                      height: 0.3.h,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 40.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // for (final date in totalOrders[index]
                              //     ['serveDates'])
                              //   RichText(
                              //     text: TextSpan(
                              //         text: DateFormat('dd/MM/yyyy')
                              //             .format(DateTime.parse(date)),
                              //         style: const TextStyle(
                              //           color: Colors.black,
                              //           fontSize: 15,
                              //           fontWeight: FontWeight.w500,
                              //           fontFamily: 'NotoSans',
                              //         ),
                              //         children: [
                              //           if (Utils()
                              //               .isHoliday(DateTime.parse(date)))
                              //             const TextSpan(
                              //                 text: ' (ngày lễ)',
                              //                 style: TextStyle(
                              //                     fontSize: 13,
                              //                     color: Colors.black54,
                              //                     fontWeight:
                              //                         FontWeight.normal))
                              //         ]),
                              //   ),
                              for (final detail in totalOrders[index]
                                  ['details'])
                                RichText(
                                  text: TextSpan(
                                      text: detail['productName'],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'NotoSans',
                                      ),
                                      children: [
                                        TextSpan(
                                            text: ' x${detail['quantity']}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.normal))
                                      ]),
                                ),
                              SizedBox(
                                height: 0.1.h,
                              ),
                              // Row(
                              //   children: [
                              //     Text(
                              //       NumberFormat.simpleCurrency(
                              //               locale: 'vi_VN',
                              //               name: '',
                              //               decimalDigits: 0)
                              //           .format(totalOrders[index]['total']),
                              //       textAlign: TextAlign.end,
                              //       overflow: TextOverflow.clip,
                              //       style: const TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.bold,
                              //           fontFamily: 'NotoSans'),
                              //     ),
                              //     Padding(
                              //       padding: const EdgeInsets.only(top: 4),
                              //       child: SvgPicture.asset(
                              //         gcoinLogo,
                              //         height: 16,
                              //       ),
                              //     )
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        updatedOrders.any((order) =>
                                order['orderUUID'] ==
                                totalOrders[index]['orderUUID'])
                            ? const Icon(
                                Icons.keyboard_double_arrow_right,
                                color: Colors.blueAccent,
                                size: 30,
                              )
                            : const Icon(
                                Icons.close,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                        const Spacer(),
                        SizedBox(
                            width: 40.w,
                            child: updatedOrders.any((order) =>
                                    order['orderUUID'] ==
                                    totalOrders[index]['orderUUID'])
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // for (final newDate
                                      // in updatedOrders.firstWhere((order) =>
                                      //         order['orderUUID'] ==
                                      //         totalOrders[index]
                                      //             ['orderUUID'])[
                                      //     'newServeDates'])
                                      // Text(
                                      //   DateFormat('dd/MM/yyyy')
                                      //       .format(DateTime.parse(newDate)),
                                      //   style: const TextStyle(
                                      //       fontSize: 15,
                                      //       fontWeight: FontWeight.w500,
                                      //       fontFamily: 'NotoSans'),
                                      // ),
                                      for (final newDetail
                                          in updatedOrders.firstWhere((order) =>
                                              order['orderUUID'] ==
                                              totalOrders[index]
                                                  ['orderUUID'])['newDetails'])
                                        RichText(
                                          text: TextSpan(
                                              text: newDetail['productName'],
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'NotoSans',
                                              ),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        ' x${newDetail['quantity']}',
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.normal))
                                              ]),
                                        ),
                                      SizedBox(
                                        height: 0.1.h,
                                      ),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.end,
                                      //   children: [
                                      //     Text(
                                      //       NumberFormat.simpleCurrency(
                                      //               locale: 'vi_VN',
                                      //               name: '',
                                      //               decimalDigits: 0)
                                      //           .format(updatedOrders
                                      //                   .firstWhere((order) =>
                                      //                       order[
                                      //                           'orderUUID'] ==
                                      //                       totalOrders[
                                      //                               index]
                                      //                           ['orderUUID'])[
                                      //               'newTotal']),
                                      //       textAlign: TextAlign.end,
                                      //       overflow: TextOverflow.clip,
                                      //       style: const TextStyle(
                                      //           fontSize: 16,
                                      //           fontWeight: FontWeight.bold,
                                      //           fontFamily: 'NotoSans'),
                                      //     ),
                                      //     Padding(
                                      //       padding:
                                      //           const EdgeInsets.only(top: 4),
                                      //       child: SvgPicture.asset(
                                      //         gcoinLogo,
                                      //         height: 16,
                                      //       ),
                                      //     )
                                      //   ],
                                      // ),
                                    ],
                                  )
                                : Text(
                                    totalOrders[index]['cancelReason'],
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NotoSans'),
                                  ))
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 1.h,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
              child: Row(
                children: [
                  const Icon(
                    Icons.info,
                    color: Colors.amber,
                    size: 25,
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  SizedBox(
                      width: 77.w,
                      child: RichText(
                          text: const TextSpan(
                              text: 'Lưu ý: ',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.amber,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold),
                              children: [
                            TextSpan(
                              text: 'Bạn sẽ không thể hoàn tác thao tác này',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.amber,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.normal),
                            )
                          ]))),
                ],
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton.icon(
                        style: elevatedButtonStyle.copyWith(
                            backgroundColor:
                                const MaterialStatePropertyAll(Colors.white),
                            foregroundColor:
                                const MaterialStatePropertyAll(primaryColor),
                            shape: const MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    side: BorderSide(
                                        color: primaryColor, width: 1.5)))),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Huỷ'))),
                SizedBox(
                  width: 2.w,
                ),
                Expanded(
                    child: ElevatedButton.icon(
                        style: elevatedButtonStyle,
                        onPressed: () {
                          onConfirm();
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Đồng ý')))
              ],
            )
          ],
        ),
      ),
    );
  }
}
