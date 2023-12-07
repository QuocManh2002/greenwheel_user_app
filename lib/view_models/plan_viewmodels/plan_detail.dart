// To parse this JSON data, do
//
//     final planDetail = planDetailFromJson(jsonString);

import 'dart:convert';

import 'package:greenwheel_user_app/view_models/order.dart';

PlanDetail planDetailFromJson(String str) =>
    PlanDetail.fromJson(json.decode(str));

String planDetailToJson(PlanDetail data) => json.encode(data.toJson());

class PlanDetail {
  int id;
  DateTime startDate;
  DateTime endDate;
  List<dynamic> schedule;
  int memberLimit;
  String status;

  String locationName;
  int locationId;
  List<dynamic> imageUrls;
  List<OrderViewModel>? orders;

  PlanDetail(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required this.schedule,
      required this.memberLimit,
      required this.status,
      required this.locationName,
      required this.locationId,
      required this.imageUrls,
      this.orders});

  factory PlanDetail.fromJson(Map<String, dynamic> json) => PlanDetail(
        id: json["id"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        schedule: json["schedule"],
        memberLimit: json["memberLimit"],
        status: json["status"],
        locationName: json["location"]["name"],
        locationId: json["location"]["id"],
        imageUrls: json["location"]["imageUrls"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "schedule": schedule,
        "memberLimit": memberLimit,
        "status": status,
        "locationName": locationName,
        "locationId": locationId,
        "imageUrls": imageUrls,
      };
}
