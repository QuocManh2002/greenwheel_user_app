
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phuot_app/core/constants/colors.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectEmergencyDetailService extends StatefulWidget {
  const SelectEmergencyDetailService(
      {super.key,
      required this.emergency,
      required this.index,
      required this.isView,
      required this.callback});

  final EmergencyContactViewModel emergency;
  final int index;
  final void Function() callback;
  final bool isView;

  @override
  State<SelectEmergencyDetailService> createState() =>
      _SelectEmergencyDetailServiceState();
}

class _SelectEmergencyDetailServiceState
    extends State<SelectEmergencyDetailService> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Chi tiết dịch vụ',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  height: 25.h,
                  width: 100.w,
                  key: UniqueKey(),
                  fit: BoxFit.fill,
                  errorWidget: (context, url, error) => Image.network(defaultHomeImage),
                  placeholder: (context, url) => Image.memory(kTransparentImage),
                  imageUrl: '$baseBucketImage${widget.emergency.imageUrl}'),
                SizedBox(
                  height: 2.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.h, right: 1.h),
                  child: Text(
                    widget.emergency.name!,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.h, right: 2.h),
                  child: Row(
                    children: [
                      const Text(
                        'Số điện thoại: ',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '0${widget.emergency.phone!.substring(3)}',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () async {
                            final Uri url = Uri(
                                scheme: 'tel',
                                path:
                                    '0${widget.emergency.phone!.substring(3)}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          icon: const Icon(
                            Icons.call,
                            color: primaryColor,
                            size: 32,
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.h, right: 1.h),
                  child: RichText(
                      overflow: TextOverflow.clip,
                      text: TextSpan(
                          text: 'Địa chỉ: ',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                                text: widget.emergency.address ??
                                    'Không có địa chỉ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal))
                          ])),
                ),
                SizedBox(
                  height: 3.h,
                )
              ],
            )));
  }
}
