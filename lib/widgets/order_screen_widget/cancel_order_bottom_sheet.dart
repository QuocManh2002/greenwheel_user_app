import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/cancel_reasons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/urls.dart';
import '../../service/order_service.dart';
import '../style_widget/button_style.dart';
import '../style_widget/text_form_field_widget.dart';

class CancelOrderBottomSheet extends StatefulWidget {
  const CancelOrderBottomSheet(
      {super.key,
      required this.orderId,
      required this.total,
      required this.callback,
      required this.orderCreatedAt});
  final int orderId;
  final DateTime orderCreatedAt;
  final int total;
  final void Function(dynamic) callback;

  @override
  State<CancelOrderBottomSheet> createState() => _CancelOrderBottomSheetState();
}

class _CancelOrderBottomSheetState extends State<CancelOrderBottomSheet> {
  int selectedReason = 0;
  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final OrderService _orderService = OrderService();
  int refundAmount = 0;

  getRefundAmount() {
    int different = DateTime.now().difference(widget.orderCreatedAt).inHours;
    if (different >= 0 && different <= 24) {
      return (widget.total * 0.7).ceil();
    } else if (different > 24 && different <= 48) {
      return (widget.total * 0.4).ceil();
    } else if (different > 48) {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    refundAmount = getRefundAmount();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 2.h,
            ),
            Container(
              height: 8,
              width: 20.w,
              decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
            ),
            SizedBox(
              height: 1.h,
            ),
            const Text(
              'Chọn lý do huỷ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSans',
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Container(
              color: Colors.amber.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
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
                    child: const Text(
                      'Hãy chọn một lý do huỷ đơn hàng bên dưới. Lưu ý: Bạn sẽ không thể hoàn tác thao tác này',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber,
                      ),
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            for (final reason in cancelReasons)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Radio(
                    value: reason.id,
                    activeColor: primaryColor,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value!;
                      });
                      if (value == 4) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              width: 100.w,
                              child: Form(
                                key: _formKey,
                                child: defaultTextFormField(
                                    maxline: 1,
                                    maxLength: 30,
                                    hinttext: 'Lý do',
                                    controller: _reasonController,
                                    onValidate: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Lý do không được để trống';
                                      } else if (value.length > 30) {
                                        return 'Lý do không quá 30 kí tự';
                                      }
                                      return null;
                                    },
                                    inputType: TextInputType.name),
                              ),
                            ),
                            title: const Text(
                              'Thêm lý do:',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NotoSans'),
                            ),
                            actions: [
                              TextButton(
                                  style: const ButtonStyle(
                                      foregroundColor: MaterialStatePropertyAll(
                                          primaryColor)),
                                  onPressed: () {
                                    _reasonController.clear();
                                    Navigator.of(context).pop();
                                    setState(() {
                                      selectedReason = 0;
                                    });
                                  },
                                  child: const Text('Huỷ')),
                              TextButton(
                                  style: const ButtonStyle(
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                              side: BorderSide(
                                                  color: primaryColor))),
                                      foregroundColor: MaterialStatePropertyAll(
                                          primaryColor)),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text('Thêm'))
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      reason.text,
                      overflow: TextOverflow.clip,
                      style:
                          const TextStyle(fontSize: 16, fontFamily: 'NotoSans'),
                    ),
                  )
                ],
              ),
            SizedBox(
              height: 1.h,
            ),
            refundAmount == 0
                ? Container(
                    width: 100.w,
                    padding: const EdgeInsets.all(8),
                    color: primaryColor.withOpacity(0.1),
                    child: const Text(
                      'Đơn hàng quá 48h, bạn không được hoàn tiền cho đơn hàng này',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSans',
                          color: primaryColor),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Hoàn lại:',
                          style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'NotoSans'),
                        ),
                        const Spacer(),
                        Text(
                          NumberFormat.simpleCurrency(
                                  name: '', decimalDigits: 0, locale: 'vi_VN')
                              .format(refundAmount / 1000),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans'),
                        ),
                        SvgPicture.asset(
                          gcoinLogo,
                          height: 20,
                        )
                      ],
                    ),
                  ),
            SizedBox(
              height: 1.h,
            ),
            ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () async {
                  if (selectedReason == 0) {
                    AwesomeDialog(
                            context: context,
                            animType: AnimType.leftSlide,
                            dialogType: DialogType.warning,
                            title: 'Vui lòng chọn lý do huỷ đơn hàng',
                            titleTextStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSans'),
                            padding: const EdgeInsets.all(8),
                            btnOkColor: Colors.amber,
                            btnOkOnPress: () {},
                            btnOkText: 'OK')
                        .show();
                  } else {
                    final rs = await _orderService.cancelOrder(
                        widget.orderId,
                        context,
                        selectedReason == 4
                            ? _reasonController.text
                            : cancelReasons
                                .firstWhere(
                                    (element) => element.id == selectedReason)
                                .text);
                    if (rs != null) {
                      AwesomeDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          animType: AnimType.leftSlide,
                          dialogType: DialogType.success,
                          padding: const EdgeInsets.all(12),
                          title: 'Đã huỷ đơn hàng',
                          titleTextStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans',
                          )).show();
                      widget.callback(null);
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      });
                    }
                  }
                },
                child: const Text('Đồng ý')),
            SizedBox(
              height: 1.h,
            )
          ],
        ),
      ),
    );
  }
}
