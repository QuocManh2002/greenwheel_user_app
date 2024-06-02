// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/global_constant.dart';
import '../../core/constants/urls.dart';
import '../../service/order_service.dart';
import '../../view_models/order.dart';
import '../../view_models/order_detail.dart';
import '../../widgets/style_widget/dialog_style.dart';
import '../../widgets/style_widget/text_form_field_widget.dart';

class RateOrderScreen extends StatefulWidget {
  const RateOrderScreen({super.key, required this.order, required this.isRate});
  final OrderViewModel order;
  final bool isRate;

  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  List<OrderDetailViewModel> details = [];
  int ratingValue = 5;
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    final tmp =
        widget.order.details!.groupListsBy((element) => element.productId);
    for (final temp in tmp.values) {
      details.add(temp.first);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('${widget.isRate ? 'Đánh giá' : 'Báo cáo'} đơn hàng'),
        actions: [
          TextButton(
              onPressed: () async {
                if (ratingValue <=
                        GlobalConstant().ORDER_MIN_RATING_NO_COMMENT &&
                    _commentController.text.isEmpty) {
                  DialogStyle().basicDialog(
                      context: context,
                      title:
                          'Với đánh giá từ ${GlobalConstant().ORDER_MIN_RATING_NO_COMMENT - 1} sao trở xuống, phải thêm nhận xét cho đánh giá đơn hàng',
                      type: DialogType.warning);
                } else if (_formKey.currentState!.validate()) {
                  int? rs;
                  if (widget.isRate) {
                    rs = await _orderService.rateOrder(widget.order.id!,
                        ratingValue, _commentController.text, context);
                  } else {
                    rs = await _orderService.complainOrder(
                        _commentController.text, widget.order.id!, context);
                  }

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: SizedBox(
                        height: 10.h,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  );
                  if (rs != null) {
                    Navigator.of(context).pop();
                    DialogStyle().successDialog(context,
                        'Đã thêm ${widget.isRate ? 'đánh giá' : 'báo cáo'} đơn hàng');
                    Future.delayed(
                      const Duration(milliseconds: 1500),
                      () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    );
                  }
                }
              },
              child: const Text(
                'Gửi',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w300),
              ))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 1.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                      height: 10.w,
                      width: 10.w,
                      key: UniqueKey(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Image.memory(kTransparentImage),
                      errorWidget: (context, url, error) =>
                          Image.asset(emptyPlan),
                      imageUrl:
                          '$baseBucketImage${widget.order.supplier!.thumbnailUrl!}'),
                  SizedBox(
                    width: 2.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order.supplier!.name ?? 'Không có thông tin',
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans',
                          ),
                        ),
                        for (final detail in details)
                          RichText(
                              text: TextSpan(
                                  text: detail.productName,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'NotoSans',
                                      color: Colors.black38),
                                  children: [
                                TextSpan(
                                    text: ' x${detail.quantity}',
                                    style:
                                        const TextStyle(color: Colors.black45)),
                              ]))
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
              if (widget.isRate)
                Column(
                  children: [
                    Divider(
                      color: Colors.grey.withOpacity(0.5),
                      thickness: 1.5,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    RatingBar.builder(
                      initialRating: 5,
                      itemSize: 40,
                      itemCount: 5,
                      maxRating: 5,
                      minRating: 1,
                      updateOnDrag: true,
                      itemPadding: EdgeInsets.symmetric(horizontal: 1.w),
                      itemBuilder: (context, index) => Icon(
                        index < ratingValue ? Icons.star : Icons.star_outline,
                        color: Colors.amberAccent,
                      ),
                      unratedColor: Colors.amberAccent,
                      onRatingUpdate: (value) {
                        ratingValue = value.toInt();
                      },
                    ),
                  ],
                ),
              SizedBox(
                height: 2.h,
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1.5,
              ),
              SizedBox(
                height: 2.h,
              ),
              Form(
                key: _formKey,
                child: defaultTextFormField(
                    controller: _commentController,
                    text: widget.isRate ? 'Nhận xét' : 'Nội dung báo cáo ',
                    maxLength: GlobalConstant().ORDER_COMMENT_MAX_LENGTH,
                    maxline: 5,
                    minLine: 5,
                    hinttext: widget.isRate
                        ? 'Hãy chia sẻ nhận xét của bạn cho đơn hàng này'
                        : 'Hãy để lại góp ý cho nhà cung cấp, chúng tôi xin tiếp nhận và sửa đổi',
                    onValidate: (value) {
                      if (value != null &&
                          value.isEmpty &&
                          (value.length <
                                  GlobalConstant().ORDER_COMMENT_MIN_LENGTH ||
                              value.length >
                                  GlobalConstant().ORDER_COMMENT_MAX_LENGTH)) {
                        return '${widget.isRate ? 'Nhận xét' : 'Báo cáo'} của đơn hàng phải từ ${GlobalConstant().ORDER_COMMENT_MIN_LENGTH} đến ${GlobalConstant().ORDER_COMMENT_MAX_LENGTH} kí tự';
                      }
                      return null;
                    },
                    inputType: TextInputType.text),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
