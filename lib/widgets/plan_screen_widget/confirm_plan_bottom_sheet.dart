import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/surcharge.dart';
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
      this.surchargeList,
      this.plan,
      required this.isJoin,
      this.onCancel,
      required this.isInfo,
      required this.isFromHost,
      this.onJoinPlan});
  final String locationName;
  final List<OrderViewModel>? orderList;
  final void Function()? onCompletePlan;
  final List<SurchargeViewModel>? surchargeList;
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

  ComboDate? comboDate;

  List<dynamic> emergencyList = [];
  List<dynamic> scheduleList = [];
  List<dynamic>? newRoomOrderList = [];
  List<dynamic>? newFoodOrderList = [];
  List<dynamic>? newRidingOrderList = [];

  String travelDurationText = '';
  bool _isAceptedPolicy = false;
  List<List<String>> scheduleTextList = [];
  double total = 0;
  int budgetPerCapita = 0;
  bool isPlanEndAtNoon = false;

  getTotal() {
    total = 0;
    for (final order in widget.orderList!) {
      total += order.total!;
    }
    if (widget.surchargeList != null && widget.surchargeList!.isNotEmpty) {
      for (final sur in widget.surchargeList!) {
        total += sur.gcoinAmount * widget.plan!.maxMemberCount!;
      }
    }

    budgetPerCapita = ((num.parse((total * 1.1).toStringAsFixed(5)).ceil() /
            widget.plan!.maxMemberCount!))
        .ceil();
  }

  buildListScheduleText() {
    scheduleList = json.decode(widget.plan!.schedule!);
    for (final event in scheduleList) {
      List<String> eventTextList = [];
      for (final act in event) {
        if (act['shortDescription'].toString().substring(0, 1) == '"') {
          eventTextList.add(json.decode(act['shortDescription']));
        } else {
          eventTextList.add(act['shortDescription']);
        }
      }
      scheduleTextList.add(eventTextList);
    }
  }

  setUpData() {
    if (widget.plan!.savedContacts != null) {
      emergencyList = json.decode(widget.plan!.savedContacts!);
    }

    if (widget.plan!.numOfExpPeriod != null) {
      comboDate = listComboDate.firstWhere(
          (element) => element.duration == widget.plan!.numOfExpPeriod);
      if (sharedPreferences.getString('plan_arrivedTime') != null) {
        isPlanEndAtNoon = Utils().isEndAtNoon(null);
      }
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
    if (widget.plan!.maxMemberCount != null) {
      getTotal();
    }
    buildServiceInfor();
  }

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  buildServiceInfor() async {
    if (widget.isInfo) {}
    final rs = widget.orderList!.groupListsBy((e) => e.type);
    newRoomOrderList =
        rs.values.firstWhereOrNull((e) => e.first.type == 'CHECKIN') ?? [];
    newFoodOrderList =
        rs.values.firstWhereOrNull((e) => e.first.type == 'EAT') ?? [];

    newRidingOrderList =
        rs.values.firstWhereOrNull((e) => e.first.type == 'VISIT') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              if (widget.plan!.maxMemberCount != null)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.maxMemberCount != null)
                BottomSheetContainerWidget(
                    title: 'Số lượng thành viên',
                    content: widget.plan!.maxMemberCount! < 10
                        ? '0${widget.plan!.maxMemberCount!}'
                        : widget.plan!.maxMemberCount!.toString()),
              SizedBox(
                height: 1.h,
              ),
              BottomSheetContainerWidget(
                  title: 'Địa điểm', content: widget.locationName),
              if (comboDate != null)
                SizedBox(
                  height: 1.h,
                ),
              if (comboDate != null)
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
                          'Thời gian chuyến đi: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${comboDate!.numberOfDay} ngày, ${comboDate!.numberOfNight} đêm',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip,
                        ),
                        if (widget.plan!.endDate != null)
                          Divider(
                            color: Colors.black26,
                            thickness: 1,
                            height: 1.h,
                          ),
                        if (widget.plan!.endDate != null)
                          Text(
                            '${DateFormat.Hm().format(widget.plan!.departAt!)} ${DateFormat('dd/MM/yy').format(widget.plan!.departAt!)} - ${isPlanEndAtNoon ? '14:00' : '22:00'} ${DateFormat('dd/MM/yy').format(widget.plan!.endDate!)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.clip,
                          ),
                      ],
                    )),
              if (widget.plan!.travelDuration != null)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.travelDuration != null)
                BottomSheetContainerWidget(
                    title: 'Thời gian di chuyển', content: travelDurationText),
              if (widget.plan!.departAddress != null)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.departAddress != null)
                BottomSheetContainerWidget(
                    title: 'Địa điểm xuất phát',
                    content: widget.plan!.departAddress!),
              if (widget.plan!.savedContacts != null &&
                  emergencyList.isNotEmpty)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.plan!.savedContacts != null &&
                  emergencyList.isNotEmpty)
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
                              emer['name'].toString().substring(0, 1) == '"'
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
              if (widget.plan!.schedule != null &&
                  scheduleTextList.any((element) => element.isNotEmpty))
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
                            if (day.isNotEmpty)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    'CHECKIN', newRoomOrderList!),
                              if (newFoodOrderList != null &&
                                  newFoodOrderList!.isNotEmpty)
                                buildServiceWidget('EAT', newFoodOrderList!),
                              if (newRidingOrderList != null &&
                                  newRidingOrderList!.isNotEmpty)
                                buildServiceWidget(
                                    'VISIT', newRidingOrderList!),
                            ],
                          )
                      ],
                    )),
              if (widget.surchargeList != null &&
                  widget.surchargeList!.isNotEmpty)
                SizedBox(
                  height: 1.h,
                ),
              if (widget.surchargeList != null &&
                  widget.surchargeList!.isNotEmpty)
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
                        for (final sur in widget.surchargeList!)
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sur.note.substring(0, 1) == '"'
                                          ? '${json.decode(sur.note)}'
                                          : sur.note,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.simpleCurrency(
                                            decimalDigits: 0,
                                            locale: 'vi_VN',
                                            name: '')
                                        .format(sur.gcoinAmount *
                                            widget.plan!.maxMemberCount!),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: SvgPicture.asset(
                                      gcoinLogo,
                                      height: 18,
                                    ),
                                  )
                                ],
                              ),
                              if (sur != widget.surchargeList!.last)
                                Divider(
                                  thickness: 1,
                                  height: 8,
                                  color: Colors.grey.withOpacity(0.3),
                                )
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tiền dịch vụ',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              NumberFormat.simpleCurrency(
                                      locale: 'vi_VN',
                                      decimalDigits: 0,
                                      name: "")
                                  .format(total),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: SvgPicture.asset(
                                gcoinLogo,
                                height: 18,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 0.3.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chênh lệch (10%)',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              NumberFormat.simpleCurrency(
                                      locale: 'vi_VN',
                                      decimalDigits: 0,
                                      name: "")
                                  .format((total * 0.1)),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: SvgPicture.asset(
                                gcoinLogo,
                                height: 18,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 0.3.h,
                        ),
                        const Divider(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                        SizedBox(
                          height: 0.3.h,
                        ),
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
                                Text(
                                  '(Đã làm tròn)',
                                  style: TextStyle(fontSize: 11),
                                )
                              ],
                            ),
                            const Spacer(),
                            Text(
                              NumberFormat.simpleCurrency(
                                      locale: 'vi_VN',
                                      decimalDigits: 0,
                                      name: "")
                                  .format(num.parse(
                                          (total * 1.1).toStringAsFixed(5))
                                      .ceil()),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: SvgPicture.asset(
                                gcoinLogo,
                                height: 18,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 0.3.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chi phí cho chuyến đi',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '(Cho mỗi người, đã làm tròn)',
                                  style: TextStyle(
                                      fontSize: 11, fontFamily: 'NotoSans'),
                                )
                              ],
                            ),
                            const Spacer(),
                            Text(
                              NumberFormat.simpleCurrency(
                                      locale: 'vi_VN',
                                      decimalDigits: 0,
                                      name: "")
                                  .format(budgetPerCapita),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: SvgPicture.asset(
                                gcoinLogo,
                                height: 18,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 0.3.h,
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
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.8),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Text(
                    type == 'EAT'
                        ? 'Quán ăn/Nhà hàng'
                        : type == 'CHECKIN'
                            ? 'Nhà nghỉ/Khách sạn'
                            : 'Thuê xe',
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          for (final order in orders)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 5.w,
                          child: Text(
                            '${orders.indexOf(order) + 1}. ',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.clip,
                          )),
                      buildServiceText(order),
                      const Spacer(),
                      Container(
                        alignment: Alignment.centerRight,
                        width: 20.w,
                        child: Text(
                          NumberFormat.simpleCurrency(
                                  locale: 'vi_VN', decimalDigits: 0, name: '')
                              .format(((order.runtimeType == OrderViewModel
                                      ? (order.total)
                                      : order['total']))
                                  .toInt()),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SvgPicture.asset(
                          gcoinLogo,
                          height: 18,
                        ),
                      )
                    ],
                  ),
                  for (final detail in order.runtimeType == OrderViewModel
                      ? order.details
                      : order['details'])
                    Row(
                      children: [
                        SizedBox(
                          width: 5.w,
                        ),
                        SizedBox(
                          width: 50.w,
                          child: Text(
                            order.runtimeType == OrderViewModel
                                ? detail.productName
                                : detail['productName'],
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'NotoSans',
                                color: Colors.black45),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 10.w,
                          child: Text(
                            'x${order.runtimeType == OrderViewModel ? detail.quantity : detail['quantity']}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'NotoSans',
                                color: Colors.black45),
                          ),
                        )
                      ],
                    ),
                  if (order != orders.last)
                    Padding(
                      padding: EdgeInsets.only(left: 5.w, top: 2, bottom: 2),
                      child: const Divider(
                        color: Colors.black38,
                        height: 1,
                      ),
                    ),
                ],
              ),
            ),
        ],
      );

  buildServiceText(dynamic order) {
    bool isShowPeriod =
        (order.runtimeType == OrderViewModel && order.type != 'RIDING') ||
            (order.runtimeType != OrderViewModel && order['type'] != 'RIDING');
    final periodString = Utils().getPeriodString(
        order.runtimeType == OrderViewModel
            ? order.period
            : order['period'])['text'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (final day in order.runtimeType == OrderViewModel
            ? order.serveDates
            : order['serveDates'])
          SizedBox(
            width: 40.w,
            child: Text(
              '${isShowPeriod ? periodString : ''} ${DateFormat('dd/MM').format(DateTime.parse(day.toString()))}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
            ),
          )
      ],
    );
  }
}
