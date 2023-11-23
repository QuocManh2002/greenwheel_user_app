import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenwheel_user_app/config/stripe_config.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:greenwheel_user_app/service/customer_service.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:greenwheel_user_app/widgets/tag.dart';

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key, required this.balance});
  final int balance;

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  TextEditingController newBalanceController = TextEditingController();
  bool isSelected = false;
  CustomerService _customerService = CustomerService();
  bool isLoading = true;

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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                "${widget.balance.toString()} ",
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
                          leading: Image.asset(stripe_logo, height: 50),
                          title: const Text(
                            "STRIPE",
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
                    var items = [
                      {
                        "productPrice":
                            int.parse(newBalanceController.text) * 1000,
                        "productName": "Thanh toán dịch vụ",
                        "qty": 1,
                      },
                    ];
                    // setState(() {
                    //   isLoading = true;
                    // });
                    await StripeConfig.stripePaymentCheckout(
                      items,
                      int.parse(newBalanceController.text) * 1000,
                      context,
                      mounted,
                      onSuccess: () async {
                        bool check = await _customerService.addBalance(
                                int.parse(newBalanceController.text)) !=
                            null;
                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          // ignore: use_build_context_synchronously
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.topSlide,
                            title: "Thanh toán thành công",
                            desc: "Ấn tiếp tục để trở về kế hoạch",
                            btnOkText: "Tiếp tục",
                            btnOkOnPress: () {
                              Navigator.of(context).pop();

                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (ctx) =>
                              //         //     OrderHistoryScreen(
                              //         //   serviceType:
                              //         //       widget.serviceType,
                              //         // ),
                              //         ServiceMainScreen(
                              //       serviceType:
                              //           widget.serviceType,
                              //       location: widget.location,
                              //       callbackFunction: (List<OrderCreatePlan> orderList){},
                              //     ),
                              //   ),
                              // );
                            },
                          ).show();
                        } else {
                          // ignore: use_build_context_synchronously
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.topSlide,
                            title: "Thanh toán thất bại",
                            desc: "Xuất hiện lỗi trong quá trình thanh toán",
                            btnOkText: "OK",
                            btnOkOnPress: () {},
                          ).show();
                        }
                      },
                      onCancel: () {
                        setState(() {
                          isLoading = false;
                        });
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.topSlide,
                          title: "Hủy thanh toán",
                          desc: "Bạn đã hủy thanh toán thành công",
                          btnOkText: "OK",
                          btnOkOnPress: () {},
                        ).show();
                      },
                      onError: (e) {
                        setState(() {
                          isLoading = false;
                        });
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.topSlide,
                          title: "Thanh toán thất bại",
                          desc: "Xuất hiện lỗi trong quá trình thanh toán",
                          btnOkText: "OK",
                          btnOkOnPress: () {},
                        ).show();
                      },
                    );
                  },
                  child: const Text("Nạp tiền"))
            ],
          ),
        ),
      ),
    ));
  }
}
