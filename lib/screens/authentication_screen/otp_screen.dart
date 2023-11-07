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
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              Column(
                children: [
                  // Add your image widget here
                  Container(
                    // margin: EdgeInsets.only(top: 4.h),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/phuot_travel_logo.png',
                      height: 170,
                    ),
                  ),
                  Container(
                    child: const Text(
                      'Nhập OTP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans',
                      ),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  Container(
                    margin: EdgeInsets.only(right: 4.w),
                    child: const Text(
                      "Nhập mã OTP được gửi về điện thoại của bạn",
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // const SizedBox(
                    //   height: 30,
                    // ),
                    Pinput(
                      length: 6,
                      defaultPinTheme: defaultTheme,
                      focusedPinTheme: defaultTheme.copyWith(
                        decoration: defaultTheme.decoration!.copyWith(
                          border: Border.all(color: primaryColor),
                        ),
                      ),
                      onCompleted: (pin) => {otpController.text = pin},
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                      child: TextFormField(
                        controller: tokenController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 20.0),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          hintText: 'Type...',
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (tokenController.text.isNotEmpty) {
                          // Example to copy data to Clipboard
                          await Clipboard.setData(
                              ClipboardData(text: tokenController.text));
                        }
                      },
                      child: const Text('Click to Copy'),
                    ),
                    Spacer(),
                    Container(
                      height: 7.h,
                      width: 90.w,
                      child: ElevatedButton(
                        style: elevatedButtonStyle.copyWith(),
                        child: const Text(
                          'Đăng Nhập',
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          verifyCode();
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ))
            ],
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
