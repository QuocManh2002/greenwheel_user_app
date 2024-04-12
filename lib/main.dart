import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/token_refresher.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/features/home/presentation/providers/home_provider.dart';
import 'package:greenwheel_user_app/firebase_options.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/login_screen.dart';
import 'package:greenwheel_user_app/screens/introduce_screen/splash_screen.dart';
import 'package:greenwheel_user_app/screens/offline_screen/offline_home_screen.dart';
import 'package:greenwheel_user_app/service/config_service.dart';
import 'package:greenwheel_user_app/widgets/test_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer2/sizer2.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cron/cron.dart';

late SharedPreferences sharedPreferences;
late FirebaseAuth auth;
late bool hasConnection;
late FlutterLocalization localization;
ConfigService _configService = ConfigService();

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
  print(message.notification!.title.toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sharedPreferences = await SharedPreferences.getInstance();
  auth = FirebaseAuth.instance;
  await initHiveForFlutter();
  await Hive.initFlutter();
  await Hive.openBox('myPlans');
  await FlutterConfig.loadEnvVariables();
  MapboxOptions.setAccessToken(
      'pk.eyJ1IjoicXVvY21hbmgyMDIiLCJhIjoiY2xuM3AwM2hpMGlzZDJqcGFla2VlejFsOCJ9.gEsXIx57uMGskLDDQYBm4g');
  localization = FlutterLocalization.instance;
  // final _myPlans = Hive.box('myPlans');
  // _myPlans.clear();
  hasConnection = await InternetConnectionChecker().hasConnection;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // final cron = Cron();
  // cron.schedule(Schedule.parse('*/1 * * * *'),(){
  //   print('Cron Job');
  // });
  
  initializeDateFormatting('vi_VN', null).then((_) {
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    String? refreshToken = sharedPreferences.getString("userRefreshToken");
    if (refreshToken != null) {
      log('refresh: $refreshToken' );
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
