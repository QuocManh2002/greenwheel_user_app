
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/service/config_service.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  final ConfigService _configService = ConfigService();
  final OrderService _orderService = OrderService();
  bool isStart = false;

  setUpConfig() async {
    final config = await _configService.getOrderConfig(context);
    await controller.forward();
    if (controller.value == 1) {
      Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          PageTransition(
              child: const TabScreen(pageIndex: 0),
              type: PageTransitionType.rightToLeft),
          (route) => false);
    }
    if (config != null) {
      final lastModified = sharedPreferences.getString('LAST_MODIFIED');
      if(lastModified == null || lastModified != config.LAST_MODIFIED.toString()){
        _orderService.saveOrderConfigToPref(config);
      }
    }
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
        setState(() {});
      });
    setUpConfig();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              appLogo,
              height: 15.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
          Container(
            alignment: Alignment.center,
            width: 60.w,
            child: LinearProgressIndicator(
              backgroundColor: lightPrimaryTextColor,
              valueColor: AlwaysStoppedAnimation(primaryColor.withOpacity(0.9)),
              minHeight: 20,
              value: controller.value,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
          )
        ],
      ),
    ));
  }
}
