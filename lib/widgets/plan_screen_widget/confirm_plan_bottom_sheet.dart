import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_create.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/bottom_sheet_container_widget.dart';
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
      required this.onJoinPlan});
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
  bool _isAceptedPolicy = false;

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
    emergencyList = json.decode(widget.plan!.savedContacts!);
    print(widget.plan!.travelDuration!);
    var tempDuration = DateFormat.Hm().parse(widget.plan!.travelDuration!);
    print(tempDuration);
    if (tempDuration.hour != 0) {
      travelDurationText += '${tempDuration.hour} giờ ';
    }
    if (tempDuration.minute != 0) {
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
          BottomSheetContainerWidget(
              title: 'Tên chuyến đi', content: widget.plan!.name!),
          SizedBox(
            height: 1.h,
          ),
          BottomSheetContainerWidget(
              title: 'Số lượng thành viên',
              content: widget.plan!.memberLimit! < 10
                  ? '0${widget.plan!.memberLimit!}'
                  : widget.plan!.memberLimit!.toString()),
          if (widget.plan!.weight != null && widget.plan!.weight! != 1)
            SizedBox(
              height: 1.h,
            ),
          if (widget.plan!.weight != null && widget.plan!.weight! != 1)
            BottomSheetContainerWidget(
                content: widget.plan!.weight! < 10
                    ? '0${widget.plan!.weight}'
                    : widget.plan!.weight!.toString(),
                title: 'Số lượng thành viên của nhóm bạn'),
          SizedBox(
            height: 1.h,
          ),
          BottomSheetContainerWidget(
              title: 'Địa điểm', content: widget.locationName),
          SizedBox(
            height: 1.h,
          ),
          BottomSheetContainerWidget(
              title: 'Thời gian chuyến đi',
              content:
                  '${DateFormat('dd/MM/yyyy').format(widget.plan!.departureDate!)} - ${DateFormat('dd/MM/yyyy').format(widget.plan!.endDate!)}'),
          SizedBox(
            height: 1.h,
          ),
          BottomSheetContainerWidget(
              title: 'Thời gian di chuyển', content: travelDurationText),
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
          if (widget.plan!.note!.isNotEmpty)
            SizedBox(
              height: 1.h,
            ),
          if (widget.plan!.note!.isNotEmpty)
            BottomSheetContainerWidget(
                content: widget.plan!.note!, title: 'Ghi chú'),
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
          if(widget.isJoin)
          SizedBox(height: 1.h,),
          if(widget.isJoin)
          Container(
            width: 100.w,
            padding:
                const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Checkbox(value: _isAceptedPolicy , 
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _isAceptedPolicy = value!;
                      });
                    },),
                    SizedBox(
                      width: 70.w,
                      child: const Text('Tôi đã đọc và đồng ý với tất cả điều khoản của chuyến đi', 
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: 14),),
                    )
                  ],
                ),
          ),
          SizedBox(
                    height: 1.h,
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
                                    const MaterialStatePropertyAll(
                                        Colors.blue)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            label: Text(
                                widget.isJoin ? "Huỷ" : 'Chỉnh sửa')),
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
                            onPressed: widget.isJoin
                                ? (){
                                  if(!_isAceptedPolicy){
                                    AwesomeDialog(context: context,
                                      animType: AnimType.leftSlide,
                                      dialogType: DialogType.info,
                                      title: 'Bạn phải đọc và đồng ý với tất cả các điều khoản của chuyến đi để có thể tham gia vào chuyến đi',
                                      titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      btnOkColor: Colors.blue,
                                      btnOkText: 'Ok',
                                      btnOkOnPress: (){}
                                    ).show();
                                  }else{
                                  widget.onJoinPlan();
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
}
