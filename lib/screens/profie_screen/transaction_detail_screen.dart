
import 'package:flutter/material.dart';
import 'package:sizer2/sizer2.dart';

import '../../main.dart';
import '../../service/transaction_service.dart';
import '../../service/traveler_service.dart';
import '../../view_models/plan_viewmodels/plan_detail.dart';
import '../../view_models/profile_viewmodels/transaction.dart';
import '../../view_models/transaction_detail.dart';
import '../../widgets/plan_screen_widget/detail_payment_info.dart';
import '../../widgets/plan_screen_widget/detail_payment_plan_info.dart';
import '../loading_screen/transaction_detail_loading_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen(
      {super.key, required this.transaction, required this.icon});

  final Transaction transaction;
  final Widget icon;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  PlanDetail? plan;
  bool _isLoading = true;
  final TransactionService _transactionService = TransactionService();
  final CustomerService _customerService = CustomerService();
  bool isHandled = false;
  String queryText = '';
  String subQueryText = '';
  TransactionDetailViewModel? transactionDetail;
  int? travelerBalance;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    final rs = await _transactionService.getTransactionDetail(
        "type", widget.transaction.id!);
    travelerBalance = await _customerService
        .getTravelerBalance(sharedPreferences.getInt('userId')!);
    if (rs != null) {
      setState(() {
        transactionDetail = rs;
        transactionDetail!.transaction = widget.transaction;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Chi tiết thanh toán'),
            ),
            body: _isLoading
                ? const TransactionDetailLoadingScreen()
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 23, vertical: 12),
                        child: Column(children: [
                          if (transactionDetail!.plan != null)
                            DetailPaymentPlanInfo(
                              plan: transactionDetail!.plan!,
                              isView: true,
                            ),
                          if (transactionDetail!.plan != null)
                            SizedBox(
                              height: 2.h,
                            ),
                          DetailPaymentInfo(
                            transactionDetail: transactionDetail!,
                          )
                        ])))));
  }
}
