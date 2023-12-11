import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitialization =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSetting =
        InitializationSettings(android: androidInitialization);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (payload) {},
    );
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user granted provisional permission');
    } else {
      print('user denied permission');
    }
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
      }
      if(Platform.isAndroid){
        initLocalNotification(context, message);
      showNotification(message);

      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(Random.secure().nextInt(100000).toString(),
            "High Important Notification",
            importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(androidNotificationChannel.id.toString(),
            androidNotificationChannel.name.toString(),
            channelDescription: 'Your channel description',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker');

    // const DarwinNotificationDetails darwinNotificationDetails =
    //     DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentSound: true,
    //   presentBadge: true,
    // );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    Future.delayed(
      Duration.zero,
      () {
        _flutterLocalNotificationsPlugin.show(
            0,
            message.notification!.title.toString(),
            message.notification!.body.toString(),
            notificationDetails);
      },
    );
  }

  void handleMessage(BuildContext context, RemoteMessage message){
    
  }
}
