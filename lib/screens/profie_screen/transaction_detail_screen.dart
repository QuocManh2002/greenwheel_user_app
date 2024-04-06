import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/loading_screen/transaction_detail_loading_screen.dart';
import 'package:greenwheel_user_app/service/transaction_service.dart';
import 'package:greenwheel_user_app/service/traveler_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/profile_viewmodels/transaction.dart';
import 'package:greenwheel_user_app/view_models/transaction_detail.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/detail_payment_info.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/detail_payment_plan_info.dart';
import 'package:sizer2/sizer2.dart';

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
  TransactionService _transactionService = TransactionService();
  CustomerService _customerService = CustomerService();
  bool isHandled = false;
  String queryText = '';
  String subQueryText = '';
  TransactionDetailViewModel? transactionDetail;
  int? travelerBalance;

  @override
  void initState() {
    // TODO: implement initState
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

  buildDivider() => Column(
        children: [
          SizedBox(
            height: 0.7.h,
          ),
          Container(
            color: Colors.grey.withOpacity(0.5),
            height: 1.2,
          ),
          SizedBox(
            height: 0.7.h,
          ),
        ],
      );
}
