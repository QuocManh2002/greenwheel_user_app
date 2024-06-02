
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phuot_app/core/constants/colors.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/helpers/image_handler.dart';
import 'package:phuot_app/service/plan_service.dart';
import 'package:phuot_app/view_models/plan_viewmodels/surcharge.dart';
import 'package:phuot_app/widgets/style_widget/dialog_style.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class UpdateBillingSurchargeScreen extends StatefulWidget {
  const UpdateBillingSurchargeScreen(
      {super.key,
      required this.isLeader,
      required this.surcharge,
      required this.onRefreshData});
  final SurchargeViewModel surcharge;
  final bool isLeader;
  final void Function() onRefreshData;

  @override
  State<UpdateBillingSurchargeScreen> createState() =>
      _UpdateBillingSurchargeScreenState();
}

class _UpdateBillingSurchargeScreenState
    extends State<UpdateBillingSurchargeScreen> {
  String? imagePath;
  bool isChangeImage = false;
  final PlanService _planService = PlanService();

  @override
  void initState() {
    super.initState();
    imagePath = widget.surcharge.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật hoá đơn'),
        actions: [
          if (isChangeImage)
            IconButton(
                onPressed: () async {
                  var result = await _planService.updateSurcharge(
                      imagePath!, int.parse(widget.surcharge.id!), context);
                  if (result != null) {
                    setState(() {
                      widget.surcharge.imagePath = result;
                    });
                    widget.onRefreshData();
                    DialogStyle().successDialog(
                      // ignore: use_build_context_synchronously
                      context,
                      'Cập nhật hoá đơn thành công',
                    );
                    Future.delayed(
                      const Duration(seconds: 1),
                      () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    );
                  }
                },
                icon: const Icon(
                  Icons.check,
                  size: 40,
                )),
          SizedBox(
            width: 2.w,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () async {
                    if (imagePath == null) {
                      final temp =
                          await ImageHandler().handlePickImage(context);
                      if (temp != null) {
                        setState(() {
                          imagePath = temp;
                          isChangeImage = true;
                        });
                      }
                    }
                  },
                  child: Container(
                      height: 100.w,
                      width: 80.w,
                      padding: const EdgeInsets.all(4),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          border: Border.all(color: primaryColor, width: 1.5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      child: imagePath != null
                          ? CachedNetworkImage(
                              height: 100.w,
                              width: 80.w,
                              alignment: Alignment.center,
                              key: UniqueKey(),
                              fit: BoxFit.contain,
                              placeholder: (context, url) =>
                                  Image.memory(kTransparentImage),
                              errorWidget: (context, url, error) =>
                                  SvgPicture.asset(noImage),
                              imageUrl: '$baseBucketImage$imagePath')
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  noImage,
                                  height: 50.w,
                                  fit: BoxFit.cover,
                                ),
                                const Text(
                                  'Nhấn vào để cập nhật hoá đơn',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NotoSans'),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )),
                ))
          ],
        ),
      ),
    ));
  }
}
