import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:phuot_app/config/graphql_config.dart';
import 'package:phuot_app/helpers/util.dart';
import 'package:phuot_app/main.dart';
import 'package:phuot_app/models/pagination.dart';
import 'package:phuot_app/view_models/notification_viewmodels/notification_viewmodel.dart';

class AnnouncementService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();

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
      onDidReceiveNotificationResponse: (payload) {
        handleMessage(context, message);
      },
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
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {}
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
      }
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(Random.secure().nextInt(100000).toString(),
            "High Important Notification",
            playSound: true,
            sound:
                const RawResourceAndroidNotificationSound('jetsons_doorbell'),
            showBadge: true,
            importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(androidNotificationChannel.id,
            androidNotificationChannel.name.toString(),
            channelDescription: 'Your channel description',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            ticker: 'ticker');

    // const DarwinNotificationDetails darwinNotificationDetails =
    //     DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentSound: true,
    //   presentBadge: true,
    // );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // Future.delayed(
    //   Duration.zero,
    //   () {
    _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails);
    //   },
    // );
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (ctx) => DetailPlanScreen(
    //         planId: int.parse(message.data['planId']),
    //         locationName: "locationName",
    //         isEnableToJoin: true)));

    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (ctx) => TestScreen()));
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // ignore: use_build_context_synchronously
      handleMessage(context, initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  Future<Pagination<AnnouncementViewModel>?> getNotificationList(
      String? cursor) async {
    try {
      final newClient = graphQlConfig.getClient();
      int travelerId = sharedPreferences.getInt('userId')!;
      QueryResult result = await newClient.query(QueryOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql("""
{
  announcements(
    where: { accountId: { eq: $travelerId } }
    order: { id: DESC }
    after: ${cursor == null ? null : json.encode(cursor)}
    first: 10
  ) {
    pageInfo {
      endCursor
    }
    edges {
      node {
        id
        orderId
        title
        body
        imageUrl
        type
        createdAt
        accountId
        planId
        isRead
        level
        plan {
          accountId
          members {
            accountId
            status
          }
        }
      }
    }
  }
}
"""),
      ));
      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['announcements']['edges'];
      if (res == null || res.isEmpty) {
        return Pagination(pageSize: 10, cursor: cursor, objects: []);
      }
      cursor = result.data!['announcements']['pageInfo']['endCursor'];
      final listObjects =
          res.map((e) => AnnouncementViewModel.fromJson(e['node'])).toList();
      return Pagination(pageSize: 10, cursor: cursor, objects: listObjects);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> markAnnouncementAsRead(
      int announcementId, BuildContext context) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql('''
mutation{
  markAnnouncementAsRead(announcementId: $announcementId)
}
''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(),
            // ignore: use_build_context_synchronously
            context);

        throw Exception(result.exception!.linkException!);
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> markAllAnnouncementsAsRead(BuildContext context) async {
    try {
      QueryResult result = await client.mutate(MutationOptions(document: gql('''
mutation{
  markAllAnnouncementsAsRead
}
''')));
      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(),
            // ignore: use_build_context_synchronously
            context);

        throw Exception(result.exception!.linkException!);
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
