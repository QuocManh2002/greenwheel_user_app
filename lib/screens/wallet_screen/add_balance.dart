import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:greenwheel_user_app/service/customer_service.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:greenwheel_user_app/view_models/topup_request.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:greenwheel_user_app/widgets/tag.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:vnpay_client/vnpay_client.dart';
import 'package:intl/intl.dart';

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key, required this.balance});
  final int balance;

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
  int? refreshedBalance;
  String? paymentData;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    newBalanceController.dispose();
  }

  setUpData() async {
    String phone = sharedPreferences.getString("userPhone")!;
    _customer = null;
    _customer = await customerService.GetCustomerByPhone(phone);
    if (_customer != null) {
      setState(() {
        refreshedBalance = _customer!.balance;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white.withOpacity(0.92),
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
                                        locale: 'en-US',
                                        decimalDigits: 0,
                                        name: "")
                                    .format(widget.balance),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SvgPicture.asset(
                                "assets/images/gcoin_logo.svg",
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
                          setState(() {
                            newBalanceController.text = value;
                          });
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
                            "${1000 * int.parse(newBalanceController.text.isEmpty ? '0' : newBalanceController.text)}đ",
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
                                newBalanceController.text = "100";
                              });
                            },
                            child: TagWidget(
                                tag: Tag(
                                    id: "100",
                                    title: "100 GCOIN",
                                    mainColor: Colors.white,
                                    strokeColor: Colors.grey)),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                newBalanceController.text = "200";
                              });
                            },
                            child: TagWidget(
                                tag: Tag(
                                    id: "200",
                                    title: "200 GCOIN",
                                    mainColor: Colors.white,
                                    strokeColor: Colors.grey)),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                newBalanceController.text = "500";
                              });
                            },
                            child: TagWidget(
                                tag: Tag(
                                    id: "500",
                                    title: "500 GCOIN",
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
                          leading: Image.asset(vnpay_logo, height: 50),
                          title: const Text(
                            "VNPay",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // subtitle: const Text("Thanh toán trong nước"),
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
                  style: elevatedButtonStyle,
                  onPressed: () async {
                    TopupRequestViewModel? request = await orderService
                        .topUpRequest(int.parse(newBalanceController.text));
                    if (request != null) {
                      // ignore: use_build_context_synchronously
                      showVNPayScreen(
                        context,
                        paymentUrl: request.paymentUrl,
                        onPaymentSuccess: _onPaymentSuccess,
                        onPaymentError: _onPaymentFailure,
                      );

                      if (paymentData != null) {
                        print(paymentData);
                        // ignore: use_build_context_synchronously
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (ctx) => TopupSuccessfulScreen(
                        //       data: paymentData!,
                        //     ),
                        //   ),
                        // );
                      }
                      // print(request.transactionId);
                      // TopupViewModel? topup = await orderService
                      //     .topUpSubcription(request.transactionId);
                      // print("TOPUP STATUS: ${topup!.status}");
                      // if (topup.status == "ACCEPTED") {
                      // } else {
                      //   // ignore: use_build_context_synchronously
                      // }
                    } else {
                      // ignore: use_build_context_synchronously
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.topSlide,
                        title: "Tạo đơn thất bại!",
                        desc: "Xuất hiện lỗi khi tạo đơn nạp GCOIN.",
                        btnOkText: "OK",
                        btnOkOnPress: () {},
                      ).show();
                    }
                  },
                  child: const Text("Nạp tiền"))
            ],
          ),
        ),
      ),
    ));
  }

  void _onPaymentSuccess(data) {
    print(data);
    setState(() {
      paymentData = data;
    });
  }

  void _onPaymentFailure(error) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: "Thanh toán thất bại!",
      desc: "Nạp GCOIN không thành công.",
      btnOkText: "OK",
      btnOkOnPress: () {},
    ).show();
    print(error);
  }
}
