import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class PlanScheduleItem {
  final String id;
  final String? description;
  TimeOfDay? time;
  DateTime? date;
  final String? orderId;
  final String? type;
  final String? shortDescription;
  final Duration? activityTime;
  final bool? isStarred;
  String? orderUUID;

  PlanScheduleItem(
      {String? id,
      this.time,
      this.description,
      this.shortDescription,
      this.date,
      this.orderId,
      this.activityTime,
      this.isStarred,
      this.orderUUID,
      this.type})
      : id = id ?? _uuid.v4();

  PlanScheduleItem fromJson(Map<String, dynamic> json) => PlanScheduleItem(
      time: json['time'],
      description: json['description'],
      orderId: json['orderGuid'],
      shortDescription: json['shortDescription'],
      type: json['type']);

  Map<String, dynamic> toJson() => {
        "time": json.encode(DateFormat.Hms()
            .format(DateTime(0, 0, 0, time!.hour, time!.minute))
            .toString()),
        "orderGuid": orderId == null ? null : json.encode(orderId),
        "description": json.encode(description),
        "shortDescription": json.encode(shortDescription),
        "type": json.encode(type)
      };
}
