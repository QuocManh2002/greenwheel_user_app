import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/token_refresher.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/firebase_options.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/login_screen.dart';
import 'package:greenwheel_user_app/screens/introduce_screen/splash_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_new_plan_screen.dart';
import 'package:greenwheel_user_app/widgets/test_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer2/sizer2.dart';
import 'package:intl/date_symbol_data_local.dart';

late SharedPreferences sharedPreferences;
late FirebaseAuth auth;

ThemeData theme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    appBarTheme: const AppBarTheme(color: primaryColor),
    timePickerTheme: TimePickerThemeData(
      dayPeriodColor: primaryColor
    ),
    datePickerTheme: DatePickerThemeData(
      headerBackgroundColor: primaryColor,
      dayOverlayColor: MaterialStatePropertyAll(primaryColor),
      rangeSelectionBackgroundColor: primaryColor.withOpacity(0.3),
      // dayBackgroundColor: const MaterialStatePropertyAll(primaryColor)
    ));
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.notification!.title.toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sharedPreferences = await SharedPreferences.getInstance();
  auth = FirebaseAuth.instance;
  await initHiveForFlutter();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  initializeDateFormatting('vi_VN', null).then((_) {
    runApp(const MainApp());
  });
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
        home: userToken != null ? const SplashScreen() : const LoginScreen(),
        // home: const LoginScreen(),
        // home: const TopupSuccessfulScreen(data: null),
        // home: const RegisterScreen(),
        // home: const TestScreen(),
        // home: const CreateNewPlanScreen(),
        // home: QRScreen(),
        // home: SharePlanScreen(),
        theme: theme,
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
