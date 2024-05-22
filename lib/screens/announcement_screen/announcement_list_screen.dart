import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/loading_screen/notification_list_loading_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_screen.dart';
import 'package:greenwheel_user_app/service/announcement_service.dart';
import 'package:greenwheel_user_app/view_models/notification_viewmodels/notification_viewmodel.dart';
import 'package:sizer2/sizer2.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  final AnnouncementService _notificationService = AnnouncementService();
  List<AnnouncementViewModel>? _notiList;
  bool _isLoading = true;

  @override
  void initState() {
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
        actions: [
          if ((_notiList ?? []).any(
            (element) => !element.isRead!,
          ))
            IconButton(
                onPressed: () {
                  AwesomeDialog(
                          context: context,
                          animType: AnimType.leftSlide,
                          dialogType: DialogType.question,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          title: 'Đánh dấu tất cả là đã đọc',
                          titleTextStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans'),
                          btnOkColor: Colors.deepOrangeAccent,
                          btnOkOnPress: () async {
                            setState(() {
                              for (final noti in _notiList!) {
                                noti.isRead = true;
                              }
                            });
                            await _notificationService
                                .markAllAnnouncementsAsRead(context);
                          },
                          btnOkText: 'Đồng ý',
                          btnCancelColor: Colors.blueAccent,
                          btnCancelOnPress: () {},
                          btnCancelText: 'Huỷ')
                      .show();
                },
                icon: const Icon(
                  Icons.checklist,
                  color: primaryColor,
                  size: 25,
                )),
          SizedBox(
            width: 2.w,
          )
        ],
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
                        Image.asset(
                          emptyPlan,
                          width: 70.w,
                        ),
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
                        onTap: () async {
                          if (!noti.isRead!) {
                            await _notificationService.markAnnouncementAsRead(
                                noti.id, context);
                            setState(() {
                              noti.isRead = true;
                            });
                          }
                          if (noti.type == 'PLAN' &&
                              noti.title == 'Kế hoạch sắp bị huỷ.') {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => DetailPlanNewScreen(
                                      isEnableToJoin: true,
                                      planId: noti.planId!,
                                      planType: "JOIN",
                                    )));
                          } else if (noti.title.contains('lời mời')) {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => DetailPlanNewScreen(
                                      isEnableToJoin: true,
                                      planId: noti.planId!,
                                      planType: "INVITATION",
                                    )));
                          }
                        },
                        child: Container(
                          color: _notiList!.indexOf(noti).isOdd
                              ? lightPrimaryTextColor
                              : Colors.white,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 12, left: 2.w, right: 2.w),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 15.w,
                                      width: 15.w,
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
                                      width: 70.w,
                                      child: Text(
                                        noti.body,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'NotoSans'),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                    if (!noti.isRead!)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.w),
                                        child: Container(
                                          width: 3.5.w,
                                          height: 3.5.w,
                                          decoration: const BoxDecoration(
                                              color: primaryColor,
                                              shape: BoxShape.circle),
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
