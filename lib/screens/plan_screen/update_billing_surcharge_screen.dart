
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/image_handler.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/surcharge.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class UpdateBillingSurchargeScreen extends StatefulWidget {
  const UpdateBillingSurchargeScreen({super.key, required this.surcharge});
  final SurchargeViewModel surcharge;

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
    // TODO: implement initState
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
          if(isChangeImage)
          IconButton(
            onPressed: ()async{
              var _imagePath = await _planService.updateSurcharge(imagePath!, int.parse(widget.surcharge.id!),context);
              if(_imagePath != null){
                setState(() {
                  widget.surcharge.imagePath = _imagePath;
                });
                Navigator.of(context).pop();
              }
            }, 
            icon: const Icon(Icons.check, size: 40,)),
            SizedBox(width: 2.w,)
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
                    final temp = await ImageHandler().handlePickImage(context);
                    if(temp != null){
                      setState(() {
                        imagePath = temp;
                        isChangeImage = true;
                      });
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
                    child: CachedNetworkImage(
                        height: 100.w,
                        width: 80.w,
                        alignment: Alignment.center,
                        key: UniqueKey(),
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            Image.memory(kTransparentImage),
                        errorWidget: (context, url, error) =>
                            SvgPicture.asset(no_image),
                        imageUrl: '$baseBucketImage$imagePath'),
                  )),
            )
          ],
        ),
      ),
    ));
  }
}
