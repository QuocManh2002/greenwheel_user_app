import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/loading_screen/notification_list_loading_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_new_screen.dart';
import 'package:greenwheel_user_app/service/notification_service.dart';
import 'package:greenwheel_user_app/view_models/notification_viewmodels/notification_viewmodel.dart';
import 'package:sizer2/sizer2.dart';

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
        backgroundColor: lightPrimaryTextColor,
        title: const Text(
          'Thông báo',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const NotificationListLoadingScreen()
          : _notiList!.isEmpty
              ? Container(
                color: lightPrimaryTextColor,
                alignment: Alignment.center,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(empty_plan, width: 70.w,),
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
                        onTap: () {
                          if (noti.type == 'PLAN'
                          && noti.title != 'Bị loại khỏi kế hoạch.'
                          && noti.title != 'Bị chặn khỏi kế hoạch.'
                          ) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => DetailPlanNewScreen(
                                      isEnableToJoin: true,
                                      planId: noti.planId!,
                                      planType: "INVITATION",
                                    )));
                          } else {}
                        },
                        child: Container(
                          color: _notiList!.indexOf(noti).isOdd
                              ? lightPrimaryTextColor
                              : Colors.white,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 12, left: 12, right: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 8.h,
                                      width: 8.h,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle),
                                      child: Image.network(
                                        noti.imageUrl == null
                                            ? noti.type == 'PLAN'
                                                ? defaultPlanNotiAvatar
                                                : defaultServiceNotiAvatar
                                            : noti.imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    SizedBox(
                                      width: 65.w,
                                      child: Text(
                                        noti.body,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'NotoSans'),
                                        overflow: TextOverflow.clip,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Container(
                                color: Colors.grey.withOpacity(0.5),
                                height: 1,
                              )
                            ],
                          ),
                        ),
                      )
                  ]),
                ),
    ));
  }
}
