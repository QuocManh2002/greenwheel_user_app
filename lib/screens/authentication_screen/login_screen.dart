import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/otp_screen.dart';
import 'package:sizer2/sizer2.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  String verificationIDReceived = "";

  bool checkVerify = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                                'assets/images/phuot_travel_logo.png',
                                height: 170,
                              ),
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
                  child: Container(
                width: size.width,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5.h),
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
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xffA0A5BA))),
                              fillColor: Color(0xffF0F5FA),
                              filled: true,
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            autofocus: false,
                            style: const TextStyle(fontSize: 20),
                            keyboardType: TextInputType
                                .number, // Set the keyboard type to number
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ], // Allow only digits
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        margin: EdgeInsets.only(top: 5.h),
                        child: ElevatedButton(
                          style: elevatedButtonStyle.copyWith(),
                          child: const Text('Gửi OTP'),
                          onPressed: () {
                            // verifyNumber();
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

  void verifyNumber() {
    auth.verifyPhoneNumber(
      phoneNumber: "+84${phoneController.text}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then(
              (value) => {
                print("VERIFY SUCCESSFULLY!"),
              },
            );
      },
      verificationFailed: (FirebaseAuthException exception) {
        print(exception.message);
        print("VERIFY FAIL!");
        Fluttertoast.showToast(
          msg: 'Vui lòng kiểm tra lại số điện thoại!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      },
      codeSent: (String verificationID, int? resendToken) {
        verificationIDReceived = verificationID;
        print("${verificationIDReceived}received");
        sharedPreferences.setString('verificationID', verificationIDReceived);
        sharedPreferences.setString('phone', "+84${phoneController.text}");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OTPScreen()),
            (route) => false);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
