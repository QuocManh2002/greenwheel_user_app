import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
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
  BaseInformationWidget(
      {super.key,
      required this.plan,
      required this.members,
      required this.isPublic});
  final PlanDetail plan;
  List<PlanMemberViewModel> members;
  final bool isPublic;

  @override
  State<BaseInformationWidget> createState() => _BaseInformationWidgetState();
}

class _BaseInformationWidgetState extends State<BaseInformationWidget> {
  int _currentIndexEmergencyCard = 0;
  bool _isShowNote = false;
  PlanService _planService = PlanService();
  String status = '';
  String travelDurationText = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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

    var tempDuration = DateFormat.Hm().parse(widget.plan.travelDuration!);
    travelDurationText = DateFormat.Hm().format(tempDuration);
    // if (tempDuration.hour != 0) {
    //   travelDurationText += '${tempDuration.hour} giờ ';
    // }
    // if (tempDuration.minute != 0) {
    //   travelDurationText += '${tempDuration.minute} phút';
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Địa điểm:",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    "Đóng đơn đăng kí:",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    "Ngày khởi hành:",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    "Ngày kết thúc:",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  if (widget.plan.memberCount! == 0)
                    const SizedBox(
                      height: 12,
                    ),
                  if (widget.plan.memberCount! == 0)
                    const Text(
                      "Số người tối đa:",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  if (widget.plan.memberCount! > 0)
                    const SizedBox(
                      height: 12,
                    ),
                  if (widget.plan.memberCount! > 0)
                    const Text(
                      "Đã tham gia:",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  if (widget.plan.status != 'PENDING')
                    const SizedBox(
                      height: 12,
                    ),
                  if (widget.plan.status != 'PENDING')
                    const Text(
                      "Trạng thái:",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    'Thời gian di chuyển: ',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    'Địa điểm xuất phát: ',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 1.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plan.locationName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(widget.plan.regClosedAt!),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(widget.plan.departureDate!),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(widget.plan.endDate!),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    widget.plan.memberCount! > 0
                        ? '${widget.plan.memberCount! > 0 && widget.plan.memberCount! < 10 ? '0${widget.plan.memberCount}' : widget.plan.memberCount}/${widget.plan.maxMember < 10 ? '0${widget.plan.maxMember}' : widget.plan.maxMember} người'
                        : '${widget.plan.maxMember < 10 ? '0${widget.plan.maxMember}' : widget.plan.maxMember} người',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // if (widget.plan.memberCount! > 0)
                  //   const SizedBox(
                  //     height: 12,
                  //   ),
                  // if (widget.plan.memberCount! > 0)
                  //   Text(
                  //     '${widget.plan.memberCount! > 0 && widget.plan.memberCount! < 10 ? '0${widget.plan.memberCount}' : widget.plan.memberCount} người',
                  //     style: const TextStyle(
                  //         fontSize: 18, fontWeight: FontWeight.bold),
                  //   ),
                   if (widget.plan.status != 'PENDING')
                  const SizedBox(
                    height: 12,
                  ),
                   if (widget.plan.status != 'PENDING')
                  Text(
                    status,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    travelDurationText,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width: 45.w,
                    child: Text(
                      widget.plan.departureAddress!,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
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
          if (widget.plan.note != null && widget.plan.note != 'null')
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isShowNote = !_isShowNote;
                    });
                  },
                  child: Row(
                    children: [
                      const Text(
                        'Ghi chú',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Icon(
                        _isShowNote
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: primaryColor,
                        size: 40,
                      )
                    ],
                  ),
                ),
                if (_isShowNote) HtmlWidget(widget.plan.note ?? ''),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  height: 1.8,
                  color: Colors.grey.withOpacity(0.4),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
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
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
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
                              " ${widget.members[i].name} (${widget.members[i].weight})",
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
}
