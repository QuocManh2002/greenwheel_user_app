import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/service/traveler_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> saveAsFile(final BuildContext context, final LayoutCallback build,
    final PdfPageFormat pageFormat) async {
  final bytes = await build(pageFormat);
  final appDocDir = await getApplicationDocumentsDirectory();
  final appDocPath = appDocDir.path;
  final file = File('$appDocPath/document.pdf');
  print('Saved as file ${file.path}...');
  await file.writeAsBytes(bytes);
  await OpenFile.open(file.path);
}

void showPrintedToast(final BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document printed successfully!')));
}

void showSharedToast(final BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document shared successfully!')));
}

Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
  final logoImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/logopng.png')).buffer.asUint8List(),
  );
  return pw.PageTheme(
      margin: const pw.EdgeInsets.symmetric(
          horizontal: 1 * PdfPageFormat.cm, vertical: 0.5 * PdfPageFormat.cm),
      textDirection: pw.TextDirection.ltr,
      orientation: pw.PageOrientation.portrait,
      buildBackground: (final context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Watermark(
              angle: 50,
              child: pw.Opacity(
                  opacity: 0.2,
                  child: pw.Image(
                    alignment: pw.Alignment.center,
                    logoImage,
                    fit: pw.BoxFit.cover,
                  )))));
}

buildMarkSvgImage(double size) => pw.SvgImage(
    svg: '''<svg viewBox="0 0 50 50" xmlns="http://www.w3.org/2000/svg">
  <ellipse style="fill: red;" cx="25" cy="25" rx="20" ry="20"></ellipse>
</svg>''', fit: pw.BoxFit.cover, height: size, width: size);

