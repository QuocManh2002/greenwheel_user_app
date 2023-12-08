import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/token_refresher.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/firebase_options.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/login_screen.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/login_success_screen.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/register_screen.dart';
import 'package:greenwheel_user_app/screens/introduce_screen/splash_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/share_plan_screen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/profile_screen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/qr_screen.dart';
import 'package:greenwheel_user_app/screens/sub_screen/topup_successfull_screen.dart';
import 'package:greenwheel_user_app/screens/wallet_screen/add_balance.dart';
import 'package:greenwheel_user_app/widgets/test_screen.dart';
import 'package:greenwheel_user_app/widgets/test_screen1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer2/sizer2.dart';

late SharedPreferences sharedPreferences;
late FirebaseAuth auth;

ThemeData theme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    appBarTheme: const AppBarTheme(color: primaryColor),
    datePickerTheme: DatePickerThemeData(
      headerBackgroundColor: primaryColor,
      dayOverlayColor: MaterialStatePropertyAll(primaryColor),
      rangeSelectionBackgroundColor: primaryColor.withOpacity(0.3),
      // dayBackgroundColor: const MaterialStatePropertyAll(primaryColor)
    ));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sharedPreferences = await SharedPreferences.getInstance();
  auth = FirebaseAuth.instance;
  await initHiveForFlutter();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    String? userToken = sharedPreferences.getString("userToken");
    if (userToken != null) {
      print(userToken);
      //Call to refreshToken
      TokenRefresher.refreshToken();
    }

    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        home: userToken != null
            ? const SplashScreen()
            : const LoginScreen(),
        // home: const TopupSuccessfulScreen(data: null),
        // home: const RegisterScreen(),
        // home : const TestScreen(),
        // home: QRScreen(),
        // home: SharePlanScreen(),
        theme: theme,
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
