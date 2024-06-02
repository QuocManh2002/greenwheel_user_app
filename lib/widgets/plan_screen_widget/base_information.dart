import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:phuot_app/core/constants/colors.dart';
import 'package:phuot_app/core/constants/plan_statuses.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/helpers/util.dart';
import 'package:phuot_app/main.dart';
import 'package:phuot_app/models/plan_status.dart';
import 'package:phuot_app/screens/sub_screen/local_map_screen.dart';
import 'package:phuot_app/service/plan_service.dart';
import 'package:phuot_app/view_models/plan_member.dart';
import 'package:phuot_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:phuot_app/widgets/plan_screen_widget/emergency_contact_view.dart';
import 'package:phuot_app/widgets/plan_screen_widget/member_list_widget.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class BaseInformationWidget extends StatefulWidget {
  BaseInformationWidget(
      {super.key,
      required this.plan,
      required this.members,
      required this.planType,
      required this.isLeader,
      this.routeData,
      required this.locationLatLng,
      required this.refreshData});
  final PlanDetail plan;
  List<PlanMemberViewModel> members;
  final String planType;
  final void Function() refreshData;
  final bool isLeader;
  final String? routeData;
  final PointLatLng locationLatLng;

  @override
  State<BaseInformationWidget> createState() => _BaseInformationWidgetState();
}

