import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/bottom_sheet_container_widget.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class ConfirmPlanBottomSheet extends StatefulWidget {
  const ConfirmPlanBottomSheet(
      {super.key,
      required this.locationName,
      this.orderList,
      this.onCompletePlan,
      this.listSurcharges,
      this.plan,
      required this.isJoin,
      this.onCancel,
      required this.isInfo,
      required this.isFromHost,
      this.onJoinPlan});
  final String locationName;
  final List<dynamic>? orderList;
  final void Function()? onCompletePlan;
  final List<dynamic>? listSurcharges;
  final PlanCreate? plan;
  final bool isJoin;
  final void Function()? onJoinPlan;
  final void Function()? onCancel;
  final bool isInfo;
  final bool isFromHost;

  @override
  State<ConfirmPlanBottomSheet> createState() => _ConfirmPlanBottomSheetState();
}

class _ConfirmPlanBottomSheetState extends State<ConfirmPlanBottomSheet> {
  bool _isShowSchedule = false;
  bool _isShowNote = false;
  bool _isShowOrder = false;
  HtmlEditorController controller = HtmlEditorController();

  List<dynamic> emergencyList = [];
  List<dynamic> scheduleList = [];
  List<dynamic>? newRoomOrderList = [];
  List<dynamic>? newFoodOrderList = [];

  String travelDurationText = '';
  bool _isAceptedPolicy = false;
  List<List<String>> scheduleTextList = [];
  double total = 0;
  int budgetPerCapita = 0;

  getTotal() {
    total = 0;
    for (final order in widget.orderList!) {
      if (order.runtimeType == OrderViewModel) {
        total += order.total / 100;
      } else {
        total += order['total'] / 100;
      }
    }
    if (widget.listSurcharges != null && widget.listSurcharges!.isNotEmpty) {
      for (final sur in widget.listSurcharges!) {
        if(sur['alreadyDivided']){
          total += sur['gcoinAmount'] * widget.plan!.memberLimit;
        }else{
          total += sur['gcoinAmount'];
        }
      }
    }

    budgetPerCapita = ((total * 1.1 / widget.plan!.memberLimit!)).floor();
  }

