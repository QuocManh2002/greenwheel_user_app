// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/otp_screen.dart';
import 'package:greenwheel_user_app/service/traveler_service.dart';
import 'package:sizer2/sizer2.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();

  final CustomerService _customerService = CustomerService();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            // Add your image widget here
                            Container(
                              margin: EdgeInsets.only(top: 4.h),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                appLogo,
                                height: 170,
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ), // Replace 'your_image_path.png' with your image asset path
                            const Text(
                              'Chào mừng đến với Phượt Travel',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSans',
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Expanded(
                  child: SizedBox(
                width: size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 3.h),
                        alignment: Alignment.topLeft,
                        child: const Text(
                          'Số điện thoại',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black45,
                            fontFamily: 'NotoSans',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: TextField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffA0A5BA)),
                              ),
                              fillColor: Color(0xffF0F5FA),
                              filled: true,
                              prefixText:
                                  '+84 ', // Replace '+1' with your desired country code
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            autofocus: false,
                            style: const TextStyle(fontSize: 20),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 7.h,
                        width: 90.w,
                        child: ElevatedButton(
                          style: elevatedButtonStyle.copyWith(),
                          child: const Text(
                            'Gửi OTP',
                            style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            verifyNumber();
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  void verifyNumber() async {
    final rs = await _customerService.requestTravelerOTP(
        phoneController.text.length == 10
            ? phoneController.text
            : '0${phoneController.text}',
        context);
    if (rs!) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => OTPScreen(
                    phoneNumber: phoneController.text.length == 10
                        ? phoneController.text
                        : '0${phoneController.text}',
                  )));
    }
  }
}