Future<Uint8List> generatePdf(final PdfPageFormat format) async {
  PlanService _planService = PlanService();
  CustomerService _cusomterService = CustomerService();
  // List<dynamic> roomOrderList = [];
  // List<dynamic> foodOrderList = [];
  // List<PlanJoinServiceInfor> listRoom = [];
  // List<PlanJoinServiceInfor> listFood = [];
  List<dynamic>? newRoomOrderList = [];
  List<dynamic>? newFoodOrderList = [];
  PlanDetail? _plan = await _planService.GetPlanById(
      sharedPreferences.getInt('plan_id_pdf')!, 'JOIN');
  final rs = await _cusomterService.GetCustomerById(_plan!.leaderId!);
  final res = await _planService
      .getOrderCreatePlan(sharedPreferences.getInt('plan_id_pdf')!);
  if (res != null) {
    _plan.orders = res['orders'];
  }
  CustomerViewModel _leader = rs[0];
  final doc = pw.Document(
    title: 'Test Generate PDF',
  );

  // if (_plan.orders != null) {
  //   for (final order in _plan.orders!) {
  //     if (order.type == 'MEAL') {
  //       foodOrderList.add(order);
  //     } else {
  //       roomOrderList.add(order);
  //     }
  //   }
  // }
  // List<int> indexRoomOrder = [];
  // List<int> indexFoodOrder = [];

  if (_plan.orders != null) {
    final serviceMap = _plan.orders!.groupListsBy((e) => e.type);
    newRoomOrderList = serviceMap.values
        .where((e) => e.first.type == 'LODGING')
        .toList()
        .firstOrNull;
    newFoodOrderList = serviceMap.values
        .where((e) => e.first.type == 'MEAL')
        .toList()
        .firstOrNull;
  }

  // if (roomOrderList.isNotEmpty) {
  //   for (final order in roomOrderList) {
  //     for (final index in order.serveDates) {
  //       if (!indexRoomOrder.contains(index)) {
  //         indexRoomOrder.add(index);
  //       }
  //     }
  //   }
  // }
  // if (foodOrderList.isNotEmpty) {
  //   for (final order in foodOrderList) {
  //     for (final index in order.serveDates) {
  //       if (!indexFoodOrder.contains(index)) {
  //         indexFoodOrder.add(index);
  //       }
  //     }
  //   }
  // }
  // for (final day in indexRoomOrder) {
  //   var orderList = [];
  //   for (final order in roomOrderList) {
  //     if (order.serveDates.contains(day)) {
  //       orderList.add(order);
  //     }
  //   }
  //   listRoom.add(PlanJoinServiceInfor(dayIndex: day, orderList: orderList));
  // }
  // for (final day in indexFoodOrder) {
  //   var orderList = [];
  //   for (final order in foodOrderList) {
  //     if (order.serveDates.contains(day)) {
  //       orderList.add(order);
  //     }
  //   }
  //   listFood.add(PlanJoinServiceInfor(dayIndex: day, orderList: orderList));
  // }

  final logoImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/logopng.png')).buffer.asUint8List(),
  );
  final font = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
  final boldFont = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
  final ttf = pw.Font.ttf(font);
  final boldTtf = pw.Font.ttf(boldFont);

  final pageTheme = await _myPageTheme(format);

  final netImage = await networkImage(defaultUserAvatarLink);

  doc.addPage(pw.MultiPage(
      pageTheme: pageTheme,
      header: (final context) => pw.Image(
            alignment: pw.Alignment.topLeft,
            logoImage,
            fit: pw.BoxFit.contain,
            width: 100,
          ),
      build: (final context) => [
            pw.Container(
                padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Text(_plan.name!.toUpperCase(),
                            style: pw.TextStyle(
                                fontSize: 30,
                                font: boldTtf,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFF2ECC71))),
                      ),
                      pw.SizedBox(height: 20),
                      buildInfoRow(
                          boldTtf, ttf, ' Địa điểm', _plan.locationName!),
                      buildInfoRow(boldTtf, ttf, ' Ngày khởi hành',
                          DateFormat('dd/MM/yyyy').format(_plan.utcDepartAt!)),
                      buildInfoRow(boldTtf, ttf, ' Ngày kết thúc',
                          DateFormat('dd/MM/yyyy').format(_plan.endDate!)),
                      buildInfoRow(
                          boldTtf,
                          ttf,
                          ' Số lượng thành viên',
                          _plan.maxMemberCount! < 10
                              ? '0${_plan.maxMemberCount}'
                              : '${_plan.maxMemberCount}'),
                      pw.SizedBox(height: 20),
                      pw.Text('LỊCH TRÌNH',
                          style: pw.TextStyle(
                              color: const PdfColor.fromInt(0xffE4080A),
                              font: boldTtf,
                              fontSize: 17,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      for (final day in _plan.schedule!)
                        pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 10),
                                  child: pw.Text(
                                      'NGÀY ${_plan.schedule!.indexOf(day) + 1}',
                                      style: const pw.TextStyle(
                                          fontSize: 15,
                                          color: PdfColor.fromInt(0xffE4080A))),
                                ),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.only(left: 50),
                                    child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          for (final event in day)
                                            pw.Text(
                                                '- ${event['shortDescription']}',
                                                style: pw.TextStyle(
                                                    fontSize: 14, font: ttf),
                                                overflow: pw.TextOverflow.clip)
                                        ]))
                              ],
                            )),
                      pw.Text('DỊCH VỤ',
                          style: pw.TextStyle(
                              color: const PdfColor.fromInt(0xffE4080A),
                              font: boldTtf,
                              fontSize: 17,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (newRoomOrderList != null &&
                              newRoomOrderList.isNotEmpty)
                            buildServiceWidget(
                                'LODGING', newRoomOrderList, ttf),
                          if (newFoodOrderList != null &&
                              newFoodOrderList.isNotEmpty)
                            buildServiceWidget('MEAL', newFoodOrderList, ttf),
                        ],
                      ),
                      // if (listRoom.isNotEmpty)
                      //   pw.Padding(
                      //       padding: const pw.EdgeInsets.only(left: 10),
                      //       child: pw.Text('LƯU TRÚ',
                      //           style: pw.TextStyle(
                      //               fontSize: 15,
                      //               font: ttf,
                      //               color:
                      //                   const PdfColor.fromInt(0xffE4080A)))),
                      // if (listRoom.isNotEmpty)
                      //   for (final day in listRoom)
                      //     pw.Padding(
                      //       padding: const pw.EdgeInsets.only(left: 50),
                      //       child: pw.Row(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //         children: [
                      //           pw.Text('- Ngày ${day.dayIndex + 1} - ',
                      //               style: pw.TextStyle(
                      //                   fontSize: 14,
                      //                   font: ttf,
                      //                   fontWeight: pw.FontWeight.bold)),
                      //           pw.Column(
                      //             children: day.orderList
                      //                 .map((e) => pw.Text(
                      //                       'Nghỉ ngơi tại khách sạn',
                      //                       style: pw.TextStyle(
                      //                           fontSize: 14,
                      //                           font: ttf,
                      //                           fontWeight: pw.FontWeight.bold),
                      //                     ))
                      //                 .toList(),
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      // if (listFood.isNotEmpty)
                      //   pw.Padding(
                      //       padding: const pw.EdgeInsets.only(left: 10),
                      //       child: pw.Text('ĂN UỐNG',
                      //           style: pw.TextStyle(
                      //               fontSize: 15,
                      //               font: ttf,
                      //               color:
                      //                   const PdfColor.fromInt(0xffE4080A)))),
                      // if (listFood.isNotEmpty)
                      //   for (final day in listFood)
                      //     pw.Padding(
                      //       padding: const pw.EdgeInsets.only(left: 50),
                      //       child: pw.Row(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //         children: [
                      //           pw.Text('- Ngày ${day.dayIndex + 1} - ',
                      //               style: pw.TextStyle(
                      //                   fontSize: 14,
                      //                   font: ttf,
                      //                   fontWeight: pw.FontWeight.bold)),
                      //           pw.Column(
                      //             children: day.orderList
                      //                 .map((e) => pw.Text(
                      //                       '${Utils().getPeriodString(e.period)['text']} - Nhà hàng',
                      //                       style: pw.TextStyle(
                      //                           fontSize: 14,
                      //                           font: ttf,
                      //                           fontWeight: pw.FontWeight.bold),
                      //                     ))
                      //                 .toList(),
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      // if (listFood.isNotEmpty || listRoom.isNotEmpty)
                      //   pw.SizedBox(height: 10),
                      // pw.Text('CHI PHÍ',
                      //     style: pw.TextStyle(
                      //         color: const PdfColor.fromInt(0xffE4080A),
                      //         font: boldTtf,
                      //         fontSize: 17,
                      //         fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Row(
                            children: [
                              pw.Text('CHI PHÍ CHUYẾN ĐI TRỌN GÓI',
                                  style: pw.TextStyle(
                                      fontSize: 15,
                                      font: ttf,
                                      color:
                                          const PdfColor.fromInt(0xffE4080A))),
                              pw.Spacer(),
                              pw.Text(
                                  '${NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: '').format(_plan.gcoinBudgetPerCapita! * 100)} VND/ NGƯỜI',
                                  style: pw.TextStyle(
                                      font: boldTtf,
                                      fontSize: 16,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(width: 20)
                            ],
                          )),
                      pw.SizedBox(height: 10),
                      pw.Text('THÔNG TIN LIÊN HỆ',
                          style: pw.TextStyle(
                              color: const PdfColor.fromInt(0xffE4080A),
                              font: boldTtf,
                              fontSize: 17,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text(
                              'Nếu bạn còn bất kỳ thắc mắc gì về chuyến đi này. Vui lòng liên hệ trực tiếp đến người tổ chức chuyến đi theo thông tin dưới đây',
                              style: pw.TextStyle(fontSize: 14, font: ttf))),
                      pw.SizedBox(height: 20),
                      pw.Row(
                        children: [
                          pw.Spacer(),
                          pw.Container(
                            height: 70,
                            width: 70,
                            alignment: pw.Alignment.center,
                            foregroundDecoration: const pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                            ),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              image: pw.DecorationImage(
                                image: netImage,
                                fit: pw.BoxFit.cover,
                              ),
                            ),
                          ),
                          pw.SizedBox(
                            width: 20,
                          ),
                          pw.Column(
                            children: [
                              pw.Text(_leader.name,
                                  style: pw.TextStyle(
                                      fontSize: 15,
                                      font: boldTtf,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('0${_leader.phone.substring(3)}',
                                  style: pw.TextStyle(
                                      fontSize: 15,
                                      font: boldTtf,
                                      fontWeight: pw.FontWeight.bold)),
                            ],
                          )
                        ],
                      )
                    ]))
          ]));
  return doc.save();
}

