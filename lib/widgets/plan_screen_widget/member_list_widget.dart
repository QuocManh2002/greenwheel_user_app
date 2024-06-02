import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/urls.dart';
import '../../models/plan_status.dart';
import '../../view_models/plan_member.dart';
import '../style_widget/dialog_style.dart';

class MemberListWidget extends StatelessWidget {
  const MemberListWidget(
      {super.key,
      required this.members,
      required this.onRemoveMember,
      required this.status});
  final PlanStatus status;
  final List<PlanMemberViewModel> members;
  final void Function(int memberId, bool isBlock) onRemoveMember;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: 100.w,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.5),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              width: 10.h,
              height: 6,
            ),
            SizedBox(
              height: 1.h,
            ),
            for (final mem in members)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: 100.w,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.white),
                  child: Row(
                    children: [
                      Container(
                          height: 6.h,
                          width: 6.h,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          clipBehavior: Clip.hardEdge,
                          child: CachedNetworkImage(
                            key: UniqueKey(),
                            height: 6.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            imageUrl: '$baseBucketImage${mem.imagePath}',
                            placeholder: (context, url) =>
                                Image.memory(kTransparentImage),
                            errorWidget: (context, url, error) => Image.asset(
                              mem.isMale
                                  ? maleDefaultAvatar
                                  : femaleDefaultAvatar,
                              height: 6.h,
                              fit: BoxFit.cover,
                            ),
                          )),
                      SizedBox(
                        width: 1.h,
                      ),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${mem.name} (${mem.companions == null ? 1 : mem.companions!.length + 1})',
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '0${mem.phone.substring(2)}',
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                    fontFamily: 'NotoSans', fontSize: 19),
                              )
                            ]),
                      ),
                      if (mem.accountType == 1)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.star,
                            color: yellowColor,
                            size: 30,
                          ),
                        ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: primaryColor,
                                  size: 32,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Chi tiết',
                                  style: TextStyle(
                                      color: primaryColor, fontSize: 18),
                                )
                              ],
                            ),
                          ),
                          if (mem.accountType == 3 && status.value < 2)
                            const PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: Colors.blueAccent,
                                    size: 32,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Xoá',
                                    style: TextStyle(
                                        color: Colors.blueAccent, fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                          if (mem.accountType == 3 && status.value < 2)
                            const PopupMenuItem(
                              value: 2,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.block,
                                    color: redColor,
                                    size: 32,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Chặn',
                                    style: TextStyle(
                                        color: redColor, fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                        ],
                        onSelected: (value) {
                          if (value == 0) {
                            List<String> names = [mem.name];
                            if (mem.companions != null) {
                              for (final name in mem.companions!) {
                                names.add(name);
                              }
                            }
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      content: SizedBox(
                                        width: 100.w,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            for (int index = 0;
                                                index < names.length;
                                                index++)
                                              Container(
                                                width: 100.w,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.h,
                                                    vertical: 1.h),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                index == 0
                                                                    ? 12
                                                                    : 0),
                                                        topRight:
                                                            Radius.circular(
                                                                index == 0
                                                                    ? 12
                                                                    : 0),
                                                        bottomLeft: Radius.circular(
                                                            index == names.length - 1
                                                                ? 12
                                                                : 0),
                                                        bottomRight:
                                                            Radius.circular(
                                                                index == names.length - 1 ? 12 : 0)),
                                                    color: index.isOdd ? Colors.white : lightPrimaryTextColor),
                                                child: Text(
                                                  '${index + 1}. ${names[index]}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                    fontFamily: 'NotoSans',
                                                  ),
                                                  overflow: TextOverflow.clip,
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                      title: const Text(
                                        'Chi tiết thành viên',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NotoSans'),
                                      ),
                                      actions: [
                                        TextButton(
                                            style: const ButtonStyle(
                                                foregroundColor:
                                                    MaterialStatePropertyAll(
                                                        primaryColor)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Đóng'))
                                      ],
                                    ));
                          } else if (value == 1) {
                            DialogStyle().basicDialog(
                              context: context,
                              title: 'Xoá "${mem.name}" khỏi chuyến đi này ?',
                              type: DialogType.question,
                              onOk: () {
                                onRemoveMember(mem.memberId, false);
                              },
                              btnOkText: 'Xoá',
                              btnOkColor: Colors.deepOrangeAccent,
                              btnCancelText: 'Huỷ',
                              btnCancelColor: Colors.blue,
                              onCancel: (){}
                            );
                          } else if (value == 2) {
                            DialogStyle().basicDialog(
                                context: context,
                                title: 'Chặn "${mem.name}" khỏi chuyến đi này ?',
                                type: DialogType.question,
                                btnOkText: 'Chặn',
                                onOk: () {
                                  onRemoveMember(mem.memberId, true);
                                },
                                btnOkColor: Colors.deepOrangeAccent,
                                btnCancelText: 'Huỷ',
                                onCancel: () {
                                  
                                },
                                btnCancelColor: Colors.blue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
          ]),
        ),
      ),
    );
  }
}
