import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
const uuid = Uuid();
class PlanScheduleItem {
  final String id;
  final String title;
  final TimeOfDay time;
  final DateTime date;
  final String? orderId;
  final String? orderType;

  PlanScheduleItem({String? id, required this.time, required this.title, required this.date, this.orderId, this.orderType}): id = id ?? uuid.v4();
}