buildInfoRow(
        pw.Font contentFont, pw.Font titlefont, String title, String content) =>
    pw.Row(children: [
      buildMarkSvgImage(8),
      pw.Text(' $title:  ', style: pw.TextStyle(font: titlefont)),
      pw.Text(content,
          style: pw.TextStyle(
            font: contentFont,
            fontWeight: pw.FontWeight.bold,
          )),
    ]);

buildServiceWidget(String type, List<dynamic> orders, pw.Font font) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4, left: 8),
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF2ECC71),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8))),
            child: pw.Text(
              type == 'MEAL' ? 'Quán ăn/Nhà hàng' : 'Nhà nghỉ/Khách sạn',
              style: pw.TextStyle(
                  fontSize: 17,
                  font: font,
                  color: const PdfColor.fromInt(0xFFF2F2F2),
                  fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
        for (final order in orders)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 16),
            child: pw.Row(
              children: [
                pw.SizedBox(
                    width: 70,
                    child: pw.Text(
                      'Đơn ${orders.indexOf(order) + 1}',
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 17,
                          fontWeight: pw.FontWeight.bold),
                      overflow: pw.TextOverflow.clip,
                    )),
                pw.SizedBox(
                  width: 270,
                  child: pw.Text(
                    '${Utils().getPeriodString(order.runtimeType == OrderViewModel ? order.period : order['period'])['text']} ${buildServingDatesText(order.runtimeType == OrderViewModel ? order.serveDates : order['serveDates'])}',
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 17,
                        fontWeight: pw.FontWeight.bold),
                    overflow: pw.TextOverflow.clip,
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  NumberFormat.simpleCurrency(
                          locale: 'vi_VN', decimalDigits: 0, name: 'GCOIN')
                      .format(((order.runtimeType == OrderViewModel
                                  ? order.total
                                  : order['total']) /
                              100)
                          .toInt()),
                  style: pw.TextStyle(
                      font: font, fontSize: 17, fontWeight: pw.FontWeight.bold),
                  overflow: pw.TextOverflow.clip,
                ),
                // pw.Text
                // SvgPicture.asset(
                //   gcoin_logo,
                //   height: 23,
                // )
              ],
            ),
          ),
      ],
    );
buildServingDatesText(List<dynamic> serveDateIndexes) {
  if (serveDateIndexes.length == 1) {
    return DateFormat('dd/MM').format(DateTime.parse(serveDateIndexes[0]));
  } else {
    return '${DateFormat('dd/MM').format(DateTime.parse(serveDateIndexes[0]))} (+${serveDateIndexes.length - 1} ngày)';
  }
}
