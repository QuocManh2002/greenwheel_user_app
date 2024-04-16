import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/create_plan_surcharge.dart';
import 'package:greenwheel_user_app/screens/plan_screen/update_billing_surcharge_screen.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/surcharge.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class SurchargeCard extends StatelessWidget {
  const SurchargeCard(
      {super.key,
      required this.surcharge,
      required this.callbackSurcharge,
      required this.isEnableToUpdate,
      required this.maxMemberCount,
      required this.isCreate});
  final SurchargeViewModel surcharge;
  final void Function(dynamic) callbackSurcharge;
  final bool isCreate;
  final bool isEnableToUpdate;
  final int maxMemberCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: 100.w,
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: const BorderRadius.all(Radius.circular(14))),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 1.w,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 70.w,
                    child: Text(
                      surcharge.note.substring(0,1) == "\"" ?
                      '${json.decode(surcharge.note)}' : surcharge.note, 
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                          fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 70.w,
                    child: Row(
                      children: [
                        Text(
                          NumberFormat.currency(
                                  locale: 'vi_VN', decimalDigits: 0, symbol: 'Đ')
                              .format(
                                surcharge.alreadyDivided?
                                surcharge.amount:
                                (surcharge.amount / maxMemberCount).ceil()
                                ),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip,
                        ),
                        const Text(' /',style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),),
                        const Icon(Icons.person, color: primaryColor, size: 20,),
                        const Spacer()
                      ],
                    ),
                  )
                ],
              ),
              const Spacer(),
              if(isEnableToUpdate)
              PopupMenuButton(
                itemBuilder: (context) => [
                  if (isCreate)
                    const PopupMenuItem(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_square,
                              color: Colors.blueAccent,
                              size: 25,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              'Chỉnh sửa',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'NotoSans',
                                  color: Colors.blueAccent),
                            ),
                          ],
                        )),
                  if (isCreate)
                    const PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                              size: 25,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text('Xoá',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'NotoSans',
                                    color: Colors.redAccent)),
                          ],
                        )),
                  if (!isCreate)
                    const PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: Colors.blueAccent,
                              size: 25,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text('Cập nhật hoá đơn',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'NotoSans',
                                    color: Colors.blueAccent)),
                          ],
                        )),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      Navigator.push(
                          context,
                          PageTransition(
                              child: CreatePlanSurcharge(
                                callback: callbackSurcharge,
                                isCreate: false,
                                surcharge: surcharge,
                              ),
                              type: PageTransitionType.rightToLeft));
                      break;
                    case 1:
                      var list = json.decode(
                          sharedPreferences.getString('plan_surcharge')!);
                      final index =
                          list.firstWhere((e) => e['id'] == surcharge.id);
                      list.remove(index);
                      sharedPreferences.setString(
                          'plan_surcharge', json.encode(list));
                      callbackSurcharge(null);
                      break;
                    case 2:
                      Navigator.push(context, PageTransition(child: UpdateBillingSurchargeScreen(surcharge: surcharge,), type: PageTransitionType.rightToLeft));
                      break;
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
