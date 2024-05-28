
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/global_constant.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:greenwheel_user_app/screens/payment_screen/payment_webview_screen.dart';
import 'package:greenwheel_user_app/service/traveler_service.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:greenwheel_user_app/view_models/topup_request.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/search_screen_widget/tag.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';

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
  OrderService orderService = OrderService();
  CustomerService customerService = CustomerService();
  CustomerViewModel? _customer;
  bool isLoading = true;
  double? refreshedBalance;
  String? paymentData;
  int amount = 0;
  bool isSuccess = true;

  @override
  void dispose() {
    super.dispose();
    newBalanceController.dispose();
  }

  setUpData() async {
    String phone = sharedPreferences.getString("userPhone")!;
    CustomerViewModel? customer;
    customer = await customerService.getCustomerByPhone(phone);
    if (customer != null) {
      setState(() {
        refreshedBalance = _customer!.balance;
      });
    }
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
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.isEmpty) {
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
                        controller: newBalanceController,
                        cursorColor: primaryColor,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                            hintText: "0",
                            labelText: "Số GCOIN cần nạp",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelStyle: TextStyle(color: primaryColor),
                            floatingLabelStyle: TextStyle(color: Colors.grey),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            prefixIcon: Icon(Icons.wallet, color: Colors.grey),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: primaryColor,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14))),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)))),
                      ),
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
                                    name: 'Đ')
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
                      TopupRequestViewModel? request =
                          await orderService.topUpRequest(amount, context);

                      if (request != null) {
                        Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            PageTransition(
                                child: PaymentWebViewScreen(
                                  callback: widget.callback,
                                  request: request.paymentUrl,
                                  amount: amount,
                                ),
                                type: PageTransitionType.bottomToTop));

// Ngân hàng	NCB
// Số thẻ	9704198526191432198
// Tên chủ thẻ	NGUYEN VAN A
// Ngày phát hành	07/15
// Mật khẩu OTP	123456
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
