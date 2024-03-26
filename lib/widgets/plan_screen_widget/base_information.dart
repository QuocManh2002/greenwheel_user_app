import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_view.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/member_list_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class BaseInformationWidget extends StatefulWidget {
  BaseInformationWidget({
    super.key,
    required this.plan,
    required this.members,
  });
  final PlanDetail plan;
  List<PlanMemberViewModel> members;

  @override
  State<BaseInformationWidget> createState() => _BaseInformationWidgetState();
}

class _BaseInformationWidgetState extends State<BaseInformationWidget> {
  int _currentIndexEmergencyCard = 0;
  PlanService _planService = PlanService();
  String status = '';
  String travelDurationText = '';
  String maxMemberText = '';
  late String memberCountText;
  String comboDateText = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.plan.status != 'PENDING') {
      switch (widget.plan.status) {
        case 'REGISTERING':
          status = 'Đang mời';
          break;
        case 'READY':
          status = 'Đã chốt';
          break;
        case 'COMPLETED':
          status = 'Đã hoàn tất';
          break;
        case 'CANCELED':
          status = 'Đã huỷ';
          break;
        case 'FLAWED':
          status = 'Để hỏi lead';
          break;
      }
    }
    var tempDuration = DateFormat.Hm().parse(widget.plan.travelDuration!);
    if (tempDuration.hour != 0) {
      travelDurationText += '${tempDuration.hour} giờ ';
    }
    if (tempDuration.minute != 0) {
      travelDurationText += '${tempDuration.minute} phút';
    }
    maxMemberText =
        '${widget.plan.maxMember < 10 ? '0${widget.plan.maxMember}' : widget.plan.maxMember}';
    if (widget.plan.memberCount != 0) {
      memberCountText =
          '${widget.plan.memberCount! < 10 ? '0${widget.plan.memberCount}' : widget.plan.memberCount}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          buildInforWidget('Địa điểm:', widget.plan.locationName),
          SizedBox(
            height: 1.h,
          ),
          buildInforWidget('Trưởng đoàn:', widget.plan.leaderName!),
          SizedBox(
            height: 1.h,
          ),
          buildInforWidget('Đóng đơn đăng kí:',
              DateFormat('dd/MM/yy').format(widget.plan.regClosedAt!)),
          SizedBox(
            height: 1.h,
          ),
          buildInforWidget('Bắt đầu:',
              '${DateFormat.Hm().format(widget.plan.departureDate!)} ${DateFormat('dd/MM/yy').format(widget.plan.departureDate!)}'),
          SizedBox(
            height: 1.h,
          ),
          buildInforWidget('Kết thúc:',
              DateFormat('dd/MM/yy').format(widget.plan.endDate!)),
          SizedBox(
            height: 1.h,
          ),
          widget.plan.memberCount == 0
              ? buildInforWidget('Thành viên tối đa:', '$maxMemberText người')
              : buildInforWidget(
                  'Đã tham gia:', '$memberCountText/$maxMemberText người'),
          if (widget.plan.status != 'PENDING')
            SizedBox(
              height: 1.h,
            ),
          if (widget.plan.status != 'PENDING')
            buildInforWidget('Trạng thái:', status),
          // SizedBox(
          //   height: 1.h,
          // ),
          // buildInforWidget('Thời gian xuất phát:',
          //     DateFormat.Hm().format(widget.plan.departureDate!)),
          SizedBox(
            height: 1.h,
          ),
          buildInforWidget('Thời gian di chuyển:', travelDurationText),
          SizedBox(
            height: 1.h,
          ),
          buildInforWidget(
              'Địa điểm xuất phát:', widget.plan.departureAddress!),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 1.h,
          ),
          SizedBox(
            height: 13.h,
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
                return EmergencyContactView(
                  emergency: widget.plan.savedContacts![index],
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
          // if (widget.plan.note != null && widget.plan.note != 'null')
          //   Column(
          //     children: [
          //       InkWell(
          //         onTap: () {
          //           setState(() {
          //             _isShowNote = !_isShowNote;
          //           });
          //         },
          //         child: Row(
          //           children: [
          //             const Text(
          //               'Ghi chú',
          //               style: TextStyle(
          //                   fontSize: 18, fontWeight: FontWeight.bold),
          //             ),
          //             const Spacer(),
          //             Icon(
          //               _isShowNote
          //                   ? Icons.arrow_drop_up
          //                   : Icons.arrow_drop_down,
          //               color: primaryColor,
          //               size: 40,
          //             )
          //           ],
          //         ),
          //       ),
          //       if (_isShowNote)
          //         Container(
          //             padding: const EdgeInsets.all(8),
          //             decoration: const BoxDecoration(
          //                 color: Color(0xFFf2f2f2),
          //                 borderRadius: BorderRadius.all(Radius.circular(12))),
          //             child: HtmlWidget(widget.plan.note ?? '')),
          //       const SizedBox(
          //         height: 8,
          //       ),
          //       Container(
          //         height: 1.8,
          //         color: Colors.grey.withOpacity(0.4),
          //       ),
          //       const SizedBox(
          //         height: 16,
          //       ),
          //     ],
          //   ),
          if (widget.plan.memberCount != 0)
            Container(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Thành viên đã tham gia: ",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const Spacer(),
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
                                  style: TextStyle(fontSize: 16),
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
                                    imageUrl: widget.members[i].imageUrl ??
                                        defaultUserAvatarLink,
                                    placeholder: (context, url) =>
                                        Image.memory(kTransparentImage),
                                    errorWidget: (context, url, error) =>
                                        FadeInImage.assetNetwork(
                                      height: 25,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: '',
                                      image: empty_plan,
                                    ),
                                  )),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                " ${widget.members[i].name} (${widget.members[i].companions== null ? 1 : widget.members[i].companions!.length + 1})",
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        )
                  ],
                ))
        ]));
  }

  onRemoveMember(int memberId, bool isBlock) async {
    final rs = await _planService.removeMember(memberId, isBlock);
    if (rs != 0) {
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        dialogType: DialogType.success,
        title: 'Đã ${isBlock ? 'chặn' : 'xoá'} người dùng khỏi chuyến đi',
        titleTextStyle:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.all(12),
      ).show();
      Future.delayed(const Duration(seconds: 1), () async {
        final planMembers = await _planService.getPlanMember(widget.plan.id);

        if (planMembers.isNotEmpty) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          setState(() {
            widget.members = planMembers;
          });
        }
      });
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
              style: const TextStyle(
                fontSize: 17,fontFamily: 'NotoSans'
              ),
            ),
          ),
          SizedBox(
            width: 45.w,
            child: Text(
              content,
              overflow: TextOverflow.clip,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSans'),
            ),
          )
        ],
      );
}
