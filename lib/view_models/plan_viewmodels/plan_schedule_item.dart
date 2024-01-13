import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlanScheduleItem {
  final String id;
  final String description;
  final TimeOfDay time;
  final DateTime? date;
  final String? orderId;
  final String? type;
  final String? shortDescription;

  PlanScheduleItem(
      {String? id,
      required this.time,
      required this.description,
      this.shortDescription,
      this.date,
      this.orderId,
      this.type})
      : id = id ?? uuid.v4();

  PlanScheduleItem fromJson(Map<String, dynamic> json) => PlanScheduleItem(
      time: json['time'],
      description: json['description'],
      orderId: json['orderGuid'],
      shortDescription: json['shortDescription'],
      type: json['type']);

  Map<String, dynamic> toJson() => {
        // "time": json.encode(DateFormat.Hms()
        //     .format(DateTime(0, 0, 0, model.time.hour, model.time.minute))
        //     .toString()),
        // "orderGuid": model.orderId == null ? null : json.encode(model.orderId),
        // "description": json.encode(model.title),
        // "type": "GATHER"

        "time": json.encode(DateFormat.Hms()
            .format(DateTime(0, 0, 0, time.hour, time.minute))
            .toString()),
        "orderGuid": orderId == null ? null : json.encode(orderId),
        "description": json.encode(description),
        "shortDescription": json.encode(shortDescription),
        "type": json.encode(type)
      };
}
