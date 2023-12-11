import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/config/token_refresher.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/introduce_screen/splash_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/service/customer_service.dart';
import 'package:greenwheel_user_app/view_models/register.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:sizer2/sizer2.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isMale = true;
  DateTime selectedDate = DateTime.now();
  bool isPolicyAccept = false;
  CustomerService _customerService = CustomerService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailController.dispose();
  }

  void _showDatePicker(BuildContext context) async {
    DateTime? newDay = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2024),
        builder: (context, child) {
          return Theme(
            data: ThemeData().copyWith(
                colorScheme: const ColorScheme.light(
                    primary: primaryColor, onPrimary: Colors.white)),
            child: DatePickerDialog(
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2024),
            ),
          );
        });
    if (newDay != null) {
      setState(() {
        selectedDate = newDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Đăng ký tài khoản",
          style: TextStyle(
              // color: Colors.black
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Lần đầu đăng nhập vào ứng dụng",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                "Hãy cho chúng tôi biết một vài thông tin về bạn",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 16,
              ),
              // const Text("Tên", style: TextStyle(
              //   fontSize: 16
              // ),),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: nameController,
                cursorColor: primaryColor,
                keyboardType: TextInputType.name,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                    hintText: "Nguyen Van A",
                    hintStyle: TextStyle(color: Colors.grey),
                    labelText: "Họ và tên",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(color: primaryColor, fontSize: 20),
                    floatingLabelStyle:
                        TextStyle(color: Colors.grey, fontSize: 20),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: primaryColor,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(14))),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(14)))),
              ),

              const SizedBox(
                height: 32,
              ),
              TextFormField(
                controller: emailController,
                cursorColor: primaryColor,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                    hintText: "vana@gmail.com",
                    hintStyle: TextStyle(color: Colors.grey),
                    labelText: "Email",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(color: primaryColor, fontSize: 20),
                    floatingLabelStyle:
                        TextStyle(color: Colors.grey, fontSize: 20),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: primaryColor,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(14))),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(14)))),
              ),
              //male

              const SizedBox(
                height: 16,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  "Giới tính",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isMale = true;
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: 6.h,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: isMale
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.white,
                              border: Border.all(color: primaryColor, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: const Text(
                            "Nam",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isMale = false;
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: 6.h,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: !isMale
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.white,
                              border: Border.all(color: primaryColor, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: const Text(
                            "Nữ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  "Ngày sinh",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 8,
              ),

              //birthday
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6.h,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                          border: Border.all(color: primaryColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      child: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                      style: elevatedButtonStyle.copyWith(
                        minimumSize: MaterialStatePropertyAll(Size(20.w, 6.h)),
                      ),
                      onPressed: () {
                        _showDatePicker(context);
                      },
                      child: const Text(
                        "Chọn ngày",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Checkbox(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                    value: isPolicyAccept,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        isPolicyAccept = !isPolicyAccept;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Tôi đã đọc và đồng ý tất cả các điều khoản về chính sách sử dụng và quyền lợi của người dùng",
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                    style: elevatedButtonStyle,
                    onPressed: _register,
                    child: const Text(
                      "Đăng ký",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
              )
            ],
          ),
        ),
      ),
    ));
  }

  _register() async {
    var id = await _customerService.registerTraveler(RegisterViewModel(
        birthday: selectedDate,
        isMale: isMale,
        email: emailController.text,
        name: nameController.text));
    if (id != null || id != 0) {
      TokenRefresher.refreshToken();
      print("2: ${sharedPreferences.getString('userToken')}");

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => const SplashScreen()),
          (route) => false);
    }
  }
}
