import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:sizer2/sizer2.dart';
// late SharedPreferences sharedPreferences;

ThemeData theme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    appBarTheme: const AppBarTheme(color: primaryColor),
    datePickerTheme: DatePickerThemeData(
        rangeSelectionBackgroundColor: primaryColor.withOpacity(0.3),
        dayBackgroundColor: const MaterialStatePropertyAll(primaryColor)));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // sharedPreferences = await SharedPreferences.getInstance();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        home: const TabScreen(pageIndex: 0),
        theme: theme,
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
