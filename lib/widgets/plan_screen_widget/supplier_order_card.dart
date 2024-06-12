// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phuot_app/core/constants/colors.dart';
import 'package:phuot_app/core/constants/sessions.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/helpers/util.dart';
import 'package:phuot_app/models/menu_item_cart.dart';
import 'package:phuot_app/models/order_input_model.dart';
import 'package:phuot_app/screens/main_screen/service_menu_screen.dart';
import 'package:phuot_app/screens/order_screen/detail_order_screen.dart';
import 'package:phuot_app/service/product_service.dart';
import 'package:phuot_app/service/supplier_service.dart';
import 'package:phuot_app/view_models/location.dart';
import 'package:phuot_app/view_models/order.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:phuot_app/view_models/product.dart';
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
      required this.isCancel,
      this.cancelReason,
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
  final bool isCancel;
  final String? cancelReason;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: SizedBox(
              height: 15.h,
              width: 100.w,
              child: const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
            ),
          ),
        );
        final SupplierService supplierService = SupplierService();
        final ProductService productService = ProductService();

        final supplier = await supplierService
            .getInvalidSupplierByIds([order.supplier!.id], context);

        if (supplier.isNotEmpty) {
          Navigator.of(context).pop();
          DialogStyle().basicDialog(
              context: context,
              title: 'Rất tiếc! Nhà cung cấp đã không còn khả dụng',
              desc: 'Vui lòng chọn lại một nhà cung cấp khác',
              onOk: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: ServiceMainScreen(
                          inputModel: OrderInputModel(
                              serviceType: services.firstWhere(
                                  (element) => element.name == order.type),
                              location: location,
                              isOrder: true,
                              availableGcoinAmount: availableGcoinAmount,
                              session: sessions.firstWhere((element) =>
                                  element.enumName == order.period),
                              numberOfMember: memberLimit,
                              startDate: startDate,
                              endDate: endDate,
                              orderGuid: order.uuid,
                              servingDates: order.serveDates!
                                  .map((e) => DateTime.parse(e))
                                  .toList(),
                              callbackFunction: callback),
                        ),
                        type: PageTransitionType.rightToLeft));
              },
              btnOkText: 'Chọn lại',
              onCancel: () {},
              btnCancelColor: Colors.blue,
              btnCancelText: 'Huỷ',
              type: DialogType.warning);
        } else {
          final List<int> productIds = [];
          for (final detail in order.details!) {
            if (!productIds.contains(detail.productId)) {
              productIds.add(detail.productId);
            }
          }
          final invalidProduct =
              await productService.getInvalidProductByIds(productIds, context);
          if (invalidProduct.isNotEmpty) {
            Navigator.of(context).pop();
            AwesomeDialog(
                    context: context,
                    animType: AnimType.leftSlide,
                    dialogType: DialogType.warning,
                    body: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'Sản phẩm: ',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontFamily: 'NotoSans',
                                    fontWeight: FontWeight.w600),
                                children: [
                                  for (final prod in invalidProduct)
                                    TextSpan(
                                        text:
                                            '"${prod.name}" ${prod != invalidProduct.last ? ',' : ''}',
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87)),
                                  const TextSpan(text: 'đã không còn khả dụng')
                                ]),
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          const Text(
                            'Vui lòng điều chỉnh lại đơn hàng',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontFamily: 'NotoSans'),
                          )
                        ],
                      ),
                    ),
                    btnOkColor: Colors.amber,
                    btnOkOnPress: () {
                      final validDetail = order.details!
                          .where((element) => !invalidProduct.any(
                              (product) => product.id == element.productId))
                          .toList();
                      final groupDetail = validDetail
                          .groupListsBy((element) => element.productId);
                      List<ItemCart> newCart = groupDetail.values
                          .map((detail) => ItemCart(
                              product: ProductViewModel(
                                  id: detail.first.productId,
                                  name: detail.first.productName,
                                  price: detail.first.price!),
                              qty: detail.first.quantity))
                          .toList();
                      final holidayServingDates = Utils()
                          .getHolidayServingDates((order.serveDates ?? [])
                              .map((e) => DateTime.parse(e))
                              .toList());
                      final holidayUpPCT = Utils().getHolidayUpPct(order.type!);
                      Navigator.push(
                          context,
                          PageTransition(
                              child: ServiceMenuScreen(
                                inputModel: OrderInputModel(
                                  availableGcoinAmount: availableGcoinAmount,
                                  serviceType: services.firstWhere(
                                      (element) => element.name == order.type),
                                  isOrder: true,
                                  session: sessions.firstWhere((element) =>
                                      element.enumName == order.period),
                                  callbackFunction: callback,
                                  servingDates: order.serveDates!
                                      .map((e) => DateTime.parse(e))
                                      .toList(),
                                  supplier: order.supplier,
                                  iniNote: order.note,
                                  period: order.period,
                                  orderGuid: order.uuid,
                                  numberOfMember: memberLimit,
                                  startDate: startDate,
                                  endDate: endDate!,
                                  holidayServingDates: holidayServingDates[
                                      'holidayServingDates'],
                                  holidayUpPCT: holidayUpPCT,
                                  currentCart: newCart,
                                ),
                              ),
                              type: PageTransitionType.rightToLeft));
                    },
                    btnOkText: 'Ok',
                    btnCancelColor: Colors.blue,
                    btnCancelOnPress: () {},
                    btnCancelText: 'Huỷ')
                .show();
          } else {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => OrderDetailScreen(
                      numberOfMember: memberLimit,
                      isCancel: isCancel,
                      availableGcoinAmount: availableGcoinAmount,
                      endDate: endDate,
                      order: order,
                      startDate: startDate,
                      isFromTempOrder: isFromTempOrder,
                      isTempOrder: isTempOrder && !isConfirm,
                      planId: planId,
                      location: location,
                      cancelReason: cancelReason,
                      callback: () {
                        callback(null);
                      },
                    )));
          }
        }
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
            isCancel
                ? Padding(
                    padding: EdgeInsets.only(right: 2.w, top: 1.h),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 25,
                    ),
                  )
                : isConfirm
                    ? Padding(
                        padding: EdgeInsets.only(right: 2.w, top: 1.h),
                        child: const Icon(
                          Icons.check_circle,
                          color: primaryColor,
                          size: 25,
                        ),
                      )
                    : Container()
          ]),
        ),
      ),
    );
  }
}
