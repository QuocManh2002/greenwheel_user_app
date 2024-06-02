import 'package:flutter/material.dart';
import 'package:sizer2/sizer2.dart';

import '../../core/constants/urls.dart';
import '../../models/pagination.dart';
import '../../service/transaction_service.dart';
import '../../view_models/profile_viewmodels/transaction.dart';
import '../../widgets/profile_screen_widget/transaction_card.dart';
import '../loading_screen/notification_list_loading_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionViewModel>? _transactions = [];
  Pagination<TransactionViewModel>? page;
  bool _isLoading = true;
  String? cursor;
  final controller = ScrollController();
  bool _isCalled = false;

  @override
  void initState() {
    super.initState();
    setUpData();

    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (!_isCalled) {
          setUpData();
          _isCalled = true;
        }
      } else {
        if (_isCalled) {
          _isCalled = false;
        }
      }
    });
  }

  setUpData() async {
    page = await _transactionService.getTransactionList(cursor);
    if (page != null) {
      cursor = page!.cursor;
      setState(() {
        _isLoading = false;
        _transactions!.addAll(page!.objects!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFf2f2f2),
              title: const Text(
                "Lịch sử giao dịch",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: _isLoading
                ? const NotificationListLoadingScreen()
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        cursor = null;
                        _isLoading = true;
                        _transactions = [];
                      });
                      setUpData();
                    },
                    child: _transactions!.isEmpty
                        ? ListView.builder(
                            controller: controller,
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 1,
                            itemBuilder: (context, index) => SizedBox(
                              height: 60.h,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(emptyPlan, width: 60.w,),
                                  const Text(
                                    'Bạn không có giao dịch nào',
                                    style: TextStyle(
                                        fontFamily: 'NotoSans',
                                        fontSize: 17,
                                        color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            controller: controller,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _transactions!.length,
                            itemBuilder: (context, index) => TransactionCard(
                                index: index,
                                transaction: _transactions![index]),
                          ),
                  )));
  }
}
