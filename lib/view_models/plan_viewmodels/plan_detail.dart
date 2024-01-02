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
  String name;
  DateTime startDate;
  DateTime endDate;
  String joinMethod;
  List<dynamic> schedule;
  int memberLimit;
  String status;
  String locationName;
  int locationId;
  List<dynamic> imageUrls;
  List<OrderViewModel>? orders;
  List<dynamic>? savedSupplierIds;

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
      required this.name,
      required this.joinMethod,
      this.savedSupplierIds,
      this.orders});

  factory PlanDetail.fromJson(Map<String, dynamic> json) => PlanDetail(
        id: json["id"],
        name: json["name"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        schedule: json["schedule"],
        memberLimit: json["memberLimit"],
        status: json["status"],
        locationName: json["location"]["name"],
        locationId: json["location"]["id"],
        imageUrls: json["location"]["imageUrls"],
        joinMethod: json["joinMethod"],
        savedSupplierIds: json["savedSupplierIds"]
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
