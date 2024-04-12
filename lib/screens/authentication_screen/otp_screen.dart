import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/login.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/register_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/service/traveler_service.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer2/sizer2.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();
  TextEditingController tokenController = TextEditingController();
  CustomerService customerService = CustomerService();

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
                    margin: EdgeInsets.only(top: 4.h),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      app_logo,
                      height: 170,
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
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
                  const SizedBox(
                    height: 20,
                  ),
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
                    const SizedBox(
                      height: 30,
                    ),
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
                    // Container(
                    //   child: TextFormField(
                    //     controller: tokenController,
                    //     decoration: const InputDecoration(
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.all(
                    //           Radius.circular(5.0),
                    //         ),
                    //       ),
                    //       contentPadding:
                    //           EdgeInsets.symmetric(horizontal: 20.0),
                    //       hintStyle: TextStyle(
                    //         color: Colors.grey,
                    //       ),
                    //       hintText: 'Type...',
                    //     ),
                    //   ),
                    // ),
                    // TextButton(
                    //   onPressed: () async {
                    //     if (tokenController.text.isNotEmpty) {
                    //       // Example to copy data to Clipboard
                    //       await Clipboard.setData(
                    //           ClipboardData(text: tokenController.text));
                    //     }
                    //   },
                    //   child: const Text('Click to Copy'),
                    // ),
                    const Spacer(),
                    SizedBox(
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
      // String token = "";
      // String verificationIDReceived =
      //     sharedPreferences.getString('verificationID') ?? "";

      // PhoneAuthCredential credential = PhoneAuthProvider.credential(
      //     verificationId: verificationIDReceived, smsCode: otpController.text);
      // await auth.signInWithCredential(credential).then(
      //       (value) => {print(value)},
      //     );

      // await auth.currentUser!.getIdTokenResult().then(
      //       (value) => {
      //         // tokenController.text = value.token ?? "";
      //         token = value.token!,
      //         sharedPreferences.setString('userToken', token),
      //       },
      //     );
      // print(sharedPreferences.getString("userToken"));
      // Map<String, dynamic> payload = Jwt.parseJwt(token);

      // if (payload['id'] != null) {
      //   sharedPreferences.setString('userId', payload['id'].toString());
      //   print("NEW PAYLOAD: $payload");

      //   List<CustomerViewModel>? customer =
      //       await customerService.GetCustomerByPhone(payload['phone_number']);
      //   if (customer.isNotEmpty) {
      //     sharedPreferences.setString('userName', customer[0].name);
      //     sharedPreferences.setDouble('userBalance', customer[0].balance);
      String deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
      if (deviceToken != '') {
        sharedPreferences.setString('deviceToken', deviceToken);
        // customerService.travelerSignIn(deviceToken);
      }
      //     // Utils().SaveDefaultAddressToSharedPref(customer[0].defaultAddress!, customer[0].defaultCoordinate!);
      //     sharedPreferences.setString("userPhone", payload['phone_number']);
      //     // ignore: use_build_context_synchronously
      //     Navigator.pushAndRemoveUntil(context,
      //         MaterialPageRoute( builder: (_) => const TabScreen(pageIndex: 0)), (route) => false,);
      //   }
      // }else{
      //     String deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
      //   if(deviceToken != ''){
      //       sharedPreferences.setString('deviceToken', deviceToken);
      //     }
      //   sharedPreferences.setString("userPhone", payload['phone_number']);
      //   // ignore: use_build_context_synchronously
      //   Navigator.of(context).pop();
      //   // ignore: use_build_context_synchronously
      //   Navigator.push(context,
      //         MaterialPageRoute(builder: (_) => const RegisterScreen()));
      // }
      print(widget.phoneNumber);
      print(otpController.text);
      print(deviceToken);
      LoginModel? model = await customerService.travelerRequestAuthorize(
          widget.phoneNumber, otpController.text, deviceToken);
      if (model != null) {
        log('access: ${model.accessToken}');
        log('refresh: ${model.refreshToken}');
        sharedPreferences.setString('userToken', model.accessToken);
        sharedPreferences.setString('userRefreshToken', model.refreshToken);
        CustomerViewModel? traveler = await customerService.GetCustomerByPhone(
            '84${widget.phoneNumber.substring(1)}');
        if (traveler == null) {
          Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                  child: const RegisterScreen(),
                  type: PageTransitionType.rightToLeft),
              (ctx) => false);
        } else {
          if (traveler.defaultAddress != null &&
              traveler.defaultCoordinate != null) {
            Utils().SaveDefaultAddressToSharedPref(
                traveler.defaultAddress!, traveler.defaultCoordinate!);
          }
          if (traveler.avatarUrl != null && traveler.avatarUrl!.isNotEmpty) {
            sharedPreferences.setString('userAvatarPath', traveler.avatarUrl!);
          }
          sharedPreferences.setInt('userId', traveler.id);
          sharedPreferences.setString('userPhone', traveler.phone);
          sharedPreferences.setString('userName', traveler.name);
          sharedPreferences.setInt('userBalance', traveler.balance.toInt());
          Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                  child: const TabScreen(pageIndex: 0),
                  type: PageTransitionType.bottomToTop),
              (ctx) => false);
        }
      }
    } on PlatformException catch (e) {
      print(e.message);
    } on FirebaseAuthException {
      print("ERROR_INVALID_VERIFICATION_CODE");
    }
  }
}
