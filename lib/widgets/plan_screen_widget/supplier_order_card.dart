import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/sessions.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/order_screen/detail_order_screen.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../core/constants/service_types.dart';
import '../../screens/main_screen/service_main_screen.dart';
import '../style_widget/dialog_style.dart';

class SupplierOrderCard extends StatelessWidget {
  const SupplierOrderCard(
      {super.key,
      this.isFromTempOrder,
      this.availableGcoinAmount,
      this.memberLimit,
      this.endDate,
      required this.callback,
      required this.order,
      required this.startDate,
      required this.isTempOrder,
      this.location,
      required this.isConfirm,
      this.planId});
  final OrderViewModel order;
  final DateTime startDate;
  final bool isTempOrder;
  final int? planId;
  final int? memberLimit;
  final DateTime? endDate;
  final bool? isFromTempOrder;
  final int? availableGcoinAmount;
  final void Function(dynamic) callback;
  final LocationViewModel? location;
  final bool isConfirm;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // if (!order.supplier!.isActive!) {
        //   DialogStyle().basicDialog(
        //       context: context,
        //       title: 'Nhà cung cấp đã không còn khả dụng',
        //       desc: 'Vui lòng chọn lại một nhà cung cấp khác',
        //       onOk: () {
        //         Navigator.push(
        //             context,
        //             PageTransition(
        //                 child: ServiceMainScreen(
        //                     serviceType: services.firstWhere(
        //                         (element) => element.name == order.type),
        //                     location: location!,
        //                     isOrder: true,
        //                     isFromTempOrder: isFromTempOrder,
        //                     availableGcoinAmount: availableGcoinAmount,
        //                     initSession: sessions.firstWhere(
        //                         (element) => element.enumName == order.period),
        //                     numberOfMember: memberLimit!,
        //                     startDate: startDate,
        //                     endDate: endDate!,
        //                     uuid: order.uuid,
        //                     serveDates: order.serveDates!
        //                         .map((e) => DateTime.parse(e))
        //                         .toList(),
        //                     callbackFunction: callback),
        //                 type: PageTransitionType.rightToLeft));
        //       },
        //       type: DialogType.warning);
        // } else if (order.details!.any((detail) => !detail.isAvailable!)) {
        //   final invalidProduct =
        //       order.details!.where((detail) => !detail.isAvailable!).toList();
        //   AwesomeDialog(
        //           context: context,
        //           animType: AnimType.leftSlide,
        //           dialogType: DialogType.warning,
        //           body: Padding(
        //             padding: EdgeInsets.symmetric(horizontal: 2.w),
        //             child: Column(
        //               children: [
        //                 RichText(
        //                   text: TextSpan(
        //                       text: 'Sản phẩm: ',
        //                       style: const TextStyle(
        //                           fontSize: 17,
        //                           color: Colors.black,
        //                           fontFamily: 'NotoSans',
        //                           fontWeight: FontWeight.bold),
        //                       children: [
        //                         for (final prod in invalidProduct)
        //                           TextSpan(
        //                               text:
        //                                   '${prod.productName} ${prod != invalidProduct.last ? ',' : ''}',
        //                               style: const TextStyle(
        //                                   color: Colors.black87)),
        //                         const TextSpan(text: 'đã không còn khả dụng')
        //                       ]),
        //                   overflow: TextOverflow.clip,
        //                   textAlign: TextAlign.center,
        //                 ),
        //                 SizedBox(
        //                   height: 1.h,
        //                 ),
        //                 const Text(
        //                   'Vui lòng điều chỉnh lại đơn hàng',
        //                   style: TextStyle(
        //                       color: Colors.grey,
        //                       fontSize: 15,
        //                       fontFamily: 'NotoSans'),
        //                 )
        //               ],
        //             ),
        //           ),
        //           btnOkColor: Colors.amber,
        //           btnOkOnPress: () {},
        //           btnOkText: 'Ok',
        //           btnCancelColor: Colors.blue,
        //           btnCancelOnPress: () {},
        //           btnCancelText: 'Huỷ')
        //       .show();
        // } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => OrderDetailScreen(
                  memberLimit: memberLimit,
                  availableGcoinAmount: availableGcoinAmount,
                  endDate: endDate,
                  order: order,
                  startDate: startDate,
                  isFromTempOrder: isFromTempOrder,
                  isTempOrder: isTempOrder && !isConfirm,
                  planId: planId,
                  location: location,
                  callback: () {
                    callback(null);
                  },
                )));
        // }
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black12,
              offset: Offset(1, 3),
            )
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        height: 15.h,
        width: double.infinity,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(14)),
              child: Hero(
                  tag: UniqueKey(),
                  child: FadeInImage(
                    height: 15.h,
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(
                        '$baseBucketImage${order.supplier!.thumbnailUrl!}'),
                    fit: BoxFit.cover,
                    width: 15.h,
                    filterQuality: FilterQuality.high,
                  )),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 3,
                  ),
                  SizedBox(
                    width: 45.w,
                    child: Text(order.supplier!.name!,
                        overflow: TextOverflow.clip,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text("Đã đặt ${order.details!.length.toString()} sản phẩm"),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ước tính: ${NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: "").format(order.total)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: SvgPicture.asset(
                          gcoinLogo,
                          height: 15,
                        ),
                      )
                    ],
                  ),
                  if (order.actualTotal != order.total)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Thực tế: ${NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: "").format(order.actualTotal)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: SvgPicture.asset(
                            gcoinLogo,
                            height: 15,
                          ),
                        )
                      ],
                    ),
                ],
              ),
            ),
            if (isConfirm)
              Padding(
                padding: EdgeInsets.only(right: 2.w, top: 1.h),
                child: const Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: 25,
                ),
              )
          ]),
        ),
      ),
    );
  }
}
