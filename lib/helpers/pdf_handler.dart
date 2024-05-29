import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
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
  final PlanService planService = PlanService();
  final CustomerService cusomterService = CustomerService();
  final OrderService orderService = OrderService();
  List<dynamic>? newRoomOrderList = [];
  List<dynamic>? newFoodOrderList = [];
  PlanDetail? plan = await planService.getPlanById(
      sharedPreferences.getInt('plan_id_pdf')!, 'JOIN');
  final rs = await cusomterService.getCustomerById(plan!.leaderId!);
  final res = await orderService
      .getOrderByPlan(sharedPreferences.getInt('plan_id_pdf')!, 'JOIN');
  if (res != null) {
    plan.orders = res['orders'];
  }
  CustomerViewModel leader = rs[0];
  final doc = pw.Document(
    title: 'Test Generate PDF',
  );

  if (plan.orders != null) {
    final serviceMap = plan.orders!.groupListsBy((e) => e.type);
    newRoomOrderList = serviceMap.values
        .where((e) => e.first.type == 'LODGING')
        .toList()
        .firstOrNull;
    newFoodOrderList = serviceMap.values
        .where((e) => e.first.type == 'MEAL')
        .toList()
        .firstOrNull;
  }

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
                        child: pw.Text(plan.name!.toUpperCase(),
                            style: pw.TextStyle(
                                fontSize: 30,
                                font: boldTtf,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFF2ECC71))),
                      ),
                      pw.SizedBox(height: 20),
                      buildInfoRow(
                          boldTtf, ttf, ' Địa điểm', plan.locationName!),
                      buildInfoRow(boldTtf, ttf, ' Ngày khởi hành',
                          DateFormat('dd/MM/yyyy').format(plan.utcDepartAt!)),
                      buildInfoRow(boldTtf, ttf, ' Ngày kết thúc',
                          DateFormat('dd/MM/yyyy').format(plan.utcEndAt!)),
                      buildInfoRow(
                          boldTtf,
                          ttf,
                          ' Số lượng thành viên',
                          plan.maxMemberCount! < 10
                              ? '0${plan.maxMemberCount}'
                              : '${plan.maxMemberCount}'),
                      pw.SizedBox(height: 20),
                      pw.Text('LỊCH TRÌNH',
                          style: pw.TextStyle(
                              color: const PdfColor.fromInt(0xffE4080A),
                              font: boldTtf,
                              fontSize: 17,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      for (final day in plan.schedule!)
                        pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 10),
                                  child: pw.Text(
                                      'NGÀY ${plan.schedule!.indexOf(day) + 1}',
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
                                  '${NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: '').format(plan.gcoinBudgetPerCapita! * 100)} VND/ NGƯỜI',
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
                              pw.Text(leader.name,
                                  style: pw.TextStyle(
                                      fontSize: 15,
                                      font: boldTtf,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('0${leader.phone.substring(3)}',
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
