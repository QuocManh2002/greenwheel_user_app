
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer2/sizer2.dart';

import 'config/token_refresher.dart';
import 'core/constants/colors.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'firebase_options.dart';
import 'screens/authentication_screen/login_screen.dart';
import 'screens/introduce_screen/splash_screen.dart';
import 'screens/offline_screen/offline_home_screen.dart';

late SharedPreferences sharedPreferences;
late bool hasConnection;
late FlutterLocalization localization;

ThemeData theme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  appBarTheme: const AppBarTheme(
    color: primaryColor,
    foregroundColor: Colors.white,
  ),
  timePickerTheme: const TimePickerThemeData(dayPeriodColor: primaryColor),
);
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sharedPreferences = await SharedPreferences.getInstance();
  await dotenv.load(fileName: 'keys.env');

  // await initHiveForFlutter();
  await Hive.initFlutter();
  // await Hive.openBox('myPlans');

  MapboxOptions.setAccessToken(dotenv.env['mapbox_access_token'].toString());
  localization = FlutterLocalization.instance;
  final myPlans = await Hive.openBox('myPlans');
  // myPlans.clear();
  hasConnection = await InternetConnectionChecker().hasConnection;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // final cron = Cron();
  // cron.schedule(Schedule.parse('*/1 * * * *'),(){
  //   print('Cron Job');
  // });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    String? refreshToken = sharedPreferences.getString("userRefreshToken");
    if (refreshToken != null && hasConnection) {
      TokenRefresher.refreshToken();
    }

    return Sizer(builder: (context, orientation, deviceType) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => HomeProvider(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: localization.localizationsDelegates,
          supportedLocales: const [
            Locale('vi'),
          ],
          locale: const Locale('vi'),
          home: hasConnection
              ? refreshToken != null
                  ? const SplashScreen()
                  : const LoginScreen()
              : const OfflineHomeScreen(),
          // home: const TestScreen(),
          theme: theme,
          debugShowCheckedModeBanner: false,
        ),
      );
    });
  }
}
