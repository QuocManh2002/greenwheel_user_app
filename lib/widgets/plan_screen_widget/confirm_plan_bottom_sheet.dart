import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_service_infor.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/bottom_sheet_container_widget.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class ConfirmPlanBottomSheet extends StatefulWidget {
  const ConfirmPlanBottomSheet(
      {super.key,
      required this.locationName,
      this.orderList,
      this.onCompletePlan,
      this.listSurcharges,
      this.budgetPerCapita,
      this.total,
      this.plan,
      required this.isJoin,
      this.onCancel,
      required this.isInfo,
      this.onJoinPlan});
  final String locationName;
  final List<dynamic>? orderList;
  final void Function()? onCompletePlan;
  final List<Map>? listSurcharges;
  final double? total;
  final double? budgetPerCapita;
  final PlanCreate? plan;
  final bool isJoin;
  final void Function()? onJoinPlan;
  final void Function()? onCancel;
  final bool isInfo;

  @override
  State<ConfirmPlanBottomSheet> createState() => _ConfirmPlanBottomSheetState();
}

class _ConfirmPlanBottomSheetState extends State<ConfirmPlanBottomSheet> {
  bool _isShowSchedule = false;
  bool _isShowNote = false;
  final _controller = QuillController.basic();

  List<String> _scheduleText = [];
  List<dynamic> emergencyList = [];
  List<dynamic> scheduleList = [];
  List<dynamic> roomOrderList = [];
  List<dynamic> foodOrderList = [];
  String travelDurationText = '';
  bool _isAceptedPolicy = false;
  List<PlanServiceInfor> listRoom = [];
  List<PlanServiceInfor> listFood = [];

  buildListScheduleText() {
    scheduleList = json.decode(widget.plan!.schedule!);
    for (final event in scheduleList) {
      var _eventText = '';
      for (final act in event['events']) {
        if (act != event['events'].last) {
          if (act['shortDescription'].toString().substring(0, 1) == '\"') {
            _eventText += '${json.decode(act['shortDescription'])}, ';
          } else {
            _eventText += '${act['shortDescription']}, ';
          }
        } else {
          if (act['shortDescription'].toString().substring(0, 1) == '\"') {
            _eventText += '${json.decode(act['shortDescription'])}, ';
          } else {
            _eventText += '${act['shortDescription']}';
          }
        }
      }
      _scheduleText.add(_eventText);
    }
  }

