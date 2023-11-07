import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer2/sizer2.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
    );

    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xff1E1E2E),
        body: SingleChildScrollView(
          child: Container(
            height: 100.h,
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
                                child: Image.asset(
                                  'assets/icons/instapark.png',
                                  height: 170,
                                ),
                              ), // Replace 'your_image_path.png' with your image asset path
                              Container(
                                child: const Text(
                                  'Xác Nhận OTP',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontFamily: 'SF Pro Text',
                                  ),
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
                    child: Container(
                  width: size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 5.h),
                          child: Pinput(
                            length: 6,
                            defaultPinTheme: defaultTheme,
                            focusedPinTheme: defaultTheme.copyWith(
                              decoration: defaultTheme.decoration!.copyWith(
                                border: Border.all(color: primaryColor),
                              ),
                            ),
                            onCompleted: (pin) => {otpController.text = pin},
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          margin:
                              EdgeInsets.only(top: 4.h, right: 5.w, left: 5.w),
                          child: const Text(
                            'Vui lòng nhập mã xác nhận được gửi.',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5.h, bottom: 1.h),
                          width: size.width,
                          height: 64,
                          child: ElevatedButton(
                            style: elevatedButtonStyle.copyWith(),
                            child: Text('ĐĂNG NHẬP'),
                            onPressed: () {
                              // login(phoneController.text.toString(),
                              //     passwordController.text.toString());
                              // Navigator.pushAndRemoveUntil(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (_) => VerificationPage()),
                              //     (route) => false);
                              verifyCode();
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
      ),
    );
  }

  void verifyCode() async {
    try {
      print("CODE: ${otpController.text}");
      String verificationIDReceived =
          sharedPreferences.getString('verificationID') ?? "";
      print("${verificationIDReceived} OTP RECEIVED");
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationIDReceived, smsCode: otpController.text);
      await auth.signInWithCredential(credential).then(
            (value) => {
              // print("Login successfully!"),
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(builder: (_) => const MainScreen()),
              //     (route) => false)
            },
          );
      await auth.currentUser!.getIdTokenResult().then(
            (value) => {
              setState(() {
                tokenController.text = value.token ?? "";
              }),
              print("USER TOKEN: ${value.token}"),
            },
          );
    } on PlatformException catch (e) {
      print(e.message);
    } on FirebaseAuthException {
      print("ERROR_INVALID_VERIFICATION_CODE");
    }
  }
}
