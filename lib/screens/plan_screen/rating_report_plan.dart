import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/combo_date_plan.dart';
import '../../core/constants/global_constant.dart';
import '../../core/constants/urls.dart';
import '../../service/plan_service.dart';
import '../../view_models/plan_viewmodels/combo_date.dart';
import '../../view_models/plan_viewmodels/plan_detail.dart';
import '../../widgets/style_widget/dialog_style.dart';
import '../../widgets/style_widget/text_form_field_widget.dart';

class RatingReportPlan extends StatefulWidget {
  const RatingReportPlan(
      {super.key,
      required this.plan,
      required this.isRate,
      required this.callback});
  final PlanDetail plan;
  final bool isRate;
  final void Function() callback;

  @override
  State<RatingReportPlan> createState() => _RatingReportPlanState();
}

class _RatingReportPlanState extends State<RatingReportPlan> {
  int ratingValue = 5;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PlanService _planService = PlanService();

  final TextEditingController _contentController = TextEditingController();
  ComboDate? combodate;

  @override
  void initState() {
    combodate = listComboDate.firstWhere(
        (element) => element.duration == widget.plan.numOfExpPeriod);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('${widget.isRate ? 'Đánh giá' : 'Báo cáo'} chuyến đi'),
        actions: [
          TextButton(
              onPressed: () async {
                if (ratingValue <=
                        GlobalConstant().ORDER_MIN_RATING_NO_COMMENT &&
                    _contentController.text.isEmpty) {
                  DialogStyle().basicDialog(
                      context: context,
                      title:
                          'Với đánh giá từ ${GlobalConstant().ORDER_MIN_RATING_NO_COMMENT - 1} sao trở xuống, phải thêm nhận xét cho đánh giá chuyến đi',
                      type: DialogType.warning);
                } else if (_formKey.currentState!.validate()) {
                  int? rs;
                  showDialog(
                    // ignore: use_build_context_synchronously
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

                  if (widget.isRate) {
                    rs = await _planService.ratePlan(_contentController.text,
                        widget.plan.id!, ratingValue, context);
                  } else {
                    rs = await _planService.reportPlan(
                        _contentController.text, widget.plan.id!, context);
                  }

                  if (rs != null) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    DialogStyle().successDialog(context,
                        'Đã thêm ${widget.isRate ? 'đánh giá' : 'báo cáo'} chuyến đi');
                    Future.delayed(
                      const Duration(milliseconds: 1500),
                      () {
                        widget.callback();
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
                      height: 20.w,
                      width: 20.w,
                      key: UniqueKey(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Image.memory(kTransparentImage),
                      errorWidget: (context, url, error) =>
                          Image.asset(emptyPlan),
                      imageUrl: '$baseBucketImage${widget.plan.imageUrls![0]}'),
                  SizedBox(
                    width: 2.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.plan.name ?? 'Không có thông tin',
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans',
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: primaryColor, size: 15),
                            SizedBox(
                              width: 1.w,
                            ),
                            Text(
                              widget.plan.locationName ?? 'Không có thông tin',
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'NotoSans',
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                color: primaryColor, size: 15),
                            SizedBox(
                              width: 1.w,
                            ),
                            Text(
                              '${combodate!.numberOfDay} ngày, ${combodate!.numberOfNight} đêm',
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'NotoSans',
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.attach_money_outlined,
                                color: primaryColor, size: 15),
                            SizedBox(
                              width: 1.w,
                            ),
                            Text(
                              NumberFormat.simpleCurrency(
                                      locale: 'vi_VN',
                                      name: '',
                                      decimalDigits: 0)
                                  .format(widget.plan.gcoinBudgetPerCapita),
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'NotoSans',
                              ),
                            ),
                            SvgPicture.asset(
                              gcoinLogo,
                              height: 15,
                            ),
                            const Text(
                              ' /',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                            const Icon(
                              Icons.person,
                              color: primaryColor,
                              size: 15,
                            )
                          ],
                        ),
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
                    controller: _contentController,
                    text: widget.isRate ? 'Nhận xét' : 'Nội dung báo cáo ',
                    maxLength: GlobalConstant().PLAN_COMMENT_MAX_LENGTH,
                    maxline: 5,
                    minLine: 5,
                    hinttext: widget.isRate
                        ? 'Hãy chia sẻ nhận xét của bạn cho chuyến đi này'
                        : 'Hãy để lại góp ý cho chuyến đi, chúng tôi xin tiếp nhận và sửa đổi',
                    onValidate: (value) {
                      if (value != null &&
                          value.isEmpty &&
                          (value.length <
                                  GlobalConstant().PLAN_COMMENT_MIN_LENGTH ||
                              value.length >
                                  GlobalConstant().PLAN_COMMENT_MAX_LENGTH)) {
                        return '${widget.isRate ? 'Nhận xét' : 'Báo cáo'} của chuyến đi phải từ ${GlobalConstant().PLAN_COMMENT_MIN_LENGTH} đến ${GlobalConstant().PLAN_COMMENT_MAX_LENGTH} kí tự';
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