  setUpData() {
    if (widget.plan!.savedContacts != null) {
      emergencyList = json.decode(widget.plan!.savedContacts!);
    }
    if (widget.plan!.travelDuration != null) {
      var tempDuration = DateFormat.Hm().parse(widget.plan!.travelDuration!);
      if (tempDuration.hour != 0) {
        travelDurationText += '${tempDuration.hour} giờ ';
      }
      if (tempDuration.minute != 0) {
        travelDurationText += '${tempDuration.minute} phút';
      }
    }
    if (widget.orderList != null) {
      for (final order in widget.orderList!) {
        if (widget.isJoin ? order.type == 'MEAL' : order['type'] == 'FOOD') {
          foodOrderList.add(order);
        } else {
          roomOrderList.add(order);
        }
      }
    }
    if (widget.plan!.schedule != null) {
      buildListScheduleText();
    }
    if (widget.isJoin) {
      buildNewServiceInfo();
    }
    if (widget.plan!.note != null && widget.plan!.note!.isNotEmpty) {
      _controller.document = Document.fromJson(jsonDecode(widget.plan!.note!));
      // print(_controller.document.toPlainText());
      // setState(() {
      //   widget.plan!.note = _controller.document.toPlainText();
      // });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  buildNewServiceInfo() {
    List<int> indexRoomOrder = [];
    List<int> indexFoodOrder = [];

    if (roomOrderList.isNotEmpty) {
      for (final order in roomOrderList) {
        for (final index in order.serveDateIndexes) {
          if (!indexRoomOrder.contains(index)) {
            indexRoomOrder.add(index);
          }
        }
      }
    }
    if (foodOrderList.isNotEmpty) {
      for (final order in foodOrderList) {
        for (final index in order.serveDateIndexes) {
          if (!indexFoodOrder.contains(index)) {
            indexFoodOrder.add(index);
          }
        }
      }
    }
    for (final day in indexRoomOrder) {
      var orderList = [];
      for (final order in roomOrderList) {
        if (order.serveDateIndexes.contains(day)) {
          orderList.add(order);
        }
      }
      listRoom.add(PlanServiceInfor(dayIndex: day, orderList: orderList));
    }
    for (final day in indexFoodOrder) {
      var orderList = [];
      for (final order in foodOrderList) {
        if (order.serveDateIndexes.contains(day)) {
          orderList.add(order);
        }
      }
      listFood.add(PlanServiceInfor(dayIndex: day, orderList: orderList));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
      child: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                height: 6,
                width: 10.h,
                decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(12))),
              ),
              if (widget.plan!.name != null)
                SizedBox(
                  height: 2.h,
                ),
              if (widget.plan!.name != null)
                BottomSheetContainerWidget(
                    title: 'Tên chuyến đi', content: widget.plan!.name!),
              if (widget.plan!.memberLimit != null)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.memberLimit != null)
                BottomSheetContainerWidget(
                    title: 'Số lượng thành viên',
                    content: widget.plan!.memberLimit! < 10
                        ? '0${widget.plan!.memberLimit!}'
                        : widget.plan!.memberLimit!.toString()),
              SizedBox(
                height: 1.h,
              ),
              BottomSheetContainerWidget(
                  title: 'Địa điểm', content: widget.locationName),
              if (widget.plan!.travelDuration != null)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.departureDate != null)
                BottomSheetContainerWidget(
                    title: 'Thời gian chuyến đi',
                    content:
                        '${DateFormat('dd/MM/yyyy').format(widget.plan!.departureDate!)} - ${DateFormat('dd/MM/yyyy').format(widget.plan!.endDate!)}'),
              if (widget.plan!.travelDuration != null)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.travelDuration != null)
                BottomSheetContainerWidget(
                    title: 'Thời gian di chuyển', content: travelDurationText),
              if (widget.plan!.schedule != null)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.schedule != null)
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
              if (widget.plan!.note != null && widget.plan!.note!.isNotEmpty)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.note != null && widget.plan!.note!.isNotEmpty)
                // BottomSheetContainerWidget(content: widget.plan!.note!, title: 'Ghi chú'),
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
                              _isShowNote = !_isShowNote;
                            });
                          },
                          child: Row(
                            children: [
                              const Text(
                                'Ghi chú',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Icon(
                                _isShowNote
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: primaryColor,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        if (_isShowNote)
                          QuillEditor.basic(
                            configurations: QuillEditorConfigurations(
                              controller: _controller,
                              readOnly: true,
                              customStyles: const DefaultStyles(
                                  sizeSmall: TextStyle(fontSize: 25),
                                  italic: TextStyle(fontSize: 20),
                                  small: TextStyle(fontSize: 20)),
                              sharedConfigurations:
                                  const QuillSharedConfigurations(
                                locale: Locale('vi'),
                              ),
                            ),
                          ),
                        // Text(
                        //   widget.plan!.note!,
                        //   style: const TextStyle(
                        //       fontSize: 18, fontWeight: FontWeight.bold),
                        //   overflow: TextOverflow.clip,
                        // ),
                      ]),
                ),

              // BottomSheetContainerWidget(
              //     content: widget.plan!.note!, title: 'Ghi chú'),
              if (widget.plan!.savedContacts != null)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.savedContacts != null)
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
                              emer['name'].toString().substring(0, 1) == '\"'
                                  ? json.decode(emer['name'])
                                  : emer['name'],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.clip,
                            ),
                          )
                      ],
                    )),
              if (!widget.isJoin && widget.orderList != null)
                SizedBox(
                  height: 1.h,
                ),
              if (!widget.isJoin && widget.orderList != null)
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
                        for (final order in widget.orderList!)
                          SizedBox(
                            width: 80.w,
                            child: Text(
                              widget.isJoin
                                  ? '${order.supplierName} - ${order.details!.length} sản phẩm'
                                  : '${order['supplierName']} - ${order['details']!.length} sản phẩm',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    )),
              if (widget.listSurcharges != null &&
                  widget.listSurcharges!.isNotEmpty)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.listSurcharges != null &&
                  widget.listSurcharges!.isNotEmpty)
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
                        const Text(
                          'Phụ thu',
                          style: TextStyle(fontSize: 16),
                        ),
                        for (final order in widget.listSurcharges!)
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
              if (widget.orderList != null && widget.isJoin)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.orderList != null && widget.isJoin)
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
                        const Text(
                          'Dịch vụ chuyến đi',
                          style: TextStyle(fontSize: 16),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (listRoom.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8))),
                                    child: const Text(
                                      'Lưu trú',
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              if (listRoom.isNotEmpty)
                                for (final day in listRoom)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Text('Ngày ${day.dayIndex + 1} - ',
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold)),
                                        Column(
                                          children: day.orderList
                                              .map((e) => const Text(
                                                    'Nghỉ ngơi tại khách sạn',
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ))
                                              .toList(),
                                        )
                                      ],
                                    ),
                                  ),
                              if (listFood.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8))),
                                    child: const Text(
                                      'Ăn uống',
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              if (listFood.isNotEmpty)
                                for (final day in listFood)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Ngày ${day.dayIndex + 1} - ',
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold)),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (final detail in day.orderList)
                                              Text(
                                                '${getPeriodString(detail.period)} - Nhà hàng',
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ]),
                ),
              if (widget.total != null)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.total != null)
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
                        if (!widget.isJoin)
                          Row(
                            children: [
                              const Text(
                                'Tổng cộng',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Text(
                                '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(widget.total ?? 0)} GCOIN',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        Row(
                          children: [
                            const Text(
                              'Chi phí cho chuyến đi',
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
              if (widget.isJoin)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.isJoin)
                Container(
                  width: 100.w,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isAceptedPolicy,
                        activeColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _isAceptedPolicy = value!;
                          });
                        },
                      ),
                      SizedBox(
                        width: 70.w,
                        child: const Text(
                          'Tôi đã đọc và đồng ý với tất cả điều khoản của chuyến đi',
                          overflow: TextOverflow.clip,
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ),
              SizedBox(
                height: 1.h,
              ),
              if (!widget.isInfo)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          style: elevatedButtonStyle.copyWith(
                              backgroundColor:
                                  const MaterialStatePropertyAll(Colors.blue)),
                          onPressed: () {
                            widget.isJoin
                                ? widget.onCancel!()
                                : Navigator.of(context).pop();
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
                          style: elevatedButtonStyle.copyWith(
                              foregroundColor:
                                  const MaterialStatePropertyAll(Colors.white),
                              backgroundColor:
                                  MaterialStatePropertyAll(widget.isJoin
                                      ? _isAceptedPolicy
                                          ? primaryColor
                                          : Colors.grey
                                      : primaryColor)),
                          onPressed: widget.isJoin
                              ? () {
                                  if (_isAceptedPolicy) {
                                    widget.onJoinPlan!();
                                  }
                                }
                              : widget.onCompletePlan,
                          label: Text(widget.isJoin ? 'Đi thôi' : 'Xác nhận')),
                    )
                  ],
                )
            ]),
      ),
    );
  }

  getPeriodString(String period) {
    String rs = '';
    switch (period) {
      case 'MORNING':
        rs = 'Buổi sáng';
        break;
      case 'NOON':
        rs = 'Buổi trưa';
        break;
      case 'AFTERNOON':
        rs = 'Buổi chiều';
        break;
      case 'EVENING':
        rs = 'Buổi tối';
        break;
    }
    return rs;
  }
}
