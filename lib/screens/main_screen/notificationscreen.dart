import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/main.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sharedPreferences.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("NOTIFICATION"),);
  }
}