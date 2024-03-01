import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class ConfirmPlanBottomSheet extends StatefulWidget {
  const ConfirmPlanBottomSheet(
      {super.key,
      required this.locationName,
      required this.orderList,
      required this.onCompletePlan,
      required this.listSurcharges,
      required this.budgetPerCapita,
      required this.total,
      this.plan,
      required this.isJoin,
      required this.onJoinPlan
      });
  final String locationName;
  final List<dynamic> orderList;
  final void Function() onCompletePlan;
  final List<Map> listSurcharges;
  final double total;
  final double budgetPerCapita;
  final PlanCreate? plan;
  final bool isJoin;
  final void Function() onJoinPlan;

  @override
  State<ConfirmPlanBottomSheet> createState() => _ConfirmPlanBottomSheetState();
}

class _ConfirmPlanBottomSheetState extends State<ConfirmPlanBottomSheet> {
  bool _isShowSchedule = false;

  List<String> _scheduleText = [];
  List<dynamic> emergencyList = [];
  List<dynamic> scheduleList = [];
  String travelDurationText = '';


  buildListScheduleText() {
    scheduleList = json.decode(widget.plan!.schedule!);
    for (final event in scheduleList) {
      var _eventText = '';
      for (final act in event['events']) {
        if (act != event['events'].last) {
          _eventText += '${json.decode(act['shortDescription'])}, ';
        } else {
          _eventText += json.decode(act['shortDescription']);
        }
      }
      _scheduleText.add(_eventText);
    }
  }

  setUpData() {
    emergencyList = json.decode(widget.plan!.savedContacts!);
    print(widget.plan!.travelDuration!);
    var tempDuration = DateFormat.Hm().parse(widget.plan!.travelDuration!);
    print(tempDuration);
    if(tempDuration.hour != 0 ){
      travelDurationText += '${tempDuration.hour} giờ ';
    }
    if(tempDuration.minute != 0){
      travelDurationText += '${tempDuration.minute} phút';
    }
    print(travelDurationText);
    // travelDurationText = DateFormat.Hm().format(tempDuration);
    buildListScheduleText();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  alignment: Alignment.center,
                  height: 6,
                  width: 10.h,
                  decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                ),
                SizedBox(
                  height: 2.h,
                ),
                buildInfoWidget('Tên chuyến đi', widget.plan!.name!),
                SizedBox(
                  height: 1.h,
                ),
                buildInfoWidget('Số lượng thành viên',
                    widget.plan!.memberLimit! < 10 ? '0${widget.plan!.memberLimit!}' :widget.plan!.memberLimit!.toString() ),
                SizedBox(
                  height: 1.h,
                ),
                buildInfoWidget('Địa điểm', widget.locationName),
                SizedBox(
                  height: 1.h,
                ),
                buildInfoWidget('Thời gian chuyến đi',
                    '${DateFormat('dd/MM/yyyy').format(widget.plan!.departureDate!)} - ${DateFormat('dd/MM/yyyy').format(widget.plan!.endDate!)}'),
                SizedBox(
                  height: 1.h,
                ),
                buildInfoWidget('Thời gian di chuyển', travelDurationText),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                  width: 100.w,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 3,
                          color: Colors.black12,
                          offset: Offset(1, 3),
                        )
                      ],
                      color: Colors.white.withOpacity(0.97),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isShowSchedule = !_isShowSchedule;
                            });
                          },
                          child: Row(
                            children: [
                              const Text(
                                'Lịch trình',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Icon(
                                _isShowSchedule
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: primaryColor,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        if (_isShowSchedule)
                          for (final day in scheduleList)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '- Ngày ${scheduleList.indexOf(day) + 1}: ',
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  width: 60.w,
                                  child: Text(
                                    _scheduleText[scheduleList.indexOf(day)],
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                      ]),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                    width: 100.w,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.black12,
                            offset: Offset(1, 3),
                          )
                        ],
                        color: Colors.white.withOpacity(0.97),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dịch vụ khẩn cấp đã lưu: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        for (final emer in emergencyList)
                          SizedBox(
                            width: 80.w,
                            child: Text(
                              json.decode(emer['name']),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.clip,
                            ),
                          )
                      ],
                    )),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                    width: 100.w,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.black12,
                            offset: Offset(1, 3),
                          )
                        ],
                        color: Colors.white.withOpacity(0.97),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đơn hàng mẫu đã lên: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        for (final order in widget.orderList)
                          SizedBox(
                            width: 80.w,
                            child: Text(
                              '${order['supplierName']} - ${order['details']!.length} sản phẩm',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    )),
                SizedBox(
                  height: 1.h,
                ),
                if (widget.listSurcharges.isNotEmpty)
                  Container(
                    width: 100.w,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.black12,
                            offset: Offset(1, 3),
                          )
                        ],
                        color: Colors.white.withOpacity(0.97),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phụ thu',
                            style: TextStyle(fontSize: 16),
                          ),
                          for (final order in widget.listSurcharges)
                            SizedBox(
                                width: 80.w,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 50.w,
                                      child: Text(
                                        '${json.decode(order['note'])}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${order['gcoinAmount']} GCOIN',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ))
                        ]),
                  ),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                  width: 100.w,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 3,
                          color: Colors.black12,
                          offset: Offset(1, 3),
                        )
                      ],
                      color: Colors.white.withOpacity(0.97),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Tổng cộng',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(widget.total)} GCOIN',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Khoản thu bình quân',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(widget.budgetPerCapita)} GCOIN',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ]),
                ),
              ]),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.edit_square,
                      color: Colors.white,
                    ),
                    style: elevatedButtonStyle.copyWith(
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.blue)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    label: Text(widget.isJoin ? "Huỷ" : 'Chỉnh sửa')),
              ),
              SizedBox(
                width: 1.h,
              ),
              Expanded(
                child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    style: elevatedButtonStyle,
                    onPressed: widget.isJoin ? widget.onJoinPlan : widget.onCompletePlan,
                    label: const Text('Xác nhận')),
              )
            ],
          )
        ],
      ),
    );
  }

  buildInfoWidget(String title, String content) => Container(
        width: 100.w,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                color: Colors.black12,
                offset: Offset(1, 3),
              )
            ],
            color: Colors.white.withOpacity(0.97),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              content,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
            )
          ],
        ),
      );
}
