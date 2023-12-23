import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
const uuid = Uuid();
class PlanScheduleItem {
  final String id;
  final String title;
  final TimeOfDay time;
  final DateTime date;
  final String? orderId;

  PlanScheduleItem({String? id, required this.time, required this.title, required this.date, this.orderId}): id = id ?? uuid.v4();
}
