import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/pdf_handler.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/holiday.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/create_note_surcharge_screen.dart';
import 'package:greenwheel_user_app/service/config_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/province.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sizer2/sizer2.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key, required this.request, required this.callback});
  final String request;
  final void Function(bool isSuccess) callback;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<int> list = [1];
  bool isLongTap = false;

  late WebViewController controller;

  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            print('start');
          },
          onPageFinished: (String url) {
            print('finish');
            // Navigator.of(context).pop();
            // Navigator.of(context).push(MaterialPageRoute(builder:(_)=> TabScreen(pageIndex: 4,)));
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url
                .startsWith('https://greenwheels.azurewebsites.net/graphql/')) {
              if (request.url.contains('vnp_BankTranNo')) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                widget.callback(true);
                return NavigationDecision.navigate;
              }else{
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                widget.callback(false);
                return NavigationDecision.navigate;
              }
            } else {
              return NavigationDecision.navigate;
            }
          },
          onUrlChange: (change) {
            print('url change');
            print(change);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.request));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(body: WebViewWidget(controller: controller)));
  }
}
