import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/service/customer_service.dart';
import 'package:greenwheel_user_app/view_models/profile_viewmodels/transaction.dart';
import 'package:greenwheel_user_app/widgets/profile_screen_widget/transaction_card.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  CustomerService _customerService = CustomerService();
  List<Transaction>? _transactions = [];
  bool _isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() async {
    _transactions = await _customerService.getTransactionList();
    if (_transactions != null) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Lịch sử giao dịch'),
            ),
            body: _isLoading
                ? const Center(
                    child: Text('Đang tải ...'),
                  )
                : _transactions!.isEmpty
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(empty_plan),
                       const Text('Bạn không có giao dịch nào', style: TextStyle(fontFamily: 'NotoSans', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),)
                      ],
                    )
                    : 
                    SingleChildScrollView(
                      physics:const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          for(final tran in _transactions!)
                          TransactionCard(index: _transactions!.indexOf(tran), transaction: tran)
                        ],
                      ),
                    )
                    ));
  }
}
