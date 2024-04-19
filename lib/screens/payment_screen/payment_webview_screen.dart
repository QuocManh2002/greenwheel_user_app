import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen(
      {super.key, required this.request, required this.callback, required this.amount});
  final String request;
  final void Function(bool isSuccess, int amount) callback;
  final int amount;
  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url
                .startsWith('https://greenwheels.azurewebsites.net/graphql/')) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              widget.callback(request.url.contains('vnp_BankTranNo'), widget.amount);
              return NavigationDecision.navigate;
            } else {
              return NavigationDecision.navigate;
            }
          },
          onUrlChange: (change) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.request));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: WebViewWidget(controller: controller),
    ));
  }
}
