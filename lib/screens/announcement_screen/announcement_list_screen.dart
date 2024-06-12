import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/urls.dart';
import '../../models/pagination.dart';
import '../../service/announcement_service.dart';
import '../../view_models/notification_viewmodels/notification_viewmodel.dart';
import '../../widgets/style_widget/dialog_style.dart';
import '../loading_screen/notification_list_loading_screen.dart';
import '../plan_screen/detail_plan_screen.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  final AnnouncementService _notificationService = AnnouncementService();
  Pagination<AnnouncementViewModel>? page;
  final List<AnnouncementViewModel> _notiList = [];

  bool _isLoading = true;
  final controller = ScrollController();
  bool isCalled = false;
  String? cursor;

  @override
  void initState() {
    super.initState();
    setUpData();

    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (!isCalled) {
          setUpData();
          isCalled = true;
        }
      } else {
        if (isCalled) {
          isCalled = false;
        }
      }
    });
  }

  setUpData() async {
    page = null;
    page = await _notificationService.getNotificationList(cursor);

    if (page != null) {
      cursor = page!.cursor;

      setState(() {
        _isLoading = false;
        _notiList.addAll(page!.objects!);
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              actions: [
                if (_notiList.any(
                  (element) => !element.isRead!,
                ))
                  IconButton(
                      onPressed: () {
                        DialogStyle().basicDialog(
                            context: context,
                            title: 'Đánh dấu tất cả là đã đọc',
                            btnOkColor: Colors.deepOrangeAccent,
                            btnOkText: 'Đồng ý',
                            onOk: () async {
                              setState(() {
                                for (final noti in _notiList) {
                                  noti.isRead = true;
                                }
                              });
                              await _notificationService
                                  .markAllAnnouncementsAsRead(context);
                            },
                            btnCancelColor: Colors.blueAccent,
                            btnCancelText: 'Huỷ',
                            onCancel: () {},
                            type: DialogType.question);
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
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        cursor = null;
                        _notiList.clear();
                        _isLoading = true;
                      });
                      setUpData();
                    },
                    child: _notiList.isEmpty
                        ? ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 1,
                            itemBuilder: (context, index) => SizedBox(
                                  height: 60.h,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          emptyPlan,
                                          width: 60.w,
                                        ),
                                        SizedBox(
                                          height: 1.h,
                                        ),
                                        const Text(
                                          'Bạn không có thông báo nào',
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        )
                                      ]),
                                ))
                        : ListView.builder(
                            shrinkWrap: true,
                            controller: controller,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _notiList.length,
                            itemBuilder: (context, index) => InkWell(
                                  onTap: () async {
                                    if (!_notiList[index].isRead!) {
                                      await _notificationService
                                          .markAnnouncementAsRead(
                                              _notiList[index].id, context);
                                      setState(() {
                                        _notiList[index].isRead = true;
                                      });
                                    }
                                    if (_notiList[index].type == 'PLAN') {
                                      if (_notiList[index].isJoinedPlan !=
                                              null &&
                                          _notiList[index].isJoinedPlan!) {
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    DetailPlanNewScreen(
                                                      isEnableToJoin: true,
                                                      planId: _notiList[index]
                                                          .planId!,
                                                      planType: "JOIN",
                                                    )));
                                      } else if (_notiList[index].isOwnedPlan !=
                                              null &&
                                          _notiList[index].isOwnedPlan!) {
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    DetailPlanNewScreen(
                                                      isEnableToJoin: true,
                                                      planId: _notiList[index]
                                                          .planId!,
                                                      planType: "OWN",
                                                    )));
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    DetailPlanNewScreen(
                                                      isEnableToJoin: true,
                                                      planId: _notiList[index]
                                                          .planId!,
                                                      planType: "INVITATION",
                                                    )));
                                      }
                                    }
                                  },
                                  child: Container(
                                    color: index.isOdd
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
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle),
                                                  child: CachedNetworkImage(
                                                      key: UniqueKey(),
                                                      height: 15.w,
                                                      width: 15.w,
                                                      fit: BoxFit.cover,
                                                      imageUrl: _notiList[index]
                                                                  .imageUrl ==
                                                              null
                                                          ? _notiList[index]
                                                                      .type ==
                                                                  'PLAN'
                                                              ? defaultPlanNotiAvatar
                                                              : defaultServiceNotiAvatar
                                                          : _notiList[index]
                                                              .imageUrl!,
                                                      placeholder: (context,
                                                              url) =>
                                                          Image.memory(
                                                              kTransparentImage),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                              emptyPlan))),
                                              SizedBox(
                                                width: 2.w,
                                              ),
                                              SizedBox(
                                                width: 70.w,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _notiList[index].body,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              'NotoSans'),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                    SizedBox(
                                                      height: 0.5.h,
                                                    ),
                                                    Text(
                                                      '${DateFormat.Hm().format(_notiList[index].createdAt!.toLocal())}${_notiList[index].createdAt!.toLocal().day == DateTime.now().day ? '' : ' ${DateFormat('dd/MM/yyyy').format(_notiList[index].createdAt!.toLocal())}'}',
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey,
                                                          fontFamily:
                                                              'NotoSans'),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              if (!_notiList[index].isRead!)
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 2.w),
                                                  child: Container(
                                                    width: 3.5.w,
                                                    height: 3.5.w,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: primaryColor,
                                                            shape: BoxShape
                                                                .circle),
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
                                )))));
  }
}