class _BaseInformationWidgetState extends State<BaseInformationWidget> {
  int _currentIndexEmergencyCard = 0;
  final PlanService _planService = PlanService();
  PlanStatus? status;
  String travelDurationText = '';
  String maxMemberText = '';
  String? memberCountText;
  String comboDateText = '';
  @override
  void initState() {
    super.initState();
    status = planStatuses
        .firstWhereOrNull((element) => element.engName == widget.plan.status);
    var tempDuration = DateFormat.Hm().parse(widget.plan.travelDuration!);
    if (tempDuration.hour != 0) {
      travelDurationText += '${tempDuration.hour} giờ ';
    }
    if (tempDuration.minute != 0) {
      travelDurationText += '${tempDuration.minute} phút';
    }
    maxMemberText =
        '${widget.plan.maxMemberCount! < 10 ? '0${widget.plan.maxMemberCount}' : widget.plan.maxMemberCount}';
    if (widget.plan.memberCount != null && widget.plan.memberCount != 0) {
      memberCountText =
          '${widget.plan.memberCount! < 10 ? '0${widget.plan.memberCount}' : widget.plan.memberCount}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          buildInforWidget('Địa điểm:', widget.plan.locationName!),
          SizedBox(
            height: 1.h,
          ),
          buildInforWidget('Trưởng đoàn:', widget.plan.leaderName!),
          SizedBox(
            height: 1.h,
          ),
          buildInforWidget('Khởi hành:',
              '${DateFormat.Hm().format(widget.plan.utcDepartAt!.toLocal())} ${DateFormat('dd/MM/yy').format(widget.plan.utcDepartAt!.toLocal())}'),
          SizedBox(
            height: 1.h,
          ),
          buildInforWidget('Kết thúc:',
              '${DateFormat.Hm().format(widget.plan.utcEndAt!.toLocal())} ${DateFormat('dd/MM/yy').format(widget.plan.utcEndAt!)}'),
          if (memberCountText != null)
            SizedBox(
              height: 1.h,
            ),
          if (memberCountText != null)
            widget.plan.memberCount == 0 || !widget.isLeader
                ? buildInforWidget('Thành viên tối đa:', '$maxMemberText người')
                : buildInforWidget(
                    'Đã tham gia:', '$memberCountText/$maxMemberText người'),
          // if (widget.plan.status != 'PENDING')
          //   SizedBox(
          //     height: 1.h,
          //   ),
          // if (status != null && status!.value != 0)
          //   buildInforWidget('Trạng thái:', status!.name),
          SizedBox(
            height: 1.h,
          ),
          buildInforWidget('Thời gian di chuyển:', travelDurationText),
          SizedBox(
            height: 1.h,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 40.w,
                child: const Text(
                  'Địa điểm xuất phát:',
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontSize: 17, fontFamily: 'NotoSans'),
                ),
              ),
              SizedBox(
                width: 45.w,
                child: InkWell(
                  onTap: () {
                    final defaultCoordinate =
                        sharedPreferences.getStringList('defaultCoordinate');
                    if (defaultCoordinate == null) {
                      Utils().handleNonDefaultAddress(() {}, context);
                    } else {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: LocalMapScreen(
                                title: 'Địa điểm xuất phát',
                                fromLocation: PointLatLng(
                                    widget.plan.startLocationLat!,
                                    widget.plan.startLocationLng!),
                                toAddress: widget.plan.locationName,
                                toLocation: widget.locationLatLng,
                                routeData: widget.routeData,
                              ),
                              type: PageTransitionType.rightToLeft));
                    }
                  },
                  child: Text(
                    widget.plan.departureAddress!,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans'),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 1.h,
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            height: 1.8,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Dịch vụ khẩn cấp đã lưu: ',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 1.h,
          ),
          SizedBox(
            height: 7.h,
            width: double.infinity,
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.plan.savedContacts!.length,
              onPageChanged: (value) {
                setState(() {
                  _currentIndexEmergencyCard = value;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: EmergencyContactView(
                    emergency: widget.plan.savedContacts![index],
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          if (widget.plan.savedContacts!.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < widget.plan.savedContacts!.length; i++)
                  SizedBox(
                      height: 1.5.h,
                      child: Utils()
                          .buildIndicator(i, _currentIndexEmergencyCard)),
              ],
            ),
          const SizedBox(
            height: 8,
          ),
          Container(
            height: 1.8,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(
            height: 8,
          ),
          if ((widget.isLeader && widget.plan.memberCount != 0) ||
              (!widget.isLeader &&
                  widget.planType != 'PUBLISH' &&
                  planStatuses
                          .firstWhere((element) =>
                              element.engName == widget.plan.status)
                          .value >
                      1))
            Container(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Đã tham gia: ",
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'NotoSans',
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const Spacer(),
                        if (widget.plan.memberCount != null)
                          TextButton(
                              style: ButtonStyle(
                                  foregroundColor: MaterialStatePropertyAll(
                                      widget.plan.memberCount! != 0
                                          ? primaryColor
                                          : Colors.grey)),
                              onPressed: () {
                                if (widget.plan.memberCount != 0) {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (ctx) => MemberListWidget(
                                            status: status!,
                                            members: widget.members
                                                .where((element) =>
                                                    element.weight != 0)
                                                .toList(),
                                            onRemoveMember: onRemoveMember,
                                          ));
                                }
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'Xem tất cả',
                                    style: TextStyle(
                                        fontFamily: 'NotoSans', fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 23,
                                  )
                                ],
                              ))
                      ],
                    ),
                    for (int i = 0;
                        i <
                            (widget.members.length < 3
                                ? widget.members.length
                                : 3);
                        i++)
                      if (widget.members[i].weight != 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                  height: 25,
                                  width: 25,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle),
                                  clipBehavior: Clip.hardEdge,
                                  child: CachedNetworkImage(
                                      key: UniqueKey(),
                                      height: 25,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          '$baseBucketImage${widget.members[i].imagePath}',
                                      placeholder: (context, url) =>
                                          Image.memory(kTransparentImage),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                            widget.members[i].isMale
                                                ? maleDefaultAvatar
                                                : femaleDefaultAvatar,
                                            height: 25,
                                            fit: BoxFit.cover,
                                          ))),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                " ${widget.members[i].name} (${widget.members[i].companions == null ? 1 : widget.members[i].companions!.length + 1})",
                                style: const TextStyle(
                                    fontSize: 18, fontFamily: 'NotoSans'),
                              ),
                            ],
                          ),
                        ),
                    if (widget.members.length > 3)
                      Text(
                        '  ... +${widget.members.length - 3} thành viên',
                        style: const TextStyle(
                            fontSize: 17,
                            fontFamily: 'NotoSans',
                            color: Colors.black54),
                      )
                  ],
                ))
        ]));
  }

  onRemoveMember(int memberId, bool isBlock) async {
    final rs = await _planService.removeMember(memberId, isBlock, context);
    if (rs != 0) {
      AwesomeDialog(
        // ignore: use_build_context_synchronously
        context: context,
        animType: AnimType.leftSlide,
        dialogType: DialogType.success,
        title: 'Đã ${isBlock ? 'chặn' : 'xoá'} người dùng khỏi chuyến đi',
        titleTextStyle:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.all(12),
      ).show();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      widget.refreshData();
    }
  }

  buildInforWidget(String title, String content) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.w,
            child: Text(
              title,
              overflow: TextOverflow.clip,
              style: const TextStyle(fontSize: 17, fontFamily: 'NotoSans'),
            ),
          ),
          SizedBox(
            width: 45.w,
            child: Text(
              content,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSans'),
            ),
          )
        ],
      );
}