  buildListScheduleText() {
    scheduleList = json.decode(widget.plan!.schedule!);
    for (final event in scheduleList) {
      List<String> _eventTextList = [];
      for (final act in event['events']) {
        if (act['shortDescription'].toString().substring(0, 1) == '\"') {
          _eventTextList.add(json.decode(act['shortDescription']));
        } else {
          _eventTextList.add(act['shortDescription']);
        }
      }
      scheduleTextList.add(_eventTextList);
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
    if (widget.plan!.schedule != null) {
      buildListScheduleText();
    }
    getTotal();
    buildServiceInfor();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  buildServiceInfor() {
    final rs = widget.orderList!.groupListsBy(
        (e) => e.runtimeType == OrderViewModel ? e.type : e['type']);
    newRoomOrderList = rs.values
        .where((e) => e.firstOrNull.runtimeType == OrderViewModel
            ? e.first.type == 'LODGING'
            : e.first['type'] == 'LODGING')
        .toList()
        .firstOrNull;
    newFoodOrderList = rs.values
        .where((e) => e.firstOrNull.runtimeType == OrderViewModel
            ? e.first.type == 'MEAL'
            : e.first['type'] == 'MEAL')
        .toList()
        .firstOrNull;
    print(rs.values);
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
              if (widget.plan!.departureAddress != null)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.departureAddress != null)
                BottomSheetContainerWidget(
                    title: 'Địa điểm xuất phát',
                    content: widget.plan!.departureAddress!),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, left: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Text(
                                      'Ngày ${scheduleList.indexOf(day) + 1}',
                                      style: const TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final event in scheduleTextList[
                                        scheduleList.indexOf(day)])
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: Text(
                                          event,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                )
                              ],
                            ),
                      ]),
                ),
              if (widget.plan!.note != null &&
                  widget.plan!.note!.isNotEmpty &&
                  widget.plan!.note! != 'null')
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.note != null &&
                  widget.plan!.note!.isNotEmpty &&
                  widget.plan!.note! != 'null')
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
                        if (_isShowNote) HtmlWidget(widget.plan!.note ?? ''),
                      ]),
                ),
              if (widget.orderList != null && widget.orderList!.isNotEmpty)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.orderList != null && widget.orderList!.isNotEmpty)
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
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isShowOrder = !_isShowOrder;
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                widget.isJoin
                                    ? 'Dịch vụ chuyến đi'
                                    : 'Kinh phí dự trù',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Icon(
                                _isShowOrder
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: primaryColor,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        if (_isShowOrder)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (newRoomOrderList != null &&
                                  newRoomOrderList!.isNotEmpty)
                                buildServiceWidget(
                                    'LODGING', newRoomOrderList!),
                              if (newFoodOrderList != null &&
                                  newFoodOrderList!.isNotEmpty)
                                buildServiceWidget('MEAL', newFoodOrderList!),
                            ],
                          )
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
                        for (final sur in widget.listSurcharges!)
                          Row(
                            children: [
                              SizedBox(
                                width: 50.w,
                                child: Text(
                                  '${json.decode(sur['note'])}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                NumberFormat.simpleCurrency(
                                        decimalDigits: 0,
                                        locale: 'vi_VN',
                                        name: '')
                                    .format(
                                    sur['alreadyDivided'] ?
                                    sur['gcoinAmount'] * widget.plan!.memberLimit :
                                    sur['gcoinAmount']
                                    ),
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SvgPicture.asset(gcoin_logo,height:  23)
                            ],
                          )
                      ]),
                ),
              if (total != 0)
                SizedBox(
                  height: 1.h,
                ),
              if (total != 0)
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                    'Tổng cộng',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                 Text('(+10% chênh lệch)',
                                  style: TextStyle(fontSize: 12),
                                  )
                                ],
                              ),
                              const Spacer(),
                              Text(
                                NumberFormat.simpleCurrency(
                                        locale: 'vi_VN',
                                        decimalDigits: 0,
                                        name: "")
                                    .format((total * 1.1).ceil()),
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              SvgPicture.asset(
                                gcoin_logo,
                                height: 23,
                              )
                            ],
                          ),
                        SizedBox(
                          height: 0.3.h,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Chi phí cho chuyến đi',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              NumberFormat.simpleCurrency(
                                      locale: 'vi_VN',
                                      decimalDigits: 0,
                                      name: "")
                                  .format(budgetPerCapita),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            SvgPicture.asset(
                              gcoin_logo,
                              height: 23,
                            )
                          ],
                        ),
                      ]),
                ),
              if (widget.isJoin)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.isJoin && !widget.isFromHost)
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
                                      ? _isAceptedPolicy || widget.isFromHost
                                          ? primaryColor
                                          : Colors.grey
                                      : primaryColor)),
                          onPressed: widget.isJoin
                              ? () {
                                  if (widget.isFromHost || _isAceptedPolicy) {
                                    widget.onJoinPlan!();
                                  }
                                }
                              : widget.onCompletePlan,
                          label: Text(widget.isJoin
                              ? widget.isFromHost
                                  ? 'Tham gia'
                                  : 'Đi thôi'
                              : 'Xác nhận')),
                    )
                  ],
                )
            ]),
      ),
    );
  }

  buildServiceWidget(String type, List<dynamic> orders) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.8),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Text(
                type == 'MEAL' ? 'Quán ăn/Nhà hàng' : 'Nhà nghỉ/Khách sạn',
                style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          for (final order in orders)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  SizedBox(
                      width: 5.w,
                      child: Text(
                        '${orders.indexOf(order) + 1}. ',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.clip,
                      )),
                  SizedBox(
                    width: 42.w,
                    child: Text(
                      '${Utils().getPeriodString(order.runtimeType == OrderViewModel ? order.period : order['period'])['text']} ${Utils().buildServingDatesText(order.runtimeType == OrderViewModel ? order.serveDates : order['serveDates'])}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    alignment: Alignment.centerRight,
                    width: 20.w,
                    child: Text(
                      NumberFormat.simpleCurrency(
                              locale: 'vi_VN', decimalDigits: 0, name: '')
                          .format(((order.runtimeType == OrderViewModel
                                      ? order.total
                                      : order['total']) /
                                  100)
                              .toInt()),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  SvgPicture.asset(
                    gcoin_logo,
                    height: 23,
                  )
                ],
              ),
            ),
        ],
      );
}
