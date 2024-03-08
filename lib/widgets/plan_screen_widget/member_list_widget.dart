import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:sizer2/sizer2.dart';

class MemberListWidget extends StatelessWidget {
  const MemberListWidget({super.key, required this.members, required this.onRemoveMember});
  final List<PlanMemberViewModel> members;
  final void Function(int memberId, bool isBlock) onRemoveMember;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: 100.w,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(12),
                width: 100.w,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: Colors.white),
                child: Row(
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mem.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '0${mem.phone.substring(3)}',
                            style: const TextStyle(fontSize: 19),
                          )
                        ]),
                    const Spacer(),
                    mem.accountType == 2
                        ? Container()
                        : mem.accountType == 3
                            ? PopupMenuButton(
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 0,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.close,
                                          color: primaryColor,
                                          size: 32,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          'Xoá',
                                          style: TextStyle(
                                              color: primaryColor,
                                              fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 1,
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
                                  )
                                ],
                                onSelected: (value) {
                                  if (value == 0) {
                                    AwesomeDialog(
                                            context: context,
                                            animType: AnimType.bottomSlide,
                                            dialogType: DialogType.question,
                                            title:
                                                'Bạn có chắc chắn muốn xoá tài khoản này khỏi chuyến đi không ?',
                                            titleTextStyle: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            btnOkColor: Colors.blue,
                                            btnOkText: 'Có',
                                            padding: const EdgeInsets.all(12),
                                            btnOkOnPress: () {
                                              onRemoveMember(
                                                  mem.memberId, false);
                                            },
                                            btnCancelColor: Colors.orange,
                                            btnCancelText: 'Không',
                                            btnCancelOnPress: () {})
                                        .show();
                                  } else {
                                    AwesomeDialog(
                                            context: context,
                                            animType: AnimType.bottomSlide,
                                            dialogType: DialogType.question,
                                            title:
                                                'Bạn có chắc chắn muốn chặn tài khoản này hay không ?',
                                            titleTextStyle: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            btnOkColor: Colors.blue,
                                            padding: const EdgeInsets.all(12),
                                            btnOkText: 'Có',
                                            btnOkOnPress: () {
                                              onRemoveMember(
                                                  mem.memberId, true);
                                            },
                                            btnCancelColor: Colors.orange,
                                            btnCancelText: 'Không',
                                            btnCancelOnPress: () {})
                                        .show();
                                  }
                                },
                              )
                            : const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.star,
                                  color: yellowColor,
                                  size: 30,
                                ),
                              )
                  ],
                ),
              ),
            )
        ]),
      ),
    );
  }
}
