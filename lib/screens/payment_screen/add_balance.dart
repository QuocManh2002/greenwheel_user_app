import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phuot_app/core/constants/colors.dart';
import 'package:phuot_app/core/constants/global_constant.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/models/tag.dart';
import 'package:phuot_app/screens/payment_screen/payment_webview_screen.dart';
import 'package:phuot_app/view_models/topup_request.dart';
import 'package:phuot_app/widgets/style_widget/button_style.dart';
import 'package:phuot_app/widgets/search_screen_widget/tag.dart';
import 'package:phuot_app/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:phuot_app/widgets/style_widget/text_form_field_widget.dart';

import '../../service/transaction_service.dart';

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen(
      {super.key, required this.balance, required this.callback});
  final double balance;
  final void Function(bool isSuccess, int amount) callback;

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  TextEditingController newBalanceController = TextEditingController();
  bool isSelected = false;
  TransactionService transactionService = TransactionService();
  bool isLoading = true;
  double? refreshedBalance;
  String? paymentData;
  int amount = 0;
  bool isSuccess = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int minTopUp = 0;
  int maxTopUp = 0;

  @override
  void dispose() {
    super.dispose();
    newBalanceController.dispose();
  }

  @override
  void initState() {
    super.initState();
    minTopUp = sharedPreferences.getInt('MIN_TOPUP')!;
    maxTopUp = sharedPreferences.getInt('MAX_TOPUP')!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: lightPrimaryTextColor,
      appBar: AppBar(
        title: const Text("Nạp tiền vào ví"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Số dư ví",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 20,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                NumberFormat.simpleCurrency(
                                        locale: 'vi_VN',
                                        decimalDigits: 0,
                                        name: "")
                                    .format(refreshedBalance ?? widget.balance),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SvgPicture.asset(
                                gcoinLogo,
                                height: 32,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        height: 1.8,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Form(
                          key: _formKey,
                          child: defaultTextFormField(
                              controller: newBalanceController,
                              isNumber: true,
                              hinttext: '0',
                              text: "Số GCOIN cần nạp",
                              maxLength: maxTopUp.toString().length,
                              prefixIcon: const Icon(Icons.wallet),
                              onChange: (value) {
                                if (value!.isEmpty) {
                                  setState(() {
                                    amount = 0;
                                  });
                                } else {
                                  setState(() {
                                    amount = NumberFormat.simpleCurrency(
                                            locale: 'vi_VN',
                                            decimalDigits: 0,
                                            name: '')
                                        .parse(value)
                                        .toInt();
                                  });
                                }
                                newBalanceController.text =
                                    NumberFormat('###,###,##0', 'vi_VN')
                                        .format(amount);
                              },
                              onValidate: (value) {
                                if (value == null || value.trim() == '') {
                                  return "Số GCOIN không được để trống";
                                } else if (amount < minTopUp ||
                                    amount > maxTopUp) {
                                  return "Số GCOIN phải từ $minTopUp đến ${NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: '').format(maxTopUp)}";
                                }
                                return null;
                              },
                              inputType: TextInputType.number)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8, left: 20, right: 20, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng tiền",
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                          Text(
                            NumberFormat.simpleCurrency(
                                    decimalDigits: 0,
                                    locale: 'vi_VN',
                                    name: 'đ')
                                .format(
                                    amount * GlobalConstant().VND_CONVERT_RATE),
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8, right: 16, left: 16, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                amount = 100;
                                newBalanceController.text = "100";
                              });
                            },
                            child: TagWidget(
                                tag: Tag(
                                    id: "100",
                                    title: "100 GCOIN",
                                    type: "cash",
                                    enumName: "GCOIN",
                                    mainColor: Colors.white,
                                    strokeColor: Colors.grey)),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                amount = 200;
                                newBalanceController.text = "200";
                              });
                            },
                            child: TagWidget(
                                tag: Tag(
                                    id: "200",
                                    title: "200 GCOIN",
                                    type: "cash",
                                    enumName: "GCOIN",
                                    mainColor: Colors.white,
                                    strokeColor: Colors.grey)),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                amount = 500;
                                newBalanceController.text = "500";
                              });
                            },
                            child: TagWidget(
                                tag: Tag(
                                    id: "500",
                                    title: "500 GCOIN",
                                    type: "cash",
                                    enumName: "GCOIN",
                                    mainColor: Colors.white,
                                    strokeColor: Colors.grey)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Nguồn tiền',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  )),
              const SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          isSelected = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey,
                              width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(14)),
                        ),
                        child: ListTile(
                          minLeadingWidth: 0,
                          leading: Image.asset(vnpayLogo, height: 50),
                          title: const Text(
                            "VNPay",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: isSelected
                              ? Image.asset(
                                  "assets/images/outline_circle.png",
                                  height: 25,
                                )
                              : const Text(""),
                        ),
                      )),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                  style: elevatedButtonStyle.copyWith(
                      backgroundColor: MaterialStatePropertyAll(
                          isSelected && amount != 0
                              ? primaryColor
                              : Colors.grey.withOpacity(0.6))),
                  onPressed: () async {
                    if (isSelected && amount != 0) {
                      if (_formKey.currentState!.validate()) {
                        TopupRequestViewModel? request =
                            await transactionService.topUpRequest(
                                amount, context);

                        if (request != null) {
                          // final sub = await transactionService
                          //     .topUpSubcription(request.transactionId);

                          // sub.listen((event) {
                          //   log(event.toString());
                          //  });

                          Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              PageTransition(
                                  child: PaymentWebViewScreen(
                                    callback: widget.callback,
                                    request: request,
                                    amount: amount,
                                  ),
                                  type: PageTransitionType.bottomToTop));
                        }
                      }
                    }
                  },
                  child: const Text("Nạp tiền"))
            ],
          ),
        ),
      ),
    ));
  }
}
