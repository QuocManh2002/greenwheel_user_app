import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/firebase_options.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/login_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/setting_screen.dart';
import 'package:greenwheel_user_app/screens/wallet_screen/add_balance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer2/sizer2.dart';

late SharedPreferences sharedPreferences;

ThemeData theme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    appBarTheme: const AppBarTheme(color: primaryColor),
    datePickerTheme: DatePickerThemeData(
        rangeSelectionBackgroundColor: primaryColor.withOpacity(0.3),
        dayBackgroundColor: const MaterialStatePropertyAll(primaryColor)));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sharedPreferences = await SharedPreferences.getInstance();
  await initHiveForFlutter();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        home: const TabScreen(pageIndex: 0),
        // home: const ProfileScreen(),
        // home: const LoginScreen(),
        theme: theme,
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
