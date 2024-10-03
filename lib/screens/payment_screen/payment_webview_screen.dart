
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:phuot_app/config/graphql_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../view_models/profile_viewmodels/transaction.dart';
import '../../view_models/topup_request.dart';

// ignore: must_be_immutable
class PaymentWebViewScreen extends StatefulWidget {
  PaymentWebViewScreen(
      {super.key,
      required this.request,
      required this.callback,
      required this.amount,
      this.transaction});
  final TopupRequestViewModel request;
  final void Function(bool isSuccess, int amount) callback;
  final int amount;
  TransactionViewModel? transaction;
  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late WebViewController controller;
  static GraphQlConfig config = GraphQlConfig();
  GraphQLClient client = config.getClient();

  String text = r"""
      subscription($transactionId: Int!) {
        topUpStatus(transactionId: $transactionId) {
            id
            providerId
            planMemberId
            orderId
            type
            status
            amount
            description
            gateway
            bankTransCode
            createdAt
            accountId
          }
        }
""";

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
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
                .startsWith('https://greenwheels.azurewebsites.net')) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              widget.callback(
                  request.url.contains('vnp_BankTranNo'), widget.amount);
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
          onUrlChange: (change) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.request.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: GraphQLProvider(
        client: ValueNotifier(client),
        child: CacheProvider(
          child: Stack(
            children: [
              WebViewWidget(
                controller: controller,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
