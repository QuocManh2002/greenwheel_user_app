
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:greenwheel_user_app/widgets/tag.dart';

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key});

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  TextEditingController newBalanceController = TextEditingController();
  bool isSelected = false;

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
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Số dư ví",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "10 Gcoin",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: newBalanceController,
                        cursorColor: primaryColor,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                            hintText: "0đ",
                            labelText: "Số tiền cần nạp",
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
                      padding: const EdgeInsets.only(top: 8, right: 16, left: 16, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: (){
                              setState(() {
                                newBalanceController.text = "100000";
                              });
                            },
                            child: TagWidget(
                                tag: Tag(
                                    id: "100000",
                                    title: "100000đ",
                                    mainColor: Colors.white,
                                    strokeColor: Colors.grey)),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                newBalanceController.text = "200000";
                              });
                            },
                            child: TagWidget(
                                tag: Tag(
                                    id: "200000",
                                    title: "200000đ",
                                    mainColor: Colors.white,
                                    strokeColor: Colors.grey)),
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                newBalanceController.text = "500000";
                              });
                            },
                            child: TagWidget(
                                tag: Tag(
                                    id: "500000",
                                    title: "500000đ",
                                    mainColor: Colors.white,
                                    strokeColor: Colors.grey)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16,),
              Container(
                alignment: Alignment.centerLeft,
                child:const Text('Nguồn tiền', style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87
                ),)),
              const SizedBox(height: 16,),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        isSelected = true;
                      });
                    }, 
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.white,
                          width: 2
                        ),
                        borderRadius:const BorderRadius.all(Radius.circular(14)),
                      ),
                      child: ListTile(
                        minLeadingWidth: 0,
                        leading: Image.asset("assets/images/vnpay.png", height: 50),
                        title:const Text("VNPAY", style: TextStyle(fontWeight: FontWeight.bold),),
                        subtitle:const Text("Thanh toán trong nước"),
                        trailing: isSelected? Image.asset("assets/images/outline_circle.png", height: 30,): const Text(""),
                      ),
                    )),),
              ),
              const SizedBox(height: 16,),
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: (){}, 
                child:const Text("Nạp tiền"))
            ],
          ),
        ),
      ),
    ));
  }
}
