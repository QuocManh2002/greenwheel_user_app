import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/loading_screen/plan_loading_screen.dart';
import 'package:greenwheel_user_app/service/notification_service.dart';
import 'package:greenwheel_user_app/view_models/notification_viewmodels/notification_viewmodel.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationViewModel>? _notiList;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
    print('deviceToken: ${sharedPreferences.getString('deviceToken')}');
  }

  setUpData() async {
    _notiList = null;
    _notiList = await _notificationService.getNotificationList();
    if (_notiList != null) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Thông báo',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const PlanLoadingScreen()
          : Padding(
              padding: EdgeInsets.all(1.h),
              child: _notiList!.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(empty_plan),
                            SizedBox(
                              height: 1.h,
                            ),
                            const Text(
                              'Bạn không có thông báo nào',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              textAlign: TextAlign.center,
                            )
                          ]),
                    )
                  : SingleChildScrollView(
                      child: Column(children: [
                        for (final noti in _notiList!)
                          InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 12, left: 12, right: 12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 8.h,
                                        width: 8.h,
                                        clipBehavior: Clip.hardEdge,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle),
                                        child: CachedNetworkImage(
                                          imageUrl: noti.imageUrl.toString(),
                                          key: UniqueKey(),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Image.memory(kTransparentImage),
                                          errorWidget: (context, url, error) =>
                                              Image.network(
                                            'https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2.w,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            noti.title,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            noti.body,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                    color: Colors.grey.withOpacity(0.5),
                                    height: 1.5,
                                  )
                                ],
                              ),
                            ),
                          )
                      ]),
                    ),
            ),
    ));
  }
}
